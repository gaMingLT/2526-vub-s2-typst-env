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

*TODO*


= Methodology

For each iteration of the combination of values to be measures, *15* runs where measured. The first 5 runs where discarded to allow the system to stabilize. This is in accordance to the recommendations in @number_of_runs. For each measured value, is applicable a Cov range chart is produced and will be reference, these can be found in @appendix. The acceptable range of the Cov is taken from @paae_cov_range.


#pagebreak()
= Part 1: Addition vs Multiplication

== Setup

*TODO*



== Memory Bandwidth

#figure(
  image(
    "images/part-1/desktop/part_1_memory_bandwidth_vs_array_size.pdf",
  ),
  caption: [],
) <part-1-memory-bandwidth-vs-array-size>

*TODO*


#figure(
  image(
    "images/part-1/desktop/part_1_memory_bandwidth_boxplot.pdf",
  ),
  caption: [],
) <part-1-memory-bandwidth-vs-array-size>


== Compute Throughput

#figure(
  image(
    "images/part-1/desktop/part_1_compute_throughput_vs_array_size.pdf",
  ),
  caption: [],
) <part-1-compute-throughput-vs-array-size>



#pagebreak()
= Part 2: Elements Per Thread

== Setup

The array size is fixed for all benchmark variations performed in this part to $2^20$.

== Memory Bandwidth


#figure(
  image(
    "images/part-2/desktop/part_2_memory_vs_ept.pdf",
  ),
  caption: [],
) <part-2-memory-bandwidth-vs-ept>


#figure(
  image(
    "images/part-2/desktop/part_2_memory_bandwidth_ci.pdf",
  ),
  caption: [],
) <part-2-memory-bandwidth-vs-ept-ci>




== Time

#figure(
  image(
    "images/part-2/desktop/part_2_time_vs_ept.pdf",
  ),
  caption: [],
) <part-2-time-vs-ept>


#figure(
  image(
    "images/part-2/desktop/part_2_time_ci.pdf",
  ),
  caption: [],
) <part-2-time-ci>




#pagebreak()
= Part 3: Roofline Model


= Part 4: Local vs Global


= Extra: Desktop vs Macbook



// TODO: Update figure captions!
#set page(columns: 1)
= Appendix <appendix>

== Part 1


#figure(
  image(
    "images/part-1/desktop/part_1_memory_bandwidth_cov.pdf",
  ),
  caption: [],
) <part-1-memory-bandwidth-cov>

#figure(
  image(
    "images/part-1/desktop/part_1_compute_throughput_cov.pdf",
  ),
  caption: [],
) <part-1-compute-troughput-cov>


== Part 2

#figure(
  image(
    "images/part-2/desktop/part_2_memory_vs_ept_cov.pdf",
  ),
  caption: [],
) <part-2-memory-vs-ept-cov>


#figure(
  image(
    "images/part-2/desktop/part_2_time_vs_ept_cov.pdf",
  ),
  caption: [],
) <part-2-time-vs-ept-cov>



== Specifications

=== Macbook

#figure(
  table(
    columns: (1fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [M2 Pro (6 performance and 4 efficiency)],
    [RAM], [16GB],
    // TODO: Update this value
    [OS], [*TODO*],
  ),
  caption: [Macbook Specifications],
) <macbook>


=== Desktop

#figure(
  table(
    columns: (1fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [Ryzen 9 5950X],
    [GPU], [RTX 3070],
    // TODO: Update this value
    [OpenCL], [*TODO*],
    // TODO: Update this value
    [Driver Version], [*TODO*],
    [RAM], [64GB (3200 Mhz)],
    [OS],
    [Windows Version	10.0.22631 Build 22631
    ],
  ),
  caption: [Desktop Specifications],
) <desktop>



#bibliography("references.bib")
