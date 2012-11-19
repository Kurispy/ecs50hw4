#sizeof(pthread_t) = 4

.equ MAX_THREADS, 10

.data

threads:
  .rept MAX_THREADS
  .long 0
  .endr

.text

.globl ucdsort

ucdsort: #(int *x, int n, int nth)
  #split array x into roughly equal sized chunks based on nth and assign to threads
  movl $0, %ebx #thread counter
  
createloop:
  movl $threads, %ecx
  .rept 4
  addl %ebx, %ecx #&threads[i]
  .endr
  push %ecx
  push $0 #This might not work
  push $sort
  push %ebx
  call pthread_create

  incl %ebx
  cmpl 4(%ebp), %ebx
  jnz createloop #leave loop when nth threads have been created
  
  #BARRIER combine results to get overall min/max

  #split range mx-mn into roughly equal sized chunks based on nth and assign to threads
  #CRITICAL SECTION in each thread determine which elements are in its range as well as how many of
  #them there are

  #publicize the amount of elements in a global variable, and use it to determine where each of
  #the threads will be writing their output

  #sort said elements in each chunk using qsort() and store results in said locations

  #???
  #Profit

minmax: #assume %ecx = size of chunk; %edx = remainder; 
  #4(%ebp) = thread number
  #find min/max in each thread

sort:
  
