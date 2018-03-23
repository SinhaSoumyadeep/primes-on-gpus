#Sample Makefile
NVCC=nvcc
TESTS=primes
FLAGS=


all: $(TESTS)

default: all

clean:
	rm -rf ./*.o $(TESTS)

%: %.cu
	$(NVCC) $(CFLAGS) $< -o $@

run: all $(TESTS)
	./$(TESTS)


dist:
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar
