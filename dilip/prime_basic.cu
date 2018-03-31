#include <stdio.h>
#include <stdlib.h>
#include "primedisk.h"

#define EXECCPU 0

#define LIMIT 100

typedef unsigned long long int uint64_cu;
#define INTSIZE sizeof(uint64_cu)
#define BLOCK_SIZE 32 

uint64_cu countPrime(uint64_cu* arr, uint64_cu len){
    uint64_cu pcount = 0;
    for(uint64_cu x=0; x<len; x++){
        if(arr[x]!=0)pcount++;
    }
    return pcount;
}

void addPrimes(uint64_cu* target, uint64_cu* source,uint64_cu sourcelen){
    uint64_cu pindex = 0;
    for(uint64_cu val=0; val<sourcelen; val++){
        if(source[val]!=0){
            target[pindex] = source[val];
            pindex++;
        }
    }
}

__global__ void calcPrime(uint64_cu* primelist, uint64_cu* inputlist,uint64_cu plen, uint64_cu ilen ){

    uint64_cu ind1 = blockIdx.x * blockDim.x + threadIdx.x;
    //uint64_cu num = primelist[ind1-1];
    //uint64_cu lastno = inputlist[ilen-1];

    /*
       if(num > 99403){
       printf("calcPrime %lu --- %lu \n",num, lastno);
       }
     */

    //printf("\n threadId %llu , ilen %llu, plen %llu",ind1,ilen, plen);

    if(ind1<plen){
        uint64_cu num = primelist[ind1];
        //printf("\ncore num %llu\n",num);
        //uint64_cu lastno = inputlist[ilen-1];
        for(uint64_cu start = 0; start< ilen; start++){
            if(inputlist[start] == num) continue;
            if(inputlist[start] % num == 0){
                //printf("CROSSING %llu --- %llu \n",num, inputlist[start]);
                inputlist[start] = 0;
            }
        }
    }
}

int main( void ) { 
    cudaSetDevice(0);
    srand(time(NULL));
    // Time Variables
    cudaEvent_t start, stop;
    float time;
    cudaEventCreate (&start);
    cudaEventCreate (&stop);


    // Set device that we will use for our cuda code
    // It will be either 0 or 1

    PrimeHeader ret = readPrimes();
    uint64_cu firstLimit = ret.lastMaxNo;
    uint64_cu plen = ret.length;
    uint64_cu* primelist = ret.primelist;
    printf("\n\n ret lastMaxNo-> %llu ",ret.lastMaxNo);
    printf("\tlength -> %llu ",ret.length);
    printList(ret.primelist ,ret.length);

    printf(" \n\n>>>>>>>>>>>>>> POST FILE READ\n");
    if(ret.length == 0 ){
        // start from beginning on CPU
        firstLimit = 10;
        printf("firstLimit %llu \n", firstLimit);

        uint64_cu firstLimitLen = firstLimit-1;
        printf("firstLimitLen %llu \n", firstLimitLen);
        uint64_cu* firstLimitArray = (uint64_cu*) malloc(firstLimitLen*INTSIZE);

        for(uint64_cu x=2; x<= firstLimit; x++){
            //printf(" %d %d \t",x-2,x);
            firstLimitArray[x-2] = x;
        }
        //printList(firstLimitArray, firstLimitLen);

        cudaEventRecord(start,0);

        for(uint64_cu val = 0; val < firstLimitLen/2; val++){
            uint64_cu num = firstLimitArray[val];
            if(num==0) continue;
            //printf("\n fixing prime %llu ", num);
            for(uint64_cu index=val+1; index< firstLimitLen; index++){
                //printf(" %llu, %llu ", num, firstLimitArray[index]);
                if(firstLimitArray[index]%num== 0 && firstLimitArray[index]!=0)
                    firstLimitArray[index] = 0;
            }
        }
        cudaEventRecord(stop,0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&time, start, stop);
        //printList(firstLimitArray, firstLimitLen);
        printf("\nSerial Job Time: %.2f ms\n", time);
        //printList(firstLimitArray, firstLimitLen);
        uint64_cu pcount = countPrime(firstLimitArray, firstLimitLen);
        //printf("first round primes %llu",pcount);

        plen = pcount;
        primelist = (uint64_cu*) malloc(pcount*INTSIZE);
        addPrimes(primelist, firstLimitArray, firstLimitLen);
        writePrimes(primelist,plen,firstLimit);
    } 

    while(firstLimit < LIMIT*LIMIT){
        printf("\nfirstLimit %llu",firstLimit);
        uint64_cu CUR_MAX = firstLimit;

        uint64_cu startNo = CUR_MAX+1;
        uint64_cu endNo = CUR_MAX * CUR_MAX; 

        uint64_cu range = endNo - CUR_MAX;
        printf("\n######################## startNo %llu , endNo %llu  ########################", startNo, endNo);
        //printf("\nrange %llu\n",range);
        uint64_cu* inputlist = (uint64_cu*) malloc(range*INTSIZE);

        for(uint64_cu index = 0; index < range; index++){
            inputlist[index] = index + startNo;
        }

        //printList(inputlist,range);

        // Pointers in GPU memory
        uint64_cu* dev_ilist;
        uint64_cu* dev_plist;

        // allocate the memory on the GPU
        cudaMalloc( (void**)&dev_plist,  plen*INTSIZE);
        cudaMalloc( (void**)&dev_ilist,  range*INTSIZE);

        cudaMemcpy( dev_plist, primelist, plen*INTSIZE, cudaMemcpyHostToDevice );
        cudaMemcpy( dev_ilist, inputlist, range*INTSIZE, cudaMemcpyHostToDevice );

        //
        // GPU Calculation
        ////////////////////////
        uint64_cu gridSize =  ((plen + BLOCK_SIZE - 1)/ BLOCK_SIZE) + 1; 
        cudaEventRecord(start,0);
        calcPrime<<<gridSize, BLOCK_SIZE>>>(dev_plist, dev_ilist, plen, range);

        cudaEventRecord(stop,0);
        cudaEventSynchronize(stop);
        cudaEventElapsedTime(&time, start, stop);

        cudaMemcpy( inputlist, dev_ilist, range*INTSIZE, cudaMemcpyDeviceToHost);
        printf("\n\nUpto %llu , Parallel Job Time: %.2f ms\n",endNo ,time);
        //printList(inputlist,range);

        // 2) WRITE primes from INPUTLIST
        uint64_cu ilistPrimeCount = countPrime(inputlist,range);
        printf("ilistPrimeCount %llu \n",ilistPrimeCount);
        uint64_cu* ilistprimes = (uint64_cu*) malloc(ilistPrimeCount*INTSIZE);
        addPrimes(ilistprimes, inputlist, range);
        writePrimes(ilistprimes,ilistPrimeCount,endNo);
        //printList(ilistprimes,ilistPrimeCount);

        // APPEND LOGIC
        uint64_cu totalPrimes = plen + ilistPrimeCount;
        printf("\n%llu totalPrimes for Upto %llu",totalPrimes,endNo);
        uint64_cu* primeNewArray = (uint64_cu*) malloc(totalPrimes*INTSIZE);
        memcpy(primeNewArray,primelist,plen*INTSIZE);
        memcpy(primeNewArray+plen, ilistprimes, ilistPrimeCount*INTSIZE);
        //printList(primeNewArray, totalPrimes);

        primelist = primeNewArray;
        plen = totalPrimes;
        firstLimit = endNo;
        fflush(stdout);
    }

    printf("\n**** MAIN END ***\n");
    return 0;
}
