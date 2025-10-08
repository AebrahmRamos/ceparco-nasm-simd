# ceparco-nasm-simd
To be submitted in partial fulfillment of the requirements in Multiprocessing and Parallel Computing class (CEPARCO) using x86_64 ASM

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