#include <stdio.h>
#include <stdlib.h>

#define EXECCPU 0

#define block_size   32
#define vector_size  1000000000

#define LIMIT 10

#define ROWS 3000
#define K 4000
#define COLS 5000
#define INTSIZE sizeof(unsigned int)
#define BLOCK_SIZE 32 

void printList(int* ilist, int len){
    printf("\n(START, length-> %d)\n", len);
    for(int index=0; index<len ; index++){
        printf(" %d",ilist[index]);
    }
    printf("\nEND \n");
}

int countPrime(int* arr, int len){
    int pcount = 0;
    for(int x=0; x<len; x++){
        if(arr[x]!=-1)pcount++;
    }
    return pcount;
}

void addPrimes(int* target, int* source, int sourcelen){
    int pindex = 0;
    for(int val=0; val<sourcelen; val++){
        if(source[val]!=-1){
            target[pindex] = source[val];
            pindex++;
        }
    }
}

__global__ void calcPrime(int* primelist, int* inputlist,unsigned  int plen, unsigned int ilen ){

    unsigned int ind1 = blockIdx.x * blockDim.x + threadIdx.x;
    int num = primelist[ind1];
    int lastno = inputlist[ilen-1];

    //printf("%d --- %d \n",num, lastno);

    if(num<lastno){
        for(int start = 0; start< ilen; start++){
            if(inputlist[start] % num == 0){
                inputlist[start] = -1;
            }
        }
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

    int firstLimit = LIMIT;
    printf("firstLimit %d \n", firstLimit);

    int* firstLimitArray;
    int firstLimitLen = firstLimit-1;
    printf("firstLimitLen %d \n", firstLimitLen);
    cudaMallocHost( (void**)&firstLimitArray,  firstLimitLen*INTSIZE);

    for(int x=2; x<= firstLimit; x++){
        //printf(" %d %d \t",x-2,x);
        firstLimitArray[x-2] = x;
    }
    //printList(firstLimitArray, firstLimitLen);

    cudaEventRecord(start,0);

    for(int val = 0; val < firstLimitLen/2; val++){
        int num = firstLimitArray[val];
        if(num==-1) continue;
        //printf("\n fixing prime %d ", num);
        for(int index=val+1; index< firstLimitLen; index++){
            //printf(" %d, %d ", num, firstLimitArray[index]);
            if(firstLimitArray[index]%num== 0 && firstLimitArray[index]!=0)
                firstLimitArray[index] = -1;
        }
    }
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);
    printf("\nSerial Job Time: %.2f ms\n", time);

    //printList(firstLimitArray, firstLimitLen);
    int pcount = countPrime(firstLimitArray, firstLimitLen);
    printf("first round primes %d",pcount);

    int* primelist ;
    int plen = pcount;
    cudaMallocHost( (void**)&primelist,  pcount*INTSIZE);

    addPrimes(primelist, firstLimitArray, firstLimitLen);
    /*
    int pindex = 0;
    for(int val=0; val<firstLimitLen; val++){
        if(firstLimitArray[val]!=-1){
            primelist[pindex] = firstLimitArray[val];
            pindex++;
        }
    }
    printf("\n pindex -> %d", pindex);
    */

    int CUR_MAX = firstLimit;

    int startNo = CUR_MAX+1;
    int endNo = CUR_MAX * CUR_MAX; 

    int range = endNo - CUR_MAX;
    printf(" \n range %d",range);
    int* inputlist ;
    cudaMallocHost((void**)&inputlist,range*INTSIZE);

    for(int index = 0; index < range; index++){
        inputlist[index] = index + startNo;
    }

    //printList(inputlist,range);

    // Pointers in GPU memory
    int *dev_ilist;
    int *dev_plist;

    // allocate the memory on the GPU
    cudaMalloc( (void**)&dev_plist,  plen*INTSIZE);
    cudaMalloc( (void**)&dev_ilist,  range*INTSIZE);

    cudaMemcpy( dev_plist, primelist, plen*INTSIZE, cudaMemcpyHostToDevice );
    cudaMemcpy( dev_ilist, inputlist, range*INTSIZE, cudaMemcpyHostToDevice );

    //
    // GPU Calculation
    ////////////////////////
    unsigned int gridSize =  (plen + BLOCK_SIZE - 1)/ BLOCK_SIZE; 
    dim3 grids(gridSize,1);
    dim3 blocks(BLOCK_SIZE, 1);

    cudaEventRecord(start,0);
    calcPrime<<<grids, blocks>>>(dev_plist, dev_ilist, plen, range);

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start, stop);

    cudaMemcpy( inputlist, dev_ilist, range*INTSIZE, cudaMemcpyHostToDevice );
    printf("\nParallel Job Time: %.2f ms\n", time);
    printList(inputlist,range);
    return 0;
}
