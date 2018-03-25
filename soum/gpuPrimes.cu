#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
#include<cuda.h>

#define INPUT_SIZE 100000000
#define PRIME_RANGE 100000000
#define BLOCK_SIZE 32
typedef unsigned long long int uint64_c;


int generate_seed_primes(int*, int*, uint64_c);
void copy_seed_primes(uint64_c *,int *,int);
void print_primelist(uint64_c *, uint64_c);
void print_inputlist(uint64_c *);
void initializing_inputlist(uint64_c *);
void memsetting_range_of_input(uint64_c *,uint64_c);
void calculatePrime(uint64_c*, uint64_c*, uint64_c, uint64_c, uint64_c);
uint64_c appending_prime(uint64_c*, uint64_c*, uint64_c, uint64_c, uint64_c);


//KERNAL CODE GOES HERE!!


__global__ void prime_generator(uint64_c* device_input_list, uint64_c* device_prime_list, uint64_c* device_start_of_range,uint64_c* device_end_of_range, uint64_c* device_number_of_primes)
{
//	printf("------- INSIDE KERNEL ---------%llu-------%llu------\n",device_start_of_range[0],device_end_of_range[0]);

	int p= blockIdx.x * blockDim.x + threadIdx.x;
	int primeno= device_prime_list[p];
       for(uint64_c i=device_start_of_range[0];i<device_end_of_range[0];i++)
        {


                
                        if(i % primeno==0)
                        {
                                device_input_list[i]=1;
                                
                               
                        }



        }



}


//KERNAL CODE ENDS HERE!!!


