#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)

#let title = [
  Project: Mini-Project
]

#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Milan Lagae],
    email: [],
    mark: [],
  ),
)

#let affiliations = (
  (
    name: [Institution/University Name:],
    faculty: [Faculty:],
    course: [Course:],
  ),
  (
    name: [Vrije Universiteit Brussel],
    faculty: [Sciences and Bioengineering Sciences],
    course: [GPU Computing],
  ),
)

#let conference = (
  name: [],
  short: [],
  year: [],
  date: [],
  venue: [],
)


#let doi = "/"



#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: conference,
  doi: doi,
  copyright: "",
  // isbn: "",
  // price: "",
  // Font Size as described by the assignment
  font-size: 12pt,
)


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1em, below: 0.75em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)

#colbreak()
= Intro

The first section involves a direct comparison between addition and multiplication operations to establish a baseline, as specified in assignment descriptions.

Following the comparison in the first part, the kernels are modified to execute on multiple elements simultaneous in two different one-to-many mapping described in the assignment doc @part_2_doc.

For the third section, the compute intensity of the benchmark are parameterized by using a loop count factor. Increasing the compute intensity should surface the limitation of the memory & compute of the gpu.

The final section will compare the trade-offs between local vs global memory on the performance of the execution, as indicated in the schema @part_4_scheme  in the assignment.


= Structure

Included in the zip file is a `src` folder. This folder contains a `project-desktop` folder, the kernel files and the CMake project file. The `src` folder contains all the `c++` files responsible for orchestrating the benchmark execution. The following list of kernels are included: `partOne`, `partTwo`, `partThree`, `partThree-2` `partFour`.


= Methodology

A total of *20* runs were performed for each parameter combination.The first 5 runs where discarded to allow the system to stabilize. This is in accordance to the recommendations in @number_of_runs. For each measured value, if applicable a CoV range chart is produced and will be referenced, these can be found in @appendix. The acceptable range of the CoV is taken from @paae_cov_range. The Cov charts for each part, can be found in the appendix section @appendix. All benchmarks where executed on the system while the least amount of other programs were running at the same moment of performing the benchmarks.


// #pagebreak()
= Part 1: Addition vs Multiplication

This section evaluates the performance differential between addition and multiplication operations. Furthermore, it quantifies the overall GPU acceleration relative to a CPU baseline to determine the magnitude of the observed speedup


== Setup

The code for this part can be found in the file: `part-1.cpp` and the kernel file in `partOne.cl` Included in the `partOne.cl` kernel file, are two separate kernels, respectively: `mul_continuous`, `add_continuous`.


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

Normalizing the observed bandwidth against the GPU's theoretical peak confirms that the implementation is bandwidth-limited. The throughput maximum at $2^18$ *may* suggest optimal cache utilization; for the RTX 3070 architecture, this data volume aligns with the 4MB L2 cache limit #footnote[https://www.techpowerup.com/gpu-specs/geforce-rtx-3070.c3674]. Beyond this threshold, the working set exceeds cache capacity, forcing the system to rely on global memory bandwidth.


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



// #pagebreak()

// #colbreak()
= Part 2: Elements Per Thread

This section will analyze the result of increasing the number of elements a single thread (kernel item) is responsible for on the performance of the execution. These different access patterns are described as `continuous` & `strided`. They are based on the pdf @part_2_doc in the assignment description.

== Setup

The array size is fixed for all benchmark variations performed in this part to $2^22$, based on the data gathered in part 1 and the workgroup size is set to $64$.

The benchmark file is called: `part-2.cpp` and kernel file `partTwo.cl`. Included in the kernel file are the following kernels: `mul_contiguous`, `add_continguous`, `mul_strided`, `add_strided`.

The `contiguous` pattern, corresponds t the example code shown in @pattern-contiguous-code.

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
  caption: [],
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
  caption: [],
) <pattern-strided-code>

== Visualization

The changes the variable elements per thread brings to the orchestration of work-item is shown in @drawing-1.

#figure(
  image(
    "images/drawings/drawings-mini-report-1.pdf",
  ),
  caption: [Elements per thread (8) - Work Item Orchestration],
) <drawing-1>

