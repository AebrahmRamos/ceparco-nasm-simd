#include <math.h>
#include <stddef.h>
#include "kernel.h"

void c_kernel(const float *A, const float *x, float *y, int n) {
    for (int i = 0; i < n; i++) {
        float sum = 0.0f;
        const float *row = A + (size_t)i * n;
        for (int j = 0; j < n; j++) {
            sum += row[j] * x[j];
        }
        y[i] = sum;
    }
}
