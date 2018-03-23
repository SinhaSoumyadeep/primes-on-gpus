#include <stdio.h>
#include <stdlib.h>


#define INTSIZE sizeof(unsigned int)

void printList(int* ilist, int len){
    printf("\n(START, length-> %d)\n", len);
    for(int index=0; index<len ; index++){
        printf("%d ",ilist[index]);
    }
    printf("\nEND \n");
}

int main( void ) { 
    FILE* fin = fopen("pdata.txt","r");

    int len ;
    int* parr;
    //fread(&len,INTSIZE,1,fin);

    while(!feof(fin)){
        //fscanf(fin, "%d",&len);
        int nread = fread(&len, INTSIZE, 1, fin);
        if(nread == 0)break;
        printf("\nnread %d ",nread);
        printf("\tlen -> %d ",len);
        parr = (int*) malloc(len*INTSIZE);
        int nreadArr = fread(parr,INTSIZE,len,fin);
        if(nreadArr == 0){
            printf("SOMETHING NOT WRITE WITH FILE, %d primes were expected but 0 found!!",len);
        }
        printf("\t %d",nreadArr);
        printList(parr,len);
    }
}
