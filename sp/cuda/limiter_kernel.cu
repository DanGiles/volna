//
// auto-generated by op2.py
//

//user function
__device__ void limiter_gpu( const float *q, float *lim,
                    const float *value, const float *gradient,
                    const float *edgecenter1, const float *edgecenter2,
                    const float *edgecenter3, const float *cellcenter) {

  float facevalue[3], dx[3], dy[3];
  int i, j;
  float max[3], edgealpha[3];

  dx[0] = (edgecenter1[0] - cellcenter[0]);
  dy[0] = (edgecenter1[1] - cellcenter[1]);
  dx[1] = (edgecenter2[0] - cellcenter[0]);
  dy[1] = (edgecenter2[1] - cellcenter[1]);
  dx[2] = (edgecenter3[0] - cellcenter[0]);
  dy[2] = (edgecenter3[1] - cellcenter[1]);

  if((value[0] > EPS) && (q[0]> EPS)){






  for(j=0;j<4;j++){
   for(i =0 ; i<3; i++){
    facevalue[i] = value[j] + ((gradient[2*j]*dx[i]) + (gradient[2*j + 1]*dy[i]));
     if(facevalue[i] > value[j]) {
      edgealpha[i] = (q[2*j + 1] - value[j]) / (facevalue[i] - value[j]);
     } else if (facevalue[i] < value[j]){
      edgealpha[i] = (q[2*j] - value[j]) / (facevalue[i] - value[j]);
     } else{
      edgealpha[i] = 1.0f;
     }
    max[i] = edgealpha[i] < 1.0f ? edgealpha[i] : 1.0f;
   }
   lim[j] = max[0] < max[1] ? max[0] : max[1];
   lim[j] = lim[j] < max[2] ? lim[j]: max[2];
  }
  lim[0] = lim[0] < lim[1] ? lim[0]: lim[1];
  lim[0] = lim[0] < lim[2] ? lim[0]: lim[2];
  lim[0] = lim[0] < lim[3] ? lim[0]: lim[3];

  } else {
    lim[0] = 0.0f;
    lim[1] = 0.0f;
    lim[2] = 0.0f;
    lim[3] = 0.0f;
  }
}

// CUDA kernel function
__global__ void op_cuda_limiter(
  const float *__restrict ind_arg0,
  const int *__restrict opDat4Map,
  const float *__restrict arg0,
  float *arg1,
  const float *__restrict arg2,
  const float *__restrict arg3,
  const float *__restrict arg7,
  int    block_offset,
  int   *blkmap,
  int   *offset,
  int   *nelems,
  int   *ncolors,
  int   *colors,
  int   nblocks,
  int   set_size) {

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
    int map4idx;
    int map5idx;
    int map6idx;
    map4idx = opDat4Map[n + offset_b + set_size * 0];
    map5idx = opDat4Map[n + offset_b + set_size * 1];
    map6idx = opDat4Map[n + offset_b + set_size * 2];


    //user-supplied kernel call
    limiter_gpu(arg0+(n+offset_b)*8,
            arg1+(n+offset_b)*4,
            arg2+(n+offset_b)*4,
            arg3+(n+offset_b)*8,
            ind_arg0+map4idx*2,
            ind_arg0+map5idx*2,
            ind_arg0+map6idx*2,
            arg7+(n+offset_b)*2);
  }
}


//host stub function
void op_par_loop_limiter(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4,
  op_arg arg5,
  op_arg arg6,
  op_arg arg7){

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
  op_timing_realloc(22);
  op_timers_core(&cpu_t1, &wall_t1);
  OP_kernels[22].name      = name;
  OP_kernels[22].count    += 1;


  int    ninds   = 1;
  int    inds[8] = {-1,-1,-1,-1,0,0,0,-1};

  if (OP_diags>2) {
    printf(" kernel routine with indirection: limiter\n");
  }

  //get plan
  #ifdef OP_PART_SIZE_22
    int part_size = OP_PART_SIZE_22;
  #else
    int part_size = OP_part_size;
  #endif

  int set_size = op_mpi_halo_exchanges_cuda(set, nargs, args);
  if (set->size > 0) {

    op_plan *Plan = op_plan_get(name,set,part_size,nargs,args,ninds,inds);

    //execute plan

    int block_offset = 0;
    for ( int col=0; col<Plan->ncolors; col++ ){
      if (col==Plan->ncolors_core) {
        op_mpi_wait_all_cuda(nargs, args);
      }
      #ifdef OP_BLOCK_SIZE_22
      int nthread = OP_BLOCK_SIZE_22;
      #else
      int nthread = OP_block_size;
      #endif

      dim3 nblocks = dim3(Plan->ncolblk[col] >= (1<<16) ? 65535 : Plan->ncolblk[col],
      Plan->ncolblk[col] >= (1<<16) ? (Plan->ncolblk[col]-1)/65535+1: 1, 1);
      if (Plan->ncolblk[col] > 0) {
        op_cuda_limiter<<<nblocks,nthread>>>(
        (float *)arg4.data_d,
        arg4.map_data_d,
        (float*)arg0.data_d,
        (float*)arg1.data_d,
        (float*)arg2.data_d,
        (float*)arg3.data_d,
        (float*)arg7.data_d,
        block_offset,
        Plan->blkmap,
        Plan->offset,
        Plan->nelems,
        Plan->nthrcol,
        Plan->thrcol,
        Plan->ncolblk[col],
        set->size+set->exec_size);

      }
      block_offset += Plan->ncolblk[col];
    }
    OP_kernels[22].transfer  += Plan->transfer;
    OP_kernels[22].transfer2 += Plan->transfer2;
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  cutilSafeCall(cudaDeviceSynchronize());
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[22].time     += wall_t2 - wall_t1;
}
