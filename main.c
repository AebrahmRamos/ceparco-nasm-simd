#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <malloc.h>
#include <windows.h>

#include "kernel.h"

extern void asmfunc(const float *A, const float *x, float *y, int n);
extern void asm_xmm(const float *A, const float *x, float *y, int n);
extern void asm_ymm(const float *A, const float *x, float *y, int n);

static double now_seconds(void) {
    static LARGE_INTEGER freq = {0};
    LARGE_INTEGER t;
    if (freq.QuadPart == 0) QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&t);
    return (double)t.QuadPart / (double)freq.QuadPart;
}

void init_data(float *A, float *x, int n) {
    for (int i = 0; i < n; i++) {
        x[i] = sinf(i * 0.01f) * cosf(i * 0.007f) + 0.01f;
        for (int j = 0; j < n; j++) {
            A[i * n + j] = 1.0f / ((i + 1.0f) * (j + 1.0f));
        }
    }
}

int compare_vecs(const float *a, const float *b, int n) {
    for (int i = 0; i < n; i++) {
        float da = fabsf(a[i] - b[i]);
        if (da > 1e-4f) return 0;
    }
    return 1;
}

void print_head_tail(const float *y, int n) {
    int show = n < 3 ? n : 3;
    printf("first %d:\n", show);
    for (int i = 0; i < show; i++) {
        printf("  [%d] = %.6f\n", i, y[i]);
    }
    printf("last %d:\n", show);
    for (int i = n - show; i < n; i++) {
        printf("  [%d] = %.6f\n", i, y[i]);
    }
    printf("\n");
}

int main(int argc, char **argv) {
    int n = 256;
    if (argc > 1) n = atoi(argv[1]);
    const int runs = 30;

    size_t elems = (size_t)n * n;
    size_t bytesA = elems * sizeof(float);
    size_t bytesv = (size_t)n * sizeof(float);

    float *A = (float*)_aligned_malloc(bytesA, 32);
    float *x = (float*)_aligned_malloc(bytesv, 32);
    float *y_ref = (float*)_aligned_malloc(bytesv, 32);
    float *y = (float*)_aligned_malloc(bytesv, 32);
    if (!A || !x || !y_ref || !y) {
        fprintf(stderr, "allocation failed\n");
        return 1;
    }

    init_data(A, x, n);

    // reference C kernel
    double t0 = now_seconds();
    c_kernel(A, x, y_ref, n);
    double t1 = now_seconds();
    double dt = t1 - t0;
    double us = dt * 1e6;
    printf("C kernel time: %.3f us || %.9f s\n", us, dt);
    print_head_tail(y_ref, n);

    // nasm non simd (asmfunc)
    double total = 0.0;
    for (int r = 0; r < runs; r++) {
        double s = now_seconds();
        asmfunc(A, x, y, n);
        double e = now_seconds();
        total += (e - s);
    }
    dt = total / runs;
    us = dt * 1e6;
    printf("asm non-SIMD average time: %.3f us || %.9f s (runs=%d)\n", us, dt, runs);
    printf("asm non-SIMD correctness: %s\n", compare_vecs(y_ref, y, n) ? "OK" : "FAIL");
    print_head_tail(y, n);
    
    // nasm simd xmm register
    total = 0.0;
    printf("starting asm_xmm loop\n");
    for (int r = 0; r < runs; r++) {
        double s = now_seconds();
        asm_xmm(A, x, y, n);
        double e = now_seconds();
        total += (e - s);
    }
    printf("finished asm_xmm loop\n");
    dt = total / runs;
    us = dt * 1e6;
    printf("asm SSE/XMM average time: %.3f us || %.9f s (runs=%d)\n", us, dt, runs);
    printf("asm SSE/XMM correctness: %s\n", compare_vecs(y_ref, y, n) ? "OK" : "FAIL");
    print_head_tail(y, n);

    // nasm simd ymm register (AVX2)
    total = 0.0;
    printf("starting asm_ymm loop\n");
    for (int r = 0; r < runs; r++) {
        double s = now_seconds();
        asm_ymm(A, x, y, n);
        double e = now_seconds();
        total += (e - s);
    }
    printf("finished asm_ymm loop\n");
    dt = total / runs;
    us = dt * 1e6;
    printf("asm AVX2/YMM average time: %.3f us || %.9f s (runs=%d)\n", us, dt, runs);
    printf("asm AVX2/YMM correctness: %s\n", compare_vecs(y_ref, y, n) ? "OK" : "FAIL");
    if (!compare_vecs(y_ref, y, n) && n <= 64) {
        for (int i = 0; i < n; i++) {
            if (fabsf(y_ref[i] - y[i]) > 1e-4f) {
                printf("first mismatch at index %d: ref=%.6f ymm=%.6f\n", i, y_ref[i], y[i]);
                break;
            }
        }
    }
    print_head_tail(y, n);

    _aligned_free(A);
    _aligned_free(x);
    _aligned_free(y_ref);
    _aligned_free(y);
    return 0;
}