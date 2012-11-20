#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

extern void ucdsort(int *x, int n, int nth)

int main(void)
{
	int x[5] = {5, 4, 3, 2, 1};
	ucdsort(x, 5, 2);
	
	return 0;
}

