#include "functions.h"
#include "debugger.h"

extern PrimeHeader pheader;
extern GpuHandler gpu_data;


using namespace std;

#define WARNINGS 0

long find_number_of_gpus() {
    // System command to find number of GPUs attached 
    // find /proc/driver/nvidia/gpus -type d | wc -l

    char cmd[100] = "find /proc/driver/nvidia/gpus -type d | wc -l\0";
    array<char, 128> buffer;
    string result;
    shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) throw runtime_error("popen() failed!");
    while (!feof(pipe.get())) {
        if (fgets(buffer.data(), 128, pipe.get()) != nullptr)
            result += buffer.data();
    }
    long number_of_gpus = (long)stoi(result);
    number_of_gpus--; // The systems command returns a value which is
    // one more than the actual number of GPUs.
    return (number_of_gpus);

    // Function Complete --KTB
}



void start_info() {
    // Will print all the stats about the program like
    // Number of GPU being used.
    // End Number being Calculated, and so on.

    green_start();
    cout << "\n\n\n\n\n\n\n\n\n\nProgram Start\n";
    color_reset();

}



void end_info() {
    // Statistics about the program goes here


    cout << endl<< endl<< endl;
}



void iteration_info() {
    // Statistics about every iteration of the program goes here


}

// Launch the kernel:

void kernelLauncher(int gpu_id) {

    
    
    uint64_cu IL_len =  gpu_data.IL_end - gpu_data.IL_start;
    
    int total_gpus=gpu_data.gpus;
	// Round off the number of GPUs to the next lower power of 2:
	// for(int i=0; i<10; i++) {
	// 	if(pow(2,i) > gpu_data->gpus)
    //         total_gpus = pow(2, i-1);
	// 		break;
	// }

    int *d_IL = NULL;
    uint64_cu *d_PL = NULL;
    uint64_cu *d_startPrimelist;
    uint64_cu *d_splitILsize;
    uint64_cu *d_elementsPerSplit;

	// Select the device:
	gpuErrchk( cudaSetDevice(gpu_id) );

	// Calculate memory sizes required:
	uint64_cu elementsPerSplit = IL_len / total_gpus;			// WARNING: 'total_gpus' should be a power of 2 (code added for this check)
	uint64_cu splitILsize = (elementsPerSplit / (sizeof(uint64_cu) * 8)); 				// Confirm during code integration whether a '+1' is needed in the end.
	uint64_cu size_PL = (pheader.length) * sizeof(uint64_cu);

	// Space for device copies:
	gpuErrchk( cudaMalloc((void **) &d_IL, splitILsize));
	gpuErrchk( cudaMalloc((void **) &d_PL, size_PL));
    gpuErrchk( cudaMalloc((void **) &d_startPrimelist, sizeof(uint64_cu)) );
    gpuErrchk( cudaMalloc((void **) &d_splitILsize, sizeof(uint64_cu)) );
    gpuErrchk( cudaMalloc((void **) &d_elementsPerSplit, sizeof(uint64_cu)) );

    // Calculate the start value of I/P list for kernel of current GPU:
    uint64_cu c_startPrimelist = gpu_id * elementsPerSplit;                                // uint64_cu conflict

    
	// Copy the data to the device (GPU):
	gpuErrchk( cudaMemcpy(d_PL, pheader.primelist, size_PL, cudaMemcpyHostToDevice) );
    gpuErrchk( cudaMemcpy(d_startPrimelist, &c_startPrimelist, sizeof(uint64_cu), cudaMemcpyHostToDevice) );
    gpuErrchk( cudaMemcpy(d_splitILsize, &splitILsize, sizeof(uint64_cu), cudaMemcpyHostToDevice) );
    gpuErrchk( cudaMemcpy(d_elementsPerSplit, &elementsPerSplit, sizeof(uint64_cu), cudaMemcpyHostToDevice) );

    uint64_cu PL_len = pheader.length;

    // Launch the GPU kernel:
    cout << "splitILsize: "<< splitILsize << endl;
    cout << "elementsPerSplit: "<< elementsPerSplit << endl;
    cout << "c_startPrimelist: "<< c_startPrimelist << endl;
 
    
    
    cout << "d_IL: "<< d_IL << endl;
    cout << "d_PL: "<< d_PL << endl;
    cout << "d_startPrimelist: "<< d_startPrimelist << endl;
    cout << "d_splitILsize: "<< d_splitILsize << endl;
    cout << "d_elementsPerSplit: "<< d_elementsPerSplit << endl;
    
    

	prime_generator<<<(PL_len/THREADS_PER_BLOCK) + 1 , THREADS_PER_BLOCK>>>(d_IL, d_PL, d_startPrimelist, d_splitILsize, d_elementsPerSplit);

}



/* NOTES:
1) Finalize the function parameters. They vary across APIs. (kernel launcher)
*/



PrimeHeader calculate_primes_on_cpu(PrimeHeader pheader, uint64_cu pl_end_number, ) {
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
    printf("CPU Time: %.2f ms till end prime number: %llu\n", time, pl_end_number);


    // Count Total Primes
    uint64_cu small_sieve_counter = 0;
    for (uint64_cu i = 2; i <= pl_end_number; i++) {
        if (small_sieve[i] == true) {
            //cout << i << " "; // To display prime numbers
            small_sieve_counter++;
        }
    }
    //cout << endl;

    total_primes += small_sieve_counter;
    if (DEBUG >= 1) {
        cout << "Total Primes Calculated on CPU: " << small_sieve_counter << endl;
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

}