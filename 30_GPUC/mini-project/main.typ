// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)


#set text(lang: "en")

#show: ilm.with(
  title: [Mini-Project],
  authors: "Milan Lagae",
  date: datetime(year: 2026, month: 03, day: 29),

  bibliography: bibliography("references.bib"),
  table-of-contents: outline(depth: 2),


  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false),

  chapter-pagebreak: false,

  affiliations: (
    university: "Vrije Universiteit Brussel",
    faculty: "Sciences and Bioengineering Sciences",
    course: "GPU Computing",
  ),
)

// Template defaults where already pretty high, just increased the more
// Currently set for the ilm template
// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1.5em, below: 0.90em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 2em, below: 1em)


// #colbreak()
= Intro

The first section involves a direct comparison between addition and multiplication operations to establish a baseline, as specified in the assignment descriptions.

Following the comparison in the first part, the kernels are modified to execute on multiple elements simultaneously in two different one-to-many mapping's schemes @part_2_doc.

For the third section, the compute intensity of the benchmark are parameterized by using a loop count factor. Increasing the compute intensity should surface the limitation of the memory & compute of the gpu.

The final section will compare the trade-offs between local vs global memory on the performance of the execution, as indicated in the schema @part_4_scheme  in the assignment.


= Structure

A `src` folder is included in the zip file. Which folder contains a `project-desktop` folder, the kernel files and the CMake project file. The `src` folder contains all the `c++` files responsible for orchestrating the benchmark execution. The following list of kernels are included: `partOne`, `partTwo`, `partThree`, `partThree-2` and `partFour`.


= Methodology

A total of *20* runs were performed for each parameter combination.The first 5 runs were discarded to allow the system to stabilize. This is in accordance with the recommendations in @number_of_runs. For each measured value, if applicable, a CoV range chart is produced and will be referenced. These can be found in @appendix. The acceptable range of the CoV is taken from @paae_cov_range.


#pagebreak()
= Part 1: Addition vs Multiplication <part-1-add-vs-mul>

This section evaluates the performance differential between addition and multiplication operations. Furthermore, it quantifies the overall GPU acceleration relative to a CPU baseline to determine the magnitude of the observed speedup


== Setup

The code for this part can be found in the file: `part-1.cpp` and the kernel file in `partOne.cl`. Included in the `partOne.cl` kernel file are two separate kernels, respectively: `mul_continuous` and `add_continuous`.


== GPU Analysis

The evaluation begins with an analysis of GPU performance, utilizing execution time as the primary metric. @part-1-gpu-time-vs-array-size illustrates the relationship between execution time and array size, with distinct colors utilized to differentiate between the addition and multiplication operations.


#figure(
  image(
    "images/part-1/desktop/part_1_gpu_time_vs_array_size.pdf",
  ),
  caption: [GPU Execution time vs Array Size],
) <part-1-gpu-time-vs-array-size>

A notable observation from the data is that the computational workload only becomes significant enough to impact execution time at an array size of $2^18$. Beyond this threshold, the execution time scales linearly with the array size, as evidenced by the constant slope on the logarithmic plot.

To further evaluate performance, the bandwidth utilization is plotted against array size in @part-1-memory-bandwidth-vs-array-size.

#figure(
  image(
    "images/part-1/desktop/part_1_memory_bandwidth_vs_array_size.pdf",
  ),
  caption: [GPU Memory Bandwidth vs Array Size],
) <part-1-memory-bandwidth-vs-array-size>

The effective memory bandwidth scales proportionally with array size until reaching a peak at $2^18$. Beyond this saturation point, throughput begins to decline as the system encounters overheads associated with kernel invocation, kernel inefficiencies and hardware-level memory constraints. At scales of $2^26$ and higher, the results suggest that the GPU enters a memory-bound regime, where performance is strictly limited by the available bus width.


To provide a more robust basis for these conclusions, the arithmetic throughput is examined in @part-1-compute-throughput-vs-array-size. This metric allows for a precise evaluation of the computational intensity across varying array sizes.

