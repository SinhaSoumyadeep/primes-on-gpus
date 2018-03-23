#include <stdio.h>
#include <stdlib.h>

#define EXECCPU 0

#define block_size   32
#define vector_size  1000000000

#define ROWS 3000
#define K 4000
#define COLS 5000
#define INTSIZE sizeof(unsigned int)
#define BLOCK_SIZE 32 

__global__ void matMult(int* a, int* b, int* res,unsigned  int rows, unsigned int k, unsigned int cols){
    unsigned int r = blockIdx.y * blockDim.y + threadIdx.y;
    unsigned int c = blockIdx.x * blockDim.x + threadIdx.x;

    unsigned int sum = 0;

    if(r< rows && c< cols){
        for(int x=0; x<k; x++){
            sum += a[r*k +x] + b[x*cols + c]; 
        }
        res[r*cols + c] = sum;
    }
}

int main( void ) { 

    // Set device that we will use for our cuda code
    // It will be either 0 or 1
    cudaSetDevice(1);

    srand(time(NULL));

    // Time Variables
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);

    // Express matrix elements as 1 dimension
    unsigned int aSize =  ROWS * K * INTSIZE;
    unsigned int bSize =  K * COLS* INTSIZE;
    unsigned int cSize =  ROWS * COLS * INTSIZE;

    int *a, *b, *c_cpu, *c_gpu;
    cudaMallocHost((void**)&a,aSize);
    cudaMallocHost((void**)&b,bSize);
    cudaMallocHost((void**)&c_cpu,cSize);
    cudaMallocHost((void**)&c_gpu,cSize);

    // Pointers in GPU memory
    int *dev_a;
    int *dev_b;
    int *dev_c;

    // fill the arrays 'a' and 'b' on the CPU
    for(int r=0; r<ROWS; r++){
        for(int c=0; c<K; c++){
            a[ r*K + c] = rand()%10;
        }
    }

    for(int r=0; r<K; r++){
        for(int c=0; c<COLS; c++){
            b[ r*COLS + c ] = rand()%10;
        }
    }

    //
    // CPU Calculation
    //////////////////

    printf("Running sequential job.\n");
    cudaEventRecord(start,0);

    if(EXECCPU){
        // Calculate C in the CPU
        for(unsigned int r=0; r<ROWS; r++){
            for(unsigned int c=0; c<COLS; c++){

                int sum = 0; 
                for(int k=0; k<K;k++){
                    sum +=  a[r*K + k] + b[k*COLS + c];
                }
                c_cpu[r*COLS + c] = sum;
            }
        }
    }

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    printf("\tSequential Job Time: %.2f ms\n", time);


    // allocate the memory on the GPU
    cudaMalloc( (void**)&dev_a,  aSize);
    cudaMalloc( (void**)&dev_b,  bSize);
    cudaMalloc( (void**)&dev_c,  cSize);

    // copy the arrays 'a' and 'b' to the GPU
    cudaMemcpy( dev_a, a, aSize, cudaMemcpyHostToDevice );
    cudaMemcpy( dev_b, b, bSize, cudaMemcpyHostToDevice );

    //
    // GPU Calculation
    ////////////////////////
    printf("Running parallel job.\n");

    unsigned int gridRows =  (ROWS + BLOCK_SIZE - 1)/ BLOCK_SIZE; 
    unsigned int gridCols =  (COLS+ BLOCK_SIZE - 1)/ BLOCK_SIZE; 

    dim3 grids(gridCols, gridRows);
    dim3 blocks(BLOCK_SIZE, BLOCK_SIZE);

    cudaEventRecord(start,0);
    matMult<<<grids, blocks>>>(dev_a, dev_b, dev_c, ROWS, K, COLS);

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    printf("\tParallel Job Time: %.2f ms\n", time);

    cudaMemcpy( c_gpu, dev_c, cSize, cudaMemcpyDeviceToHost);

    if(EXECCPU){
        // compare the results
        int error = 0;
        for(unsigned int r=0; r<ROWS; r++){
            for(unsigned int c=0; c<COLS; c++){
                if (c_cpu[r*COLS + c] != c_gpu[r*COLS + c]){
                    error = 1;
                    break;
                }
            }
        }

        if (error == 0){
            printf ("Correct result. No errors were found.\n");

        }
    }

    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    cudaFreeHost(a);
    cudaFreeHost(b);
    cudaFreeHost(c_cpu);
    cudaFreeHost(c_gpu);

    return 0;
}


