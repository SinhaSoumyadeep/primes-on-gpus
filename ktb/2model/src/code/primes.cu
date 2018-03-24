#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <functions.h>
#include <debugger.h>

using namespace std;

#define block_size   32
#define vector_size 1000
#define DEBUG 1

__global__ void prime( bool *il, unsigned long long int *pl ) {
    int tid = (blockIdx.x*blockDim.x) + threadIdx.x;    // this thread handles the data at its thread id

    if (tid <= sizeof(pl)/sizeof(unsigned long long int)) {
        unsigned long long int tpno = pl[tid];
            for (unsigned long long int k=0;k<sizeof(pl)/sizeof(bool);k++) {
                if (k % tpno == 0) {
                    il[k] = false;                   // add vectors together                
            }
        }
    }
}



// ********************** MAIN FUNCTION **********************

unsigned long long int pl_end_number = 1000;
//unsigned long long int end_val = 1000000;


int main(int argc, char *argv[]) { 

    

    green_start();
    cout << "\n\n\n\n\n\n\n\n\n\nProgram Start\n";
    color_reset();
    
    // Accepting input from Console
    switch (argc) { // For getting input from console
        case 6:
            long input_5;
            input_5 = atol(argv[5]); //Fifth Input
            //num_threads = input_5;
        case 5:
            long input_4;
            input_4 = atol(argv[4]); //Fourth Input
            //in_parallel = input_4;
        case 4:
            long input_3;
            input_3 = atol(argv[3]); // Third Input
            //display_bit = input_3;
        case 3:
            long input_2;
            input_2 = atol(argv[2]); // Second Input
        case 2:
            long input_1;
            input_1 = atol(argv[1]); // First input
            pl_end_number = (unsigned long long int)input_1;

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








    // Select GPU
    cudaSetDevice(1);

    // Time Variables
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);


    // Create Small Sieve
    bool *small_sieve = new bool [pl_end_number];


    
    // Initialize Small Sieve
    for (unsigned long long int i = 0; i < pl_end_number; i++) {
        small_sieve[i] = true;
    }

    // Compute Small Sieve on CPU
    cudaEventRecord(start,0);
    
    for (unsigned long long int i = 2; i <= int(sqrt(pl_end_number))+1; i++) {
        for (unsigned long long int j = i+1; j <= pl_end_number; j++) {
            if (j % i == 0) {
                small_sieve[j] = false;
                //cout << j << " is Composite, as divisible by " << i << endl;
            }
        }        
    }

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    printf("CPU Time: %.2f ms\n", time);


    // Count Total Primes
    unsigned long long int small_sieve_counter = 0;
    for (unsigned long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            // To display prime numbers
            //cout << i << " ";
            small_sieve_counter++;
        }
    }
    cout << endl;


    unsigned long long int *prime_list = new unsigned long long int [small_sieve_counter];

    // Storing numbers from the sieve to an array.
    unsigned long long int inner_counter = 0;
    for (unsigned long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            prime_list[inner_counter] = i;
            inner_counter++;
        }
    }

    
    // Create Input list on CPU
    unsigned long long int il_size = pl_end_number*pl_end_number;
    bool *input_list = new bool [il_size];
    for (unsigned long long int i =0; i < il_size; i++) {
        input_list[i] = true;
    }

    // Pointers in GPU memory
    bool *dev_il;
    unsigned long long int *dev_pl;
    

    // Allocate the memory on the GPU
    cudaMalloc( (void**)&dev_il,  il_size * sizeof(bool) );
    cudaMalloc( (void**)&dev_pl,  small_sieve_counter * sizeof(unsigned long long int) );


    // Copy the arrays 'a' and 'b' to the GPU
     cudaMemcpy( dev_il, input_list, il_size * sizeof(bool),
             cudaMemcpyHostToDevice );
     cudaMemcpy( dev_pl, prime_list, small_sieve_counter * sizeof(unsigned long long int),
             cudaMemcpyHostToDevice );


    //
    // GPU Calculation
    ////////////////////////

 //   printf("Running parallel job.\n");

    int grid_size = (small_sieve_counter-1)/block_size;
    grid_size++;

    cudaEventRecord(start,0);
    prime<<<grid_size,block_size>>>(dev_il, dev_pl);

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);

    cudaEventElapsedTime(&time, start, stop);
    printf("GPU Time: %.2f ms\n", time);

        // Create Output list on CPU
        bool *output_list = new bool [il_size];
        

    // copy the array Input List back from the GPU to the CPU
     cudaMemcpy( output_list, dev_il, il_size * sizeof(bool), 
             cudaMemcpyDeviceToHost );


    // Check Returned Primes
    for (unsigned long long int i = pl_end_number; i < pl_end_number*pl_end_number; i++) {
        if (output_list[i] == true) {
            // To display prime numbers
            cout << i << " ";
            //small_sieve_counter++;
        }
    }
    cout << endl;
             
    

    // Free the memory allocated on the GPU
    cudaFree( dev_il );
    cudaFree( dev_pl );

    // free(a);
    // free(b);
    // free(c_cpu);
    // free(c_gpu);

    return 0;
}

