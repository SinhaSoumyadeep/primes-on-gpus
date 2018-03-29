#include <stdio.h>
#include <stdlib.h>

typedef unsigned long long int uint64_cu;
#define INTSIZE sizeof(uint64_cu)

const char* PRIME_FILENAME = "diskprime.txt";
FILE* fout = NULL;

typedef struct PrimeHeader{
    uint64_cu lastMaxNo;
    uint64_cu length;
}PrimeHeader;

void logError(const char* errMesg){
    fprintf(stderr,"%s %d , %s\n", __FILE__, __LINE__,errMesg);
}

void printList(uint64_cu* ilist, uint64_cu len){
    printf("\n(START, length-> %llu)\n", len);
    for(uint64_cu index=0; index<len ; index++){
        printf("%llu ",ilist[index]);
    }
    printf("\nEND \n");
}

void openFile(){
    fout = fopen(PRIME_FILENAME,"w");
    if(!fout){
        logError("error opening disk file for primes");
        exit(1);
    }
}

void closeFile(){
    fclose(fout);
}

void writePrimes(uint64_cu primes[], uint64_cu length, uint64_cu lastNo){
    if(!fout){
        logError("need to open file first before writing");
        exit(1);
    }

    PrimeHeader hdr;
    hdr.lastMaxNo = lastNo;
    hdr.length = length;

    fwrite(&hdr, sizeof(PrimeHeader), 1, fout);
    fwrite(primes, INTSIZE, length, fout );
}


void readPrimes(){
    FILE* fin = fopen(PRIME_FILENAME,"r");
    PrimeHeader hdr;
    uint64_cu* parr;
    while(!feof(fin)){
        //fscanf(fin, "%d",&len);
        uint64_cu nread = fread(&hdr, sizeof(PrimeHeader), 1, fin);
        if(nread == 0)break;
        printf("\nnread %llu ",nread);
        printf("\tlastMaxNo-> %llu ",hdr.lastMaxNo);
        printf("\tlength -> %llu ",hdr.length);
        parr = (uint64_cu*) malloc(hdr.length*INTSIZE);
        uint64_cu nreadArr = fread(parr,INTSIZE,hdr.length,fin);
        if(nreadArr == 0){
            printf("SOMETHING NOT WRITE WITH FILE, %llu primes were expected but 0 found!!",hdr.length);
        }
        printf("\t %llu",nreadArr);
        printList(parr,hdr.length);
    }
}
