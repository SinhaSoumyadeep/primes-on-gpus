#include "functions.h"
#include "debugger.h"

using namespace std;

#define WARNINGS 0

/*
 struct TheJob {
 long int id = -1; // Will be unique per job
 long int required_cores = -1;
 long int duration = -1;
 long int duration_left = -1;
 bool valid = false;
 };
 
 struct CompNode {
 long int id = -1;
 long int node_number = -1;
 long int total_cores= -1;
 long int used_cores = -1;
 long int free_cores = -1;
 TheJob NodeJob[NODE_MAX_JOBS]; // All Zero Initially
 long int node_job_queue = 0;
 
 };
 */


 inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
 {
    if (code != cudaSuccess) 
    {
 
     fprintf(stderr,"\e[1;31mGPUassert: %s %s %d \e[0m\n", cudaGetErrorString(code), file, line);
 
       if (abort) exit(code);
    }
 }