// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)


#set text(lang: "en")

#show: ilm.with(
  title: [Assignment-2:  Path Tracer],
  authors: "Milan Lagae",
  date: datetime(year: 2026, month: 05, day: 27),

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

// Template defaults where already pretty high, just increased the more
// Currently set for the ilm template
// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1.5em, below: 0.90em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 2em, below: 1em)


// #colbreak()
= Intro

// Explain structure of report

This report will discuss the improvements made to the CPU based pathtracer for Assignment-2 of the course: 'Performance Analysis & Evaluation'. Each major improvement will be discussed in their respective sections. A collection of miscellaneous improvements will be discussed in @misc-improvement. Finally, the latest version of the implementation will be thoroughly discussed in @benchmarking.


// More?


= Improvement 1: Lock Contention

// Explain the lock contention with random

This section will discuss the improvement of removing lock contention in the pathtracer implementation.


== Analysis




== Problem


== Solution



= Improvement 2: Inlining

// Explain the practice of inlining the `vec3*` operations

== Analysis



== Problem



== Solution


= Improvement 3: Thread Pooling

// Explain the process of adding a thread pool to better share the workload during rendering

This section will discuss the implementation of adding a thread pool which contains image rendering tasks. Each task will be responsible for a square tile of the image to be rendered.


== Analysis



== Problem

// TODO: Add amd uprof thread image

#figure(
  image("images/pool-tilling/PAE-AS2-Tiling-Old.png", width: 80%),
  caption: [...],
) <thread-util-before>

== Solution

// TODO: Add amd uprof thread image

// TODO: Fix image
#figure(
  image("images/pool-tilling/PAE-AS2-Tiling-New.png", width: 80%),
  caption: [...],
) <thread-util-after>


// #grid(
//   columns: (1fr, 1fr)
// )[
//   #figure(
//     image("images/wrapper/wrapper-old-size-vs-nuc.pdf"),
//     caption: [Old - Size vs NCU Metric],
//   ) <wrapper-old-size-vs-ncu>
// ][
//   #figure(
//     image("images/wrapper/wrapper-new-size-vs-ncu.pdf"),
//     caption: [New - Size vs NCU Metric],
//   ) <wrapper-new-size-vs-ncu>
// ]




= Improvement 4: Parallel Build

// Explain the process of multi threaded `bvh_build`






= Improvement 5: Structure of Arrays & SIMD

// Explain the process of SoA & SIMD






= Miscellaneous improvements <misc-improvement>

// List of miscellaneous  (minor) improvements







= Benchmarking <benchmarking>

// Analyze the performance of current implementation






= Conclusion

// Overall conclusion
