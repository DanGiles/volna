//
// auto-generated by op2.m on 18-Jan-2013 17:40:15
//

// user function

__device__
#include "initBathymetry_update.h"


// CUDA kernel function

__global__ void op_cuda_initBathymetry_update(
  float *arg0,
  const int *arg1,
  int   offset_s,
  int   set_size ) {

  float arg0_l[4];
  int   tid = threadIdx.x%OP_WARPSIZE;

  extern __shared__ char shared[];

  char *arg_s = shared + offset_s*(threadIdx.x/OP_WARPSIZE);

  // process set elements

  for (int n=threadIdx.x+blockIdx.x*blockDim.x;
       n<set_size; n+=blockDim.x*gridDim.x) {

    int offset = n - tid;
    int nelems = MIN(OP_WARPSIZE,set_size-offset);

    // copy data into shared memory, then into local

    for (int m=0; m<4; m++)
      ((float *)arg_s)[tid+m*nelems] = arg0[tid+m*nelems+offset*4];

    for (int m=0; m<4; m++)
      arg0_l[m] = ((float *)arg_s)[m+tid*4];


    // user-supplied kernel call


    initBathymetry_update(  arg0_l,
                            arg1 );

    // copy back into shared memory, then to device

    for (int m=0; m<4; m++)
      ((float *)arg_s)[m+tid*4] = arg0_l[m];

    for (int m=0; m<4; m++)
      arg0[tid+m*nelems+offset*4] = ((float *)arg_s)[tid+m*nelems];

  }
}


// host stub function

void op_par_loop_initBathymetry_update(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1 ){

  int *arg1h = (int *)arg1.data;

  int    nargs   = 2;
  op_arg args[2];

  args[0] = arg0;
  args[1] = arg1;

  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  initBathymetry_update\n");
  }

  op_mpi_halo_exchanges(set, nargs, args);

  // initialise timers

  double cpu_t1, cpu_t2, wall_t1=0, wall_t2=0;
  op_timing_realloc(13);
  OP_kernels[13].name      = name;
  OP_kernels[13].count    += 1;

  if (set->size >0) {

    op_timers_core(&cpu_t1, &wall_t1);

    // transfer constants to GPU

    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(int));

    reallocConstArrays(consts_bytes);

    consts_bytes = 0;
    arg1.data   = OP_consts_h + consts_bytes;
    arg1.data_d = OP_consts_d + consts_bytes;
    for (int d=0; d<1; d++) ((int *)arg1.data)[d] = arg1h[d];
    consts_bytes += ROUND_UP(1*sizeof(int));

    mvConstArraysToDevice(consts_bytes);

    // set CUDA execution parameters

    #ifdef OP_BLOCK_SIZE_13
      int nthread = OP_BLOCK_SIZE_13;
    #else
      // int nthread = OP_block_size;
      int nthread = 128;
    #endif

    int nblocks = 200;

    // work out shared memory requirements per element

    int nshared = 0;
    nshared = MAX(nshared,sizeof(float)*4);

    // execute plan

    int offset_s = nshared*OP_WARPSIZE;

    nshared = nshared*nthread;

    op_cuda_initBathymetry_update<<<nblocks,nthread,nshared>>>( (float *) arg0.data_d,
                                                                (int *) arg1.data_d,
                                                                offset_s,
                                                                set->size );

    cutilSafeCall(cudaDeviceSynchronize());
    cutilCheckMsg("op_cuda_initBathymetry_update execution failed\n");

  }


  op_mpi_set_dirtybit(nargs, args);

  // update kernel record

  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[13].time     += wall_t2 - wall_t1;
  OP_kernels[13].transfer += (float)set->size * arg0.size * 2.0f;
}

