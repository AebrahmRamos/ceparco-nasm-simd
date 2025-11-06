## 0) Administrative

- Group members
	- Manaois, Raidon
	- Ramos, Aebrahm Clyde P.
	- Reyes, Cyril Sam N
- Project specifications
	- Problem: 
    - other specs
- AI usage declaration
	- Gemini
        - Used for explaining the contents of the discovery series notebook, tutorial notebook, and cuda documentaiton
        - Used for generating the Markdown formatting and layout of the ReadMe

## i) Program output screenshots (correctness + timing)

- screenshots/
	- output_c.png                — C baseline output + time
	- output_x86_scalar.png       — x86-64 scalar
	- output_xmm.png              — x86-64 SIMD XMM
	- output_ymm.png              — x86-64 SIMD YMM
	- simt/nvprof-var2.png        — CUDA Unified output
	- simt/nvprof-var3.png        — CUDA Prefetch output
	- simt/nvprof-var4.png        — CUDA Prefetch + page creation
	- simt/nvprof-var5.png        — CUDA Prefetch + page + memadvise
	- simt/nvprof-var6.png        — CUDA classic memcpy output
	- nsight/nsight-var2.png     — Nsight report: CUDA Unified
	- nsight/nsight-var3.png     — Nsight report: CUDA Prefetch
	- nsight/nsight-var4.png     — Nsight report: CUDA Page creation
	- nsight/nsight-var5.png     — Nsight report: CUDA MemAdvise
	- nsight/nsight-var6.png     — Nsight report: CUDA memcpy

![Output of C](screenshots/upload/output_c.png)

![Output of x86-64 scalar](screenshots/upload/output_x86_scalar.png)

![Output of x86-64 SIMD XMM](screenshots/upload/output_xmm.png)

![Output of x86-64 SIMD YMM](screenshots/upload/output_ymm.png)

![Output of Cuda Unified](screenshots/simt/nvprof-var2.png)
Caption: C baseline — correctness passed (L2 error = ...), wall-clock time = ... ms

![Output of Cuda Prefetch](screenshots/simt/nvprof-var3.png)
Caption: C baseline — correctness passed (L2 error = ...), wall-clock time = ... ms

![Output of Cuda Page Creation](screenshots/simt/nvprof-var4.png)
Caption: C baseline — correctness passed (L2 error = ...), wall-clock time = ... ms

![Output of Cuda MemAdvise](screenshots/simt/nvprof-var5.png)
Caption: C baseline — correctness passed (L2 error = ...), wall-clock time = ... ms

![Output of Cuda Memory Copy](screenshots/simt/nvprof-var6.png)
Caption: C baseline — correctness passed (L2 error = ...), wall-clock time = ... ms

## ii) nSight screenshots for CUDA variants

![Nsight Report of Cuda Unified](screenshots/nsight/nsight-var2.png)
![Nsight Report of Cuda Unified](screenshots/nsight/nsight-var3.png)
![Nsight Report of Cuda Unified](screenshots/nsight/nsight-var4.png)
![Nsight Report of Cuda Unified](screenshots/nsight/nsight-var5.png)
![Nsight Report of Cuda Unified](screenshots/nsight/nsight-var6.png)

Embed example:

![Nsight timeline for CUDA Unified](screenshots/nsight/nsight_unified.png)

## iii) Comparative execution-time table

| Platform / Variant | Measured time (ms) | Speedup vs C |
|---|---:|---:|
| C baseline | 77.856500 | 1.0000x |
| x86-64 scalar | 9.245687 | 8.4210x |
| x86-64 SIMD XMM | 4.853967 | 16.0398x |
| x86-64 SIMD YMM | 4.46691 | 17.4296x |
| CUDA Unified | 64.86667 | 1.2003x |
| CUDA Prefetch | 43.14558 | 1.8045x |
| CUDA Prefetch + Page creation | 89.16437 |0.8734x (slower than C) |
| CUDA Prefetch + Page + memadvise | 13.824438 |5.6318x|
| CUDA classic memcpy | 12.831062 |6.0678x |
| CUDA data init in kernel | ____ | ____ |



## iv) Analysis of results

*Provide concise, evidence-backed answers to the questions below and include any additional observations.*

The x86-64 SIMD YMM variant was the fastest overall at 4.46 ms and achieved the maximum speedup of 17.4296x. In contrast, the fastest GPU variant, CUDA classic memcpy, achieved only 6.0678x speedup. This difference indicates that for this matrix-vector product workload, the SIMD approach on the CPU is highly efficient because it avoids the high latency and limited bandwidth associated with data transfer to the GPU's memory.

The CUDA Unified Memory (UM) results highlight the importance of tuning:

- The CUDA Prefetch + Page creation variant was the slowest overall (89.16 ms, a 0.8734x speedup). This severe performance hit was primarily due to Page Thrashing, which resulted in a massive 71.6 ms Device-to-Host (D2H) transfer overhead.

- Adding memadvise solved the thrashing, reducing the time dramatically to 13.82 ms (5.6318x speedup)

