#sizeof(pthread_t) = 4
#sizeof(pthread_barrier_t) = 20

.equ MAX_THREADS, 10

.comm barr, 20

.data

size:
  .long 0
  
nthreads:
  .long 0

csize:
  .long 0

remainder:
  .long 0

array:
  .long 0

min:
  .long 30000

max:
  .long -30000

range:
  .long 0

counts: #each element holds the amount of elements of x to be called by the corresponding thread
  .rept MAX_THREADS
  .long 0
  .endr

threads:
  .rept MAX_THREADS
  .long 0
  .endr


.text

.globl ucdsort

ucdsort: #(int *x, int n, int nth)
  pushl 12(%esp)
  pushl $0
  pushl $barr #initialize barrier
  call pthread_barrier_init
  addl $12, %esp
  movl 12(%esp), %eax
  movl %eax, nthreads
  movl 4(%esp), %eax
  movl %eax, array
  #split array x into roughly equal sized chunks based on nth and assign to threads
  movl 8(%esp), %eax
  movl %eax, size
  movl $0, %edx
  idivl nthreads #standard chunk size is now in %eax, with remainder in %edx
  movl %eax, csize
  movl %edx, remainder
  movl $0, %ebx #thread counter
  
createloop:
  movl $threads, %ecx
  shll $2, %ebx
  addl %ebx, %ecx #&threads[i]
  shrl $2, %ebx  
  pushl %ebx
  pushl $worker
  pushl $0
  pushl %ecx
  call pthread_create
  addl $16, %esp
  
  incl %ebx
  cmpl 12(%esp), %ebx
  jnz createloop #leave loop when nth threads have been created
  
  #pthread_join
  movl $0, %ebx
  movl threads, %eax
  pushl $0
  pushl (%eax, %ebx, 4)
  call pthread_join
  addl $8, %esp 
  
done:
  movl %eax, %eax
  
  #gminmax combine results to get overall min/max

  #split range mx-mn into roughly equal sized chunks based on nth and assign to threads
  #CRITICAL SECTION in each thread determine which elements are in its range as well as how many of
  #them there are

  #publicize the amount of elements in a global variable, and use it to determine where each of
  #the threads will be writing their output

  #sort said elements in each chunk using qsort() and store results in said locations

  #???
  #Profit

worker: 
  #4(%esp) = thread number
  movl csize, %eax
  imull 4(%esp)
  movl %eax, %esi #esi holds start location of chunk in array
  movl csize, %edi #edi now holds length 
  cmpl $0, 4(%esp)
  jnz notthread0
  addl remainder, %edi #edi now holds length (thread 0)
  subl remainder, %esi
notthread0:
  addl remainder, %esi
  movl $0, %eax #counter
  movl $30000, %edx #min
  movl $-30000, %ebp #max
  movl array, %ecx
  shll $2, %esi
  addl %esi, %ecx #ecx is now the start location of the chunk
  shrl $2, %esi
loop:
  movl (%ecx, %eax, 4), %ebx  #ebx holds current element
  cmpl %edx, %ebx
  jl newmin
  cmpl %ebp, %ebx
  jg newmax

  incl %eax
  cmpl %eax, %edi
  jnz loop
  jmp gminmax

newmin:
  movl %ebx, %edx  
  cmpl %ebp, %ebx
  jg newmax
  incl %eax
  cmpl %eax, %edi  
  jnz loop
  jmp gminmax

newmax:
  movl %ebx, %ebp
  incl %eax
  cmpl %eax, %edi
  jnz loop
  jmp gminmax

gminmax:
  cmpl min, %edx
  jl newgmin
  cmpl max, %ebp
  jg newgmax
  jmp barrier

newgmin:
  lock xchg %edx, min
  cmpl max, %ebp
  jg newgmax
  jmp barrier

newgmax:
  lock xchg %ebp, max
  jmp barrier

barrier:
  push $barr
  call pthread_barrier_wait
  addl $4, %esp

part2:
  movl max, %eax
  subl min, %eax
  incl %eax #eax = range
  movl $0, %edx
  idivl nthreads
  movl %eax, csize
  movl %edx, remainder
  imull 4(%esp)
  movl %eax, %edx
  addl min, %edx #min
  movl %edx, %ebp
  addl csize, %ebp #max
  decl %ebp   #MAYBE WORK MAYBE NOT
  movl nthreads, %esi
  decl %esi
  cmpl 4(%esp), %esi
  jnz notlast
  addl remainder, %ebp
notlast:
  movl $0, %eax #counter
  movl $counts, %esi
  movl 4(%esp), %ebx
p2loop:
  movl array, %ecx
  cmpl (%ecx, %eax, 4), %edx
  jg p2inc
  cmpl (%ecx, %eax, 4), %ebp
  jl p2inc
  incl (%esi, %ebx, 4)
p2inc:
  incl %eax
  cmpl size, %eax
  jnz p2loop
  
  shll $2, (%esi, %ebx, 4)  
  pushl %eax  
  pushl %ecx
  pushl %edx
  pushl (%esi, %ebx, 4)
  call malloc
  shrl $2, (%esi, %ebx, 4)
  addl $4, %esp
  movl %eax, %edi 
  popl %edx
  popl %ecx
  popl %eax
  movl %edi, %esi #esi = first element of thread array
  
  movl $0, %eax #counter
p2loop2:
  movl array, %ecx
  cmpl (%ecx, %eax, 4), %edx
  jg p2inc2
  cmpl (%ecx, %eax, 4), %ebp
  jl p2inc2
  movl (%ecx, %eax, 4), %ebx
  movl %ebx, (%edi)
  addl $4, %edi
p2inc2:
  incl %eax
  cmpl size, %eax
  jnz p2loop2

barrier2:
  push $barr
  call pthread_barrier_wait
  addl $4, %esp

  movl array, %edx
  movl $counts, %ebx
  movl $-1, %eax
  movl $0, %ebp
sumloop:
  incl %eax
  addl (%ebx, %eax, 4), %ebp
  cmpl 4(%esp), %eax
  jnz sumloop
  subl (%ebx, %eax, 4), %ebp
  #ebp is now destination location in x

  movl (%ebx, %eax, 4), %ecx #ecx = number of elements to move
  shll $2, %ebp
  addl %ebp, %edx
  movl %edx, %edi #edi = location in x to copy
  shrl $2, %ebp
  #esi already set to location of thread specific array
  pushl %edi
  rep movsl #esi->edi and increment edi by 1 word
  popl %edi
  
  pushl $compare
  pushl $4
  pushl (%ebx, %eax, 4)
  pushl %edi
  call qsort
  addl $16, %esp

barrier3:
  push $barr
  call pthread_barrier_wait
  addl $4, %esp
  
#exit thread!!!!
 pushl $0
 call pthread_exit
 addl $4, %esp 
  
compare:
  movl 8(%esp), %ebx
  movl (%ebx), %ebx
  movl 4(%esp), %eax
  movl (%eax), %eax
  subl %ebx, %eax
  ret
