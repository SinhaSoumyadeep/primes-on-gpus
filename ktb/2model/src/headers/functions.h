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

#include <memory>
#include <stdexcept>

using namespace std;



 long find_number_of_gpus();

void start_info();

void end_info();



inline void console_input() {
        switch (argc) { // For getting input from console
        case 6:
            //long input_5;
            //input_5 = atol(argv[5]); //Fifth Input
            
        case 5:
            //long input_4;
            //input_4 = atol(argv[4]); //Fourth Input
            
        case 4:
            //long input_3;
            //input_3 = atol(argv[3]); // Third Input
            
        case 3:
            long input_2;
            input_2 = atol(argv[2]); // Second Input
            number_of_gpus = (int)input_2; // Number of GPUs on the NODE.
            // Over-ride with input value.
        case 2:
            long input_1;
            input_1 = atol(argv[1]); // First input
            pl_end_number = (long long int)input_1;

            break;
        case 1:
            // Keep this empty
            break;
        default:
            red_start();
            cout << "FATAL ERROR: Wrong Number of Inputs" << endl; // If incorrect number of inputs are used.
            color_reset();
            return 1;
    }
}

 inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
 {
    if (code != cudaSuccess) 
    {
     fprintf(stderr,"\e[1;31mGPUassert: %s %s %d \e[0m\n", cudaGetErrorString(code), file, line);
       if (abort) exit(code);
    }
 }
 
#endif // FUNCTIONS_H
