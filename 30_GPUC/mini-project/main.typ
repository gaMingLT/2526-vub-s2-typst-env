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

Throughout all parts of the mini-project, it was chosen to compare two *operations* namely: addition & multiplication. To start, a comparison between the operations will be done, as requested in part 1. Following that, the kernel will be updated to execute on multiple elements simultaneous (one-to-many) mapping.

For the third part, the compute intensity will be increased by applying a loop count factor over the computations.

The final part will compare the local vs global memory location, as indicated in the scheme #footnote[http://parallel.vub.ac.be/education/gpu/labs/miniproject_step4_with_local%20memory.jpg] in the assignment.

// TODO: Add thing about macbook vs desktop?


= Structure

In the zip file, inside of the `src`, there is a `project-desktop` folder, containing the `c++` files which execute the kernel benchmarks. For each part, there is a separate `c++` file. The kernel files for each part, are located in the root `src` folder. The following list of kernels should be present in the root folder: `partOne`, `partTwo`, `partThree`, `partFour`.




= Methodology

For each combination of values to be measures, *20* runs where measured. The first 5 runs where discarded to allow the system to stabilize. This is in accordance to the recommendations in @number_of_runs. For each measured value, if applicable a Cov range chart is produced and will be reference, these can be found in @appendix. The acceptable range of the Cov is taken from @paae_cov_range. The Cov charts for each part, can be found in the appendix section @appendix.


// #pagebreak()
= Part 1: Addition vs Multiplication

This section will discuss, comparing the performance between the addition and multiplication operations. The general gpu speedup compared to cpu will also be discussed.

== Setup

The code for this part can be found in the file: `part-1.cpp` and the kernel file in `partOne.cl` Included in the `partOne.cl` kernel file, are two separate kernels, respectively: `mul_continuous` , `add_continuous`.


== GPU Analysis

Let's start of with analyzing the gpu performance. The easiest chart to get started, is time chart. Plotting the time vs the array size can be seen in @part-1-gpu-time-vs-array-size. With the color, differentiating between the 2 operations.

#figure(
  image(
    "images/part-1/desktop/part_1_gpu_time_vs_array_size.pdf",
  ),
  caption: [],
) <part-1-gpu-time-vs-array-size>

The only notable, to remark on the plot, is that only starting from an array size of $2^16$, does the computational intensity increase enough for the work to be reflected in the time taking. Starting from this point one, the time logarithmically with the size of the array.

Continuing from the time variable, to the memory bandwidth vs array size in @part-1-memory-bandwidth-vs-array-size.

#figure(
  image(
    "images/part-1/desktop/part_1_memory_bandwidth_vs_array_size.pdf",
  ),
  caption: [],
) <part-1-memory-bandwidth-vs-array-size>

The memory bandwidth increases with the increase in array size, with a peak at the array size of $2^18$.

// TODO: *WHY?*.

Increasing the size of the array beyond this 'ridge point', we are limited by the kernel (construction inefficiency) and available memory bandwidth.Increasing the array size to $2^26$ and beyond, showcase that the gpu *may* potentially be memory limited.

Before making strong conclusion's, let's take a look at the computationally intensity of the benchmark in @part-1-compute-throughput-vs-array-size.

#figure(
  image(
    "images/part-1/desktop/part_1_compute_throughput_vs_array_size.pdf",
  ),
  caption: [],
) <part-1-compute-throughput-vs-array-size>

The same curve as in @part-1-memory-bandwidth-vs-array-size is visible. The initial conclusion that can be drown from this figure and the previous one, is that at the moment, this kernel is memory bound.

#figure(
  image(
    "images/part-1/desktop/part_1_bandwidth_percentage_vs_array_size.pdf",
  ),
  caption: [],
) <part-1-bandwidth-percentage-vs-array-size>

When plotting the memory bandwidth in percentage to the max theoretical performance, it is clearly visible that the GPU is memory bound. The peak at array size of $2^18$, could be explained by the fact the two source arrays and target arrays can be stored inside of the gpu's L2 cache, which for an RTX 3070 is 4MB #footnote[https://www.techpowerup.com/gpu-specs/geforce-rtx-3070.c3674].

== CPU vs GPU

Let's start by comparing the GPU performance to CPU performance, this graph is depicted in @part-1-speedup-comparison.

#figure(
  image(
    "images/part-1/desktop/part_1_speedup_comparison.pdf",
  ),
  caption: [],
) <part-1-speedup-comparison>

Comparison to CPU performance is done using, a very naive CPU algorithm which does a loop over the loop. A better comparison, would be the usage of parallelism & potential even SIMD to further increase CPU performance. For this part, the CPU will keep using a naive algorithm.

As is visible on figure @part-1-speedup-comparison, the speed gained by using the parallelism of the GPU has a massive impact on the performance between both.


== Conclusion

From the conduced benchmarks and resulting graphs, it can be concluded that there is not considerably different in speed between the additional or multiplication operation on a RTX 3070 gpu. The comparison of the GPU to a naive CPU algorithm, showcase the massive parallelism capabilities of GPU's.



// #pagebreak()

// #colbreak()
= Part 2: Elements Per Thread

This section will analyze the result of increasing the number of elements a single thread (kernel item) is responsible for on the performance of the execution. These different access patterns are described as `continuous` & `strided`. They are based on the pdf #footnote[http://parallel.vub.ac.be/education/gpu/theory/GPU%20Computing%20-%20Lesson%202%20doc%20-%20Programming%20GPUs%20-%20levels%200%201%20and%202.pdf] mentioned in the assignment description.

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

Let's start of with charting the time in function of the workgroup size, across the LC & EPT values, using a ridgeline #footnote[https://www.data-to-viz.com/graph/ridgeline.html] visualization.

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


=== Macbook

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
  caption: [Macbook Specifications],
) <macbook>



== Charts

=== Part 1

#figure(
  image(
    "images/part-1/desktop/part_1_gpu_time_ns_cov_cov.pdf",
  ),
  caption: [],
) <part-1-time-covs>


#figure(
  image(
    "images/part-1/desktop/part_1_gpu_gbps_cov_cov.pdf",
  ),
  caption: [],
) <part-1-gpbs-covs>

#figure(
  image(
    "images/part-1/desktop/part_1_gpu_gflops_cov_cov.pdf",
  ),
  caption: [],
) <part-1-gflops-covs>



#pagebreak()
=== Part 2

#figure(
  image(
    "images/part-2/desktop/part_2_time_vs_ept_cov.pdf",
  ),
  caption: [],
) <part-2-time-covs>


#pagebreak()
=== Part 3

#figure(
  image(
    "images/part-3/desktop/part_3_time_cov.pdf",
  ),
  caption: [],
) <part-3-time-covs>

#figure(
  image(
    "images/part-3/desktop/part_3_gbps_cov.pdf",
  ),
  caption: [],
) <part-3-gpbscovs>


#figure(
  image(
    "images/part-3/desktop/part_3_gflops_cov.pdf",
  ),
  caption: [],
) <part-3-gflops-covs>




#pagebreak()
=== Part 3-2

#figure(
  image(
    "images/part-3-2/desktop/part3_add_time_cov.pdf",
  ),
  caption: [],
) <part-3-2-time-covs>

#figure(
  image(
    "images/part-3-2/desktop/part3_add_gbps_cov.pdf",
  ),
  caption: [],
) <part-3-2-gpbs-covs>

#figure(
  image(
    "images/part-3-2/desktop/part3_add_gflops_cov.pdf",
  ),
  caption: [],
) <part-3-2-gflops-covs>



=== Part 4

#figure(
  image(
    "images/part-4/desktop/part_4_time_cov.pdf",
  ),
  caption: [],
) <part-4-time-covs>

#figure(
  image(
    "images/part-4/desktop/part_4_gbps_cov.pdf",
  ),
  caption: [],
) <part-4-gpbs-covs>

#figure(
  image(
    "images/part-4/desktop/part_4_gflops_cov.pdf",
  ),
  caption: [],
) <part-4-gflops-covs>


#bibliography("references.bib")