For the example in question, let's set the EPT value to $8$, which indicates, each work item will be responsible for adding or multiplying 8 elements from the target arrays to source array. The array size ($2^22$) can than be divided by this number 8 to arrive at the number of work items that need to be launched by the kernel ($524288$).

Calculating the number of work groups can than be done, by dividing this number by the workgroup-size ($64$), which results in $8192$ work groups.


== Continuous vs Strided

Start of with looking at the time it takes between both operations and different access patterns in figure @part-2-time-vs-ept.

#figure(
  image(
    "images/part-2/desktop/part_2_time_vs_ept.pdf",
  ),
  caption: [],
) <part-2-time-vs-ept>

This chart gives the first indication that the `strided` access pattern has better performance compared to the `continuous` pattern.

When putting the continuous pattern vs the strided pattern, and plotting the speedup in figure @part-2-time-covs, the picture becomes clearer.

#figure(
  image(
    "images/part-2/desktop/part_2_time_speedup_cont_vs_strided.pdf",
  ),
  caption: [],
) <part-2-time-speedup-cont-vs-strided>

The graphs show a very clear speedup of the `strided` access pattern starting from 8 ETP value. The reason for this speedup of this pattern becomes clear when looking at the memory bandwidth for the patterns in @part-2-bandwidth-ci.

#figure(
  image(
    "images/part-2/desktop/part_2_memory_bandwidth_ci.pdf",
  ),
  caption: [],
) <part-2-bandwidth-ci>

The `continuous` access pattern is shown on the left and the `strided` on the right. The large drop in memory bandwidth for the continuous pattern when the EPT value is increased from $8$ to $16$ is noticeable. A similar drop in bandwidth is remarked for the continuous pattern when going from $64$ to $128$ and to $256$.

Let's continue to take a look at the compute intensity of both strategies, as shown in @part-2-compute-ci.

#figure(
  image(
    "images/part-2/desktop/part_2_compute_ci.pdf",
  ),
  caption: [],
) <part-2-compute-ci>

Here the picture becomes much clearer again, at the same time that the memory bandwidth takes a sharp drop, the compute throughput does to. The drop for the continuous pattern arrives at the same time, and for the strided pattern also.

But comparing the add vs mul operation, the drop for the mul operation appears to be delayed by one EPT value increase.


== Conclusion

Combining all the information from the charts above, it can be concluded that the `strided` pattern gives the GPU the data it needs to perform the computations, up until the elements per thread become to large again and the gpu is unable to saturate the bandwidth and give the gpu the data it needs to compute.

Apart from the performance that can be noticed from the data, is the fact that the CI interval of the continuous are much tighter than those of the strided pattern. No immediate answer can be given for this difference in intervals between access patterns.




// #pagebreak()
// #colbreak()
= Part 3: Roofline Model

This section will discuss the experiment to create a roofline model as described in the assignment & discussed in the lectures. Before showcasing the roofline model, several other charts will be discussed first, showcasing the utility of the roofline model chart.

== Setup

The array size is fixed for all benchmark variations performed in this part to $2^22$, based on the data gathered in part 1 and the workgroup size is set to $64$. The benchmark file is called `part-3.cpp` and kernel file: `partThree.cl`. Included in the kernel file is a single kernel called: `float_sum_increasing_ci`. It combines the elements per thread loop with the kernel `intSumIncreasingCI`, present in the list of gpu exercises given at the start of the semester. The benchmark file, also update the formulas for calculating the bandwidth (throughput), compute intensity (flops), and arithmetic intensity with formulas from the `sumIntsIncreasingCI.cpp` file.



== Analysis

Let's start with some charts, depicting the loop count for the compute intensity, memory bandwidth and runtime as show in @part-3-all-vs-loop-count.

#figure(
  image(
    "images/part-3/desktop/part_3_memory_and_flops_vs_loop_count.pdf",
  ),
  caption: [],
) <part-3-all-vs-loop-count>

The plots on the graphs do not indicated out of the ordinary, increasing the loop count increases the runtime of the execution. The behavior between the compute intensity (left) and memory bandwidth (middle) is interesting and warrants further discussion, as designed by the experiment.