#figure(
  image(
    "images/part-1/desktop/part_1_compute_throughput_vs_array_size.pdf",
  ),
  caption: [Compute Throughput vs Array Size],
) <part-1-compute-throughput-vs-array-size>

The trends observed in @part-1-compute-throughput-vs-array-size mirror those in @part-1-memory-bandwidth-vs-array-size. A primary conclusion derived from these figures is that the current kernel implementation is memory-bound, as performance scales in direct correlation with memory bandwidth utilization rather than raw computational capacity.

#figure(
  image(
    "images/part-1/desktop/part_1_bandwidth_percentage_vs_array_size.pdf",
  ),
  caption: [Bandwidth Percentage Utilization vs Array Size],
) <part-1-bandwidth-percentage-vs-array-size>

Normalizing the observed bandwidth against the GPU's theoretical peak confirms that the implementation is bandwidth-limited as illustrated in @part-1-bandwidth-percentage-vs-array-size. The throughput maximum at $2^18$ *may* suggest optimal cache utilization. For the RTX 3070 architecture, the datat size aligns with the 4MB L2 cache limit #footnote[https://www.techpowerup.com/gpu-specs/geforce-rtx-3070.c3674]. Beyond this threshold, the working set exceeds cache capacity, forcing the system to rely on global memory bandwidth.


== CPU vs GPU

A comparative analysis of GPU versus CPU performance is presented in @part-1-speedup-comparison. This comparison quantifies the GPU speedup by contrasting the high-throughput parallel architecture of the GPU against the sequential execution model typical of a CPU.

#figure(
  image(
    "images/part-1/desktop/part_1_speedup_comparison.pdf",
  ),
  caption: [],
) <part-1-speedup-comparison>

The CPU performance is benchmarked using a baseline sequential implementation consisting of a standard iterative loop. Further optimization; such as multithreading or SIMD, could enhance CPU throughput. For this part, the CPU will keep using a naive algorithm.


== Conclusion

The benchmarks reveal no significant performance difference between addition and multiplication operations. This symmetry in execution time suggests that both operations are equally optimized within the GPU's functional units. As illustrated in @part-1-speedup-comparison, the parallel architecture of the GPU provides a substantial performance advantage over the CPU baseline.



#pagebreak()

// #colbreak()

= Part 2: Elements Per Thread

This section analyzes the result of increasing the number of Elements Per Thread (EPT) a single thread (work-item) is responsible for on the performance of the execution. These different access patterns are described as `contiguous` and `strided`. They are based on the pdf @part_2_doc in the assignment description.


== Setup

The array size is standardized at $2^22$ elements, a value derived from the benchmark results observed in @part-1-add-vs-mul. Furthermore, the workgroup size is fixed at $64$ to maintain consistent results.

The benchmark file is called: `part-2.cpp`, and kernel file `partTwo.cl`. Included in the kernel file are the following kernels: `mul_contiguous`, `add_continguous`, `mul_strided` and `add_strided`.

The `contiguous` pattern, corresponds to the example code shown in @pattern-contiguous-code.

#figure(
  zebraw(
    lang: false,
    ```cpp
    // host code
    unsigned int data_index[W];
    cl::NDRange global(W/N);
    // device code
    for (int i = 0; i < N; ++i)
        data_index[N * get_global_id(0) + i] = get_global_id(0);
    ```,
  ),
  caption: [Example: Contiguous Pattern Code],
) <pattern-contiguous-code>

The `strided` access pattern, corresponds to the example code shown in @pattern-strided-code.

#figure(
  zebraw(
    lang: false,
    ```cpp
    // host code
    unsigned int data_index[W];
    cl::NDRange global(W/N);

    // device code
    for (int i = 0; i < N; ++i)
       data_index[get_global_id(0) + i*get_global_size(0)] = get_global_id(0);
    ```,
  ),
  caption: [Example: Strided Pattern Code],
) <pattern-strided-code>



== Visualization

