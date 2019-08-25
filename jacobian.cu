#include <cuda.h>
#include <stdio.h>
#include <math.h>
#include "f_eval.cuh"

__global__ void kernelCompute_shared(double h, int N, int M, double* d_data, double* d_out) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    extern __shared__ double shared_data[];
    shared_data[threadIdx.x] = d_data[index];
    __syncthreads();

    if (index < N * M) {
        int which_m = threadIdx.x / M; 
        int position = threadIdx.x - which_m * M;

        double* temp_array = (double*)malloc(sizeof(double) * M);
        memcpy(temp_array, shared_data + which_m * M, M * sizeof(double));

        double temp_minus = temp_array[position] - h;
        double temp_plus = temp_array[position] + h;

        temp_array[position] = temp_minus;
        double output_minus = f_eval(temp_array, M);

        temp_array[position] = temp_plus;
        double output_plus = f_eval(temp_array, M);

        free(temp_array);

        double output = (output_plus - output_minus) / (2 * h);

        d_out[index] = output;
    }
}

__global__ void kernelCompute(double h, int N, int M, double* d_data, double* d_out) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;

    if (index < N * M) {
        double* temp_array = (double*)malloc(sizeof(double) * M);
        memcpy(temp_array, d_data + (index / M * M), M * sizeof(double));

        double temp_minus = temp_array[index - index / M * M] - h;
        double temp_plus = temp_array[index - index / M * M] + h;

        temp_array[index - index / M * M] = temp_minus;
        double output_minus = f_eval(temp_array, M);

        temp_array[index - index / M * M] = temp_plus;
        double output_plus = f_eval(temp_array, M);

        double output = (output_plus - output_minus) / (2 * h);

        d_out[index] = output;

        free(temp_array);

        /* Old verison

        double* temp_minus = (double*)malloc(sizeof(double) * M);
        memcpy(temp_minus, d_data + (index / M * M), M * sizeof(double));
        double t_minus = temp_minus[index - index / M * M];
        temp_minus[index - index / M * M] = t_minus - h;

        double* temp_plus = (double*)malloc(sizeof(double) * M);
        memcpy(temp_plus, d_data + (index / M * M), M * sizeof(double));
        double t_plus = temp_plus[index - index / M * M];
        temp_plus[index - index / M * M] = t_plus + h;

        double output = (f_eval(temp_plus, M) - f_eval(temp_minus, M));

        // printf("%d, %f, %f\n", index - index / M * M, temp_plus[index - index / M * M], temp_minus[index - index / M * M]);
        // printf("%d, %f\n", index, f_eval(temp_plus, M) - f_eval(temp_minus, M));

        d_out[index] = output / (2 * h);
        
        */
    }
}

int main(int argc, char *argv[]) {
    if(argc != 4){
        printf("Input is not correct!\n");
        exit(1);
    }

    FILE* input = fopen(argv[1], "r");
    if (input == NULL) {
        perror("Error: Read File Error");
        exit(1);
    }

    int N = 0;
    int M = 0;

    fscanf(input, "%d", &N);
    fscanf(input, "%d", &M);

    //printf("%d, %d\n", N, M);

    /* 2D array
    double** data = (double**)malloc(N * sizeof(double*));
    for (i = 0; i < N; i++) {
        data[i] = (double*)malloc(M * sizeof(double));
    }

    for(i = 0; i < N; i++){
        for(j = 0; j < M ; j++){
            double temp = 0.0f;
            fscanf(input, "%lf,", &temp);
            data[i][j] = (double)temp;

            //debug info
            //printf("%lf ", data[i][j]);
        }

        //debug info
        //printf("\n");
    }

    //printf("%f\n", f_eval(data[i], M));
    */

    double* data = (double*)malloc(N * M * sizeof(double));
    for(int i = 0; i < N * M; i++){
        double temp = 0.0f;
        fscanf(input, "%lf,", &temp);
        data[i] = (double)temp;
    }

    fclose(input);
    
    FILE* output = fopen(argv[2], "w");
    double h = (double)atof(argv[3]);
    // printf("h on host is: %f\n", h);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    double* d_data;
    cudaMalloc((void**)&d_data, sizeof(double) * N * M);
    
    double* d_out;
    cudaMalloc((void**)&d_out, sizeof(double) * N * M);

    cudaMemcpy(d_data, data, sizeof(double) * N * M, cudaMemcpyHostToDevice);

    cudaEventRecord(start, 0);

    if (M < 1024) {
        int block_size = 1024 / M * M;
        kernelCompute_shared<<<(N * M + block_size - 1) / block_size, block_size, block_size * sizeof(double)>>>(h, N, M, d_data, d_out);
    }
    else {
        kernelCompute<<<(N * M + 1023) / 1024, 1024>>>(h, N, M, d_data, d_out);
    }

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop); 

    double* out = (double*)malloc(N * M * sizeof(double));
    cudaMemcpy(out, d_out, sizeof(double) * N * M, cudaMemcpyDeviceToHost);

    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    printf("Time spent: %f\n", elapsedTime);

    for(int i = 0; i < N * M; i++){
        if ((i + 1) % M == 0){
            fprintf(output, "%f\n", out[i]);
        }
        else {
            fprintf(output, "%f ", out[i]);
        }
    }

    free(data);
    free(out);
    cudaFree(d_data);
    cudaFree(d_out);

    // FILE* input_long = fopen("input_long", "w");
    // for(int i = 0; i < 1000; i++) {
    //     fprintf(input_long, "p_x[%d] + ", i);
    // }

    return 0;
}
