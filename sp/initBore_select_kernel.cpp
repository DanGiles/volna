//
// auto-generated by op2.m on 18-Jan-2013 17:40:15
//

// user function

#include "initBore_select.h"


// x86 kernel function

void op_x86_initBore_select(
  float *arg0,
  float *arg1,
  const float *arg2,
  const float *arg3,
  const float *arg4,
  const float *arg5,
  const float *arg6,
  const float *arg7,
  const float *arg8,
  int   start,
  int   finish ) {


  // process set elements

  for (int n=start; n<finish; n++) {

    // user-supplied kernel call


    initBore_select(  arg0+n*4,
                      arg1+n*2,
                      arg2,
                      arg3,
                      arg4,
                      arg5,
                      arg6,
                      arg7,
                      arg8 );
  }
}


// host stub function

void op_par_loop_initBore_select(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4,
  op_arg arg5,
  op_arg arg6,
  op_arg arg7,
  op_arg arg8 ){


  int    nargs   = 9;
  op_arg args[9];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  args[5] = arg5;
  args[6] = arg6;
  args[7] = arg7;
  args[8] = arg8;

  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  initBore_select\n");
  }

  op_mpi_halo_exchanges(set, nargs, args);

  // initialise timers

  double cpu_t1, cpu_t2, wall_t1=0, wall_t2=0;
  op_timing_realloc(14);
  OP_kernels[14].name      = name;
  OP_kernels[14].count    += 1;

  // set number of threads

#ifdef _OPENMP
  int nthreads = omp_get_max_threads( );
#else
  int nthreads = 1;
#endif

  if (set->size >0) {

    op_timers_core(&cpu_t1, &wall_t1);

  // execute plan

#pragma omp parallel for
  for (int thr=0; thr<nthreads; thr++) {
    int start  = (set->size* thr   )/nthreads;
    int finish = (set->size*(thr+1))/nthreads;
    op_x86_initBore_select( (float *) arg0.data,
                            (float *) arg1.data,
                            (float *) arg2.data,
                            (float *) arg3.data,
                            (float *) arg4.data,
                            (float *) arg5.data,
                            (float *) arg6.data,
                            (float *) arg7.data,
                            (float *) arg8.data,
                            start, finish );
  }

  }


  // combine reduction data

  op_mpi_set_dirtybit(nargs, args);

  // update kernel record

  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[14].time     += wall_t2 - wall_t1;
  OP_kernels[14].transfer += (float)set->size * arg0.size * 2.0f;
  OP_kernels[14].transfer += (float)set->size * arg1.size;
}

