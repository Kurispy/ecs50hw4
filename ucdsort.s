.data



.text

.globl ucdsort

ucdsort: #(int *x, int n, int nth)
  
  #create nth threads
  #split array x into roughly equal sized chunks based on nth and assign to threads
  #find min/max in each thread
  #BARRIER combine results to get overall min/max

  #split range mx-mn into roughly equal sized chunks based on nth and assign to threads
  #CRITICAL SECTION in each thread determine which elements are in its range as well as how many of
  #them there are

  #publicize the amount of elements in a global variable, and use it to determine where each of
  #the threads will be writing their output

  #sort said elements in each chunk using qsort() and store results in said locations

  #???
  #Profit
