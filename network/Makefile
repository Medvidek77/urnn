CC ?= cc
CFLAGS ?= -std=c99 -Wall -O3
LIBS = -lm
TARGETS = urnn_train urnn_run

all: $(TARGETS)

urnn_train: urnn_train.c genann.c
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

urnn_run: urnn_run.c genann.c
	$(CC) $(CFLAGS) $^ -o $@ $(LIBS)

clean:
	rm -f $(TARGETS)
