# ceparco-nasm-simd
To be submitted in partial fulfillment of the requirements in Multiprocessing and Parallel Computing class (CEPARCO) using x86_64 ASM

Instead of having to run the programs one by one and having to opt for the correctness check for each run. We've made it so that the timing and the correctness check of all the files (c kernel, non vec, xmm, and ymm) would be done in one run. The way the correctness check is done is through the vector comparison function in the main.c program
```
int compare_vecs(const float *a, const float *b, int n) {
    for (int i = 0; i < n; i++) {
        float da = fabsf(a[i] - b[i]);
        if (da > 1e-4f) return 0;
    }
    return 1;
}
```

## Build and Run
To build and run with n=30 (n being the number of times th code runs)

#### Using the Powershell file
```
pwsh -NoProfile -ExecutionPolicy Bypass-File .\build.ps1 -Run -N 30
```

Sample Run
```
PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> pwsh -NoProfile -ExecutionPolicy Bypass -File .\build.ps1 -Run -N 8 
Assembling...
  nasm -f win64 -o NonVec.o NonVec.asm
  nasm -f win64 -o asm_xmm.o asm_xmm.asm
  nasm -f win64 -o asm_ymm.o asm_ymm.asm
Compiling and linking...
  gcc -O -std=c17 -o simd.exe main.c c_kernel.c NonVec.o asm_xmm.o asm_ymm.o
Build succeeded: simd.exe
Running simd.exe with n=8 ...
C kernel time: 0.100 us || 0.000000100 s
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

asm non-SIMD average time: 0.167 us || 0.000000167 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 0.097 us || 0.000000097 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 0.100 us || 0.000000100 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> 
```

#### Traditional Way
```
# ASM > Obj
nasm -f win64 -o NonVec.o NonVec.asm
nasm -f win64 -o asm_xmm.o asm_xmm.asm
nasm -f win64 -o asm_ymm.o asm_ymm.asm

# compile and link
gcc -O -std=c17 -o simd.exe main.c c_kernel.c NonVec.o asm_xmm.o asm_ymm.o

# run with N (N=30 usually)
.\simd.exe 30
```

Sample Run
```
PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> nasm -f win64 -o NonVec.o NonVec.asm
PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> nasm -f win64 -o asm_xmm.o asm_xmm.asm
PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> nasm -f win64 -o asm_ymm.o asm_ymm.asm
PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> gcc -O -std=c17 -o simd.exe main.c c_kernel.c NonVec.o asm_xmm.o asm_ymm.o
PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> .\simd.exe 30
C kernel time: 0.700 us || 0.000000700 s
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

asm non-SIMD average time: 1.467 us || 0.000001467 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 1.410 us || 0.000001410 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 0.463 us || 0.000000463 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

PS C:\Users\aebrahm\Documents\ceparco-nasm-simd> 
```

## Discuss the problems encountered and solutions made, unique methodologies used, aha moments, etc.
Since `NonVec.asm` was already working and have been finishedfirst, we used it as a baseline template for both xmm and ymm implementations. We ensure that it followed the same matrix-vector multiplication algorithm.

We had an issue with the xmm implementation only loading one vector into both registers in the assembly code. Upon diagnosis, both lines were using the same register (i forgot to change after copying the line). It also had a redundant mov rax, rax which we removed. 

For the ymm implementation, we had multiple crashes and incorrect outputs even after many attempts at fixing only to figureout that the cause is themissing pop rbp. We've also separatedthe vmul and the vadd instead of fma leading to a worse performance than the xmm implementation which shouldnt be the case. What we did to solve these problems is to add a proper push/pop for calle savedregisters,implemented fma,and ensured the use of vzeroupper .

For the main.c we didn't really have much problems here for running, building, and linking. The only problem we had was the timing seconds was showing 0.000000  for smallertimes. To solve, we've updated the print to printbothmicroseconds and nanoseconds.


## Benchmark Logs

### n=8
```
C kernel time: 0.200 us || 0.000000200 s
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

asm non-SIMD average time: 0.517 us || 0.000000517 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 0.093 us || 0.000000093 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 0.107 us || 0.000000107 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 0.079952
  [1] = 0.039976
  [2] = 0.026651
last 3:
  [5] = 0.013325
  [6] = 0.011422
  [7] = 0.009994
```

### n=16
```
C kernel time: 0.300 us || 0.000000300 s
first 3:
  [0] = 0.159535
  [1] = 0.079767
  [2] = 0.053178
last 3:
  [13] = 0.011395
  [14] = 0.010636
  [15] = 0.009971

asm non-SIMD average time: 0.590 us || 0.000000590 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 0.159535
  [1] = 0.079767
  [2] = 0.053178
last 3:
  [13] = 0.011395
  [14] = 0.010636
  [15] = 0.009971

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 0.193 us || 0.000000193 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 0.159535
  [1] = 0.079767
  [2] = 0.053178
last 3:
  [13] = 0.011395
  [14] = 0.010636
  [15] = 0.009971

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 0.230 us || 0.000000230 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 0.159535
  [1] = 0.079767
  [2] = 0.053178
last 3:
  [13] = 0.011395
  [14] = 0.010636
  [15] = 0.009971
```

### n=30
```
C kernel time: 1.000 us || 0.000000100 s
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

asm non-SIMD average time: 1.903 us || 0.000001903 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 0.407 us || 0.000000407 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 0.513 us || 0.000000513 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 0.296672
  [1] = 0.148336
  [2] = 0.098891
last 3:
  [27] = 0.010595
  [28] = 0.010230
  [29] = 0.009889
```

### n=64
```
C kernel time: 4.900 us || 0.000004900 s
first 3:
  [0] = 0.606847
  [1] = 0.303423
  [2] = 0.202282
last 3:
  [61] = 0.009788
  [62] = 0.009632
  [63] = 0.009482

asm non-SIMD average time: 9.613 us || 0.000009613 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 0.606847
  [1] = 0.303423
  [2] = 0.202282
last 3:
  [61] = 0.009788
  [62] = 0.009632
  [63] = 0.009482

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 2.080 us || 0.000002080 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 0.606847
  [1] = 0.303423
  [2] = 0.202282
last 3:
  [61] = 0.009788
  [62] = 0.009632
  [63] = 0.009482

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 0.890 us || 0.000000890 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 0.606847
  [1] = 0.303423
  [2] = 0.202282
last 3:
  [61] = 0.009788
  [62] = 0.009632
  [63] = 0.009482
```

### n=128
```
C kernel time: 22.000 us || 0.000022000 s
first 3:
  [0] = 1.035367
  [1] = 0.517684
  [2] = 0.345122
last 3:
  [125] = 0.008217
  [126] = 0.008152
  [127] = 0.008089

asm non-SIMD average time: 44.967 us || 0.000044967 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 1.035367
  [1] = 0.517684
  [2] = 0.345122
last 3:
  [125] = 0.008217
  [126] = 0.008152
  [127] = 0.008089

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 8.320 us || 0.000008320 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 1.035367
  [1] = 0.517683
  [2] = 0.345122
last 3:
  [125] = 0.008217
  [126] = 0.008152
  [127] = 0.008089

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 5.400 us || 0.000005400 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 1.035367
  [1] = 0.517683
  [2] = 0.345122
last 3:
  [125] = 0.008217
  [126] = 0.008152
  [127] = 0.008089
```

### n=256
```
C kernel time: 87.800 us || 0.000087800 s
first 3:
  [0] = 1.228584
  [1] = 0.614292
  [2] = 0.409528
last 3:
  [253] = 0.004837
  [254] = 0.004818
  [255] = 0.004799

asm non-SIMD average time: 99.333 us || 0.000099333 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 1.228584
  [1] = 0.614292
  [2] = 0.409528
last 3:
  [253] = 0.004837
  [254] = 0.004818
  [255] = 0.004799

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 31.500 us || 0.000031500 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 1.228584
  [1] = 0.614292
  [2] = 0.409528
last 3:
  [253] = 0.004837
  [254] = 0.004818
  [255] = 0.004799

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 13.723 us || 0.000013723 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 1.228584
  [1] = 0.614292
  [2] = 0.409528
last 3:
  [253] = 0.004837
  [254] = 0.004818
  [255] = 0.004799
```

