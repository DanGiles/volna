//
// auto-generated by op2.py on 2014-02-24 23:14
//

//user function
#include "simulation_1.h"

// x86 kernel function
void op_x86_simulation_1(
  float *arg0,
  float *arg1,
  int  start, int  finish ) {
  
  // process set elements
  for ( int n=start; n<finish; n++ ){
    
    // user-supplied kernel call
    simulation_1(arg0+n*4,
                 arg1+n*4);
  }
}


// host stub function          
void op_par_loop_simulation_1(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1){
  
  int nargs = 2;
  op_arg args[2];
  
  args[0] = arg0;
  args[1] = arg1;
  
  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  simulation_1");
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
      op_x86_simulation_1(
      (float *) arg0.data,
      (float *) arg1.data,
      start, finish );
    }
  }
  
  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);
  
  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  op_timing_realloc(2);
  OP_kernels[2].name      = name;
  OP_kernels[2].count    += 1;
  OP_kernels[2].time     += wall_t2 - wall_t1;
  OP_kernels[2].transfer += (float)set->size * arg0.size;
  OP_kernels[2].transfer += (float)set->size * arg1.size;
}
