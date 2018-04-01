//
// Author: Kaustubh Shivdikar
//


#ifndef FUNCTIONS_H
#define FUNCTIONS_H


#include <iostream>
#include <stdio.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <array>
#include <cmath>
#include <fstream>
#include <sstream>
#include <string>
#include <time.h>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <pthread.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_profiler_api.h>
#include <errno.h>

#include <memory>
#include <stdexcept>

using namespace std;

typedef unsigned long long int uint64_cu;

typedef struct PrimeHeader{
    uint64_cu lastMaxNo;
    uint64_cu length;
    uint64_cu* primelist;
}PrimeHeader;


struct GpuHandler {
    int gpus;
    uint64_cu* PL;
    uint64_cu PL_len;
    uint64_cu IL_start; 
    uint64_cu IL_end; 
};


 long find_number_of_gpus();

void start_info();

void end_info();

void kernelLauncher(int gpu_id);





 inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
 {
    if (code != cudaSuccess) 
    {
     fprintf(stderr,"\e[1;31mGPUassert: %s %s %d \e[0m\n", cudaGetErrorString(code), file, line);
       if (abort) exit(code);
    }
 }

#endif // FUNCTIONS_H
