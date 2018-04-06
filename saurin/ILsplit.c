
typedef unsigned long long int uint64_cu;


// Launch the kernel:

void kernelLauncher(int gpu_id) {

    
    
    uint64_cu Il_len =  gpu_data->IL_end - gpu_data->IL_start;
    
    int total_gpus;
	// Round off the number of GPUs to the next lower power of 2:
	for(int i=0; i<10; i++) {
		if(pow(2,i) > gpu_data->gpus)
            total_gpus = pow(2, i-1);
			break;
	}

    int *d_IL = NULL;
    uint64_cu *d_PL = NULL;
    uint64_cu *d_startPrimelist;
    uint64_cu *d_splitILsize;
    uint64_cu *d_elementsPerSplit;

	// Select the device:
	cudaSetDevice(gpu_id);

	// Calculate memory sizes required:
	uint64_cu elementsPerSplit = IL_len / total_gpus;			// WARNING: 'total_gpus' should be a power of 2 (code added for this check)
	uint64_cu splitILsize = (elementsPerSplit / (sizeof(uint64_cu) * 8)); 				// Confirm during code integration whether a '+1' is needed in the end.
	uint64_cu size_PL = (pheader->length) * sizeof(uint64_cu);

	// Space for device copies:
	cudaMalloc((void **) &d_IL, splitILsize);
	cudaMalloc((void **) &d_PL, size_PL);
    cudaMalloc((void **) &d_startPrimelist, sizeof(uint64_cu));
    cudaMalloc((void **) &d_splitILsize, sizeof(uint64_cu));
    cudaMalloc((void **) &d_elementsPerSplit, sizeof(uint64_cu));

    // Calculate the start value of I/P list for kernel of current GPU:
    uint64_cu c_startPrimelist = gpu_id * elementsPerSplit;                                // uint64_cu conflict

    
	// Copy the data to the device (GPU):
	cudaMemcpy(d_PL, pheader->primelist, size_PL, cudaMemcpyHostToDevice);
    cudaMemcpy(d_startPrimelist, &c_startPrimelist, sizeof(uint64_cu), cudaMemcpyHostToDevice);
    cudaMemcpy(d_splitILsize, &splitILsize, sizeof(uint64_cu), cudaMemcpyHostToDevice);
    cudaMemcpy(d_elementsPerSplit, &elementsPerSplit, sizeof(uint64_cu), cudaMemcpyHostToDevice);

    

	// Launch the GPU kernel:
	prime_generator<<<(PL_len/THREADS_PER_BLOCK) + 1 , THREADS_PER_BLOCK>>>(d_IL, d_PL, d_startPrimelist, d_splitILsize, d_elementsPerSplit);

}



/* NOTES:
1) Finalize the function parameters. They vary across APIs. (kernel launcher)
*/