The impact of the EPT variable on the workload distribution across individual work-items is illustrated in @drawing-1.


#figure(
  image(
    "images/drawings/drawings-mini-report-1.pdf",
  ),
  caption: [Elements Per Thread (8) - Work Item Orchestration],
) <drawing-1>


In this specific scenario, the EPT is set to $8$, indicating that each individual work-item is responsible for processing eight elements from the source arrays. Consequently, the total number of work-items launched to cover the $2^22$ array size is reduced by a factor of eight, resulting in a global work size of $524,288$. Calculating the number of work groups can than be done, by dividing this number by the workgroup-size ($64$), which results in $8192$ work groups.



== Contiguous vs Strided

The initial analysis focuses on the execution time across both arithmetic operations, as well as the impact of the different access patterns. These relationships are illustrated in @part-2-time-vs-ept, which plots execution time as a function of the EPT.


#figure(
  image(
    "images/part-2/desktop/part_2_time_vs_ept.pdf",
  ),
  caption: [GPU Execution Time vs EPT - multiplication & addition operations - contiguous vs strided pattern],
) <part-2-time-vs-ept>


Initial observations from the chart suggest that the strided access pattern yields better performance compared to the contiguous pattern. This performance difference is further clarified in @part-2-time-covs, where a direct comparison of the two strategies reveals a significant speedup favoring the strided approach, as the EPT factor increases.


#figure(
  image(
    "images/part-2/desktop/part_2_time_speedup_cont_vs_strided.pdf",
  ),
  caption: [Strided Pattern Speedup vs Contiguous Pattern],
) <part-2-time-speedup-cont-vs-strided>


The results demonstrate a performance inflection point for the strided access pattern once the EPT reaches a value of $8$. The underlying mechanism for this acceleration can be assigned by the memory bandwidth analysis in @part-2-bandwidth-ci, which reveals a significant increase in data throughput compared to the contiguous implementation.


#figure(
  image(
    "images/part-2/desktop/part_2_memory_bandwidth_ci.pdf",
  ),
  caption: [Memory Bandwidth CI Intervals],
) <part-2-bandwidth-ci>


The contrast between the contiguous access pattern (left) and the strided pattern (right) is stark. A significant drop in memory bandwidth is observed for the contiguous model as the EPT increases from $8$ to $16$. Similar performance regressions occur at higher values, specifically when transitioning from $64$ to $128$ and $256$, suggesting a potential bottleneck in the access pattern or GPU limitation.


The following analysis examines the computational intensity of both strategies, as illustrated in @part-2-compute-ci, by comparing the arithmetic throughput across different EPT values.


#figure(
  image(
    "images/part-2/desktop/part_2_compute_ci.pdf",
  ),
  caption: [Computational Throughput CI Intervals],
) <part-2-compute-ci>

The data reveals a strong correlation between memory bandwidth and computational throughput. As the bandwidth utilization undergoes a sharp drop, the compute performance suffers an identical regression.

This synchronization confirms that the kernel is strictly memory-bound. Notably, while the contiguous and strided patterns exhibit these drops at similar thresholds, the multiplication operation displays a one-step phase shift in its performance decline compared to addition.


== Conclusion

In summary, the data suggests that the strided access patterns provides the GPU with the data it needs to perform computations, up to the point where the number of EPT becomes too high. The GPU is unable to saturate the bandwidth and give the needed data to the compute elements. At this point, the increased workload per thread likely exhausts local resources, preventing the GPU from effectively saturating the available bandwidth.

Furthermore, a notable disparity exists in the confidence intervals (CI); the contiguous pattern exhibits significantly lower variance than the strided approach. No immediate answer can be given for this difference in intervals between access patterns.



#pagebreak()
// #colbreak()

= Part 3: Roofline Model <part-3-roofline-model>


This section will discuss the experiment to create a roofline model as described in the assignment & discussed in the lectures. Before showcasing the roofline model, several other charts will be discussed first, showcasing the utility of the roofline model.


== Setup