### n=512
```
C kernel time: 333.500 us || 0.000333500 s
first 3:
  [0] = 1.516760
  [1] = 0.758380
  [2] = 0.505586
last 3:
  [509] = 0.002974
  [510] = 0.002968
  [511] = 0.002962

asm non-SIMD average time: 373.970 us || 0.000373970 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 1.516760
  [1] = 0.758380
  [2] = 0.505586
last 3:
  [509] = 0.002974
  [510] = 0.002968
  [511] = 0.002962

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 111.850 us || 0.000111850 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 1.516760
  [1] = 0.758380
  [2] = 0.505587
last 3:
  [509] = 0.002974
  [510] = 0.002968
  [511] = 0.002962

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 79.590 us || 0.000079590 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 1.516759
  [1] = 0.758380
  [2] = 0.505587
last 3:
  [509] = 0.002974
  [510] = 0.002968
  [511] = 0.002962
```

### n=1024
```
C kernel time: 1444.700 us || 0.001444700 s
first 3:
  [0] = 1.735650
  [1] = 0.867825
  [2] = 0.578549
last 3:
  [1021] = 0.001698
  [1022] = 0.001697
  [1023] = 0.001695

asm non-SIMD average time: 2196.107 us || 0.002196107 s (runs=30)
asm non-SIMD correctness: OK
first 3:
  [0] = 1.735650
  [1] = 0.867825
  [2] = 0.578549
last 3:
  [1021] = 0.001698
  [1022] = 0.001697
  [1023] = 0.001695

starting asm_xmm loop
finished asm_xmm loop
asm SSE/XMM average time: 574.537 us || 0.000574537 s (runs=30)
asm SSE/XMM correctness: OK
first 3:
  [0] = 1.735648
  [1] = 0.867824
  [2] = 0.578549
last 3:
  [1021] = 0.001698
  [1022] = 0.001697
  [1023] = 0.001695

starting asm_ymm loop
finished asm_ymm loop
asm AVX2/YMM average time: 217.173 us || 0.000217173 s (runs=30)
asm AVX2/YMM correctness: OK
first 3:
  [0] = 1.735648
  [1] = 0.867824
  [2] = 0.578549
last 3:
  [1021] = 0.001698
  [1022] = 0.001697
  [1023] = 0.001695
```

## Comparative Execution Time Table

| n    | C Kernel (us) | NonVec (us) | XMM (us) | YMM (us) |
|------|---------------|-------------|----------|----------|
| 8    | 0.200         | 0.517       | 0.093    | 0.107    |
| 16   | 0.300         | 0.590       | 0.193    | 0.230    |
| 30   | 1.000         | 1.903       | 0.407    | 0.513    |
| 64   | 4.900         | 9.613       | 2.080    | 0.890    |
| 128  | 22.000        | 44.967      | 8.320    | 5.400    |
| 256  | 87.800        | 99.333      | 31.500   | 13.723   |
| 512  | 333.500       | 373.970     | 111.850  | 79.590   |
| 1024 | 1444.700      | 2196.107    | 574.537  | 217.173  |

The result for ymm being faster than the rest on most n's is to be expected since we are processing less on ymm implementation with 256 bits. It's also expected for xmm to be neck and neck or even beat ymm in some test runs on lower n values since there are not much samples and may be biased. 


| Implementation    | Geometric Mean (time ratio vs c) | Average Speedup vs C | 
|------|---------------|-------------|
| Non-Vec    | 1.7149         | 0.563x (slower)       | 
| XMM   | 0.4181         | 2.39x faster      | 
| YMM   | 0.2918        | 3.43x faster      | 

From the results, YMM achieved the best performance with an average speedup of 3.43×, followed by XMM at 2.39×, while the Non-Vectorized version was slower than C at about 0.56×. This confirms that SIMD vectorization, especially with 256-bit YMM, significantly improves execution speed.


The results show that SIMD implementations significantly outperform the baseline C kernel, with performance improving as the register width increases. The YMM implementation, which operates on 256-bit registers, achieved the highest speedup of 3.43×, demonstrating its efficiency in parallel processing larger data chunks per instruction. The XMM version, using 128-bit registers, also showed a strong improvement at 2.39× faster than the C kernel, while the non-vectorized version performed slower due to its sequential computation. Overall, the trend confirms that wider vector registers lead to better throughput and reduced execution time, particularly for large data sizes


## Analysis of Results

The SIMD versions clearly ran faster than the non-vectorized one, especially as the input size increased. YMM performed best overall since it could handle more data per instruction. For smaller sizes, the difference was less noticeable because the setup overhead took more time. Overall, the results matched our expectations that wider vector registers lead to better performance in larger workloads.
