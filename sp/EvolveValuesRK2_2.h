inline void EvolveValuesRK2_2(const float *dT,const float *Lw_1, //OP_RW, discard
            const float *values, //OP_READ, discard
            const float *w_1, //OP_READ, discard
            float *out) //OP_WRITE

{
  out[0] = 0.5*(Lw_1[0] * *dT + w_1[0] + values[0]);
  out[1] = 0.5*(Lw_1[1] * *dT + w_1[1]*w_1[0] + values[1]*values[0]);
  out[2] = 0.5*(Lw_1[2] * *dT + w_1[2]*w_1[0] + values[2]*values[0]);
  out[3] = values[3];
  float TruncatedH = out[0] < EPS ? EPS : out[0];
  out[1] = out[1] / TruncatedH;
  out[2] = out[2] / TruncatedH;
}
