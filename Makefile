ucdsort: ucdsort.o sortcall.o
	gcc -Wall -g -o ucdsort sortcall.o ucdsort.o

sortcall.o: sortcall.c
	gcc -Wall -g -c sortcall.c

ucdsort.o: ucdsort.s
	gcc -Wall -g -c ucdsort.s -lpthread

clean:
	rm -f *.o 
