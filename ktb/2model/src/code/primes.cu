#include <functions.h>
#include <debugger.h>

using namespace std;

// ********************** KERNEL DEFINITION **********************

__global__ void prime_generator(int* d_input_list, uint64_cu* d_prime_list, uint64_cu* d_startPrimelist,uint64_cu* d_total_inputsize,uint64_cu* d_number_of_primes)
{
 
    uint64_cu tid = (blockIdx.x*blockDim.x) + threadIdx.x;

     
        if (tid < d_number_of_primes[0]) {
            printf("Kaustubh\n");
                                uint64_cu primes=d_prime_list[tid];
                      //  printf("%llu\n",primes);
                        for(uint64_cu i=0;i<=d_total_inputsize[0];i++) // Added less than eual to here.
                        {
                                uint64_cu bucket= i/(WORD);
                                uint64_cu setbit= i%(WORD);
                                uint64_cu number=d_startPrimelist[0]+i;
                                
                        //      printf("%llu -----> hash the value %llu to %llu bucket and change the %llu bit\n",number,i,bucket,setbit );
                        //      printf("**************  %llu --- %llu \n",number,primes);
                                if(number%primes==0)
                                {
                                        printf("%llu is divisible by %llu \n", number,primes);
                                        d_input_list[bucket]=d_input_list[bucket]| 1U<<setbit;
                                }
                        }
        }
}



// ********************** PTHREAD ITERATION **********************

void *one_iteration(void *tid) {
    // Dont use tid
    // Use thread_id
    long gpu_id = (long) tid;



    if (DEBUG >= 1) {
        cout << "GPU Handler: " << gpu_id << endl;
    }

    cudaEvent_t start, stop;
    

    

// Saurin's Code
kernelLauncher(gpu_id);



/*    
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
    */
    

}




// Global Variables.
uint64_cu pl_end_number = 1000;
uint64_cu total_primes=0;
int number_of_gpus = 1;

PrimeHeader pheader;
GpuHandler gpu_data;
//long long int end_val = 1000000;


// ********************** MAIN FUNCTION **********************

int main(int argc, char *argv[]) { 

    start_info(); // Complete

    number_of_gpus = find_number_of_gpus(); // Complete
    number_of_gpus = pow(2,int(log(number_of_gpus)/log(2)));
    gpu_data.gpus = number_of_gpus;

    // Accepting input from Console
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
            pl_end_number = (uint64_cu)input_1;

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


    




    //calculate_primes_on_cpu(); //TODO Store code in this function



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
    for (uint64_cu i = 0; i < pl_end_number; i++) {
        small_sieve[i] = true;
    }

    // Compute Small Sieve on CPU
    cudaEventRecord(start,0);
    
    for (uint64_cu i = 2; i <= int(sqrt(pl_end_number))+1; i++) {
        for (uint64_cu j = i+1; j <= pl_end_number; j++) {
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
    uint64_cu small_sieve_counter = 0;
    for (uint64_cu i = 2; i <= pl_end_number; i++) {
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


    uint64_cu *prime_list = new uint64_cu [small_sieve_counter];

    // Storing numbers from the sieve to an array.
    uint64_cu inner_counter = 0;
    for (uint64_cu i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            prime_list[inner_counter] = i;
            inner_counter++;
        }
    }
    pheader.primelist=prime_list;
    pheader.length=small_sieve_counter;
    pheader.lastMaxNo=pl_end_number;

    



//    while(end_reached) {

    //  *************** Pthreads Launch *******************


    pthread_t *thread = new pthread_t [number_of_gpus];
    int *thread_error = new int [number_of_gpus];
    GpuHandler *handler = new GpuHandler [number_of_gpus];

    //initialize_handlers(handler);

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

// output_combine();

    // INLINE
    //iteration_info();

//}


// CODE

    // INLINE
    //end_info();

    return 0;
}

