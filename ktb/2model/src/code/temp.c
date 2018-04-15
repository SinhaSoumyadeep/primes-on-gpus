#include<stdio.h>
#include<math.h>

typedef unsigned long long int uint64_cu;

void main() {

	unsigned int a[2];
	a[0] = 2863311530;
	a[1] = 1431655765;

 /*   for(int i=0; i<2; i++) {
        int bitvec = a[i];
        int num = 1;
        for(int j=sizeof(int)*8; j>0; j--) {
            int value = bitvec & num ;
            if(value==num)
            	printf("%llu ", (uint64_cu) ((sizeof(int)*i*8) + j) );
            num = num << 1;
        }
    }

*/


    for(uint64_cu i=0; i<2; i++) {
        unsigned int bitvec = a[i];
        unsigned int num = 1;
        for(unsigned int j=sizeof(int)*8; j>0; j--) {
            unsigned int value = bitvec & num ;
            if(value == num) {
                printf("%llu  ", (uint64_cu) (((uint64_cu)sizeof(int)*(uint64_cu)i*8) + (uint64_cu) j) );
//                printf("%d ", value);
            }
            num = num << 1;
        }
        printf("\n");
    }

}