int main()
{
	cudaSetDevice(1);
// This code is just to generate the seed prime numbers
        int input_size=100;
        int *input;
        uint64_c n= 10 ;// seed prime list.
        int *seed_primelist;
        input=(int *)malloc(input_size*sizeof(int));
        seed_primelist=(int *)malloc(input_size*sizeof(int));
        int num_of_seed = generate_seed_primes(input,seed_primelist,n);


// seed prime list code ends here.


//Starting code for gpu.
        //declaring host variables.

        // declaring the ranges of the input size and the primes to be generated.

        uint64_c total_input_size = INPUT_SIZE;
        printf("TOTAL INPUT SIZE IS: %llu\n",total_input_size);
        uint64_c prime_range = PRIME_RANGE;
        printf("THE PRIMES WILL BE GENERATED FROM 0 - %llu\n",prime_range);

        printf("-------------------------------------------------------------------------\n\n\n");
        // creating the host array of input-list and primelist.
        uint64_c *input_list;
        uint64_c *prime_list;
        uint64_c number_of_primes= num_of_seed; //initializing the number of primes to the number of seed primes.
        input_list=(uint64_c *)malloc(total_input_size * sizeof(uint64_c));

        //setting all the values of the input list to -1.
        initializing_inputlist(input_list);

        prime_list=(uint64_c *)malloc(prime_range * sizeof(uint64_c));

        //copying the seed primes in prime_list.
                copy_seed_primes(prime_list,seed_primelist,num_of_seed);

         

        //creating the device array of input list and primelist
        uint64_c *device_input_list;
        uint64_c *device_prime_list;
        uint64_c *device_previous_range;
        uint64_c *device_max_prime_range;
        uint64_c *device_number_of_primes;


        //allocating memory in gpu.

        if(cudaMalloc((void** )&device_input_list,total_input_size * sizeof(uint64_c))!=cudaSuccess)
        {
                printf("ERROR: CANNOT ALLOCATE MEMORY IN GPU FOR INPUT LIST ------>> :) \n");
                exit(0);
        }

        if(cudaMalloc((void** )&device_prime_list,prime_range * sizeof(uint64_c))!=cudaSuccess)
        {
                printf("ERROR: CANNOT ALLOCATE MEMORY IN GPU FOR PRIME LIST\n");
                cudaFree(device_input_list);
                exit(0);
        }

        if(cudaMalloc((void** )&device_previous_range,sizeof(uint64_c))!=cudaSuccess)
        {
                printf("ERROR: CANNOT ALLOCATE MEMORY IN GPU FOR PREVIOUS RANGE\n");
                cudaFree(device_input_list);
                cudaFree(device_prime_list);
                exit(0);
        }

        if(cudaMalloc((void** )&device_max_prime_range,sizeof(uint64_c))!=cudaSuccess)
        {
                printf("ERROR: CANNOT ALLOCATE MEMORY IN GPU FOR MAX PRIME RANGE\n");
                cudaFree(device_input_list);
                cudaFree(device_prime_list);
                cudaFree(device_previous_range);
                exit(0);
        }

        if(cudaMalloc((void** )&device_number_of_primes,sizeof(uint64_c))!=cudaSuccess)
        {
                printf("ERROR: CANNOT ALLOCATE MEMORY IN GPU FOR NUMBER OF PRIMES\n");
                cudaFree(device_input_list);
                cudaFree(device_prime_list);
                cudaFree(device_previous_range);
                cudaFree(device_max_prime_range);
                exit(0);
        }

        //allocating memory in gpu completed.


        
        

                while(n<PRIME_RANGE){

                        //copying input list and prime list from host to device.

                        if(cudaMemcpy(device_prime_list,prime_list,prime_range * sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                        {
                                printf("ERROR: CANNOT COPY PRIME LIST FROM HOST TO DEVICE\n");
                                cudaFree(device_input_list);
                                cudaFree(device_prime_list);
                                cudaFree(device_previous_range);
                                cudaFree(device_max_prime_range);
                                cudaFree(device_number_of_primes);
                                exit(0);
                        } 

                        //copying input list and prime list from host to device completed.

                        //copying number of primes generated.
                        if(cudaMemcpy(device_number_of_primes,&number_of_primes,sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                        {
                                printf("ERROR: CANNOT COPY NUMBER OF PRIMES FROM HOST TO DEVICE\n");
                                cudaFree(device_input_list);
                                cudaFree(device_prime_list);
                                cudaFree(device_previous_range);
                                cudaFree(device_max_prime_range);
                                cudaFree(device_number_of_primes);
                                exit(0);
                        } 

                        uint64_c previous_range=n;
                        //copying previous range from host to device.
                        if(cudaMemcpy(device_previous_range,&previous_range,sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                        {
                                printf("ERROR: CANNOT COPY PREVIOUS RANGE FROM HOST TO DEVICE\n");
                                cudaFree(device_input_list);
                                cudaFree(device_prime_list);
                                cudaFree(device_previous_range);
                                cudaFree(device_max_prime_range);
                                cudaFree(device_number_of_primes);
                                exit(0);
                        } 

                        printf("THE NUMBER OF PRIMES GENERATED: %llu \n",number_of_primes);
                        //to determine the maximum range a the calculated prime range can determine.
                        uint64_c max_prime_range = pow(n,2);

                        printf("MAXIMUM RANGE PRIMES BETWEEN 0 - %llu CAN DETERMINE IS %llu \n", n,max_prime_range);
                        
                        if(max_prime_range<=PRIME_RANGE){

                                if(cudaMemcpy(device_max_prime_range,&max_prime_range,sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                                {
                                        printf("ERROR: CANNOT COPY MAX PRIME RANGE FROM HOST TO DEVICE\n");
                                        cudaFree(device_input_list);
                                        cudaFree(device_prime_list);
                                        cudaFree(device_previous_range);
                                        cudaFree(device_max_prime_range);
                                        cudaFree(device_number_of_primes);
                                        exit(0);
                                } 

                                printf("CALCULATE PRIME NUMBERS BETWEEN %llu - %llu\n", previous_range,max_prime_range);
                                memsetting_range_of_input(input_list,max_prime_range);
	                        if(cudaMemcpy(device_input_list,input_list,total_input_size * sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
        	                {
                	                printf("ERROR: CANNOT COPY INPUT LIST FROM HOST TO DEVICE\n");
                        	        cudaFree(device_input_list);
                             		cudaFree(device_prime_list);
                                	cudaFree(device_previous_range);
                                	cudaFree(device_max_prime_range);
                                	cudaFree(device_number_of_primes);
                                	exit(0);
                        	} 

                             //   calculatePrime(input_list, prime_list, previous_range, max_prime_range, number_of_primes);

                                prime_generator<<<BLOCK_SIZE,256>>>(device_input_list, device_prime_list, device_previous_range, device_max_prime_range, device_number_of_primes);
				cudaError_t err = cudaGetLastError();
				if (err != cudaSuccess) 
   			        printf("Error: %s\n", cudaGetErrorString(err));

				
                                //copying input list from device to host
                                if(cudaMemcpy(input_list,device_input_list,total_input_size * sizeof(uint64_c),cudaMemcpyDeviceToHost)!=cudaSuccess)
                                {
                                        printf("ERROR: CANNOT COPY INPUT LIST FROM DEVICE TO HOST\n");
                                        cudaFree(device_input_list);
                                        cudaFree(device_prime_list);
                                        cudaFree(device_previous_range);
                                        cudaFree(device_max_prime_range);
                                        cudaFree(device_number_of_primes);
                                        exit(0);
                                } 
				
                                number_of_primes = appending_prime(input_list, prime_list, previous_range, max_prime_range, number_of_primes);

                        }
                        else
                        {

                         	printf("IN ELSE PART.\n");  
			      if(cudaMemcpy(device_max_prime_range,&prime_range,sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
                                {
                                        printf("ERROR: CANNOT COPY MAX PRIME RANGE FROM HOST TO DEVICE\n");
                                        cudaFree(device_input_list);
                                        cudaFree(device_prime_list);
                                        cudaFree(device_previous_range);
                                        cudaFree(device_max_prime_range);
                                        cudaFree(device_number_of_primes);
                                        exit(0);
                                } 
                                printf("CALCULATE PRIME NUMBERS BETWEEN %llu - %llu\n", previous_range,prime_range);
                                memsetting_range_of_input(input_list,prime_range);

	                        if(cudaMemcpy(device_input_list,input_list,total_input_size * sizeof(uint64_c),cudaMemcpyHostToDevice)!=cudaSuccess)
	                        {
        	                        printf("ERROR: CANNOT COPY INPUT LIST FROM HOST TO DEVICE\n");
                	                cudaFree(device_input_list);
                        	        cudaFree(device_prime_list);
                                	cudaFree(device_previous_range);
                                	cudaFree(device_max_prime_range);
                                	cudaFree(device_number_of_primes);
                                	exit(0);
                        	} 
			//	printf("CHECKING TIME REQUIRED\n");

                            //    calculatePrime(input_list, prime_list, previous_range, prime_range, number_of_primes);
                                prime_generator<<<BLOCK_SIZE,256>>>(device_input_list, device_prime_list, device_previous_range, device_max_prime_range, device_number_of_primes);
				cudaError_t err = cudaGetLastError();
				if (err != cudaSuccess) 
    				printf("Error: %s\n", cudaGetErrorString(err));

                                //copying input list from device to host
                               if(cudaMemcpy(input_list,device_input_list,total_input_size * sizeof(uint64_c),cudaMemcpyDeviceToHost)!=cudaSuccess)
                                {
                                        printf("ERROR: CANNOT COPY INPUT LIST FROM DEVICE TO HOST\n");
                                        cudaFree(device_input_list);
                                        cudaFree(device_prime_list);
                                        cudaFree(device_previous_range);
                                        cudaFree(device_max_prime_range);
                                        cudaFree(device_number_of_primes);
                                        exit(0);
                                } 

                                number_of_primes = appending_prime(input_list, prime_list, previous_range, prime_range, number_of_primes);
                        }
                        printf("\n\n\n");
                        
                        //print_inputlist(input_list);
                        n=pow(n,2);
                       
                }


                printf("TOTAL NUMBER OF PRIMES GENERATED: %llu \n",number_of_primes);
                print_primelist(prime_list,number_of_primes);
//ending code for gpu.
        return 0;

 }



 uint64_c appending_prime(uint64_c* input_list, uint64_c* prime_list, uint64_c start_of_range,uint64_c end_of_range, uint64_c number_of_primes)
 {

                for(uint64_c i=start_of_range;i<end_of_range;i++)
                {

                        if(input_list[i]==0)
                        {
                                prime_list[number_of_primes] = i;
                                number_of_primes++;
                        }

                }

                return number_of_primes;

 }

void calculatePrime(uint64_c* input_list, uint64_c* prime_list, uint64_c start_of_range,uint64_c end_of_range, uint64_c number_of_primes)
{
        printf("--------CALCULATING PRIME NUMBERS from %llu to %llu --------\n", start_of_range,end_of_range);
       // print_primelist(prime_list,number_of_primes);
        for(uint64_c i=start_of_range;i<end_of_range;i++)
        {
                for(uint64_c j=0;j<number_of_primes;j++){


                
                        if(i % prime_list[j]==0)
                        {
                                input_list[i]=1;
                                
                               
                        }



                }
        }
        printf("-------- END CALCULATING PRIME NUMBERS--------\n");

}

void memsetting_range_of_input(uint64_c *input_list,uint64_c size)
{
        memset(input_list,0,size * sizeof(uint64_c));
}

void initializing_inputlist(uint64_c *input_list){

        for(int i=0;i<=INPUT_SIZE;i++)
        {
                input_list[i]=2;
        }


}

void print_inputlist(uint64_c *input_list)
{

        for(int i=0;i<INPUT_SIZE;i++)
        {
                printf("%d\t--->\t%llu\n", i,input_list[i]);
        }


}

void print_primelist(uint64_c *prime_list,uint64_c number_of_primes)
{

        for(int i=0;i<number_of_primes;i++)
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
int generate_seed_primes(int *input,int *primelist, uint64_c n)
{
    for (int p=2; p*p<=n; p++)
    {
         if (input[p] == 0)
        {
            for (int i=p*2; i<=n; i += p)
                input[i] = 1;
        }
    }




int i=0;
    for (int p=2; p<=n; p++){


       if (input[p]==0)
       {

          primelist[i]=p;
          i++;
       }



   }

   return i;

}