The array size is standardized at $2^22$ elements, a value derived from the benchmark results observed in @part-1-add-vs-mul. Furthermore, the workgroup size is fixed at $64$ to maintain consistent results.

The benchmark file is called: `part-3.cpp`; and kernel file: `partThree.cl`. Included in the kernel file is a single kernel called: `float_sum_increasing_ci`. It combines the elements per thread loop with the kernel `intSumIncreasingCI`, present in the list of GPU exercises (given at the start of the semester). The benchmark file also updates the formulas for calculating the bandwidth (throughput), compute intensity (flops), and arithmetic intensity with formulas from the `sumIntsIncreasingCI.cpp` file.



== Analysis


@part-3-all-vs-loop-count illustrates the relationship between the internal kernel loop count and three key indicators: compute intensity, memory bandwidth, and total execution time.


#figure(
  image(
    "images/part-3/desktop/part_3_memory_and_flops_vs_loop_count.pdf",
  ),
  caption: [Loop Count vs Compute; Bandwidth & Execution Time],
) <part-3-all-vs-loop-count>


Execution runtime increases proportionally with the loop count. More significantly, the data reveals shift between compute intensity and memory bandwidth. This behavior is a key focus of the experiment, as it illustrates the GPU's shift from a memory-bound to a compute-bound regime.

Before analyzing the roofline model, @part-3-flops-loop-count-ci illustrates how the computational intensity scales as the instruction density increases, providing a baseline for identifying the transition to a compute-bound state.


#figure(
  image(
    "images/part-3/desktop/part_3_gflops_vs_loop_count_ci.pdf",
  ),
  caption: [GPU Compute Throughput vs Loop Count],
) <part-3-flops-loop-count-ci>

Increasing the EPT factor beyond a certain point ($>=32$) has a negative effect on the computational throughput.


A corresponding analysis for effective memory bandwidth is presented in @part-3-bandwidth-loop-count-ci, where the throughput is parameterized by both the loop count and the EPT factor.


#figure(
  image(
    "images/part-3/desktop/part_3_bandwidth_vs_loop_count_ci.pdf",
  ),
  caption: [Memory Bandwidth Utilization vs Loop Count],
) <part-3-bandwidth-loop-count-ci>

The same behavior as seen in graphs in figure @part-3-all-vs-loop-count, is again visible in the above two graphs, for different loop counts. The EPT value 'only' determines the ranges of the values, but does not change the chart behavior.

Increasing the EPT beyond ($>= 32$) for any loop factor also showcases a decreasing bandwidth and computational throughput. Potentially indicating that due to the smaller number of threads / work-items launched, the GPU cannot fully utilize its compute and bandwidth capabilities.


@part-3-model presents the Roofline Analysis,  which summaries all the plots and behavior's described earlier.


#figure(
  image(
    "images/part-3/desktop/part_3_roofline_model.pdf",
  ),
  caption: [RTX3070 - Roofline Model],
) <part-3-model>


For the GPU in question, the memory bandwidth & peak computational throughput is indicated. The results follow the memory slope from the starting loop count (LC) $8$ until $64$, where it starts diverging. The 'ridge point' at which the actual data starts becoming 'memory bound' occurs much earlier than the theoretical value.



== Conclusion


The experiment in question has clearly shown the appearance of the roofline model in the data. This part of the experiment can be considered a success, with a small remark made for the practical ridge point not matching the expected theoretical point.




// #colbreak()

#pagebreak()

= Part 3.2: Workgroup Size


This section evaluates the sensitivity of the Compute Intensity (CI) kernel from part 3, to variations in workgroup size.


== Setup


The array size is standardized at $2^22$ elements, a value derived from the benchmark results observed in section @part-1-add-vs-mul. The benchmark file is called: `part-3-2.cpp`, and kernel file: `partThree.cl`. The same kernel as in section @part-3-roofline-model is reused.


== Analysis

