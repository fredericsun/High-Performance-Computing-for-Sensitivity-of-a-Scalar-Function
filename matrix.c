#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "../randoms/randoms.c"


int main(int argc, char *argv[]) {
    

    int N = 1024;
    int M = 10;
    int i, j;


    double** data = (double**)malloc(N * sizeof(double*));
    for (i = 0; i < N; i++) {
        data[i] = (double*)malloc(M * sizeof(double));
    }


    for(i = 0; i < N; i++){
            double temp;
            random_doubles(data[i], -100, 100, M, i+1);

            //debug info
            //printf("%lf ", data[i][j]);
    }

        //debug info
        //printf("\n");


    
    FILE* output = fopen("inputArray.inp", "w+");

    fprintf(output, "%d\n", N);
    fprintf(output, "%d\n", M);
    for(i = 0; i < N; i++){
        for(j = 0; j < M - 1; j++){
                fprintf(output, "%lf,", data[i][j]);
        }
        fprintf(output, "%lf", data[i][M - 1]);
        fprintf(output, "\n");
    }

    free(data);


    return 0;
}
