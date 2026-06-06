/*
 *
 * urnn_train.c
 *
 * Usage ./urnn_train [train file] [output file]
 * Train the network.
 *
 * Compile with: cc urnn_train.c genann.c -o urnn_train -lm
 *
 */

#include "genann.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>


void
HELP(char* argv[])
{
	printf("Usage %s \t [train file] [output file]\nTrain the network.\n", argv[0]);
}

int
main(int argc, char* argv[])
{
	if (argc != 3) {
		HELP(argv);
		return 1;
	}

	FILE *in = fopen(argv[1], "r");
	if (!in) {
		printf("Error opening data file.\n");
		return 1;
	}

	int num_sets, num_input, num_output;
	if (fscanf(in, "%d %d %d", &num_sets, &num_input, &num_output) != 3) {
		printf("Error reading data file header.\n");
		fclose(in);
		return 1;
	}

	double **input = malloc(num_sets * sizeof(double*));
	double **output = malloc(num_sets * sizeof(double*));

	for (int i = 0; i < num_sets; i++) {
		input[i] = malloc(num_input * sizeof(double));
		for (int j = 0; j < num_input; j++) {
			if (fscanf(in, "%lf", &input[i][j]) != 1) {
				printf("Error reading inputs.\n");
				return 1;
			}
		}
		output[i] = malloc(num_output * sizeof(double));
		for (int j = 0; j < num_output; j++) {
			if (fscanf(in, "%lf", &output[i][j]) != 1) {
				printf("Error reading outputs.\n");
				return 1;
			}
		}
	}
	fclose(in);

	const int hidden_layers = 4;
	const int hidden_neurons = 45;
	const double desired_error = 0.0014;
	const int max_epochs = 1500000;
	const int epochs_between_reports = 20000;
	const double learning_rate = 0.1; // genann default

	// Rescale datasets to [0, 1] for genann default sigmoid. Original dataset values map to [-1, 1].
	for (int i = 0; i < num_sets; i++) {
		for (int j = 0; j < num_input; j++) {
			input[i][j] = (input[i][j] + 1.0) / 2.0;
		}
		for (int j = 0; j < num_output; j++) {
			output[i][j] = (output[i][j] + 1.0) / 2.0;
		}
	}

	genann *ann = genann_init(num_input, hidden_layers, hidden_neurons, num_output);

	for (int i = 0; i < max_epochs; i++) {
		double error = 0.0;
		for (int j = 0; j < num_sets; j++) {
			const double *guess = genann_run(ann, input[j]);
			for (int k = 0; k < num_output; k++) {
				double e = output[j][k] - guess[k];
				error += e * e;
			}
			genann_train(ann, input[j], output[j], learning_rate);
		}
		error /= (num_sets * num_output);

		if (i % epochs_between_reports == 0) {
			printf("Epochs     %8d. Current error: %f\n", i, error);
		}
		if (error < desired_error) {
			printf("Desired error reached. Epochs %d, error: %f\n", i, error);
			break;
		}
	}

	FILE *out = fopen(argv[2], "w");
	if (!out) {
		printf("Error opening output file.\n");
		return 1;
	}
	genann_write(ann, out);
	fclose(out);

	genann_free(ann);
	for (int i = 0; i < num_sets; i++) {
		free(input[i]);
		free(output[i]);
	}
	free(input);
	free(output);

	return 0;
}
