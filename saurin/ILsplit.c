
typedef unsigned long long int dataType;


// Launch the kernel:

void kernelLauncher(int gpus, int gpu_sel, dataType IL_len, dataType* PL, dataType PL_len) {

	// Round off the number of GPUs to the next lower power of 2:
	for(int i=0; i<10; i++) {
		if(pow(2,i) > gpus) 
			gpus = pow(2, i-1);
			break;
	}

	int *d_IL = NULL, *d_PL = NULL;

	// Select the device:
	cudaSetDevice(gpu_sel);

	// Calculate memory sizes required:
	dataType elementsPerSplit = IL_len / gpus;											// WARNING: 'gpus' should be a power of 2 (code added for this check)
	dataType splitILsize = (elementsPerSplit / (sizeof(dataType) * 8)); 				// Confirm during code integration whether a '+1' is needed in the end.
	dataType PLsize = PL_len * sizeof(dataType);

	// Space for device copies:
	cudaMalloc((void **) &d_IL, splitILsize);
	cudaMalloc((void **) &d_PL, PLsize);

	// Copy the data to the device (GPU):
	cudaMemcpy(d_PL, PL, size_PL, cudaMemcpyHostToDevice);

	// Calculate the start value of I/P list for kernel of current GPU:
	dataType d_startPrimelist = gpu_sel * elementsPerSplit;								// Datatype conflict

	// Launch the GPU kernel:
	prime_generator<<<(PL_len/THREADS_PER_BLOCK) + 1 , THREADS_PER_BLOCK>>>(d_IL, d_PL, d_startPrimelist, splitILsize, elementsPerSplit);

}



/* NOTES:
1) Finalize the function parameters. They vary across APIs. (kernel launcher)
*/
