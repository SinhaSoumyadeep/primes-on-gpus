#include<stdio.h>
#include<stdlib.h>

int generateInitialPrimes(int *PL, int initialPrimesRange);

int main() {
	int *a, *PL;
	generateInitialPrimes(PL, 100);

	return 0;
	
}


int generateInitialPrimes(int *PL, int initialPrimesRange) {
	int count = 0;
	int intialTempArray[initialPrimesRange];
	
	for(int i=0; i<initialPrimesRange; i++) {
		intialTempArray[i] = 1;
	}

	for(int i=2; i*i <= initialPrimesRange; i++) {
		for(int j=2*i; j <= initialPrimesRange; j=j+i) {
				intialTempArray[j] = 0;
		}
	}
	
	for(int i=2; i<=initialPrimesRange; i++) {
		int num = intialTempArray[i];
		if(num == 1) {
			printf("%d  ", i);	
			count++;
		}
	}
	printf("\nCount = %d", count);
}
