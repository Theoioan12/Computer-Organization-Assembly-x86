#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "structs.h"

#define OPERATION_COUNT 8
#define CMD_LEN 64
#define DELIMS "\n "

static sensor read_sensor(FILE *in)
{
	sensor sensor;
	fread(&sensor.sensor_type, sizeof(int), 1, in);

	const size_t sensor_type_sizes[] = {
		[TIRE] = sizeof(tire_sensor),
		[PMU] = sizeof(power_management_unit)
	};

	// Aloca memorie pentru a stoca datele proprii ale senzorului
	sensor.sensor_data = malloc(sensor_type_sizes[sensor.sensor_type]);

	assert(sensor.sensor_data);
	// Citeste datele senzorului
	fread(sensor.sensor_data, sensor_type_sizes[sensor.sensor_type], 1, in);
	fread(&sensor.nr_operations, sizeof(int), 1, in);

	// Citeste operatiile ce se vor efectua pe senzor
	sensor.operations_idxs = (int *)malloc(sizeof(int) * sensor.nr_operations);

	assert(sensor.operations_idxs);
	fread(sensor.operations_idxs, sizeof(int), sensor.nr_operations, in);

	return sensor;
}

static void free_sensor_array(sensor *sensor_arr, int arr_size)
{
	for (int i = 0; i < arr_size; i++) {
		free(sensor_arr[i].operations_idxs);
		free(sensor_arr[i].sensor_data);
	}

	free(sensor_arr);
}

static sensor *parse_input_file(const char *filename, int *sensor_arr_size)
{
	FILE *in = fopen(filename, "rb");
	assert(in);

	// Numarul de senzori din lista
	int arr_size;
	fread(&arr_size, sizeof(arr_size), 1, in);

	sensor *sensor_arr = (sensor *)malloc(arr_size * sizeof(sensor));
	assert(sensor_arr);

	int pmu_sensor_count = 0, tire_sensor_count = 0;

	// Citeste senzorii si retine numarul de senzori de fiecare tip
	for (int i = 0; i < arr_size; i++) {
		sensor_arr[i] = read_sensor(in);
		if (sensor_arr[i].sensor_type == TIRE)
			tire_sensor_count++;
		else
			pmu_sensor_count++;
	}

	fclose(in);

	// Copiaza senzorii din cele doua tipuri in doua liste separate, pastrand
	// ordinea
	sensor *tire_sensors = (sensor *)malloc(sizeof(sensor) * tire_sensor_count);
	sensor *pmu_sensors = (sensor *)malloc(sizeof(sensor) * pmu_sensor_count);
	assert(tire_sensors && pmu_sensors);

	sensor *tire_it = tire_sensors, *pmu_it = pmu_sensors;
	for (int i = 0; i < arr_size; i++) {
		if (sensor_arr[i].sensor_type == PMU)
			*pmu_it++ = sensor_arr[i];
		else
			*tire_it++ = sensor_arr[i];
	}

	// Concateneaza cele doua liste
	memcpy(sensor_arr, pmu_sensors, sizeof(sensor) * pmu_sensor_count);
	memcpy(sensor_arr + pmu_sensor_count, tire_sensors,
		sizeof(sensor) * tire_sensor_count);

	free(pmu_sensors);
	free(tire_sensors);

	*sensor_arr_size = arr_size;
	return sensor_arr;
}

void print_sensor(sensor *sensor)
{
	// Afiseaza detaliile senzorului in functie de tipul acestora,
	// asa cum se cere in enunt
	if (sensor->sensor_type == TIRE) {
		tire_sensor *data = (tire_sensor *)sensor->sensor_data;
		printf("Tire Sensor\n");
		printf("Pressure: %.2f\n", data->pressure);
		printf("Temperature: %.2f\n", data->temperature);
		printf("Wear Level: %d%%\n", data->wear_level);

		if (data->performace_score) {
			printf("Performance Score: %d\n", data->performace_score);
		} else {
			printf("Performance Score: Not Calculated\n");
		}
	} else {
		power_management_unit *data =
			(power_management_unit *)sensor->sensor_data;
		printf("Power Management Unit\n");
		printf("Voltage: %.2f\n", data->voltage);
		printf("Current: %.2f\n", data->current);
		printf("Power Consumption: %.2f\n", data->power_consumption);
		printf("Energy Regen: %d%%\n", data->energy_regen);
		printf("Energy Storage: %d%%\n", data->energy_storage);
	}
}

int is_functional(sensor *sensor)
{
	// Verifica daca senzorul functioneaza in parametrii nominali
	if (sensor->sensor_type == PMU) {
		power_management_unit *data = (power_management_unit *)sensor->sensor_data;

		// Verifica cei 5 parametri pentru senzorii PMU
		if (data->voltage < 10.f || data->voltage > 20.f ||
			data->current < -100.f || data->current > 100.f ||
			data->power_consumption < 0.f || data->power_consumption > 1000.f ||
			data->energy_regen < 0 || data->energy_regen > 100 ||
			data->energy_storage < 0 || data->energy_storage > 100)
			return 0;
	} else {
		tire_sensor *data = (tire_sensor *)sensor->sensor_data;

		// Verifica cei 3 parametri pentru senzorii jantelor
		if (data->pressure < 19.f || data->pressure > 28.f ||
			data->temperature < 0.f || data->temperature > 120.f ||
			data->wear_level < 0 || data->wear_level > 100)
			return 0;
	}
	return 1;
}

// Scoate senzorii ce nu functioneaza corespunzator din lista
void prune_sensors(sensor *sensor_arr, int *arrsize)
{
	sensor *iter = sensor_arr;
	sensor *curr = sensor_arr;

	int size = *arrsize;

	while (size--) {
		if (is_functional(curr)) {
			// Copiaza senzorul pe urmatoarea pozitie
			*iter++ = *curr;
		} else {
			// Sterge senzorul si nu avansa la urmatoarea pozitie
			free(curr->operations_idxs);
			free(curr->sensor_data);
			(*arrsize)--;
		}

		// Avanseaza la urmatorul senzor din lista
		curr++;
	}
}

void analyze_sensor(sensor *sensor)
{
	void (*operations[OPERATION_COUNT])(void *);
	get_operations((void **)operations);

	for (int i = 0; i < sensor->nr_operations; i++)
		operations[sensor->operations_idxs[i]](sensor->sensor_data);
}

int main(int argc, char const *argv[])
{
	assert(argc == 2);

	// Citeste lista de senzori din fisierul de intrare
	int arr_size;
	sensor *sensor_arr = parse_input_file(argv[1], &arr_size);

	char command[CMD_LEN];

	// Citeste urmatoarea comanda
	while (fgets(command, CMD_LEN - 1, stdin)) {
		char *cmd_name = strtok(command, DELIMS);

		// Verifica numele comenzii si executa comanda dorita
		if (!strcmp(cmd_name, "exit")) {
			break;
		} else if (!strcmp(cmd_name, "print")) {
			int index = atoi(strtok(NULL, DELIMS));
			if (index >= arr_size || index < 0) {
				printf("Index not in range!\n");
				continue;
			}

			print_sensor(&sensor_arr[index]);
		} else if (!strcmp(cmd_name, "analyze")) {
			int index = atoi(strtok(NULL, DELIMS));
			if (index >= arr_size || index < 0) {
				printf("Index not in range!\n");
				continue;
			}

			analyze_sensor(&sensor_arr[index]);
		} else if (!strcmp(cmd_name, "clear")) {
			prune_sensors(sensor_arr, &arr_size);
		}
	}

	free_sensor_array(sensor_arr, arr_size);
	return 0;
}
