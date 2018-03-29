#include <stdio.h>
#include <stdlib.h>
#include "primedisk.h"

typedef unsigned long long int uint64_cu;
#define INTSIZE sizeof(uint64_cu)

int main( void ) { 
    readPrimes();
    /*
    FILE* fin = fopen("pdata.txt","r");

    uint64_cu len ;
    uint64_cu* parr;
    //fread(&len,INTSIZE,1,fin);

    while(!feof(fin)){
        //fscanf(fin, "%d",&len);
        uint64_cu nread = fread(&len, INTSIZE, 1, fin);
        if(nread == 0)break;
        printf("\nnread %llu ",nread);
        printf("\tlen -> %llu ",len);
        parr = (uint64_cu*) malloc(len*INTSIZE);
        uint64_cu nreadArr = fread(parr,INTSIZE,len,fin);
        if(nreadArr == 0){
            printf("SOMETHING NOT WRITE WITH FILE, %llu primes were expected but 0 found!!",len);
        }
        printf("\t %llu",nreadArr);
        printList(parr,len);
    }
    */
}
