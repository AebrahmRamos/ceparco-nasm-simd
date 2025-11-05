#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <curand_kernel.h>

__global__ void initializeData( float *A, float *X, int m, int n)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = gridDim.x * blockDim.x;

    for (int i = idx; i < n; i += stride) {
        X[i] = sinf(i * 0.01f) * cosf(i * 0.007f) + 0.01f;
    }

    for (int i = idx; i < m * n; i += stride) {
        int row = i / n; // Calculate row
        int col = i % n; // Calculate col
        A[i] = 1.0f / ((row + 1.0f) * (col + 1.0f));
    }
}
