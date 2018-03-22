#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>

using namespace std;

#define block_size   32
#define pl_end_number 100
#define vector_size 1000

__global__ void prime( int *a, int *b, int *c ) {
    int tid = (blockIdx.x*blockDim.x) + threadIdx.x;    // this thread handles the data at its thread id

    if (tid < vector_size){
        c[tid] = a[tid] + b[tid];                   // add vectors together                
    }
}



// ********************** MAIN FUNCTION **********************


int main( void ) { 

    cout << "Program Start" << endl;

    cudaSetDevice(0);

    // Time Variables
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);

    bool *small_sieve = new bool [pl_end_number];

    for (unsigned long long int i = 0; i < pl_end_number; i++) {
        small_sieve[i] = true;
    }

    for (unsigned long long int i = 2; i <= int(sqrt(pl_end_number))+1; i++) {
        for (unsigned long long int j = i+1; j <= pl_end_number; j++) {
            if (j % i == 0) {
                small_sieve[j] = false;
                cout << j << " is Composite, as divisible by " << i << endl;
            }
        }        
    }

    cout << "Primes till 100\n";

    unsigned long long int small_sieve_counter = 0;
    for (unsigned long long int i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            cout << i << " ";
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

    


    // Input Arrays and variables
    int *input_list        = new int [vector_size]; 
    int *c_cpu    = new int [vector_size]; 
    int *c_gpu    = new int [vector_size];

    // Pointers in GPU memory
    int *dev_a;
    int *dev_b;
    int *dev_c;



    //
    // CPU Calculation
    //////////////////

  //  printf("Running sequential job.\n");
    cudaEventRecord(start,0);

    // Calculate C in the CPU
    // for (int i = 0; i < vector_size; i++) {
    //     c_cpu[i] = a[i] + b[i];
    // }

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
 //   printf("\tSequential Job Time: %.2f ms\n", time);

    // allocate the memory on the GPU
    cudaMalloc( (void**)&dev_a,  vector_size * sizeof(int) );
    cudaMalloc( (void**)&dev_b,  vector_size * sizeof(int) );
    cudaMalloc( (void**)&dev_c,  vector_size * sizeof(int) );

    // copy the arrays 'a' and 'b' to the GPU
    // cudaMemcpy( dev_a, a, vector_size * sizeof(int),
    //         cudaMemcpyHostToDevice );
    // cudaMemcpy( dev_b, b, vector_size * sizeof(int),
    //         cudaMemcpyHostToDevice );


    //
    // GPU Calculation
    ////////////////////////

 //   printf("Running parallel job.\n");

    int grid_size = (vector_size-1)/block_size;
    grid_size++;

    cudaEventRecord(start,0);
    //prime<<<grid_size,block_size>>>( dev_a, dev_b, dev_c);

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);

    cudaEventElapsedTime(&time, start, stop);
 //   printf("\tParallel Job Time: %.2f ms\n", time);

    // copy the array 'c' back from the GPU to the CPU
    cudaMemcpy( c_gpu, dev_c, vector_size * sizeof(int), 
            cudaMemcpyDeviceToHost );

    // compare the results
    int error = 0;
    for (int i = 0; i < vector_size; i++) {
        if (c_cpu[i] != c_gpu[i]){
            error = 1;
            // printf( "Error starting element %d, %d != %d\n", i, c_gpu[i], c_cpu[i] );    
        }
        if (error) break; 
    }

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

