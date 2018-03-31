
typedef unsigned long long int dataType;


void kernelLauncher(int gpus, int gpu_sel, dataType ILsize, dataType PL, dataType PLsize) {
	int *d_IL = NULL, *d_PL = NULL;

	cudaSetDevice(gpu_sel);


	// Space for device copies:
	int sizeIL = (ILsize / gpus / sizeof(dataType)) + 1;
	cudaMalloc((void **) &d_IL, ILsize);
	cudaMalloc((void **) &d_PL, PLsize);

	cudaMemcpy(d_PL, PL, size_PL, cudaMemcpyHostToDevice);

	prime_generator<<<(numOfInitialPrimes/THREADS_PER_BLOCK) + 1 , THREADS_PER_BLOCK>>> 
							\(d_IL, d_IL, dataType* d_startPrimelist, dataType* d_total_inputsize, dataType* d_number_of_primes);




}
