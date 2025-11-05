#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// CUDA MATVEC kernel (grid-stride loop)
__global__
void matvec(size_t m, size_t n, const float *A, const float *x, float *y){
    int row  = blockIdx.x * blockDim.x + threadIdx.x;
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
    const size_t VECTOR_BYTES = n * sizeof(float);
    const size_t LOOPS = 30;

    float *A, *x, *y;
    cudaMallocManaged(&A, MATRIX_BYTES);
    cudaMallocManaged(&x, VECTOR_BYTES);
    cudaMallocManaged(&y, VECTOR_BYTES);

    int device = -1;
    cudaGetDevice(&device);

    //prefetch data to create cpu page memory
    cudaMemPrefetchAsync(A,MATRIX_BYTES,cudaCpuDeviceId,NULL);
    cudaMemPrefetchAsync(x,VECTOR_BYTES,cudaCpuDeviceId,NULL);

    //prefetch data to create gpu page memory
    cudaMemPrefetchAsync(y,MATRIX_BYTES,device,NULL);

    // Initialize A and x
    for (size_t i = 0; i < m; i++){
        for (size_t j = 0; j < n; j++){
            A[i*n + j] = sinf(i * 0.002f + j * 0.001f);
        }
    }
    for (size_t i = 0; i < n; i++)
        x[i] = cosf(i * 0.003f);

    //Prefetch data from cpu-gpu
    cudaMemPrefetchAsync(A,MATRIX_BYTES,device,NULL);
    cudaMemPrefetchAsync(x,VECTOR_BYTES,device,NULL);

    // CUDA kernel launch setup
    size_t numThreads = 1024;
    size_t numBlocks = (m + numThreads - 1) / numThreads;

    printf("*** function = MATVEC (float)\n");
    printf("m = %lu, n = %lu (A elements = %lu)\n", m, n, MATRIX_SIZE);
    printf("numBlocks = %lu, numThreads = %lu\n",
           (unsigned long)numBlocks, (unsigned long)numThreads);

    // Multiple runs for nvprof timing
    for (size_t i = 0; i < LOOPS; i++)
        matvec<<<numBlocks, numThreads>>>(m, n, A, x, y);

    cudaDeviceSynchronize();

    //prefetch data from gpu-cpu
    cudaMemPrefetchAsync(A,MATRIX_BYTES,cudaCpuDeviceId,NULL);
    cudaMemPrefetchAsync(A,VECTOR_BYTES,cudaCpuDeviceId,NULL);
    cudaMemPrefetchAsync(A,MATRIX_BYTES,cudaCpuDeviceId,NULL);

    // Print first 3 and last 3 results (error check like SIMP spec requirement idk if still needed)
    printf("y[0..2] = { %f, %f, %f }\n", y[0], y[1], y[2]);
    printf("y[-3..-1] = { %f, %f, %f }\n", y[m-3], y[m-2], y[m-1]);

    //Floating-point tolerant error check
    float tol = 1e-3f;
    size_t err_count = 0;

    for (size_t i = 0; i < m; i++){
        float ref = 0.0f;
        for (size_t j = 0; j < n; j++){
            ref += A[i*n + j] * x[j];
        }
        if (fabsf(ref - y[i]) > tol)
            err_count++;
    }

    printf("Error count (CUDA program): %lu\n", (unsigned long)err_count);

    cudaFree(A);
    cudaFree(x);
    cudaFree(y);
    return 0;
}
