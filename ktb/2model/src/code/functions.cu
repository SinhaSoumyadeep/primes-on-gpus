#include "functions.h"
#include "debugger.h"

using namespace std;

#define WARNINGS 0



 inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
 {
    if (code != cudaSuccess) 
    {
 
     fprintf(stderr,"\e[1;31mGPUassert: %s %s %d \e[0m\n", cudaGetErrorString(code), file, line);
 
       if (abort) exit(code);
    }
 }