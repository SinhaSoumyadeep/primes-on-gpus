#include <functions.h>
#include <debugger.h>

using namespace std;


// Global Variables.
uint64_cu pl_end_number = 1000;
int number_of_gpus = 1;

PrimeHeader pheader;
GpuHandler gpu_data;
//long long int end_val = 1000000;




// ********************** KERNEL DEFINITION **********************

__global__ void prime_generator(int* d_input_list, uint64_cu* d_prime_list, uint64_cu* d_startPrimelist,uint64_cu* d_total_inputsize,uint64_cu* d_number_of_primes)
{
 
uint64_cu tid = (blockIdx.x*blockDim.x) + threadIdx.x;

     
if (tid < *d_number_of_primes) {
    //printf("Kaustubh\n");
    uint64_cu primes=d_prime_list[tid];
    for(uint64_cu i=0;i<=d_total_inputsize[0];i++) { // Added less than eual to here.
        uint64_cu bucket= i/(WORD);
        uint64_cu setbit= i%(WORD);
        uint64_cu number=d_startPrimelist[0]+i;
        if(number%primes==0) {
            //printf("%llu is divisible by %llu \n", number,primes);
            d_input_list[bucket]=d_input_list[bucket]| 1U<<setbit;
            }
        }
    }
}



// ********************** PTHREAD ITERATION **********************

void *one_iteration(void *tid) {
long gpu_id = (long) tid; // Dont use tid, Use gpu_id instead

if (DEBUG >= 1) {
    cout << "Launched GPU Handler: " << gpu_id << endl;
}

cudaEvent_t start_kernel[gpu_data.gpus]; 
cudaEvent_t stop_kernel[gpu_data.gpus];
float time[gpu_id];
gpuErrchk( cudaEventCreate (&start_kernel[gpu_id]) );
gpuErrchk( cudaEventCreate (&stop_kernel[gpu_id]) );

// cudaStream_t stream[gpu_data.gpus];
// for (int i=0;i<gpu_data.gpus;i++) {
//     stream[i] = i;
// }

    


// Saurin's Code
gpu_data.IL_start = pl_end_number+1;
gpu_data.IL_end = pl_end_number*pl_end_number;

//gpuErrchk( cudaEventRecord(start_kernel[gpu_id],(cudaStream_t)gpu_id));
  
kernelLauncher(gpu_id);


//gpuErrchk( cudaEventRecord(stop_kernel[gpu_id],(cudaStream_t)gpu_id));
//gpuErrchk( cudaEventSynchronize(stop_kernel[gpu_id]));
//gpuErrchk( cudaEventElapsedTime(&time[gpu_id], start_kernel[gpu_id], stop_kernel[gpu_id]));
//printf("GPU %d Time: %.2f ms\n", gpu_id, time[gpu_id]);

}




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

    if (number_of_gpus != find_number_of_gpus()) {
        cyan_start();
        cout << "INFO: Running on " << number_of_gpus << " GPUs out of " << find_number_of_gpus() << " GPUs." << endl;
        color_reset();
    }

    pheader = calculate_primes_on_cpu(pheader,pl_end_number);
    
    cout << "pheader.length: " << pheader.length << endl;

//    while(end_reached) {

    //  *************** PTHREADS LAUNCH *******************


    pthread_t *thread = new pthread_t [number_of_gpus];
    int *thread_error = new int [number_of_gpus];

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

