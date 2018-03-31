#include <stdio.h>
#include <time.h>

int generateInitialPrimes(int *intialTempArray, int **PL, int initialPrimesRange);
__global__ void calcPrimes(int *d_IL, int *d_PL, int numOfPrimes, int lenInputList);

#define LEN_IL 1000000
#define LEN_INITIAL_PRIMES 1000
#define THREADS_PER_BLOCK 32

int main() {
	int *IL = NULL, *PL = NULL, *tempPL = NULL;
	int *d_IL = NULL, *d_PL = NULL;
	cudaEvent_t start, stop;
	float time;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	clock_t t;
	//int count = 0;

	t = clock();
	int numOfInitialPrimes = generateInitialPrimes(tempPL, &PL, LEN_INITIAL_PRIMES);
	t = clock() - t;
	double time_taken = ((double)t)/CLOCKS_PER_SEC; 			// in seconds

	// Print the initial range of primes calculated in the CPU, which will be passed to the GPU:
	printf("\nThe initial primes calculated are:\n");
	for(int i=0; i < numOfInitialPrimes; i++) {
		printf("%d  ", PL[i]);
	}
	printf("\nNumber of initial primes = %d\n\n", numOfInitialPrimes);

	// Space for host copies:
	IL = (int*) malloc(LEN_IL * sizeof(int));
	//PL = (int*) malloc(LEN_INITIAL_PRIMES * sizeof(int));		   		// Allocated in the generate function instead


	int size_IL = LEN_IL * sizeof(int);
	int size_PL = numOfInitialPrimes * sizeof(int);

	// Initialize Input list: 0 -> Not prime:
	for(int i=0; i<LEN_IL; i++) {
		IL[i] = 1;
	}

	// Space for device copies:
	cudaMalloc((void **) &d_IL, size_IL);
	cudaMalloc((void **) &d_PL, size_PL);

	// Copying the data to the device (GPU):
	cudaMemcpy(d_IL, IL, size_IL, cudaMemcpyHostToDevice);
	cudaMemcpy(d_PL, PL, size_PL, cudaMemcpyHostToDevice);			

	// Launching the kernel and measuring the time taken:
	cudaEventRecord(start, 0);
	calcPrimes<<<(numOfInitialPrimes/THREADS_PER_BLOCK) + 1, THREADS_PER_BLOCK>>> (d_IL, d_PL, numOfInitialPrimes, LEN_IL);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&time, start, stop);

	// Space allocated to store the modified form of input array, with marking for prime and non-prime:
	int *result = (int*) malloc(size_IL);

	// Copy the result back to the host:
	cudaMemcpy(result, d_IL, size_IL, cudaMemcpyDeviceToHost);

	// Extract indexes of primes in 'result' to get the actual new prime numbers:
	printf("********* New Primes List **********\n");
	int *newPrimes = (int*)malloc(LEN_IL / 4 * sizeof(int));			// Arbitrary size; which is '1/4th' of numbers list size
	int newPrimesCount = 0;
	for(int i=LEN_INITIAL_PRIMES; i<LEN_IL; i++) {
		int num = result[i];
		if(num == 1) {
			newPrimes[newPrimesCount] = num;
			newPrimesCount++;
			printf("%d  ", i);
		}
	}
	printf("\n\nNumber of new primes found = %d\n\n", newPrimesCount);

	printf("Time taken to find initial primes on CPU = %f ms\n", time_taken * 1000);
	printf("Parallel Job time for current iteration = %f ms\n\n", time);

	// Free memory:
	cudaFree(d_IL);
	cudaFree(d_PL);
	free(IL);
	free(PL);
	free(result);
	free(newPrimes);

	return 0;
}


// Generate initial prime numbers in the CPU:
// Returns: Number of primes found from 1 to 'LEN_INITIAL_PRIMES' 
int generateInitialPrimes(int *intialTempArray, int **PL, int initialPrimesRange) {
	int primesCount = 0;
	//int intialTempArray[initialPrimesRange];
	intialTempArray = (int*) malloc(LEN_INITIAL_PRIMES * sizeof(int));
	*PL = (int*) malloc(LEN_INITIAL_PRIMES / 2 * sizeof(int));				// Taking half size of initial (full) primes array
	
	// Initialize array with all 1's:
	for(int i=0; i < initialPrimesRange; i++) {
		intialTempArray[i] = 1;
	}

	// Make non-primes as '0':
	for(int i=2; i*i <= initialPrimesRange; i++) {
		for(int j=2*i; j <= initialPrimesRange; j=j+i) {
				intialTempArray[j] = 0;
		}
	}
	
	// Store the actual primes in a new array which will be copied later to the device (converting 'prime num indexes' to 'prime numbers') :
	for(int i=2; i<=initialPrimesRange; i++) {
		if(intialTempArray[i] == 1) {
			(*PL)[primesCount] = i;
			primesCount++;
		}
	}

	free(intialTempArray);
	return primesCount;
}



// GPU Kernel (Parallel Processing):
__global__ void calcPrimes(int *d_IL, int *d_PL, int numOfPrimes, int lenInputList) {
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if(index < numOfPrimes) {
		for(int i = d_PL[numOfPrimes-1]+1; i < lenInputList; i++) {
			if(i % d_PL[index] == 0) {
				d_IL[i] = 0;
			}
		}
	}
}