@part-3-2-ridgeline-time provides a multi-dimensional analysis of execution time, utilizing a ridge line #footnote[https://www.data-to-viz.com/graph/ridgeline.html] visualization to map performance distributions across a range of Loop Counts (LC) and Elements Per Thread (EPT) values.


#figure(
  image(
    "images/part-3-2/desktop/part3_add_gputimens_ridgeline.pdf",
  ),
  caption: [Ridgeline Visualization of the GPU time in function of workgroup-size],
) <part-3-2-ridgeline-time>


The ridge line analysis in @part-3-2-ridgeline-time indicates that the most optimal range of WGZ for the kernel in part 3 is between $32-256$.  This validates the choice to fix the WGZ to $64$ across the benchmarks in part 1, 2, 3 & 4.


Completing this section with an additional roofline model chart as illustrated in @part-3-2-model. The distribution of the charts for the different workgroup-size values is clearly visible.


#figure(
  image(
    "images/part-3-2/desktop/part3_add_roofline_wgz.pdf",
  ),
  caption: [Roofline Model vs Workgroup Size],
) <part-3-2-model>




#pagebreak()

// #colbreak()

= Part 4: Local vs Global


This section will discuss the performance difference between the use of local & global memory for a reduction kernel.


== Setup


The array size is standardized at $2^22$ elements, a value derived from the benchmark results observed in @part-1-add-vs-mul. Furthermore, the workgroup size is fixed at $64$ to maintain consistent results.

The benchmark file is called: `part-4.cpp`, and kernel file: `partFour.cl`. Included in the kernel file are two separate kernels: `add_reduction_global` and `add_reduction_local`. These kernels were taken from the exercise set. No modification were made to the kernels. The benchmarking file was modified to incorporate changes required for executing the benchmarks. Such modifications include; create src array based on array size, rewrite the src buffer on each GPU kernel run and other changes to fit into the benchmark harness.



== Analysis


@part-4-compare-all-ci illustrates the difference between local & global memory pattern and three key indicators: compute intensity, memory bandwidth, and total execution time.


#figure(
  image(
    "images/part-4/desktop/part_4_compare_all_ci.pdf",
  ),
  caption: [Global vs Local - GPU Time, Compute & Memory Bandwidth],
) <part-4-compare-all-ci>


Looking at the execution time on the right chart, it can be noticed that the execution time for the local memory pattern is slightly slower compared to the global pattern on larger sizes. The patterns start diverging with small amounts from array size $>= 2^20$.

This reduction in execution time is reflected when looking at the memory bandwidth (middle) and compute throughput (left) charts. In both cases, the compute throughput and memory bandwidth are higher on larger array sizes and start widening from array size $2^20$.

It should be noted that the behavior of the bandwidth & compute metric between both memory strategies follows a similar trend on larger array sizes. The global strategy does not reach the same peaks as the local strategy.


Plotting the execution time of both patterns against each other as illustrated in @part-4-time-speedup.


#figure(
  image(
    "images/part-4/desktop/part_4_time_speedup.pdf",
  ),
  caption: [Local vs Global Speedup],
) <part-4-time-speedup>

The speedup alluded to earlier, is clearly visible starting from the array size $2^18$ and propagates until the end of the benchmarked array sizes. The peak speedup is measured to be around $times ~1.2$, and with array size $2^23$.


== Conclusion

To summarize the observations, the local memory pattern has clear benefits in utilization of the GPU on larger array sizes. The available bandwidth & memory utilization is greater when compared to the global pattern. For smaller array sizes, there is not discernible speedup, as shown in @part-4-time-speedup.

Thus, the compute size should be taking into account when deciding which pattern to use. Further experimentation with improved kernels (as presented in exercise set) is warranted to further analyze local memory behavior.




// #set page(columns: 1)


= Appendix <appendix>

== Microbenchmark

=== Desktop

#figure(
  image(
    "images/microbench/microbenchmark-1.png",
  ),
  caption: [Desktop - Microbenchmark Results 1],
) <desktop-microbenchmark-1>

