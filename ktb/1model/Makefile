#Sample Makefile
CC=gcc
WERR=-Werror
TESTS=ram cache
CFLAGS=-g -O0 -std=gnu99 # $(WERR)



all: clean $(TESTS)

default: all

clean:
	rm -rf ./*.o $(TESTS)

%: %.c
	$(CC) $(CFLAGS) $< -o $@

run: all ram cache tlb


rram: all
	./ram


rcache: all
	./cache





dist:
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar
