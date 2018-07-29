//
// auto-generated by op2.py
//

//user function
__device__ void computeGradient_gpu( const float *center,
                            const float *neighbour1,
                            const float *neighbour2,
                            const float *neighbour3,
                            const float *cellCenter,
                            const float *nb1Center,
                            const float *nb2Center,
                            const float *nb3Center,
                            float *q, float *out) {


  if( cellCenter[0] != nb3Center[0] && cellCenter[1] != nb3Center[1]){
    float total, Rhs[8];
    float dh[3], dz[3],du[3], dv[3], weights[3];
    float Gram[2][2], inverse[2][2], delta[3][2];
    float x = cellCenter[0];
    float y = cellCenter[1];

    delta[0][0] =  (nb1Center[0] - x);
    delta[0][1] =  (nb1Center[1] - y);

    delta[1][0] =  (nb2Center[0] - x);
    delta[1][1] =  (nb2Center[1] - y);

    delta[2][0] =  (nb3Center[0] - x);
    delta[2][1] =  (nb3Center[1] - y);


    weights[0] = sqrt(delta[0][0] * delta[0][0] + delta[0][1] * delta[0][1]);
    weights[1] = sqrt(delta[1][0] * delta[1][0] + delta[1][1] * delta[1][1]);
    weights[2] = sqrt(delta[2][0] * delta[2][0] + delta[2][1] * delta[2][1]);

    total = weights[0] + weights[1] + weights[2];
    weights[0] = total/weights[0];
    weights[1] = total/weights[1];
    weights[2] = total/ weights[2];

    delta[0][0] *= weights[0];
    delta[0][1] *= weights[0];

    delta[1][0] *= weights[1];
    delta[1][1] *= weights[1];

    delta[2][0] *= weights[2];
    delta[2][1] *= weights[2];

    Gram[0][0] = ((delta[0][0]*delta[0][0]) + (delta[1][0] *delta[1][0]) + (delta[2][0] *delta[2][0]));
    Gram[0][1] = ((delta[0][0]*delta[0][1]) + (delta[1][0] *delta[1][1]) + (delta[2][0] *delta[2][1]));
    Gram[1][0] = ((delta[0][0]*delta[0][1]) + (delta[1][0] *delta[1][1]) + (delta[2][0] *delta[2][1]));
    Gram[1][1] = ((delta[0][1]*delta[0][1]) + (delta[1][1] *delta[1][1]) + (delta[2][1] *delta[2][1]));

    float det = 1.0 / (Gram[0][0]*Gram[1][1] - Gram[0][1]*Gram[1][0]);
    inverse[0][0] = det * Gram[1][1];
    inverse[0][1] = det * (- Gram[0][1]);
    inverse[1][0] = det * (-Gram[1][0]);
    inverse[1][1] = det * Gram[0][0];

    dh[0] = neighbour1[0] - center[0];
    dh[1] = neighbour2[0] - center[0];
    dh[2] = neighbour3[0] - center[0];
    dh[0] *= weights[0];
    dh[1] *= weights[1];
    dh[2] *= weights[2];

    dz[0] = neighbour1[3] - center[3];
    dz[1] = neighbour2[3] - center[3];
    dz[2] = neighbour3[3] - center[3];
    dz[0] *= weights[0];
    dz[1] *= weights[1];
    dz[2] *= weights[2];

    du[0] = neighbour1[1] - center[1];
    du[1] = neighbour2[1] - center[1];
    du[2] = neighbour3[1] - center[1];
    du[0] *= weights[0];
    du[1] *= weights[1];
    du[2] *= weights[2];

    dv[0] = neighbour1[2] - center[2];
    dv[1] = neighbour2[2] - center[2];
    dv[2] = neighbour3[2] - center[2];
    dv[0] *= weights[0];
    dv[1] *= weights[1];
    dv[2] *= weights[2];

    Rhs[0] = (delta[0][0]*dh[0]) + (delta[1][0]*dh[1]) + (delta[2][0]*dh[2]);
    Rhs[1] = (delta[0][1]*dh[0]) + (delta[1][1]*dh[1]) + (delta[2][1]*dh[2]);
    out[0] = (inverse[0][0] * Rhs[0]) + (inverse[0][1] * Rhs[1]);
    out[1] = (inverse[1][0] * Rhs[0]) + (inverse[1][1] * Rhs[1]);

    Rhs[2] = (delta[0][0]*du[0]) + (delta[1][0]*du[1]) + (delta[2][0]*du[2]);
    Rhs[3] = (delta[0][1]*du[0]) + (delta[1][1]*du[1]) + (delta[2][1]*du[2]);
    out[2] = (inverse[0][0] * Rhs[2]) + (inverse[0][1] * Rhs[3]);
    out[3] = (inverse[1][0] * Rhs[2]) + (inverse[1][1] * Rhs[3]);

    Rhs[4] = (delta[0][0]*dv[0]) + (delta[1][0]*dv[1]) + (delta[2][0]*dv[2]);
    Rhs[5] = (delta[0][1]*dv[0]) + (delta[1][1]*dv[1]) + (delta[2][1]*dv[2]);
    out[4] = (inverse[0][0] * Rhs[4]) + (inverse[0][1] * Rhs[5]);
    out[5] = (inverse[1][0] * Rhs[4]) + (inverse[1][1] * Rhs[5]);

    Rhs[6] = (delta[0][0]*dz[0]) + (delta[1][0]*dz[1]) + (delta[2][0]*dz[2]);
    Rhs[7] = (delta[0][1]*dz[0]) + (delta[1][1]*dz[1]) + (delta[2][1]*dz[2]);
    out[6] = (inverse[0][0] * Rhs[6]) + (inverse[0][1] * Rhs[7]);
    out[7] = (inverse[1][0] * Rhs[6]) + (inverse[1][1] * Rhs[7]);
 }else {

    out[0] = 0.0f;
    out[1] = 0.0f;
    out[2] = 0.0f;
    out[3] = 0.0f;
    out[4] = 0.0f;
    out[5] = 0.0f;
    out[6] = 0.0f;
    out[7] = 0.0f;
 }





  q[0] = center[0] < neighbour1[0] ? center[0] : neighbour1[0];
  q[0] = q[0] < neighbour2[0] ? q[0] : neighbour2[0];
  q[0] = q[0] < neighbour3[0] ? q[0] : neighbour3[0];
  q[1] = center[0] > neighbour1[0] ? center[0] : neighbour1[0];
  q[1] = q[1] > neighbour2[0] ? q[1] : neighbour2[0];
  q[1] = q[1] > neighbour3[0] ? q[1] : neighbour3[0];

  q[2] = center[1] < neighbour1[1] ? center[1] : neighbour1[1];
  q[2] = q[2] < neighbour2[1] ? q[2] : neighbour2[1];
  q[2] = q[2] < neighbour3[1] ? q[2] : neighbour3[1];
  q[3] = center[1] > neighbour1[1] ? center[1] : neighbour1[1];
  q[3] = q[3] > neighbour2[1] ? q[3] : neighbour2[1];
  q[3] = q[3] > neighbour3[1] ? q[3] : neighbour3[1];

  q[4] = center[2] < neighbour1[2] ? center[2] : neighbour1[2];
  q[4] = q[4] < neighbour2[2] ? q[4] : neighbour2[2];
  q[4] = q[4] < neighbour3[2] ? q[4] : neighbour3[2];
  q[5] = center[2] > neighbour1[2] ? center[2] : neighbour1[2];
  q[5] = q[5] > neighbour2[2] ? q[5] : neighbour2[2];
  q[5] = q[5] > neighbour3[2] ? q[5] : neighbour3[2];

  q[6] = center[3] < neighbour1[3] ? center[3] : neighbour1[3];
  q[6] = q[6] < neighbour2[3] ? q[6] : neighbour2[3];
  q[6] = q[6] < neighbour3[3] ? q[6] : neighbour3[3];
  q[7] = center[3] > neighbour1[3] ? center[3] : neighbour1[3];
  q[7] = q[7] > neighbour2[3] ? q[7] : neighbour2[3];
  q[7] = q[7] > neighbour3[3] ? q[7] : neighbour3[3];
}

// CUDA kernel function
__global__ void op_cuda_computeGradient(
  const float *__restrict ind_arg0,
  const float *__restrict ind_arg1,
  const int *__restrict opDat1Map,
  const float *__restrict arg0,
  const float *__restrict arg4,
  float *arg8,
  float *arg9,
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
    int map1idx;
    int map2idx;
    int map3idx;
    map1idx = opDat1Map[n + offset_b + set_size * 0];
    map2idx = opDat1Map[n + offset_b + set_size * 1];
    map3idx = opDat1Map[n + offset_b + set_size * 2];


    //user-supplied kernel call
    computeGradient_gpu(arg0+(n+offset_b)*4,
                    ind_arg0+map1idx*4,
                    ind_arg0+map2idx*4,
                    ind_arg0+map3idx*4,
                    arg4+(n+offset_b)*2,
                    ind_arg1+map1idx*2,
                    ind_arg1+map2idx*2,
                    ind_arg1+map3idx*2,
                    arg8+(n+offset_b)*8,
                    arg9+(n+offset_b)*8);
  }
}


//host stub function
void op_par_loop_computeGradient(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4,
  op_arg arg5,
  op_arg arg6,
  op_arg arg7,
  op_arg arg8,
  op_arg arg9){

  int nargs = 10;
  op_arg args[10];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  args[5] = arg5;
  args[6] = arg6;
  args[7] = arg7;
  args[8] = arg8;
  args[9] = arg9;

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(5);
  op_timers_core(&cpu_t1, &wall_t1);
  OP_kernels[5].name      = name;
  OP_kernels[5].count    += 1;


  int    ninds   = 2;
  int    inds[10] = {-1,0,0,0,-1,1,1,1,-1,-1};

  if (OP_diags>2) {
    printf(" kernel routine with indirection: computeGradient\n");
  }

  //get plan
  #ifdef OP_PART_SIZE_5
    int part_size = OP_PART_SIZE_5;
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
      #ifdef OP_BLOCK_SIZE_5
      int nthread = OP_BLOCK_SIZE_5;
      #else
      int nthread = OP_block_size;
      #endif

      dim3 nblocks = dim3(Plan->ncolblk[col] >= (1<<16) ? 65535 : Plan->ncolblk[col],
      Plan->ncolblk[col] >= (1<<16) ? (Plan->ncolblk[col]-1)/65535+1: 1, 1);
      if (Plan->ncolblk[col] > 0) {
        op_cuda_computeGradient<<<nblocks,nthread>>>(
        (float *)arg1.data_d,
        (float *)arg5.data_d,
        arg1.map_data_d,
        (float*)arg0.data_d,
        (float*)arg4.data_d,
        (float*)arg8.data_d,
        (float*)arg9.data_d,
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
    OP_kernels[5].transfer  += Plan->transfer;
    OP_kernels[5].transfer2 += Plan->transfer2;
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  cutilSafeCall(cudaDeviceSynchronize());
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[5].time     += wall_t2 - wall_t1;
}
