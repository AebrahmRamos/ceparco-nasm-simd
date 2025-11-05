
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

// *** C function version: y = A * x (row-major A, single precision)
void matvec(size_t m, size_t n, float *A, float *x, float *y)
{
    for (size_t i = 0; i < m; i++) {
        float sum = 0.0f;
        for (size_t j = 0; j < n; j++) {
            sum += A[i * n + j] * x[j];
        }
        y[i] = sum;
    }
}

int main(void)
{
    const size_t N = 4096;          // m = n = 256
    const size_t M = N;
    const size_t A_BYTES = M * N * sizeof(float);
    const size_t X_BYTES = N * sizeof(float);
    const size_t Y_BYTES = M * sizeof(float);
    const size_t loope = 30;       // for averaging

    // declare arrays
    float *A = (float*)malloc(A_BYTES);
    float *x = (float*)malloc(X_BYTES);
    float *y = (float*)malloc(Y_BYTES);

    clock_t start, end;

    // init
     for (size_t i = 0; i < M; i++){
        for (size_t j = 0; j < N; j++){
            A[i*N+ j] = sinf(i * 0.002f + j * 0.001f);
        }
    }
    for (size_t i = 0; i < N; i++)
        x[i] = cosf(i * 0.003f);

    // fill-in cache (warm-up)
    matvec(M, N, A, x, y);

    // time here
    double elapse = 0.0, time_taken = 0.0;
    for (size_t i = 0; i < loope; i++) {
        start = clock();
        matvec(M, N, A, x, y);
        end = clock();
        time_taken = ((double)(end - start)) * 1E3 / CLOCKS_PER_SEC;
        elapse += time_taken;
    }

    printf("Function (in C) average time for %lu loops is %f milliseconds to execute a matrix-vector with size %lux%lu \n",
           loope, elapse / loope, M, N);

    // show results: first 3 + last 3
    printf("y[0..2]   = %f %f %f\n", y[0], y[1], y[2]);
    printf("y[-3..-1] = %f %f %f\n", y[M-3], y[M-2], y[M-1]);

    // error checking
    size_t err_count = 0;
    for (size_t i = 0; i < M; i++) {
        float sum = 0.0f;
        for (size_t j = 0; j < N; j++) {
            sum += A[i * N + j] * x[j];
        }
        if (y[i] != sum)
            err_count++;
    }
    printf("Error count (C program): %lu\n", err_count);

    // Free memory
    free(A);
    free(x);
    free(y);
    return 0;
}
