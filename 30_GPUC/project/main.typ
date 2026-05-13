// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)


#set text(lang: "en")

#show: ilm.with(
  title: [Project],
  authors: "Milan Lagae",
  date: datetime(year: 2026, month: 03, day: 28),

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

// Normal intro as usual

// Also add disclaimer here?

= Context

// Write about the context of the problem and explain the points made in the  slide deck.



= Shared Explanation

// Maybe explain the args.cpp, ...


= Sequential

// Sequential version explained & shortly


= Parallel

// Sequential cuda GPU version 


= Analysis

// Compare Sequential vs parallel & more in depth of the parallel version


#pagebreak()
= Appendix

== Platform

The benchmarks were executed on a KUbuntu 25.04 desktop, with the specifications listed in @desktop.

// TODO: Update
#figure(
  table(
    columns: (0.8fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [Ryzen 9 5950X],
    [GPU], [RTX 3070],
    [Driver Version], [595.97],
    [RAM], [64GB (3200 Mhz)],
    [OS], [Windows 11 - Version	10.0.22631 Build 22631],
    // [WSL Version], [2],
    // [WSL Distro], [24.04],
    // [Kernel Version], [6.6.87.2-microsoft-standard-WSL2],
    // [NVCC], [13.2, V13.2.51],
    // [NCU], [Version 2026.1.0.0 (build 37166530)]
  ),
  caption: [Desktop Specifications],
) <desktop>
