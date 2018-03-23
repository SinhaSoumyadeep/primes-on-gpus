#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<cuda.h>

__global__ void prime_generator(int *input,int *prime_list,int *total_input,int *seed)
{

	int i= blockIdx.x * blockDim.x + threadIdx.x;
	int primeno= prime_list[i];
	
	for(int k=seed[0];k<total_input[0];k++)
	{
		if(k%primeno==0)
		{
			input[k]=1;
		
		}
	

	}
	


}

int main()
{
	int total_input=1e6;
	int *input;
	int n= 1000 ;// seed prime list.
	int *primelist;
	input=(int *)malloc(total_input*sizeof(int));
	primelist=(int *)malloc(total_input*sizeof(int));

	for(int j=0;j<total_input;j++)
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
cudaMemcpy(d_input,input,total_input*sizeof(int),cudaMemcpyHostToDevice);



cudaMemcpy(d_prime_list,primelist,total_input*sizeof(int),cudaMemcpyHostToDevice);
cudaMemcpy(d_seed,&n,sizeof(int),cudaMemcpyHostToDevice);

prime_generator<<<1,1000>>>(d_input,d_prime_list,d_total_input,d_seed);

cudaMemcpy(h_pl,d_prime_list,total_input*sizeof(int),cudaMemcpyDeviceToHost);
cudaMemcpy(input,d_input,total_input*sizeof(int),cudaMemcpyDeviceToHost);


for(int p=2;p<total_input;p++)
{
 	if(input[p]==1)
	continue;
        		
	primelist[i]=p;       
	i++;
}		
	
for(int p=0;p<total_input;p++)
{
	printf("%d\n",primelist[p]);

}







	return 0;
 
 }


