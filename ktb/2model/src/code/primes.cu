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

__global__ void prime( int *a, int *b, int *c ) {
    int tid = (blockIdx.x*blockDim.x) + threadIdx.x;    // this thread handles the data at its thread id

    if (tid < vector_size){
        c[tid] = a[tid] + b[tid];                   // add vectors together                
    }
}



// ********************** MAIN FUNCTION **********************

unsigned long long int pl_end_number = 1000;
unsigned long long int end_val = 1000;


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
    int bool_size = sizeof(bool);


    

    for (unsigned long long int i = 0; i < pl_end_number; i++) {
        small_sieve[i] = true;
    }

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
    printf("\tPrime Numbers Computation Time on CPU: %.2f ms\n", time);

 //   cout << "Primes till 100\n";

    unsigned long long int small_sieve_counter = 0;
    for (unsigned long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            //cout << i << " ";
            small_sieve_counter++;
            //cout << small_sieve[i] << "    ";
        }
    }
    cout << endl;

    unsigned long long int *prime_list = new unsigned long long int [small_sieve_counter];

    unsigned long long int inner_counter = 0;
    for (unsigned long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            prime_list[inner_counter] = i;
            inner_counter++;
        }
    }

    


    // Pointers in GPU memory
    int *dev_il;
    int *dev_pl;

    // Create Input list
    unsigned long long int start_number = pl_end_number+1;

    unsigned long long int il_size = pl_end_number*pl_end_number;

    bool *input_list = new bool [il_size];

    for (unsigned long long int i =0; i < il_size; i++) {
        input_list[i] = true;
    }

    
    // allocate the memory on the GPU
    //cudaMalloc( (void**)&dev_il,  vector_size * bool_size );
    //cudaMalloc( (void**)&dev_pl,  small_sieve_counter * bool_size );

    // copy the arrays 'a' and 'b' to the GPU
    // cudaMemcpy( dev_a, a, vector_size * sizeof(int),
    //         cudaMemcpyHostToDevice );
    // cudaMemcpy( dev_b, b, vector_size * sizeof(int),
    //         cudaMemcpyHostToDevice );


    //
    // GPU Calculation
    ////////////////////////

 //   printf("Running parallel job.\n");

    //int grid_size = (vector_size-1)/block_size;
    //grid_size++;

    //cudaEventRecord(start,0);
    //prime<<<grid_size,block_size>>>( dev_a, dev_b, dev_c);

    //cudaEventRecord(stop,0);
    //cudaEventSynchronize(stop);

    //cudaEventElapsedTime(&time, start, stop);
 //   printf("\tParallel Job Time: %.2f ms\n", time);

    // copy the array 'c' back from the GPU to the CPU
    // cudaMemcpy( c_gpu, dev_c, vector_size * sizeof(int), 
    //         cudaMemcpyDeviceToHost );

    // compare the results
    // int error = 0;
    // for (int i = 0; i < vector_size; i++) {
    //     if (c_cpu[i] != c_gpu[i]){
    //         error = 1;
    //         // printf( "Error starting element %d, %d != %d\n", i, c_gpu[i], c_cpu[i] );    
    //     }
    //     if (error) break; 
    // }

    // if (error == 0){
    //     printf ("Correct result. No errors were found.\n");
    // }

    // free the memory allocated on the GPU
    // cudaFree( dev_a );
    // cudaFree( dev_b );
    // cudaFree( dev_c );

    // free(a);
    // free(b);
    // free(c_cpu);
    // free(c_gpu);

    return 0;
}

