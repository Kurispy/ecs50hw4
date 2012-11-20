#sizeof(pthread_t) = 4

.equ MAX_THREADS, 10

.data

nthreads:
  .long 0

csize:
  .long 0

remainder:
  .long 0

array:
  .long 0

min:
  .long 0

max:
  .long 0

range:
  .long 0

threads:
  .rept MAX_THREADS
  .long 0
  .endr


.text

.globl ucdsort

ucdsort: #(int *x, int n, int nth)
  movl 4(%esp), %eax
  movl %eax, nthreads
  movl 12(%esp), %eax
  movl %eax, array
  #split array x into roughly equal sized chunks based on nth and assign to threads
  movl 8(%esp), %eax
  idivl nthreads #standard chunk size is now in %eax, with remainder in %edx
  movl %eax, csize
  movl %edx, remainder
  movl $0, %ebx #thread counter
  
createloop:
  movl $threads, %ecx
  shll $2, %ebx
  addl %ebx, %ecx #&threads[i]
  shrl $2, %ebx
  pushl %ecx #pthread_t *thread
  pushl $0 #pthread_attr_t NULL
  pushl $worker #pointer to function
  pushl %ebx #argument passed to function
  call pthread_create
  addl $16, %esp

  incl %ebx
  cmpl 4(%esp), %ebx
  jnz createloop #leave loop when nth threads have been created
  
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
notthread0:
  movl $0, %eax #counter
  movl $0, %edx #min
  movl $0, %ebp #max
  movl array, %ecx
  shll $2, %esi
  addl %esi, %ecx #ecx is now the start location of the chunk
  shrl $2, %esi
loop:
  movl (%ecx, %eax, 4), %ebx  #ebx holds current element
  cmpl %ebx, %edx
  jl newmin
  cmpl %ebx, %ebp
  jg newmax

  incl %eax
  cmpl %eax, %edi
  jnz loop
  jmp gminmax

newmin:
  movl %ebx, %edx
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
  cmpl %edx, min
  jl newgmin
  cmpl %ebp, max
  jg newgmax
  jmp barrier

newgmin:
  lock xchg %edx, min
  jmp barrier

newgmax:
  lock xchg %ebp, max
  jmp barrier

barrier:
  

part2:
  movl max, %eax
  subl min, %eax
  incl %eax #eax = range
  idivl nthreads
  movl %eax, csize
  movl %edx, remainder
  

  movl csize, %eax
  imull 4(%esp)
  movl %eax, %esi #esi holds start location of chunk in array
  movl csize, %edi #edi now holds length 
  cmpl $0, 4(%esp)
  jnz notthread0
  addl remainder, %edi #edi now holds length (thread 0)
notthread0:
  movl $0, %eax #counter
  movl $0, %edx #min
  movl $0, %ebp #max
  movl array, %ecx
  shll $2, %esi
  addl %esi, %ecx #ecx is now the start location of the chunk
  shrl $2, %esi
