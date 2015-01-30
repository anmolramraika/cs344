/* Udacity HW5
   Histogramming for Speed

   The goal of this assignment is compute a histogram
   as fast as possible.  We have simplified the problem as much as
   possible to allow you to focus solely on the histogramming algorithm.

   The input values that you need to histogram are already the exact
   bins that need to be updated.  This is unlike in HW3 where you needed
   to compute the range of the data and then do:
   bin = (val - valMin) / valRange to determine the bin.

   Here the bin is just:
   bin = val

   so the serial histogram calculation looks like:
   for (i = 0; i < numElems; ++i)
     histo[val[i]]++;

   That's it!  Your job is to make it run as fast as possible!

   The values are normally distributed - you may take
   advantage of this fact in your implementation.

*/


#include "utils.h"
#include "reference.cpp"


__global__
void yourHisto(const unsigned int* const vals, //INPUT
               unsigned int* const histo    //OUPUT
               )
{
    int i = blockDim.x*blockIdx.x*64+threadIdx.x;
    int tid = threadIdx.x;
    extern __shared__ unsigned int s_bins[];

    unsigned int temp;
    for(int j =0; j < 4; ++j){
      temp = tid * 4 + j;
      s_bins[temp] = 0;
    }
    __syncthreads();
    
      for(int j = 0; j < 64; ++j){
      temp = vals[i + 256*j];
      atomicAdd(&s_bins[temp], 1);
    }
    __syncthreads();

    for(int j = 0; j < 4; ++j){
      temp = tid * 4 + j;
      atomicAdd(&histo[temp],s_bins[temp]); 
    }
  //TODO fill in this kernel to calculate the histogram
  //as quickly as possible

  //Although we provide only one kernel skeleton,
  //feel free to use more if it will help you
  //write faster code
}

void computeHistogram(const unsigned int* const d_vals, //INPUT
                      unsigned int* const d_histo,      //OUTPUT
                      const unsigned int numBins,
                      const unsigned int numElems)
{
  //TODO Launch the yourHisto kernel
    
  yourHisto<<<numElems/(256*64),256,(numBins+225)*sizeof(unsigned int)>>>(d_vals,d_histo); 
  
    //if you want to use/launch more than one kernel,
  //feel free
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());

  /*delete[] h_vals;
  delete[] h_histo;
  delete[] your_histo;*/
}
