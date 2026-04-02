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

The existing collect stage has been copied and no modifications has been made to this stage code.


= Command wrapper <command-wrapper>

The chosen wrapper for the updated benchmark is the `ncu2.py` wrapper, which is the cli version of NVIDIA Nsight Compute #footnote[https://developer.nvidia.com/nsight-compute].

Using the GPU's hardware performance counters, more information from the execute kernel can be gained.


#pagebreak()

= Analysis <analysis>

This section will discuss analyzing the results of executing the updated benchmark for the Cuda matrix multiplication example.

== Base

Included in the output of the base cuda kernel performance metrics are the following values:
- ma_width: Matrix A size.
- ma_height: Matrix A size.
- mb_width: Matrix B size.
- ma_width: Matrix A size.
- GFlops/s: Compute throughput per second.
- Time ms: Execution time.
- Ops: Total number of operations executed.
- Workgroup Size: Indicates the number of threads in a work group.


=== Graphs
