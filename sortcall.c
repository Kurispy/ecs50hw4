#include <stdlib.h>
#include <stdio.h>
#include <time.h>


extern void ucdsort(int *x, int n, int nth);

int main(void)
{
   int x[1000], i;
   for(i=0; i<1000; i++)
   {
     x[i]=rand()%30000+1;
   }
	
	ucdsort(x, 1000, 7);
	
	return 0;
}

