//
// auto-generated by op2.py on 2014-02-24 23:14
//

//user function
#include "EvolveValuesRK2_2.h"

// x86 kernel function
void op_x86_EvolveValuesRK2_2(
  const float *arg0,
  float *arg1,
  float *arg2,
  float *arg3,
  float *arg4,
  int  start, int  finish ) {
  
  // process set elements
  for ( int n=start; n<finish; n++ ){
    
    // user-supplied kernel call
    EvolveValuesRK2_2(arg0,
                      arg1+n*4,
                      arg2+n*4,
                      arg3+n*4,
                      arg4+n*4);
  }
}


// host stub function          
void op_par_loop_EvolveValuesRK2_2(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4){
  
  int nargs = 5;
  op_arg args[5];
  
  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  
  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  EvolveValuesRK2_2");
  }
  
  op_mpi_halo_exchanges(set, nargs, args);
  
  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);
  
  // set number of threads
  #ifdef _OPENMP
    int nthreads = omp_get_max_threads();
  #else
    int nthreads = 1;
  #endif
  
  if (set->size >0) {
    
    // execute plan
    #pragma omp parallel for
    for ( int thr=0; thr<nthreads; thr++ ){
      int start  = (set->size* thr)/nthreads;
      int finish = (set->size*(thr+1))/nthreads;
      op_x86_EvolveValuesRK2_2(
      (float *) arg0.data,
      (float *) arg1.data,
      (float *) arg2.data,
      (float *) arg3.data,
      (float *) arg4.data,
      start, finish );
    }
  }
  
  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);
  
  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  op_timing_realloc(1);
  OP_kernels[1].name      = name;
  OP_kernels[1].count    += 1;
  OP_kernels[1].time     += wall_t2 - wall_t1;
  OP_kernels[1].transfer += (float)set->size * arg1.size * 2.0f;
  OP_kernels[1].transfer += (float)set->size * arg2.size;
  OP_kernels[1].transfer += (float)set->size * arg3.size;
  OP_kernels[1].transfer += (float)set->size * arg4.size;
}