Before analyzing the roofline model, let's compare the compute intensity for the different loop count values in function of the elements per thread, in figure @part-3-flops-loop-count-ci.

#figure(
  image(
    "images/part-3/desktop/part_3_gflops_vs_loop_count_ci.pdf",
  ),
  caption: [],
) <part-3-flops-loop-count-ci>


A similar graph can be made for the bandwidth in function of the loop count and different EPT values, in @part-3-bandwidth-loop-count-ci.

#figure(
  image(
    "images/part-3/desktop/part_3_bandwidth_vs_loop_count_ci.pdf",
  ),
  caption: [],
) <part-3-bandwidth-loop-count-ci>

The same behavior as seen in graphs in figure @part-3-all-vs-loop-count, is again visible in the above two graphs, for different loop counts. The EPT value 'only' determines the ranges of the values, but does not change the chart behavior.

Plotting the arithmetic intensity, in function of the loop count as shown in @part-3-ai-vs-loop-count-ci.

#figure(
  image(
    "images/part-3/desktop/part_3_ai_vs_loop_count_ci.pdf",
  ),
  caption: [],
) <part-3-ai-vs-loop-count-ci>

The model, as seen in the lectures, which summaries all the plots and behavior's described is the roofline model, as shown in @part-3-model.

#figure(
  image(
    "images/part-3/desktop/part_3_roofline_model.pdf",
  ),
  caption: [],
) <part-3-model>

For the GPU in question, the memory bandwidth & peak computational throughput is indicated. The results follow the memory sloop from the starting loop count (LC) $8$ until $64$, were it starts diverging. The 'ridge point' at which the actual data start becoming 'memory bound' occurs much earlier than the theoretical value.


== Conclusion

The experiment in question, has clearly shown the appearance of the roofline model in the data, this part of the experiment can be considered a success. With small note made for the practical ridge point not matching the expected theoretical point.


// #colbreak()
= Part 3.2: Workgroup Size

This section will quickly discuss the impact of the workgroup-size on the performance of the CI kernel, in part 3.

Let's start of with charting the time in function of the workgroup size, across the LC & EPT values, using a ridge line #footnote[https://www.data-to-viz.com/graph/ridgeline.html] visualization.

#figure(
  image(
    "images/part-3-2/desktop/part3_add_gputimens_ridgeline.pdf",
  ),
  caption: [Ridgeline Visualization of the GPU time in function of workgroup-size],
) <part-3-2-ridgeline-time>

As can be concluded from the figure @part-3-2-ridgeline-time, is that the most optimal range of WGS for the kernel in part 3, is between $32-256$.  This validates the choice to fix the WGS to $64$ across the benchmarks in part 1, 2 & 3.

Completing this section with an additional roofline model chart as illustrated in figure @part-3-2-model. The distribution of the charts for the different workgroup-size values is clearly visible.

#figure(
  image(
    "images/part-3-2/desktop/part3_add_roofline_wgz.pdf",
  ),
  caption: [],
) <part-3-2-model>


// #pagebreak()
= Part 4: Local vs Global

// TODO: Update
This section will discuss the usage of local memory before performing operations on elements in an array.

== Setup

// TODO: *TODO*

== Analysis

// TODO: *TODO*

#figure(
  image(
    "images/part-4/desktop/part_4_compare_all_ci.pdf",
  ),
  caption: [],
) <part-4-compare-all-ci>


// TODO: *TODO*

#figure(
  image(
    "images/part-4/desktop/part_4_time_speedup.pdf",
  ),
  caption: [],
) <part-4-time-speedup>


== Conclusion







// TODO: Update figure captions!
#set page(columns: 1)
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


=== MacBook

#figure(
  table(
    columns: (1fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [M2 Pro (6 performance and 4 efficiency)],
    [OpenCL], [1.2],
    [RAM], [16GB],
    // TODO: Update this value
    [OS], [*TODO*],
  ),
  caption: [MacBook Specifications],
) <macbook>



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


#bibliography("references.bib")
