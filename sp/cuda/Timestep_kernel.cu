//
// auto-generated by op2.py
//

//user function
__device__ void Timestep_gpu( const float *maxEdgeEigenvalues0,
          const float *maxEdgeEigenvalues1,
          const float *maxEdgeEigenvalues2,
          const float *EdgeVolumes0,
          const float *EdgeVolumes1,
          const float *EdgeVolumes2,
          const float *cellVolumes,
          float *minTimeStep ) {
  float local = 0.0f;
  local += *maxEdgeEigenvalues0 * *(EdgeVolumes0);
  local += *maxEdgeEigenvalues1 * *(EdgeVolumes1);
  local += *maxEdgeEigenvalues2 * *(EdgeVolumes2);
  *minTimeStep = MIN(*minTimeStep, 2.0f * *cellVolumes / local);

}

// CUDA kernel function
__global__ void op_cuda_Timestep(
  const float *__restrict ind_arg0,
  const float *__restrict ind_arg1,
  const int *__restrict opDat0Map,
  const float *__restrict arg6,
  float *arg7,
  int    block_offset,
  int   *blkmap,
  int   *offset,
  int   *nelems,
  int   *ncolors,
  int   *colors,
  int   nblocks,
  int   set_size) {
  float arg7_l[1];
  for ( int d=0; d<1; d++ ){
    arg7_l[d]=arg7[d+blockIdx.x*1];
  }


  __shared__ int    nelem, offset_b;

  extern __shared__ char shared[];

  if (blockIdx.x+blockIdx.y*gridDim.x >= nblocks) {
    return;
  }
  if (threadIdx.x==0) {

    //get sizes and shift pointers and direct-mapped data

    int blockId = blkmap[blockIdx.x + blockIdx.y*gridDim.x  + block_offset];

    nelem    = nelems[blockId];
    offset_b = offset[blockId];

  }
  __syncthreads(); // make sure all of above completed

  for ( int n=threadIdx.x; n<nelem; n+=blockDim.x ){
    int map0idx;
    int map1idx;
    int map2idx;
    map0idx = opDat0Map[n + offset_b + set_size * 0];
    map1idx = opDat0Map[n + offset_b + set_size * 1];
    map2idx = opDat0Map[n + offset_b + set_size * 2];


    //user-supplied kernel call
    Timestep_gpu(ind_arg0+map0idx*1,
             ind_arg0+map1idx*1,
             ind_arg0+map2idx*1,
             ind_arg1+map0idx*1,
             ind_arg1+map1idx*1,
             ind_arg1+map2idx*1,
             arg6+(n+offset_b)*1,
             arg7_l);
  }

  //global reductions

  for ( int d=0; d<1; d++ ){
    op_reduction<OP_MIN>(&arg7[d+blockIdx.x*1],arg7_l[d]);
  }
}


//host stub function
void op_par_loop_Timestep(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4,
  op_arg arg5,
  op_arg arg6,
  op_arg arg7){

  float*arg7h = (float *)arg7.data;
  int nargs = 8;
  op_arg args[8];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  args[5] = arg5;
  args[6] = arg6;
  args[7] = arg7;

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(25);
  op_timers_core(&cpu_t1, &wall_t1);
  OP_kernels[25].name      = name;
  OP_kernels[25].count    += 1;


  int    ninds   = 2;
  int    inds[8] = {0,0,0,1,1,1,-1,-1};

  if (OP_diags>2) {
    printf(" kernel routine with indirection: Timestep\n");
  }

  //get plan
  #ifdef OP_PART_SIZE_25
    int part_size = OP_PART_SIZE_25;
  #else
    int part_size = OP_part_size;
  #endif

  int set_size = op_mpi_halo_exchanges_grouped(set, nargs, args, 2);
  if (set_size > 0) {

    op_plan *Plan = op_plan_get(name,set,part_size,nargs,args,ninds,inds);

    //transfer global reduction data to GPU
    int maxblocks = 0;
    for ( int col=0; col<Plan->ncolors; col++ ){
      maxblocks = MAX(maxblocks,Plan->ncolblk[col]);
    }
    int reduct_bytes = 0;
    int reduct_size  = 0;
    reduct_bytes += ROUND_UP(maxblocks*1*sizeof(float));
    reduct_size   = MAX(reduct_size,sizeof(float));
    reallocReductArrays(reduct_bytes);
    reduct_bytes = 0;
    arg7.data   = OP_reduct_h + reduct_bytes;
    arg7.data_d = OP_reduct_d + reduct_bytes;
    for ( int b=0; b<maxblocks; b++ ){
      for ( int d=0; d<1; d++ ){
        ((float *)arg7.data)[d+b*1] = arg7h[d];
      }
    }
    reduct_bytes += ROUND_UP(maxblocks*1*sizeof(float));
    mvReductArraysToDevice(reduct_bytes);

    //execute plan

    int block_offset = 0;
    for ( int col=0; col<Plan->ncolors; col++ ){
      if (col==Plan->ncolors_core) {
        op_mpi_wait_all_grouped(nargs, args, 2);
      }
      #ifdef OP_BLOCK_SIZE_25
      int nthread = OP_BLOCK_SIZE_25;
      #else
      int nthread = OP_block_size;
      #endif

      dim3 nblocks = dim3(Plan->ncolblk[col] >= (1<<16) ? 65535 : Plan->ncolblk[col],
      Plan->ncolblk[col] >= (1<<16) ? (Plan->ncolblk[col]-1)/65535+1: 1, 1);
      if (Plan->ncolblk[col] > 0) {
        int nshared = MAX(Plan->nshared,reduct_size*nthread);
        op_cuda_Timestep<<<nblocks,nthread,nshared>>>(
        (float *)arg0.data_d,
        (float *)arg3.data_d,
        arg0.map_data_d,
        (float*)arg6.data_d,
        (float*)arg7.data_d,
        block_offset,
        Plan->blkmap,
        Plan->offset,
        Plan->nelems,
        Plan->nthrcol,
        Plan->thrcol,
        Plan->ncolblk[col],
        set->size+set->exec_size);

        //transfer global reduction data back to CPU
        if (col == Plan->ncolors_owned-1) {
          mvReductArraysToHost(reduct_bytes);
        }
      }
      block_offset += Plan->ncolblk[col];
    }
    OP_kernels[25].transfer  += Plan->transfer;
    OP_kernels[25].transfer2 += Plan->transfer2;
    for ( int b=0; b<maxblocks; b++ ){
      for ( int d=0; d<1; d++ ){
        arg7h[d] = MIN(arg7h[d],((float *)arg7.data)[d+b*1]);
      }
    }
    arg7.data = (char *)arg7h;
    op_mpi_reduce(&arg7,arg7h);
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  if (OP_diags>1) {
    cutilSafeCall(cudaDeviceSynchronize());
  }
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[25].time     += wall_t2 - wall_t1;
}