#include<stdio.h>

__global__ void calcPrimes(int *d_IL, int *d_PL, int numOfPrimes, int lenInputList);

#define LEN_IL 100
#define LEN_INITIAL_PRIMES 4
#define THREADS_PER_BLOCK 32

int main() {
	int *IL, *PL;
	int *d_IL, *d_PL;
	int count = 0;

	int size_IL = LEN_IL * sizeof(int);
	int size_PL = LEN_INITIAL_PRIMES * sizeof(int);

	// Space for device copies:
	cudaMalloc((void **) &d_IL, size_IL);
	cudaMalloc((void **) &d_PL, size_PL);

	// Space for host copies:
	IL = (int*) malloc(LEN_IL * sizeof(int));
	PL = (int*) malloc(LEN_INITIAL_PRIMES * sizeof(int));

	//Initialize Primes list:
	PL[0] = 2;
	PL[1] = 3;
	PL[2] = 5;
	PL[3] = 7;

	// Initialize Input list: 0 -> Not prime:
	for(int i=0; i<LEN_IL; i++) {
		IL[i] = 1;
	}

	// Copying the data to the device (GPU):
	cudaMemcpy(d_IL, IL, size_IL, cudaMemcpyHostToDevice);
	cudaMemcpy(d_PL, PL, size_PL, cudaMemcpyHostToDevice);

	// Launching the kernel:
	calcPrimes<<<(LEN_INITIAL_PRIMES/THREADS_PER_BLOCK) + 1, THREADS_PER_BLOCK>>> (d_IL, d_PL, LEN_INITIAL_PRIMES, LEN_IL);

	int *result = (int*) malloc(size_IL);

	// Copy the result back to the host:
	cudaMemcpy(result, d_IL, size_IL, cudaMemcpyDeviceToHost);

	// Output the existing primes:
	printf("\nExisting (old) Primes List:\n");
	for(int i=0; i<LEN_INITIAL_PRIMES; i++) {
		printf("%d\t", PL[i]);
	}
	printf("\n");

	// Output the new calculated primes: (1 -> Prime)
	printf("\nNew Primes List:\n");
	for(int i=PL[LEN_INITIAL_PRIMES-1]+1; i < LEN_IL; i++) {
		if(result[i] == 1) {
			printf("%d\t", i);
			count++;
		}
	}
	printf("\n");
	printf("Number of primes found = %d\n\n", count);

	// Free memory:
	free(IL);
	free(PL);
	free(result);
	cudaFree(d_IL);
	cudaFree(d_PL);

	return 0;
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


