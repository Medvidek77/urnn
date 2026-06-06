/*
 *
 * urnn_run.c
 *
 * Usage ./urnn_run [trained file] [input file]
 * Run the network
 *
 * Compile with: cc urnn_run.c genann.c -o urnn_run -lm
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "genann.h"


void
HELP(char* argv[])
{
	printf("Usage %s \t [trained file] [input file]\nRun the network.\n", argv[0]);
}

void
read_float_from_file(char* input, double from_file[])
{
	FILE* my_file  = NULL;
	double input_data = 0.0;
	int index = 0;

	my_file = fopen(input, "r");
	if (my_file == NULL) {
		printf("Couldn't open file for reading\n");
		exit(1);
	}

	for (int i = 0; i < 30; i++) {
		if (fscanf(my_file,"%lf",&input_data) == 1) {
			from_file[index] = input_data;
			index++;
		}
	}
	fclose(my_file);
	if (index != 30) {
		printf("There wasn't 10 colors in the input\n");
	}
}

int
main(int argc, char* argv[])
{
	if (argc != 3) {
		HELP(argv);
		return 1;
	}

	FILE *ann_file = fopen(argv[1], "r");
	if (!ann_file) {
		printf("Error opening trained network file.\n");
		return 1;
	}

	genann *ann = genann_read(ann_file);
	fclose(ann_file);
	if (!ann) {
		printf("Error reading trained network file.\n");
		return 1;
	}

	double from_file[30];
	read_float_from_file(argv[2], from_file);

	for (int i = 0; i < 30; i++) {
		from_file[i] = (from_file[i] + 1.0) / 2.0;
	}

	const double *calc_out = genann_run(ann, from_file);

	for (int i = 0; i < 54; i++) {
		double rescaled = (calc_out[i] * 2.0) - 1.0;
		printf("%.15f ", rescaled);
	}

	genann_free(ann);
	return 0;
}
