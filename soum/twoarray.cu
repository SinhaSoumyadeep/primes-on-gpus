#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>


__global__ void add(int *a, int *b,int * c)
{
	int col=10;	
	int i=0;
	int j=0;	

	for(i=0;i<10;i++){
		for(j=0;j<10;j++){

			*(c + i * col +j)= *(a + i + col + j) + *(b + i + col + j);			

		}
	}

}


int main()
{

	int row = 10;
	int col = 10;
	int *a;
	int *b;
	int *c;

	int *d_a;
	int *d_b;
	int *d_c;

	a=(int *) malloc(row * col * sizeof(int));
	b=(int *) malloc(row * col * sizeof(int));
	c=(int *) malloc(row * col * sizeof(int));

	int i,j;

	for(i=0;i<row;i++)
	{

		for(j=0;j<col;j++)
		{
			*(a + i * col + j)= 11;
			*(b + i * col + j)= 10;
		}

	}

	cudaMalloc(&d_a,row*col*sizeof(int));
	cudaMalloc(&d_b,row*col*sizeof(int));
	cudaMalloc(&d_c, row*col*sizeof(int));	
	
	cudaMemcpy(d_a,a,row*col*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(d_b,b,row*col*sizeof(int),cudaMemcpyHostToDevice);
	
	add<<<1,100>>>(d_a,d_b,d_c);


	cudaMemcpy(c,d_c,row*col*sizeof(int),cudaMemcpyDeviceToHost);
	
	

	for(i=0;i<row;i++)
	{

		for(j=0;j<col;j++)
		{
			printf(" c[%d][%d] = %d\n",i,j, *(c + i * col + j) );
		}
		
	}

	return 0;
}