#figure(
  image(
    "images/microbench/microbenchmark-2.png",
  ),
  caption: [Desktop - Microbenchmark Results 2],
) <desktop-microbenchmark-2>


== Specifications

=== Desktop

#figure(
  table(
    columns: (1fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [Ryzen 9 5950X],
    [GPU], [RTX 3070],
    [OpenCL], [300 (Set in code)],
    [Driver Version], [591.59],
    [RAM], [64GB (3200 Mhz)],
    [OS],
    [Windows 11 - Version	10.0.22631 Build 22631
    ],
  ),
  caption: [Desktop Specifications],
) <desktop>


// === MacBook

// #figure(
//   table(
//     columns: (1fr, 1fr),
//     [*Part*], [*Value*],
//     [CPU], [M2 Pro (6 performance and 4 efficiency)],
//     [OpenCL], [1.2],
//     [RAM], [16GB],
//     // TODO: Update this value
//     [OS], [*TODO*],
//   ),
//   caption: [MacBook Specifications],
// ) <macbook>



== Charts

=== Part 1

#figure(
  image(
    "images/part-1/desktop/part_1_gpu_time_ns_cov_cov.pdf",
  ),
  caption: [Desktop - Part 1 - GPU Time CoV],
) <part-1-time-covs>


#figure(
  image(
    "images/part-1/desktop/part_1_gpu_gbps_cov_cov.pdf",
  ),
  caption: [Desktop - Part 1 - Memory Bandwidth CoV],
) <part-1-gpbs-covs>

#figure(
  image(
    "images/part-1/desktop/part_1_gpu_gflops_cov_cov.pdf",
  ),
  caption: [Desktop - Part 1 - Compute Throughput CoV],
) <part-1-gflops-covs>




#pagebreak()
=== Part 2

#figure(
  image(
    "images/part-2/desktop/part_2_time_vs_ept_cov.pdf",
  ),
  caption: [Desktop - Part 2 - GPU Time CoV],
) <part-2-time-covs>



#pagebreak()
=== Part 3

#figure(
  image(
    "images/part-3/desktop/part_3_time_cov.pdf",
  ),
  caption: [Desktop - Part 3 - GPU Time CoV],
) <part-3-time-covs>

#figure(
  image(
    "images/part-3/desktop/part_3_gbps_cov.pdf",
  ),
  caption: [Desktop - Part "" - Memory Bandwidth CoV],
) <part-3-gpbscovs>


#figure(
  image(
    "images/part-3/desktop/part_3_gflops_cov.pdf",
  ),
  caption: [Desktop - Part 3 - Compute Throughput CoV],
) <part-3-gflops-covs>




#pagebreak()
=== Part 3-2

#figure(
  image(
    "images/part-3-2/desktop/part3_add_time_cov.pdf",
  ),
  caption: [Desktop - Part 3.2 - GPU Time CoV],
) <part-3-2-time-covs>

#figure(
  image(
    "images/part-3-2/desktop/part3_add_gbps_cov.pdf",
  ),
  caption: [Desktop - Part 3.2 - Memory Bandwidth CoV],
) <part-3-2-gpbs-covs>

#figure(
  image(
    "images/part-3-2/desktop/part3_add_gflops_cov.pdf",
  ),
  caption: [Desktop - Part 3.2 - Compute Throughput CoV],
) <part-3-2-gflops-covs>



=== Part 4

#figure(
  image(
    "images/part-4/desktop/part_4_time_cov.pdf",
  ),
  caption: [Desktop - Part 4 - GPU Time CoV],
) <part-4-time-covs>

#figure(
  image(
    "images/part-4/desktop/part_4_gbps_cov.pdf",
  ),
  caption: [Desktop - Part 4 - Memory Bandwidth CoV],
) <part-4-gpbs-covs>

#figure(
  image(
    "images/part-4/desktop/part_4_gflops_cov.pdf",
  ),
  caption: [Desktop - Part 4 - Compute Throughput CoV],
) <part-4-gflops-covs>


// #bibliography("references.bib")
