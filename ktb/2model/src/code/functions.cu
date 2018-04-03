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

void kernelLauncher(int gpu_id) {
    /*
    Convention for naming variables:
    len: relates to number of elements
    size: relates to size of memory
    */

    uint64_cu IL_len =  gpu_data.IL_end - gpu_data.IL_start + 1;
    int total_gpus = gpu_data.gpus;
    uint64_cu PL_len = pheader.length;

    // Declare all pointers to GPU:
    int *d_IL;                                                                      // Should be change to uint64_cu* 
    uint64_cu *d_PL, *d_startInputlist, *d_elementsPerILSplit, *d_PL_len;

    // Calculate memory sizes required:
    uint64_cu size_PL = (pheader.length) * sizeof(uint64_cu);
    uint64_cu elementsPerILSplit = IL_len / total_gpus;                               // WARNING: 'total_gpus' should be a power of 2 (code added for this check)
    
    // Calculate number of blocks (of 'int' type) required to store IL for a specific GPU (i.e. after splitting original IL):
    uint64_cu blocksFor_splitIL = (elementsPerILSplit / (sizeof(int) * 8));                 // Change the sizeof(param) to int / uint64_cu as per decision
    blocksFor_splitIL = (elementsPerILSplit % (sizeof(uint64_cu) * 8)) ? blocksFor_splitIL + 1 : blocksFor_splitIL;     // Taking ceiling of decimal (which will mean that last few bits will be unused by us)

    // Space for device copies:
    gpuErrchk( cudaMalloc((void **) &d_IL, blocksFor_splitIL*sizeof(int)));
    gpuErrchk( cudaMalloc((void **) &d_PL, size_PL));
    gpuErrchk( cudaMalloc((void **) &d_startInputlist, sizeof(uint64_cu)) );
    //gpuErrchk( cudaMalloc((void **) &d_blocksFor_splitIL, sizeof(uint64_cu)) );
    gpuErrchk( cudaMalloc((void **) &d_elementsPerILSplit, sizeof(uint64_cu)) );
    //gpuErrchk( cudaMalloc((void **) &d_ILlenPerGPU, sizeof(uint64_cu)) );
    gpuErrchk( cudaMalloc((void **) &d_PL_len, sizeof(uint64_cu)) );

    // Calculate the start value of I/P list for kernel of current GPU:
    uint64_cu startInputlist = (gpu_id * elementsPerILSplit) + gpu_data.IL_start;                               

    // Copy the data to the device (GPU):
    gpuErrchk( cudaMemcpy(d_PL, pheader.primelist, size_PL, cudaMemcpyHostToDevice) );
    gpuErrchk( cudaMemcpy(d_startInputlist, &startInputlist, sizeof(uint64_cu), cudaMemcpyHostToDevice) );
    //gpuErrchk( cudaMemcpy(d_blocksFor_splitIL, &blocksFor_splitIL, sizeof(uint64_cu), cudaMemcpyHostToDevice) );
    gpuErrchk( cudaMemcpy(d_elementsPerILSplit, &elementsPerILSplit, sizeof(uint64_cu), cudaMemcpyHostToDevice) );
    //gpuErrchk( cudaMemcpy(d_ILlenPerGPU, &ILlenPerGPU, sizeof(uint64_cu), cudaMemcpyHostToDevice) );
    gpuErrchk( cudaMemcpy(d_PL_len, &PL_len, sizeof(uint64_cu), cudaMemcpyHostToDevice) );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Print and Cross-check the data received by this API:
    printf("Running on GPU with ID = %d\n", gpu_id);
    printf("gpus = %llu\n", gpu_data.gpus);
    printf("size_PL = %llu bytes\n", size_PL);
    printf("IL_len = %llu\n", IL_len);
    printf("IL_start = %llu\n", gpu_data.IL_start);
    printf("IL_end = %llu\n\n", gpu_data.IL_end);
    printf("blocksFor_splitIL = %llu blocks of 'int' type\n", blocksFor_splitIL);

    printf("startInputlist = %llu\n\n", startInputlist);
    printf("elementsPerILSplit = %llu\n", elementsPerILSplit);
    printf("PL_len (= pheader.length) = %llu\n", PL_len);
   
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Select the device:
    gpuErrchk( cudaSetDevice(gpu_id) );

    // Launch the GPU kernel:
    // Should pass the 'blocksFor_splitIL' too?
    //prime_generator<<<(PL_len/THREADS_PER_BLOCK) + 1 , THREADS_PER_BLOCK>>>(d_IL, d_PL, d_startInputlist, d_blocksFor_splitIL, d_elementsPerILSplit);
    //                                                                                                        10^6-10^3/2         #168
    prime_generator<<<(PL_len/THREADS_PER_BLOCK) + 1 , THREADS_PER_BLOCK>>>(d_IL, d_PL, d_startInputlist, d_elementsPerILSplit, d_PL_len);
    

    // Allocate space on host to copy back the splitIL from device:
    int *result = (int*) malloc(blocksFor_splitIL*sizeof(int));
cout << "KTB: " << blocksFor_splitIL*sizeof(int) << "Result: " << result<<endl;
    // Copy the result back to the host:
    gpuErrchk( cudaMemcpy(result, d_IL, blocksFor_splitIL*sizeof(int), cudaMemcpyDeviceToHost) );

/*  ********** DECODING: NOT WORKING FOR NOW **************
    for(uint64_cu i=0; i<blocksFor_splitIL; i++) {
        int bitvec = result[i];
        int num = 1;
        for(int j=sizeof(int)*8; j>0; j--) {
            int value = bitvec & num ;
            if(value == num) {
                printf("%llu  ", (uint64_cu) (((uint64_cu)sizeof(int)*(uint64_cu)i*8) + (uint64_cu) j) );
                printf("Hi  ");
            }
            num = num << 1;
        }
        printf("\n");
    }
*/

    // Printing the elements of IL after GPU computation as it is (not decoding to get the prime):
//      if (gpu_id==1) {
//      for(int i=0; i<blocksFor_splitIL; i++) {
//          if (result[i] != 0)
//          printf("%d  ", result[i]);
//      }
//  }
red_start();
 cout << "*********** I am GPU: " << gpu_id << endl;
color_reset();
// SOUMYADEEP :: Needs to make sure additional unused bits in IL (after ceiling) are converted to values other than 0, 
// else they might be interpreted wrongly as primes:


    // Free GPU memory:
    cudaFree(d_IL);
    cudaFree(d_PL);
    cudaFree(d_startInputlist);
    //cudaFree(d_blocksFor_splitIL);
    cudaFree(d_elementsPerILSplit);
    cudaFree(d_PL_len);
}



/* NOTES:
1) Finalize the function parameters. They vary across APIs. (kernel launcher)
*/



/* NOTES:
1) Finalize the function parameters. They vary across APIs. (kernel launcher)
*/






PrimeHeader calculate_primes_on_cpu(PrimeHeader pheader, uint64_cu pl_end_number ) {

// Time Variables
cudaEvent_t start, stop;
float time;
gpuErrchk( cudaEventCreate (&start));
gpuErrchk( cudaEventCreate (&stop));



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

    return (pheader);
}
