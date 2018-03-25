#include<stdio.h>
#include<stdlib.h>

#define LEN_INITIAL_PRIMES 700

int generateInitialPrimes(int *tempPL, int **PL, int initialPrimesRange);

int main() {
	int *a, *tempPL, *PL;
		
	int primesCount = generateInitialPrimes(tempPL, &PL, LEN_INITIAL_PRIMES);

	printf("\nThe initial primes calculated are:\n");
	for(int i=0; i<primesCount; i++) {
		printf("%d  ", PL[i]);
	}
	printf("\n\nCount of initial primes = %d\n\n", primesCount);
	
	return 0;
	
}	


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
