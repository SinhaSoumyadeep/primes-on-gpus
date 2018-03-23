#include<stdio.h>
#include<stdlib.h>
#include <math.h>


int main()
{
	int total_input=1000;
	int *input;
	int n= 100 ;// seed prime list.
	int *primelist;
	input=(int *)malloc(total_input*sizeof(int));
	primelist=(int *)malloc(total_input*sizeof(int));

	for(int j=0;j<n;j++)
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


for(int i=0;i<

	return 0;
 
 }

