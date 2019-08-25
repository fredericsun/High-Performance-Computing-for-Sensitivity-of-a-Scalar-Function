#ifndef mykernel_h
#define mykernel_h

double f_eval(double* p_x, int m){
    // printf("%f, %f\n", p_x[0], p_x[1]);
    return (double)(p_x[0] * p_x[1] + p_x[2] * p_x[3] + p_x[4] * p_x[5] + p_x[6] * p_x[7] + p_x[8] * p_x[9]);
};


#endif
