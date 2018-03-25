#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
#include<cuda.h>
#define INPUT_SIZE 100000000
#define PRIME_RANGE 1000000
#define BLOCK_SIZE 32
typedef unsigned long long int uint64_c;

void initializeInput(char* , int );
int generate_seed_primes(char*, int*, uint64_c);
void copy_seed_primes(uint64_c *,int *,int);
void print_primelist(uint64_c *, uint64_c);
void print_inputlist(uint64_c *input_list,uint64_c range);
void initializing_inputlist(uint64_c *input_list, uint64_c start,uint64_c range);
void calculatePrime(uint64_c* , uint64_c* , uint64_c ,uint64_c);
void appending_prime(uint64_c* input_list, uint64_c* prime_list, uint64_c range, uint64_c prev_number_of_primes, uint64_c number_of_primes);
uint64_c counting_primes(uint64_c*, uint64_c, uint64_c);

//KERNAL CODE GOES HERE!!


__global__ void prime_generator(uint64_c* d_input_list, uint64_c* d_prime_list, uint64_c* d_range,uint64_c* d_number_of_primes)
{


    int p= blockIdx.x * blockDim.x + threadIdx.x;
    int prime = d_prime_list[p];

        for(uint64_c i=0;i<d_range[0];i++){


                        if(d_input_list[i] % prime ==0)
                        {
                                d_input_list[i]=0;
                                
                               
                        }
                
        }



}


//KERNAL CODE ENDS HERE!!!


int main()
{


 cudaSetDevice(1);

// This code is just to generate the seed prime numbers
        int input_size=100;
        char *input;
        uint64_c n= 10 ;// seed prime list.
        int *seed_primelist;
        input=(char *)malloc(input_size*sizeof(char));
        initializeInput(input, input_size);
        seed_primelist=(int *)malloc(input_size*sizeof(int));
        int num_of_seed = generate_seed_primes(input,seed_primelist,n);
    
        uint64_c* input_list;
        uint64_c* prime_list;
        uint64_c number_of_primes= num_of_seed; 
        prime_list=(uint64_c *)malloc(number_of_primes*sizeof(uint64_c));
        copy_seed_primes(prime_list,seed_primelist,num_of_seed);

        uint64_c* d_input_list;
        uint64_c* d_prime_list;
        uint64_c* d_number_of_primes;
	uint64_c* d_range;

       
            for(int i=0;i<3;i++){


                uint64_c start=n;
                uint64_c end=pow(n,2);
                printf("CALCULATING PRIMES FROM 0 - %llu\n",end);
                uint64_c range=end-start;
                input_list=(uint64_c *)malloc(range*sizeof(uint64_c));
                initializing_inputlist(input_list,start,range);
		

		if(cudaMalloc((void **)&d_input_list,range*sizeof(uint64_c))!=cudaSuccess)
                {
                    printf("Error:  1\n");
                }
                
                if(cudaMemcpy(d_input_list,input_list,range*sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                {
                    printf("copy Error:  1\n");
                }

                if(cudaMalloc((void **)&d_prime_list,number_of_primes*sizeof(uint64_c))!=cudaSuccess)
                {
                    printf("Error:  2\n");
                }

                if(cudaMemcpy(d_prime_list,prime_list,number_of_primes*sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                {
                    printf("copy Error:  2\n");
                }

                if(cudaMalloc((void **)&d_range,sizeof(uint64_c))!=cudaSuccess)
                {
                    printf("Error:  3\n");
                }
                
                if(cudaMemcpy(d_range,&range,sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                {
                    printf("copy Error:  3\n");
                }

                if(cudaMalloc((void **)&d_number_of_primes,sizeof(uint64_c))!=cudaSuccess)
                {
                    printf("Error:  4\n");
                }
                
                if(cudaMemcpy(d_number_of_primes,&number_of_primes,sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                {
                    printf("copy Error:  4\n");
                }







              
             //   calculatePrime(input_list,prime_list,range,number_of_primes);

		prime_generator<<<43,32>>>(d_input_list,d_prime_list,d_range,d_number_of_primes);

		if(cudaMemcpy(input_list,d_input_list,range*sizeof(uint64_c),cudaMemcpyDeviceToHost)!=cudaSuccess)
                {
                    printf("copy Host Error:  1\n");
			exit(0);
                }





                
                //print_inputlist(input_list,range);
                uint64_c previous_number_of_primes= number_of_primes;
                number_of_primes = counting_primes(input_list, range, number_of_primes)+previous_number_of_primes;
                printf("THE NUMBER OF PRIMES ARE: %llu\n",number_of_primes);
                prime_list=(uint64_c *)realloc(prime_list,number_of_primes*sizeof(uint64_c));
                appending_prime(input_list, prime_list,  range, previous_number_of_primes, number_of_primes);
                print_primelist(prime_list,number_of_primes);
                n=pow(n,2);
                printf("******************************************\n\n");

            }







    
        return 0;

 }



int generate_seed_primes(char *input,int *primelist, uint64_c n)
{
    for (int p=2; p*p<=n; p++)
    {
         if (input[p] == 'P')
        {
            for (int i=p*2; i<=n; i += p)
                input[i] = 'N';
        }
    }




int i=0;
    for (int p=2; p<=n; p++){


       if (input[p]=='P')
       {

          primelist[i]=p;
          i++;
       }



   }

   return i;

}

void initializeInput(char *input, int input_size)
{

    for(int i=0;i<input_size;i++)
    {
        input[i]='P';
    }

}

void initializing_inputlist(uint64_c *input_list, uint64_c start,uint64_c range){

        for(uint64_c i=0;i<range;i++)
        {
                input_list[i]=start+i;

        }


}

void print_inputlist(uint64_c *input_list,uint64_c range)
{

        for(uint64_c i=0;i<range;i++)
        {
                printf("%llu\t--->\t%llu\n", i,input_list[i]);
        }


}

void print_primelist(uint64_c *prime_list,uint64_c number_of_primes)
{

        for(uint64_c i=0;i<number_of_primes;i++)
        {
                printf("%llu\n",prime_list[i]);
        }


}


void copy_seed_primes(uint64_c *prime_list,int * seed_primelist,int num_of_seed)
{
        

        for(int i=0;i<num_of_seed;i++)
        {
                prime_list[i]=seed_primelist[i];
                
        }

}



void calculatePrime(uint64_c* input_list, uint64_c* prime_list, uint64_c range,uint64_c number_of_primes)
{
        
       // print_primelist(prime_list,number_of_primes);
            for(uint64_c i=0;i<range;i++)
        {
                for(uint64_c j=0;j<number_of_primes;j++){


                

                        if(input_list[i] % prime_list[j]==0)
                        {
                                input_list[i]=0;
                                
                               
                        }



                }
        }
        

}

void appending_prime(uint64_c* input_list, uint64_c* prime_list, uint64_c range, uint64_c prev_number_of_primes, uint64_c number_of_primes)
 {

                for(uint64_c i=0;i<range;i++)
                {
                        if(input_list[i]>0){
                            //printf("XXXXXXXXX>>> %llu\n", input_list[i]);
                            prime_list[prev_number_of_primes]=input_list[i];
                            prev_number_of_primes++;
                        }

                }
               // printf("the number he he ha ha... %llu\n",prev_number_of_primes);

                //exit(0);
                

 }

uint64_c counting_primes(uint64_c* input_list,uint64_c range,uint64_c number_of_primes)
{  
    
    int prime=0;

    for(uint64_c i=0;i<range;i++)
    {
        if(input_list[i]>0)
        {
            prime++;
        }
    }

    return prime;

}

