#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

__global__ void add(int *a, int *b, int *c)
{
	int i= blockIdx.x*blockDim.x+threadIdx.x;
	
		c[i]= a[i]+b[i];

}

int main()
{
	// host pointers
	int *a;
	int *b;
	int *c;
	//device pointers
	int *d_a;
	int *d_b;
	int *d_c;

	a=(int *)malloc(10*sizeof(int));
	b=(int *)malloc(10* sizeof(int));
	c=(int *)malloc(10*sizeof(int));
	int i=0;
	for(i=0;i<10;i++)
	{
		a[i]=i;
		b[i]=i+1;
	}
	

	cudaMalloc(&d_a, 10*sizeof(int));
	cudaMalloc(&d_b, 10*sizeof(int));
	cudaMalloc(&d_c, 10*sizeof(int));

	cudaMemcpy(d_a,a,10*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(d_b,b,10*sizeof(int),cudaMemcpyHostToDevice);


	add<<<1,10>>>(d_a,d_b,d_c);

	cudaMemcpy(c,d_c,10*sizeof(int),cudaMemcpyDeviceToHost);


	int j=0;

	for(j=0;j<10;j++)
	{
		printf("%d\n",c[j] );
	}

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	
	return 0;
}