### Guide questions:

a) What overheads are included in the GPU execution time (up to the point data are transferred back for error checking)? Is it different for each CUDA variant?

	-	Kernel Launch Overhead: The time taken by the CPU thread to invoke and queue the kernel on the GPU.
	
	-	Kernel Execution Time: The time spent by the Streaming Multiprocessors performing the actual matrix-vector multiplication.
	
	-	Data Transfer/Management Overheads:
		-	Classic memcpy (VAR6): Includes explicit, predictable cudaMemcpyHostToDevice (H2D) and cudaMemcpyDeviceToHost (D2H) transfer
			times, which happen sequentially before and after the kernel.
			
		-	Unified Memory (VAR2-VAR5): These variants replace explicit transfers with Page Migration Overheads. Data is moved on-demand
			via Page Faults when accessed by either the CPU or GPU.
			
		-	UM + Prefetch (VAR3/VAR5): Explicit cudaMemPrefetchAsync is used to hide some of the H2D migration cost by moving data
			asynchronously before the kernel starts, preventing on-demand page faults during execution.
			
		-	UM + Thrashing (VAR4): This introduces severe, destructive overhead from Page Thrashing, where the CPU and GPU repeatedly
			request and migrate the same memory pages back and forth, consuming vast amounts of time (as seen in the 89 ms result). 
	
b) How does block size affect execution time (observing various element counts and max blocks)? Which block size would you recommend and why?



c) Is prefetching always recommended, or should CUDA manage memory? Give specific use cases where prefetching helps or hurts.

- Prefetching is not always recommended. Relying on CUDA's automatic Unified Memory (UM) management is generally simpler and safer by default.
-  Prefetching is beneficial for large, sequential data access patterns (e.g., streaming data to the GPU). It enables the programmer to execute a single, efficient bulk transfer (cudaMemPrefetchAsync), which is faster than relying on the high latency of multiple, individual page faults (e.g., Prefetch reduced time from 64.86 text ms to 43.14 ms).
-  Prefetching hurts performance if used without the memadvise locality hint. In alternating CPU/GPU access scenarios, this can confuse the memory manager and lead to severe Page Thrashing, resulting in the worst-case time of 89.16 ms.

d) Between SIMD and SIMT, which is faster for this workload? Give use cases where one model is preferable.

- SIMD (x86-64) is significantly faster for this workload (4.46 ms) than the fastest SIMT/CUDA variant (12.83 ms).
- SIMD is preferable for small, simple, compute-intensive workloads where the cost of data movement to the GPU is the dominant bottleneck.
- SIMT is preferable for massively parallel, latency-tolerant workloads where the computation time is large enough to amortize the initial data transfer overhead, such as large-scale simulations.

// add charts like bar charts for timings, speedup plots, and any roofline or bandwidth utilization graphs

![Execution time comparison](screenshots/upload/ExecutionTime.png)

![Speedup time comparison](screenshots/upload/PerformanceSpeedup.png)

## v) Problems encountered, solutions, and notable methodology

- Problems encountered:
	- We encountered inconsisstency in the data initialization across the differnt CUDA variants which resulted to the inaccurate comparison of execution time. 

- Solutions and reasoning:
    - Our solution for thhe inconsistency of the data initailization is a single, unified deterministic data initializer executed before timing identifical for all variants. 

- Unique methodology / AHA moments:
    - SIMD vs. SIMT Crossover Point: The clearest AHA moment was the empirical result showing that SIMD (YMM) was significantly faster than all SIMT variants. This demonstrated that for the 4096 x 4096 matrix-vector problem, the overhead of data transfer and Unified Memory management dominated the total execution time, negating the GPU's massive theoretical computational advantage.
    - Grid-Stride Loop Implementation: The consistent use of the Grid-Stride Loop pattern in all CUDA kernels ensured that the code was scalable across various block and grid sizes, which is an essential best practice for robust parallel programming on the GPU.

## vi) SIMD vs SIMT — conceptual comparison and project-specific pros/cons

The conceptual difference between SIMD (Single Instruction, Multiple Data) and SIMT (Single Instruction, Multiple Threads) is fundamentally one of scale versus overhead. SIMD, used via x86 AVX, achieves parallelism by applying a single instruction to multiple data elements within a single CPU core. This model has very low launch overhead and the fastest implementation (YMM) achieved an exceptional 4.467 ms. In contrast, SIMT achieves massive parallelism by running thousands of threads across numerous GPU cores. Although theoretically more powerful for compute-heavy tasks, the best performing SIMT variant (Classic memcpy) took 12.831 ms. Therefore, for this specific 4096 x 4096 matrix-vector multiplication, the SIMD model was empirically faster due to the high data transfer and memory management overheads (including cudaMemcpy time) that bottlenecked the CUDA variants. SIMD is preferable for workloads where the data set fits in memory and the overhead of data transfer dominates computation time, while SIMT is preferable for large-scale, compute-bound problems where data transfer time is relatively small compared to the kernel execution time. 

## Final notes
notes
---

Last updated: November 5, 2025
