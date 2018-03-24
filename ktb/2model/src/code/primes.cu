#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <functions.h>
#include <debugger.h>

using namespace std;

#define block_size   32
#define DEBUG 1


// ********************** KERNEL DEFINITION **********************

__global__ void prime( bool *il, 
    long long int *pl, 
    long long int *dev_input_size_ptr, 
    long long int *dev_prime_size_ptr, 
    long long int *dev_pl_end_number_ptr ) {
    
        long long int dev_input_size = *dev_input_size_ptr;
        long long int dev_prime_size = *dev_prime_size_ptr; 
        long long int dev_pl_end_number = *dev_pl_end_number_ptr;



        long long int tid = (blockIdx.x*blockDim.x) + threadIdx.x;    // this thread handles the data at its thread id


    if (tid <= dev_prime_size) {
        long long int tpno = pl[tid];
        //printf("\tTID: %d", tid);
            for (long long int k=dev_pl_end_number; k<dev_input_size; k++) {
                if (k % tpno == 0) {
                    il[k] = false;                   // add vectors together                
            }
        }
    }
}




// Global Variables.
long long int pl_end_number = 1000;
long long int total_primes=0;
//long long int end_val = 1000000;


// ********************** MAIN FUNCTION **********************

int main(int argc, char *argv[]) { 


    cuProfilerStart();

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
    for (long long int i = 0; i < pl_end_number; i++) {
        small_sieve[i] = true;
    }

    // Compute Small Sieve on CPU
    cudaEventRecord(start,0);
    
    for (long long int i = 2; i <= int(sqrt(pl_end_number))+1; i++) {
        for (long long int j = i+1; j <= pl_end_number; j++) {
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
    long long int small_sieve_counter = 0;
    for (long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            // To display prime numbers
            //cout << i << " ";
            small_sieve_counter++;
        }
    }
    cout << endl;

    total_primes += small_sieve_counter;
    if (DEBUG >= 1) {
        cout << "Total Primes in Small Sieve: " << small_sieve_counter << endl;
    }

    long long int *prime_list = new long long int [small_sieve_counter];

    // Storing numbers from the sieve to an array.
    long long int inner_counter = 0;
    for (long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            prime_list[inner_counter] = i;
            inner_counter++;
        }
    }

    
    // Create Input list on CPU
    long long int il_size = pl_end_number*pl_end_number;
    bool *input_list = new bool [il_size];
    for (long long int i =0; i < il_size; i++) {
        input_list[i] = true;
    }

    printf("Input List Size on CPU: %llu\n", il_size);



    // Pointers in GPU memory
    bool *dev_il;
    long long int *dev_pl;
    long long int *dev_input_size;
    long long int *dev_prime_size;
    long long int *dev_pl_end_number;   
    

    // Allocate the memory on the GPU
    cudaMalloc( (void**)&dev_il,  il_size * sizeof(bool) );
    cudaMalloc( (void**)&dev_pl,  small_sieve_counter * sizeof(long long int) );
    cudaMalloc( (void**)&dev_input_size,  sizeof(long long int) );
    cudaMalloc( (void**)&dev_prime_size,  sizeof(long long int) );
    cudaMalloc( (void**)&dev_prime_size,  sizeof(long long int) );
    cudaMalloc( (void**)&dev_pl_end_number,  sizeof(long long int) );


    // Copy the arrays 'a' and 'b' to the GPU
    cudaMemcpy( dev_il, input_list, il_size * sizeof(bool),
             cudaMemcpyHostToDevice );
    cudaMemcpy( dev_pl, prime_list, small_sieve_counter * sizeof(long long int),
             cudaMemcpyHostToDevice );
    cudaMemcpy( dev_prime_size, &small_sieve_counter, sizeof(long long int),
             cudaMemcpyHostToDevice );
    cudaMemcpy( dev_input_size, &il_size, sizeof(long long int),
             cudaMemcpyHostToDevice );
    cudaMemcpy( dev_pl_end_number, &pl_end_number, sizeof(long long int),
             cudaMemcpyHostToDevice );


    //
    // GPU Calculation
    ////////////////////////

 //   printf("Running parallel job.\n");

    int grid_size = (small_sieve_counter-1)/block_size;
    grid_size++;

    if (DEBUG >=1) {
        cout << "Grid Size: " << grid_size << endl;
        cout << "Block Size: " << block_size << endl;
        
    }


    // ********************** KERNEL LAUNCH **********************

    cudaEventRecord(start,0);
    prime<<<grid_size,block_size>>>(dev_il, dev_pl, dev_input_size, dev_prime_size, dev_pl_end_number);

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
    long long int ret_primes=0;
    
    for (long long int i = pl_end_number; i < pl_end_number*pl_end_number; i++) {
        if (output_list[i] == true) {
            // To display prime numbers
            //cout << i << " ";
            ret_primes++;
            //small_sieve_counter++;
        }
    }

    total_primes += ret_primes; 
    cout << "Total Primes: "<< total_primes;
    cout << endl;
             
    

    // Free the memory allocated on the GPU
    cudaFree( dev_il );
    cudaFree( dev_pl );

    // free(a);
    // free(b);
    // free(c_cpu);
    // free(c_gpu);

    cudaProfilerStop();

    return 0;
}

