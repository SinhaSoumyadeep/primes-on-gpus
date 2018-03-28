#include <functions.h>
#include <debugger.h>

using namespace std;

#define block_size   32
#define DEBUG 1
#define GPU 0
#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
#define WARNINGS 1


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


// ********************** PTHREAD ITERATION **********************

void *one_iteration(void *tid) {
    // Dont use tid
    // Use thread_id
    long thread_id = (long) tid;

    if (DEBUG >= 1) {
        cout << "GPU Handler: " << thread_id << endl;
    }

    cudaEvent_t start, stop;
    


        // Select GPU
        gpuErrchk(cudaSetDevice(thread_id));


        // Pointers in GPU memory
        long long int *dev_prime_list;
        long long int *dev_prime_list_start;
        long long int *dev_prime_list_end;
        
        long long int *dev_input_list_start;
        long long int *dev_input_list_end;
        
        
    
        // Allocate the memory on the GPU
        gpuErrchk( cudaMalloc( (void**)&dev_prime_list,  small_sieve_counter * sizeof(long long int) ) );
        gpuErrchk( cudaMalloc( (void**)&dev_input_size,  sizeof(long long int) ));
        gpuErrchk( cudaMalloc( (void**)&dev_prime_size,  sizeof(long long int) ));
        gpuErrchk( cudaMalloc( (void**)&dev_prime_size,  sizeof(long long int) ));
        gpuErrchk( cudaMalloc( (void**)&dev_pl_end_number,  sizeof(long long int) ));
    
    
        // Copy the arrays 'a' and 'b' to the GPU
                gpuErrchk( cudaMemcpy( dev_il, input_list, il_size * sizeof(bool),
                 cudaMemcpyHostToDevice ));
                gpuErrchk( cudaMemcpy( dev_pl, prime_list, small_sieve_counter * sizeof(long long int),
                 cudaMemcpyHostToDevice ));
                gpuErrchk( cudaMemcpy( dev_prime_size, &small_sieve_counter, sizeof(long long int),
                 cudaMemcpyHostToDevice ));
                 gpuErrchk( cudaMemcpy( dev_input_size, &il_size, sizeof(long long int),
                 cudaMemcpyHostToDevice ));
                 gpuErrchk( cudaMemcpy( dev_pl_end_number, &pl_end_number, sizeof(long long int),
                 cudaMemcpyHostToDevice ));
    
    
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
        gpuErrchk( cudaProfilerStart() );
    
        if (DEBUG >=1) {
            cout << "Launching Kernel" << endl;
        }
    
        gpuErrchk(cudaEventRecord(start,0));
        prime<<<grid_size,block_size>>>(dev_il, dev_pl, dev_input_size, dev_prime_size, dev_pl_end_number);
        gpuErrchk( cudaPeekAtLastError() );
        gpuErrchk(cudaEventRecord(stop,0));
        gpuErrchk(cudaEventSynchronize(stop));
        if (DEBUG >=2) {
            cout << "Kernel Computation Complete" << endl;
        }
        gpuErrchk(cudaEventElapsedTime(&time, start, stop));
        yellow_start();
        printf("GPU Time: %.2f ms\n", time);
        color_reset();
    
            // Create Output list on CPU
            if (DEBUG >=2) {
                cout << "Allocating OUTPUT_LIST" << endl;
            }
            bool *output_list = new bool [il_size];
            
    
        // copy the array Input List back from the GPU to the CPU
        gpuErrchk(cudaMemcpy( output_list, dev_il, il_size * sizeof(bool), 
                 cudaMemcpyDeviceToHost ));
        gpuErrchk(cudaProfilerStop());
    
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
        green_start();
        cout << "Total Primes: "<< total_primes;
        cout << endl;
        color_reset();
                 
        
    
        // Free the memory allocated on the GPU
        cudaFree( dev_il );
        cudaFree( dev_pl );
        cudaFree( dev_prime_size );
        cudaFree( dev_input_size );
        cudaFree( dev_pl_end_number );
        
    
         free(small_sieve);
         free(prime_list);
         free(input_list);
         free(output_list);
    
    

}




// Global Variables.
long long int pl_end_number = 1000;
long long int total_primes=0;
long number_of_gpus = 1;
//long long int end_val = 1000000;


// ********************** MAIN FUNCTION **********************

int main(int argc, char *argv[]) { 

    // INLINE
    start_info();

    number_of_gpus = find_number_of_gpus();


    // For debugging, I am hardcoding the numbber of GPUs to 1.
    number_of_gpus = 1; // Remove this line to run on multiple GPUs.


    // Accepting input from Console
    // INLINE
    console_input();


    







    // Time Variables
    cudaEvent_t start, stop;
    float time;
    gpuErrchk(cudaEventCreate (&start));
    gpuErrchk(cudaEventCreate (&stop));



    // Create Small 
    if (DEBUG >=2) {
        cout << "Allocating SMALL_SIEVE" << endl;
    }



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

    gpuErrchk( cudaEventRecord(stop,0));
    gpuErrchk( cudaEventSynchronize(stop));
    gpuErrchk( cudaEventElapsedTime(&time, start, stop));
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



    if (DEBUG >=2) {
        cout << "Allocating PRIME_LIST" << endl;
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

    



    while(end_reached) {







    // Create Input list on CPU
    long long int il_size = pl_end_number*pl_end_number;
    if (DEBUG >=2) {
        cout << "Allocating INPUT_LIST" << endl;
    }
    bool *input_list = new bool [il_size];
    for (long long int i =0; i < il_size; i++) {
        input_list[i] = true;
    }

    if (DEBUG >=1) {
    printf("Input List Size on CPU: %llu\n", il_size);
    }



    // Pthreads Launch
    pthread_t *thread = new pthread_t [number_of_gpus];
    int *thread_error = new int [number_of_gpus];
    GpuHandler *handler = new GpuHandler [number_of_gpus];

    initialize_handlers(handler);

    for (long i = 0; i < number_of_gpus; i++) {
        thread_error[i] = pthread_create(&thread[i], NULL, one_iteration, (void *) i);
        if (thread_error[i] && WARNINGS) {
            yellow_start();
            cout << "Warning: Thread " << i << " failed to launch" << endl;
            cout << "GPU: " << i << " is being mishandled." << endl;
            color_reset();
        }
    }
    for (long i = 0; i < number_of_gpus; i++) {
        thread_error[i] = pthread_join(thread[i], NULL);
    }


    // INLINE
    iteration_info();

}


// CODE

    // INLINE
    end_info();

    return 0;
}

