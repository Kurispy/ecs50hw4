ucdsort: ucdsort.o sortcall.o
	gcc -Wall -g -o ucdsort sortcall.o ucdsort.o -lpthread -lm

sortcall.o: sortcall.c
	gcc -Wall -g -c sortcall.c

ucdsort.o: ucdsort.s
	gcc -Wall -g -c ucdsort.s 

clean:
	rm -f *.o 
