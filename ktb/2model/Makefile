#!/bin/sh

# Created by KAUSTUBH SHIVDIKAR

TARGET=simulator.bin

NVCC=NVCC
FLAGS=-O0
LDFLAGS=

ROOT_DIR=$(PWD)
CODE_DIR=$(ROOT_DIR)/src/code
HEADER_DIR=$(ROOT_DIR)/src/headers
INC_DIR=$(ROOT_DIR)/src/inc
LIB_DIR=$(ROOT_DIR)/src/lib
OBJ_DIR=$(ROOT_DIR)/src/obj
BIN_DIR=$(ROOT_DIR)/src/bin
OBJ=$(OBJ_DIR)/primes.o $(OBJ_DIR)/functions.o $(OBJ_DIR)/debugger.o



all: $(OBJ)
	$(NVCC) $(FLAGS) $(LDFLAGS) -o $(BIN_DIR)/$(TARGET) $(OBJ)
	cp $(BIN_DIR)/$(TARGET) $(ROOT_DIR)

$(OBJ_DIR)/%.o: $(CODE_DIR)/%.cpp
	$(CC) -I$(HEADER_DIR) $(CFLAGS) -c $<
	mv $(@F) $(OBJ_DIR)

clean:
	printf "\n\e[1;32mCleaning all Object files\e[0m\n"
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/*.bin $(ROOT_DIR)/*.bin

run: clean all
	$(BIN_DIR)/$(TARGET)



clean-dat:
	printf "\n\e[1;32mCleaning all Data files\e[0m\n"
	rm -f $(ROOT_DIR)/*.dat



dist: clean
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar

