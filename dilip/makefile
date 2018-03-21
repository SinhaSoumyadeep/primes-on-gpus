CC=nvcc

all: check

default: check

clean:
	rm -rf *.o *.so ${TESTS} *out*

# For every XYZ.c file, generate XYZ.o.
%.o: %.cu
	$(CC) $<  -o $@

check: MatMult.o 
	./MatMult.o
