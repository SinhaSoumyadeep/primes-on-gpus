#include <stdio.h>
#include <stdlib.h>

#define block_size   32
#define vector_size  1000000000

#define ROWS 3
#define K 4
#define COLS 5
#define INTSIZE sizeof(int)

int main( void ) { 

    // Set device that we will use for our cuda code
    // It will be either 0 or 1
    cudaSetDevice(0);

    // Time Variables
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);

    // Express matrix elements as 1 dimension
    int aSize =  ROWS * K * INTSIZE;
    int bSize =  K * COLS* INTSIZE;
    int cSize =  ROWS * COLS * INTSIZE;

    // Input Arrays and variables
    int *a        = new int [aSize]; 
    int *b        = new int [bSize]; 
    int *c_cpu    = new int [cSize]; 
    //int *c_gpu    = new int [cSize];

    /*
    // Pointers in GPU memory
    int *dev_a;
    int *dev_b;
    int *dev_c;
    */


    // fill the arrays 'a' and 'b' on the CPU
    for(int r=0; r<ROWS; r++){
        for(int c=0; c<K; c++){
            a[ r*K + c] = rand()%10;
        }
    }

    for(int r=0; r<K; r++){
        for(int c=0; c<COLS; c++){
            b[ r*COLS + c ] = rand()%10;
        }
    }

    //
    // CPU Calculation
    //////////////////

    printf("Running sequential job.\n");
    cudaEventRecord(start,0);

    // Calculate C in the CPU
    for(int r=0; r<ROWS; r++){
        for(int c=0; c<COLS; c++){

            int sum = 0; 
            for(int k=0; k<K;k++){
                sum +=  a[r*K + k] + b[k*COLS + c];
            }
            c_cpu[r*COLS + c] = sum;
        }
    }

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    printf("\tSequential Job Time: %.2f ms\n", time);

    free(a);
    free(b);
    free(c_cpu);

    return 0;
}

