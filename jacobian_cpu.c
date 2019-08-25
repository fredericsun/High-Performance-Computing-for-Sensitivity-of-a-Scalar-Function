#define _POSIX_C_SOURCE 201902L
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include "f_eval.h"

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
    int i, j;

    fscanf(input, "%d", &N);
    fscanf(input, "%d", &M);

    //printf("%d, %d\n", N, M);


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


    fclose(input);
    
    FILE* output_file = fopen(argv[2], "a+");
    double h = (double)atof(argv[3]);


    double** out = (double**)malloc(N * sizeof(double*));
    for (i = 0; i < N; i++) {
        out[i] = (double*)malloc(M * sizeof(double));
    }
    struct timespec start;
    struct timespec end;
    float mtime = 0.0;

    clock_gettime(CLOCK_MONOTONIC, &start);
    for(i = 0; i < N; i++){
        for(j = 0; j < M; j++){

            data[i][j]=  data[i][j] + h;

            double temp_a = f_eval(data[i], M);
            //printf("%lf, %lf\n", temp_a, data[i][j]);
            data[i][j] = data[i][j] - 2*h;
            double temp_b = f_eval(data[i], M);
            //printf("%lf, %lf\n", temp_b, data[i][j]);
            data[i][j] = data[i][j] + h;
            double output = (temp_a - temp_b)/(2 *  h);
            out[i][j] = output; 

        }
    }
    
    clock_gettime(CLOCK_MONOTONIC, &end);

    float ntime = end.tv_nsec - start.tv_nsec;

    float stime = end.tv_sec - start.tv_sec;

    mtime = stime + ntime / 1000000000;
    printf("%d, %d, %f\n", N, M, mtime);

    for(i = 0; i < N; i++){
       for(j = 0; j < M ; j++){
               fprintf(output_file, "%lf", out[i][j]);
               if (j == M - 1) {
                   fprintf(output_file, "\n");
               }
               else {
                   fprintf(output_file, ", ");
               }
       }
    }

    free(data);
    free(out);
    fclose(output_file);


    return 0;
}
