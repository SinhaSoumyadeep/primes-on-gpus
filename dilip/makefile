CC=nvcc

all: pbasic 

default: pbasic 

clean:
	rm -rf *.o *.so ${TESTS} *out*

# For every XYZ.c file, generate XYZ.o.
%.o: %.cu
	$(CC) $<  -o $@

check: mat_mult.o 
	./mat_mult.o

pbasic : prime_basic.o 
	./prime_basic.o
