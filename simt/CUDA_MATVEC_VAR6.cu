#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

// CUDA MATVEC kernel (grid-stride loop)
__global__
void matvec(size_t m, size_t n, const float *A, const float *x, float *y){
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = row; i < (int)m; i += stride){
        float sum = 0.0f;
        for (size_t j = 0; j < n; j++){
            sum += A[i*n + j] * x[j];
        }
        y[i] = sum;
    }
}

int main() {
    const size_t m = 4096;
    const size_t n = 4096;
    const size_t MATRIX_SIZE = m * n;
    const size_t MATRIX_BYTES = MATRIX_SIZE * sizeof(float);
    const size_t X_BYTES = n * sizeof(float);
    const size_t Y_BYTES = m * sizeof(float);
    const size_t LOOPS = 30;

    // Host memory allocation
    float *h_A = (float*)malloc(MATRIX_BYTES);
    float *h_x = (float*)malloc(X_BYTES);
    float *h_y = (float*)malloc(Y_BYTES);

    // Initialize A and x on host
    for (size_t i = 0; i < m; i++)
        for (size_t j = 0; j < n; j++)
            h_A[i*n + j] = sinf(i * 0.002f + j * 0.001f);

    for (size_t i = 0; i < n; i++)
        h_x[i] = cosf(i * 0.003f);

    for (size_t i = 0; i < m; i++)
        h_y[i] = 0.0f;

    // Device memory allocation
    float *d_A, *d_x, *d_y;
    cudaMalloc(&d_A, MATRIX_BYTES);
    cudaMalloc(&d_x, X_BYTES);
    cudaMalloc(&d_y, Y_BYTES);

    // Copy data from host to device
    cudaMemcpy(d_A, h_A, MATRIX_BYTES, cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, X_BYTES, cudaMemcpyHostToDevice);
    cudaMemset(d_y, 0, Y_BYTES);

    // CUDA kernel launch setup
    size_t numThreads = 1024;
    size_t numBlocks = (m + numThreads - 1) / numThreads;

    printf("*** VARIANT 5: MATVEC with Classic MemCopy (No Unified Memory)\n");
    printf("m = %lu, n = %lu (A elements = %lu)\n", m, n, MATRIX_SIZE);
    printf("numBlocks = %lu, numThreads = %lu\n",
           (unsigned long)numBlocks, (unsigned long)numThreads);

    for (size_t i = 0; i < LOOPS; i++)
        matvec<<<numBlocks, numThreads>>>(m, n, d_A, d_x, d_y);

    cudaDeviceSynchronize();

    cudaMemcpy(h_y, d_y, Y_BYTES, cudaMemcpyDeviceToHost);

    printf("y[0] = %.8e, y[%lu] = %.8e, y[%lu] = %.8e\n",
       h_y[0], m-1, h_y[m-1], m/2, h_y[m/2]);


    size_t err_count = 0;
    float max_rel_err = 0.0f;
    for (size_t i = 0; i < m; i++){
        float ref = 0.0f;
        for (size_t j = 0; j < n; j++)
            ref += h_A[i*n + j] * h_x[j];

        // Use relative error for better comparison
        float abs_err = fabsf(ref - h_y[i]);
        float rel_err = abs_err / fmaxf(1.0f, fabsf(ref));

        if (rel_err > 1e-4f)  // 0.01% relative tolerance
            err_count++;

        max_rel_err = fmaxf(max_rel_err, rel_err);
}

printf("Error count (Variant 5): %lu\n", (unsigned long)err_count);
printf("Max relative error: %.6e\n", max_rel_err);

    cudaFree(d_A);
    cudaFree(d_x);
    cudaFree(d_y);
    free(h_A);
    free(h_x);
    free(h_y);

    return 0;
}
