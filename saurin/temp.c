#include<stdio.h>

#define LEN_IL 100
#define LEN_INITIAL_PRIMES 4
#define THREADS_PER_BLOCK 32

int main() {
	int *IL, *PL;
	int *d_IL, *d_PL;

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
		IL[i] = 0;
	}


	
	int *result = malloc(sizeof(size_IL));


	return 0;
}



