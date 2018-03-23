#include<stdio.h>
#include<stdlib.h>

#define LEN_INITIAL_PRIMES 200

int generateInitialPrimes(int *PL, int initialPrimesRange);

int main() {
	int *a, *PL;
	//PL = (int*) malloc(LEN_INITIAL_PRIMES * sizeof(int));
	int count = generateInitialPrimes(PL, LEN_INITIAL_PRIMES);

	return 0;
	
}


int generateInitialPrimes(int *intialTempArray, int initialPrimesRange) {
	int count = 0;
	//int intialTempArray[initialPrimesRange];
	intialTempArray = (int*) malloc(LEN_INITIAL_PRIMES * sizeof(int));
	
	// Initialize array with all 1's:
	for(int i=0; i<initialPrimesRange; i++) {
		intialTempArray[i] = 1;
	}

	// Make non-primes as '0':
	for(int i=2; i*i <= initialPrimesRange; i++) {
		for(int j=2*i; j <= initialPrimesRange; j=j+i) {
				intialTempArray[j] = 0;
		}
	}
	
	// Print the initial primes:
	printf("\n Initial Primes are: \n");
	for(int i=2; i<=initialPrimesRange; i++) {
		int num = intialTempArray[i];
		if(num == 1) {
			printf("%d  ", i);	
			count++;
		}
	}
	printf("\n\nCount of initial primes = %d\n", count);
	return count;
}
