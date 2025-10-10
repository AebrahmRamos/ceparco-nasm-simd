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

