#!/bin/sh

# Created by KAUSTUBH SHIVDIKAR

TARGET=simulator.bin

NVCC=NVCC
CFLAGS=-O0
LDFLAGS=

ROOT_DIR=$(PWD)
CODE_DIR=$(ROOT_DIR)/src/code
HEADER_DIR=$(ROOT_DIR)/src/headers
INC_DIR=$(ROOT_DIR)/src/inc
LIB_DIR=$(ROOT_DIR)/src/lib
OBJ_DIR=$(ROOT_DIR)/src/obj
BIN_DIR=$(ROOT_DIR)/src/bin
OBJ=$(OBJ_DIR)/main.o $(OBJ_DIR)/functions.o $(OBJ_DIR)/debugger.o
DAT_OBJ=$(OBJ_DIR)/dat_gen.o $(OBJ_DIR)/functions.o $(OBJ_DIR)/debugger.o


all: $(OBJ) $(DAT_OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/$(TARGET) $(OBJ)
	cp $(BIN_DIR)/$(TARGET) $(ROOT_DIR)

$(OBJ_DIR)/%.o: $(CODE_DIR)/%.cpp
	$(CC) -I$(HEADER_DIR) $(CFLAGS) -c $<
	mv $(@F) $(OBJ_DIR)

clean: clean-dat
	printf "\n\e[1;32mCleaning all Object files\e[0m\n"
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/*.bin $(ROOT_DIR)/*.bin

run: clean all
	$(BIN_DIR)/$(TARGET)

dat-gen: clean-dat all
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/$(DAT_GEN) $(DAT_OBJ)
	cp $(BIN_DIR)/$(DAT_GEN) $(ROOT_DIR)
	$(BIN_DIR)/$(DAT_GEN)


clean-dat:
	printf "\n\e[1;32mCleaning all Data files\e[0m\n"
	rm -f $(ROOT_DIR)/*.dat

$(ROOT_DIR)/%.dat: dat-gen
	echo "Dat-Gen Call"

data: $(ROOT_DIR)/resources.dat $(ROOT_DIR)/jobs.dat
	echo "Generating Data"


fifs:
	$(BIN_DIR)/$(TARGET) 1

tetris:
	$(BIN_DIR)/$(TARGET) 2

both:
	$(BIN_DIR)/$(TARGET) 3


run_small: clean all
	$(BIN_DIR)/$(TARGET) 3 100 10

run_big: clean all
	$(BIN_DIR)/$(TARGET) 3

dist: clean
	dir=`basename $$PWD`; cd ..; tar cvf $$dir.tar ./$$dir; gzip $$dir.tar

