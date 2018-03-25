#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<cuda.h>

__global__ void prime_generator(int *input,int *prime_list,int *total_input,int *seed)
{

	printf("-------XXXXXX>>> %d\n",seed[0]);
	int i= blockIdx.x * blockDim.x + threadIdx.x;
	int primeno= prime_list[i];
	int total=seed[0]*seed[0];
	for(int k=seed[0];k<total;k++)
	{
		if(k%primeno==0)
		{
			input[k]=1;
			
		
		}
	

	}
	


}

int main()
{
	int total_input=100000000;
	int *input;
	int n= 10 ;// seed prime list.
	int calculate_upto=pow(n,2);
	int *primelist;
	input=(int *)malloc(total_input*sizeof(int));
	primelist=(int *)malloc(total_input*sizeof(int));
        memset(input,-1,total_input*sizeof(int));
	for(int j=0;j<calculate_upto;j++)
	{
		input[j]=0;
	}

	
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


int *d_input;
int *d_prime_list;
int *h_pl;
int *d_total_input;
int *d_seed;

h_pl=(int *)malloc(total_input*sizeof(int));

cudaMalloc(&d_input,total_input*sizeof(int));
cudaMalloc(&d_prime_list,total_input*sizeof(int));
cudaMalloc(&d_total_input,sizeof(int));
cudaMalloc(&d_seed,sizeof(int));

cudaMemcpy(d_total_input,&total_input,sizeof(int),cudaMemcpyHostToDevice);
//cudaMemcpy(d_input,input,total_input*sizeof(int),cudaMemcpyHostToDevice);


while(n<=total_input){

printf("inside loop\n");
if(cudaMemcpy(d_input,input,total_input*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
{
		printf("not able to copy memory\n");
}
if(cudaMemcpy(d_prime_list,primelist,total_input*sizeof(int),cudaMemcpyHostToDevice) != cudaSuccess)
{
	printf("not able to copy memory 2\n");
}
if(cudaMemcpy(d_seed,&n,sizeof(int),cudaMemcpyHostToDevice) != cudaSuccess)
{

	printf(" not able to copy memory\n");
}

prime_generator<<<5,500>>>(d_input,d_prime_list,d_total_input,d_seed);

cudaError_t err = cudaGetLastError();
if (err != cudaSuccess) 
    printf("Error: %s\n", cudaGetErrorString(err));

/*
if(cudaMemcpy(h_pl,d_prime_list,total_input*sizeof(int),cudaMemcpyDeviceToHost)!=cudaSuccess)
{
	printf("not able to copy memory!!\n");

}
*/

if(cudaMemcpy(input,d_input,total_input*sizeof(int),cudaMemcpyDeviceToHost)!=cudaSuccess)
{
	printf(" hello not able to copy memory::\n");

}
printf("------------>> %d\n",i);

for(int p=n;p<total_input;p++)
{

//	printf("%d ----> %d\n",p,input[p]);
 	if(input[p]==0){
	primelist[i]=p;
	i++;
	}
}		
for(int p=0;p<i;p++)
{
       printf("%d\n",primelist[p]);

}
n=n*n;
printf("################  %d\n",n);
if(pow(n,2)>=total_input){
for(int m=n;m<total_input;m++) input[m]=0;
}
else
{
for(int m=n;m<pow(n,2);m++) input[m]=0;
}

}
/*for(int p=0;p<i;p++)
{
	printf("%d\n",primelist[p]);

}*/



	return 0;
 
 }
