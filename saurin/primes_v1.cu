#include <stdio.h>

int generateInitialPrimes(int *intialTempArray, int **PL, int initialPrimesRange);
__global__ void calcPrimes(int *d_IL, int *d_PL, int numOfPrimes, int lenInputList);

#define LEN_IL 10000
#define LEN_INITIAL_PRIMES 100
#define THREADS_PER_BLOCK 32

int main() {
	int *IL = NULL, *PL = NULL, *tempPL = NULL;
	int *d_IL, *d_PL;
	//int count = 0;

	// Space for host copies:
	IL = (int*) malloc(LEN_IL * sizeof(int));
	PL = (int*) malloc(LEN_INITIAL_PRIMES * sizeof(int));

	int numOfInitialPrimes = generateInitialPrimes(tempPL, &PL, LEN_INITIAL_PRIMES);

	// Print the initial range of primes calculated in the CPU, which will be passed to the GPU:
	printf("\nThe initial primes calculated are:\n");
	for(int i=0; i < numOfInitialPrimes; i++) {
		printf("%d  ", PL[i]);
	}
	printf("\n\nCount of initial primes = %d\n\n", numOfInitialPrimes);


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
	cudaMemcpy(d_PL, PL, size_PL, cudaMemcpyHostToDevice);			/// NEEDS CORRECTION, 'PL' has length of 'LEN_INITIAL_PRIMES' and not 'size_PL'

	// Launching the kernel:
	calcPrimes<<<(numOfInitialPrimes/THREADS_PER_BLOCK) + 1, THREADS_PER_BLOCK>>> (d_IL, d_PL, numOfInitialPrimes, LEN_IL);  // CHECK if it should be 'numOfInitialPrimes' or 'LEN_INITIAL_PRIMES'

	// Space allocated to store the modified form of input array, with marking for prime and non-prime:
	int *result = (int*) malloc(size_IL);

	// Copy the result back to the host:
	cudaMemcpy(result, d_IL, size_IL, cudaMemcpyDeviceToHost);

	// Extract indexes of primes in 'result' to get the actual new prime numbers:
	printf("New Primes List:\n");
	int *newPrimes = (int*)malloc(LEN_IL / 4 * sizeof(int));
	int newPrimesCount = 0;
	for(int i=LEN_INITIAL_PRIMES; i<LEN_IL; i++) {
		int num = result[i];
		if(num == 1) {
			newPrimes[newPrimesCount] = num;
			newPrimesCount++;
			printf("%d  ", i);
		}
	}
	printf("\nNumber of new primes found = %d\n\n", newPrimesCount);



	/* Output the existing primes:										// SECTION NEEDS CHANGES
	printf("\nExisting (old) Primes List:\n");
	for(int i=0; i<numOfInitialPrimes; i++) {
		printf("%d\t", PL[i]);
	}
	printf("\n");
	*/

/*
	// Output the new calculated primes: (1 -> Prime)					// SECTION NEEDS CHANGES
	printf("New Primes List:\n");
	for(int i=PL[numOfInitialPrimes-1]+1; i < LEN_IL; i++) {
		if(result[i] == 1) {
			printf("%d\t", i);
			count++;
		}
	}
	printf("\n");
	printf("Number of new primes found = %d\n\n", count);
*/
	// Free memory:
	free(IL);
	free(PL);
	free(result);
	cudaFree(d_IL);
	cudaFree(d_PL);

	return 0;
}



// Returns: Count of primes
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
	return primesCount;
}


	
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


