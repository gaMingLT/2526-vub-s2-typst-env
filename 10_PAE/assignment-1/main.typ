// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)


#set text(lang: "en")

#show: ilm.with(
  title: [Assignment-1: Benchkit],
  authors: "Milan Lagae",
  date: datetime(year: 2026, month: 05, day: 10),

  bibliography: bibliography("references.bib"),
  table-of-contents: outline(depth: 2),


  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false),

  chapter-pagebreak: false,

  affiliations: (
    university: "Vrije Universiteit Brussel",
    faculty: "Sciences and Bioengineering Sciences",
    course: "Performance Analysis & Evaluation",
  ),
)

// TODO: Change back to acmart template!

// Template defaults where already pretty high, just increased the more
// Currently set for the ilm template
// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1.5em, below: 0.90em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 2em, below: 1em)


// #colbreak()
= Intro

The benchmark chosen for porting to the updated Benchkit V2 campaign API is the `cuda_samples_matmul`. To start, context of the chosen benchmark will be discussed in @context. Modifications made will be discussed in @bench, with use of a command wrapper in @command-wrapper. Discussion of benchmark results will be done in @analysis.


= Context <context>


// Rewrite
It is a matrix multiplication microbenchmark for testing the performance of performing matrix multiplication on a GPU's. It is tailored to test the performance of GPU's.

Specified in the benchmark variables are the dimensions of the matrix that are to multiplied with each other.

// Explaining parameters?



#pagebreak()
= Bench <bench>

This section will briefly discuss the updated benchmark implementation;

== Fetch

The fetch stage of the benchmark has been updated with cloning the completely example repository list in the original benchmarks documentation.

== Build

The build stage is specially tailored to compiling and building the `matrixMul.cu` kernel at the moment. The `cmake` & `make` commands are sequentially executed for compiling said example.

== Run

This stage executes a single program execution, existing bench code has been reused.


== Collect

The existing collect has been slightly modified. The original collect phase code has been kept as is. The updated modification, is the addition of 3 new metric fields, as follows:
- dim_a: Matrix A dimensions.
- dim_b: Matrix B dimensions.
- dim_a_x_dim_b: Matrix A & B dimensions combined.


= Command wrapper <command-wrapper>

The chosen wrapper for the updated benchmark is the `ncu2.py` wrapper, which is the cli version of NVIDIA Nsight Compute #footnote[https://developer.nvidia.com/nsight-compute].

Using the GPU's hardware performance counters, more information from the execute kernel can be gained.


#pagebreak()

= Analysis <analysis>

This section will discuss analyzing the results of executing the updated benchmark for the Cuda matrix multiplication example.

== Platform

Due to platform availability the benchmarks were executed on a Ubuntu 22.04 WSL image on Windows 11. More information can be found in @desktop.

#figure(
  table(
    columns: (1fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [Ryzen 9 5950X],
    [GPU], [RTX 3070],
    [Driver Version], [595.97],
    [RAM], [64GB (3200 Mhz)],
    [OS], [Windows 11 - Version	10.0.22631 Build 22631],
    [WSL Version], [2],
    [WSL Distro], [24.04],
  ),
  caption: [Desktop Specifications],
) <desktop>

== Base

Included in the output of the base cuda kernel performance metrics are the following values:
- ma_width: Matrix A size.
- ma_height: Matrix A size.
- mb_width: Matrix B size.
- ma_width: Matrix A size.
- dim_a: Matrix A dimensions.
- dim_b: Matrix B dimensions.
- dim_a_x_dim_b: Matrix A & B dimensions combined.
- GFlops/s: Compute throughput per second.
- Time ms: Execution time.
- Ops: Total number of operations executed.
- Workgroup Size: Indicates the number of threads in a work group.


#pagebreak()
=== Graphs

The run variables used in the benchmark can be found in @base-run-variables.

#figure(
  zebraw(
    lang: false,
    ```python
        "ma_width": [32, 64, 128],
        "ma_height": [32, 64, 128],
        "mb_width": [32, 64, 128],
    ```,
  ),
  caption: [Base - Run Variables],
) <base-run-variables>


The matrix A size vs execution time is charted in the figures @base-old-size-vs-time and @base-old-size-vs-time.

#grid(
  columns: (1fr, 1fr)
)[
  #figure(
    image("images/base/base-old-size-vs-time.pdf"),
    caption: [Old - Size vs Execution Time],
  ) <base-old-size-vs-time>
][
  #figure(
    image("images/base/base-new-size-vs-time.pdf"),
    caption: [New - Size vs Execution Time],
  ) <base-new-size-vs-time>
]

While @base-new-size-vs-time, gives a general idea of how the execution time rises with Matrix A Width. The information of the dimension of both matrixes are lost. For this reason the additional metric fields in the collect phase have been added. The updated chart with these additional fields are shown in @base-old-size-vs-time.

Furthermore, the computational throughput of the matrix multiplication kernel can be charted as seen in @base-old-size-vs-throughput and @base-new-size-vs-throughput.

#grid(
  columns: (1fr, 1fr)
)[
  #figure(
    image("images/base/base-old-size-vs-throughtput.pdf"),
    caption: [Old - Size vs Throughput],
  )  <base-old-size-vs-throughput>
][
  #figure(
    image("images/base/base-new-size-vs-throughtput.pdf"),
    caption: [New - Size vs Throughput],
  ) <base-new-size-vs-throughput>
]

Using the existing information gathered during the collect phase, the throughput vs the matrix A width is graphed in @base-old-size-vs-throughput, but again some information is lost. For this reason, using the additional metric fields added in the collect phase, the information is illustrated in @base-new-size-vs-throughput.


== Wrapper

The default metric included in the wrapper for analysis is: `smsp__sass_l1tex_tags_mem_global`. Using the command: `ncu --query-metrics --metrics smsp__sass_l1tex_tags_mem_global` the description of this metric can be queried.
The description reads as follows: "\# of L1 cache tag lookups generated by global memory instructions"


=== Graphs

The run variables used in the benchmark can be found in @wrapper-run-variables.

#figure(
  zebraw(
    lang: false,
    ```python
        "ma_width": [32, 64, 128],
        "ma_height": [32, 64, 128],
        "mb_width": [32, 64, 128],
    ```,
  ),
  caption: [Wrapper - Run Variables],
) <wrapper-run-variables>

The measured NCU metric is illustrated in the graphs @wrapper-old-size-vs-ncu and @wrapper-new-size-vs-ncu.

#grid(
  columns: (1fr, 1fr)
)[
  #figure(
    image("images/wrapper/wrapper-old-size-vs-nuc.pdf"),
    caption: [Old - Size vs NCU Metric],
  ) <wrapper-old-size-vs-ncu>
][
  #figure(
    image("images/wrapper/wrapper-new-size-vs-ncu.pdf"),
    caption: [New - Size vs NCU Metric],
  ) <wrapper-new-size-vs-ncu>
]

The additional information gathered in the collect phase, again illustrates it usefulness show in @wrapper-new-size-vs-ncu. Plotting using the new information has it limits, when increasing the size & number of run variables, the information becomes to much to be properly displayed on the x-axis & inside of the legend of the chart.
