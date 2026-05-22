// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.6.0" as lq

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


= Intro

This report will discuss the improvements made to the CPU based pathtracer for Assignment-2 of the course: 'Performance Analysis & Evaluation'. Each major improvement will be discussed in their respective sections. Finally, the latest version of the implementation will be thoroughly discussed in @final. The methodology section discussing deviations from the standard per improvement section can be found in @methodology.



= Improvement 1: Lock Contention

// Explain the lock contention with random

This section will discuss the improvement of removing lock contention in the pathtracer implementation.


== Problem

The first problem that was identified & solved is the lock contention in the `random.c` file. When first benchmarking the application, it became clear that increasing the thread count made the application significantly slower.

// TODO: Complete  todo
Initial sourcing for this became clear after using `perf stat`, `perf record` & `strace` for which the result can be seen in (*TODO/ADD*). This same behavior is visible in @lock-before, where the gray lines between the thread activity is the thread waiting for a lock to be finished.

#figure(
  image("images/3-pool/pool-uprof/pool-base.png", width: 80%),
  caption: [AMD μProf - Lock Contention Threads ],
) <lock-before>


Further investigating the file, the offending function was identified to be `rand()`. Looking up the man page of the function @rand, it becomes clear that the function is not thread safe and suffers from heavy lock contention in thread heavy workloads.

This behavior becomes clear when the Total Time of each scene is plotted vs the thread count in @base-tt_vs_thread_count.

#figure(
  image("charts/0-base/total_time_vs_thread_count.pdf", width: 80%),
  caption: [Total Time - Base],
) <base-tt_vs_thread_count>

In the scenes 01, 02 and 04 increasing the thread count from 8 to 12 increases the Total Time taking for rendering said image. For the larger scene 05 this behavior is not as clearly visible, but there is slight increase in time when increasing the number of threads. This increase can be attributed to the use of the non reentrant safe `rand()` function.


== Solution

Included in the man page of the `rand()` function is a recommendation to use the safe function `rand_r()`, but this function seems to require enabling some posix standard and is deprecated.

As a fix, the `rand()` was replaced with a `xoroshiro128plusplus` implementation based on @xorshiroplusplus and `splitmix` for seeding the random number generator @splitmix.



== Results

The improvements in performance when the lock contention is removed is visible in @time-lock-vs-base and @speedup-lock-vs-base.

// TODO: Check charts for correctness!
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/1-lock/total_time_comparison.pdf"),
      caption: [Total Time - Lock vs Base],
    ) <time-lock-vs-base>
  ],
  [
    #figure(
      image("charts/1-lock/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Lock vs Base],
    ) <speedup-lock-vs-base>
  ],
)

The behavior where the speedup increases when more threads are used, clearly show the non re-entrant behavior of the original `rand()` function. The charts in @speedup-lock-vs-base given an indication of how efficiently the implementation makes use of the available threads compared between the versions.


The improvement in performance becomes even more clear, when looking at the IPC of the two implementations in @derived-metrics-lock-vs-base.

// TODO: Check charts for correctness!
#figure(
  image("charts/1-lock/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Lock & Base],
) <derived-metrics-lock-vs-base>


#pagebreak()
= Improvement 2: Inlining

// Explain the practice of inlining the `vec3*` operations

This section will discuss the process of inlining @inlining compute & time intensive operations to improve performance.

== Problem

What became clear during the previous improvement & looking at the code, is the heavy usage of `vec3` operation calls. Using the information displayed in @inlining-base-perf-1 & @inlining-base-perf-2, it becomes clear that there is potential performance to be gained.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
)[
  // TODO: Fix image
  #figure(
    image("images/2-inlining/select-perf-record-base-inline-02-04.png"),
    caption: [...],
  ) <inlining-base-perf-1>
][
  #figure(
    image("images/2-inlining/select-perf-record-base-inline-04-04.png"),
    caption: [...],
  ) <inlining-base-perf-2>
]

When using the AMD μProf application in which show the profile result in @inlining-base-amd-uprof, that the `vec3_index` function alone is taking *95 seconds*.

#figure(
  image("images/2-inlining/select-uprof-base-inline-04-20.png", width: 80%),
  caption: [...],
) <inlining-base-amd-uprof>


== Solution

The most immediate fix for this performance issue is the application of placing all the `vec3_*` function inside of the `vec3.h` file and placing the `inline` keyword before each. This 'forces' the compiler to inline the function code in every location where the code is called.



== Results

The benchmark results of this section are the combination of the previous improvement and this improvement applied.

// TODO: Check charts for correctness!
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/2-inlining/total_time_comparison.pdf"),
      caption: [Total Time - Inline vs Lock],
    ) <time-inline-vs-lock>
  ],
  [
    #figure(
      image("charts/2-inlining/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Inline vs Lock],
    ) <speedup-inline-vs-lock>
  ],
)

// TODO: paragraph here


// TODO: Check charts for correctness!
#figure(
  image("charts/2-inlining/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Inline vs Lock],
) <derived-metrics-inline-vs-lock>

// TODO: Talk about what is visible on the charts!

#pagebreak()
= Improvement 3: Thread Pooling


This section will discuss the implementation of adding a thread pool which contains image rendering tasks. Each task will be responsible for a square tile of the image to be rendered.


== Problem

Analyzing the application, using the AMD μProf @amd_uprof application, and viewing the thread section, shows the behavior visible in @pool-before.

// TODO: More here!
Specifically the end of the timeline of the renderer is import. There is can be seen that the rendered splits the image in non equal work vertical slices as illustrated in @thread-util-before.


#grid(
  columns: (1fr, 1fr)
)[
  #figure(
    image("images/3-pool/pool-tilling/PAE-AS2-Tiling-Old.png"),
    caption: [Renderer - Image Slicing Before],
  ) <thread-util-before>
][
  #figure(
    image("images/3-pool/pool-uprof/pool-base.png"),
    caption: [AMD μProf - Thread behavior ],
  ) <pool-before>
]

Depending on the image to be rendered, some vertical slices may have less work than other vertical slices. Additionally, the last vertical slice of the image is padded so it rendered the full with of the image.

== Solution

// TODO: Add some source also
The problem identified above was solved by two additions. First, instead of vertical slices, the image is now split in smaller (16x16) square tiles, as illustrated in @thread-util-after. In addition to the image tilling, render tasks are now based on pool design @c_pool_1 @c_pool_2.

The improvement in evenly shared work between the threads can be seen in @pool-updated. The end of the timeline, the threads finish more at the same time and there are no more threads that are sitting idle.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
)[
  // TODO: Fix image
  #figure(
    image("images/3-pool/pool-tilling/PAE-AS2-Tiling-New.png"),
    caption: [...],
  ) <thread-util-after>
][
  #figure(
    image("images/3-pool/pool-uprof/pool-updated.png"),
    caption: [...],
  ) <pool-updated>
]

Included in the pooling modifications is the addition of the `ray_color2_soa` and packing the results of several ray's in an array. The framebuffer of the image has also been transformed into a SoA layout.


== Results

// TODO: Check charts for correctness!
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/3-pool/total_time_comparison.pdf"),
      caption: [Total Time - Pool vs Inline],
    ) <time-pool-vs-inline>
  ],
  [
    #figure(
      image("charts/3-pool/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Pool vs Inline],
    ) <speedup-pool-vs-inline>
  ],
)

// TODO: paragraph here


// TODO: Check charts for correctness!
#figure(
  image("charts/3-pool/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Pool vs Inline],
) <derived-metrics-pool-vs-inline>

// TODO: Talk about what is visible on the charts!


#pagebreak()
= Improvement 4: Parallel Build

// Explain the process of multi threaded `bvh_build`

This section will focus on making the `bvh_build` initialization function faster, by applying fork-join like multi-threading to the build process.


== Problem


Increasing the complexity & number of triangles when the scenes increases, leads to an explosion of the time it takes to build the BVH tree during the inizliation process, this behavior is visible in *ADD*.

// TODO: Add image: build time increasing for large scenes.


== Solution



== Results

// TODO: Check charts for correctness!
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/4-parallel/total_time_comparison.pdf"),
      caption: [Total Time - Parallel vs Inline],
    ) <time-parallel-vs-inline>
  ],
  [
    #figure(
      image("charts/4-parallel/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Parallel vs Inline],
    ) <speedup-parallel-vs-inline>
  ],
)

// TODO: paragraph here


// TODO: Check charts for correctness!
#figure(
  image("charts/4-parallel/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Parallel vs Pool],
) <derived-metrics-parallel-vs-pool>

// TODO: Talk about what is visible on the charts!




#pagebreak()
= Improvement 5: Structure of Arrays & SIMD <soa>

// Explain the process of SoA & SIMD

This section will discuss the application of transforming data layout from a AoS to Structure of Arrays (SoA). This to facilitate the application of SIMD vectorization on select functions.


== Problem

The problem to be solved is the usage of linked list, which makes use of next pointers to keep track of elements in the linked list. While also transforming the data from a AoS to a SoA allowing for application of SIMD somewhere in the data path.



== Solution

Implementing the SoA memory layout in combination with `aligned_malloc` allows for the application of SIMD. While it would seem attractive to just use apply SIMD everywhere this is not what the performance numbers said. Choosing which function to transform in to using SIMD must be considered & measured.

Due note, that transforming from a AoS to SoA and (naively) replacing all `LINKED_LIST_FOREACH` macro with `for` loops, considerably reduces the performance of the application. Specifically for scene 05 on threads the times where: $~$25s build; $~$60s rendering (1 on @simd-soa-timings).

After improving the `aabb_ray_intersect` with a more performant implementation and addition of an `inverse` field on `vec3` the render time was reduced to $~$50s; the build time staid the same (2 on @simd-soa-timings).

Let's start of with some example of functions where the application of SIMD has negligible or negative impacts. The following numbers and example are measured for `scene-05` and using *20* threads. We note that his is not a statisicaly analyis, but the wide chance in numbers does give an indicatiion of performance.

Implementing a SIMD based version of `aabb_for_triangles` (including `aabb_for_triangle` & `aabb_surrounding`) the build time regressed to $~$30s. The same can be said for `postprocess_pixels`, there the SIMD implementation regressed by about $~$1s for the render time (3 on @simd-soa-timings).

#figure(
  caption: [Performance Evolution Profile (Scene 05, 20 Threads)],
  lq.diagram(
    width: 14cm,
    height: 8cm,
    ylabel: [Time (seconds)],
    ylim: (0, 70),
    grid: (stroke: 0.5pt + gray.lighten(50%)),
    legend: (position: right + top),

    xaxis: (
      subticks: none,
      ticks: (
        (0, [1]),
        (1, [2]),
        (2, [3]),
        (3, [4]),
        (4, [5]),
        (5, [6]),
      ),
    ),

    // 1. Build Time Bars
    lq.bar(
      range(6),
      (25, 25, 30, 30, 12, 12),
      width: 35%,
      offset: -0.18,
      fill: rgb("#4A90E2"),
      label: [Build Time],
    ),

    // 2. Render Time Bars
    lq.bar(
      range(6),
      (60, 50, 50, 35, 35, 22),
      width: 35%,
      offset: 0.18,
      fill: rgb("#d009c0"),
      label: [Render Time],
    ),

    // Number positioning using official documentation's padding and placement rules
    ..range(6)
      .map(i => {
        let build_y = (25, 25, 30, 30, 12, 12).at(i)
        let render_y = (60, 50, 50, 35, 35, 22).at(i)

        (
          lq.place(i - 0.18, build_y, pad(bottom: 0.3em)[#text(size: 8pt)[#build_y\s]], align: bottom + center),
          lq.place(i + 0.18, render_y, pad(bottom: 0.3em)[#text(size: 8pt)[#render_y\s]], align: bottom + center),
        )
      })
      .flatten(),
  ),
) <simd-soa-timings>

The function's that did benefit from SIMD application is the `linked_list_ray_intersect` (now called `ray_intersect`) and the 2 downstream functions: `triangle_ray_intersect_simd` &`triangle_ray_intersect_sse`. This resulted in the following improvement: render time to $~$35s for scene 05; $~$6s for scene 04, coming from 10/8s (4 on @simd-soa-timings).

Continuing with the improvements, applying SIMD on the `calculate_split_cost` function decreased the build time from around $~$25s to $~$12s (5 on @simd-soa-timings).

Included in this improvement is the addition of the `inverse` field on the `vec3` struct and re-reordering in the `bvh_ray_intersect` function by returning distance from the `aab_ray_intersect` function. For scene 05, this result in the following improvement; From $~$35s render time to $~$22s (6 on @simd-soa-timings).


== Results


// TODO: Check charts for correctness!
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/5-soa/total_time_comparison.pdf"),
      caption: [Total Time - SoA vs Parallel],
    ) <time-soa-vs-parallel>
  ],
  [
    #figure(
      image("charts/5-soa/speedup_comparison.pdf"),
      caption: [Speedup Total Time - SoA vs Inline],
    ) <speedup-soa-vs-parallel>
  ],
)

// TODO: paragraph here


// TODO: Check charts for correctness!
#figure(
  image("charts/5-soa/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - SoA vs Parallel],
) <derived-metrics-soa-vs-parallel>

// TODO: Talk about what is visible on the charts!



#pagebreak()
= Final <final>

This section will discuss the final version of the pathtracer.

== Improvement

The latest improvements for the pathtracer is the addition of a indices based bvh build step. This step is more focused on the reduction of the memory usage, particularly for scene 05. Where original, for the implementation in @soa, the maxium memory usage sits around $~$12GB. The added benefit is also a slight improvement in performance during the render time of the image, while build time is the same.


== Results

// - greater benefit on the large image compared to smaller images

// TODO: Check charts for correctness!
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/6-final/total_time_comparison.pdf"),
      caption: [Total Time - Final vs SoA],
    )
  ],
  [
    #figure(
      image("charts/6-final/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Final vs SoA],
    )
  ],
)

// TODO: paragraph here


// TODO: Check charts for correctness!
#figure(
  image("charts/6-final/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Final vs SoA],
)

// TODO: Talk about what is visible on the charts!


= Overview


// TODO: Check charts for correctness!
#figure(
  image("charts/all/tt_per_stage.pdf"),
  caption: [],
)



// TODO: Check charts for correctness!

#figure(
  image("charts/all/speedup_vs_base.pdf"),
  caption: [Geometric Mean Speedup, Per Stage & Scene (1, 20, 32 threads)],
)



= Conclusion

// Overall


#pagebreak()
= Appendix

== Methodology <methodology>

This section will briefly explain some of the benchmarking methodology used and why there are some diversion from the recommendations made in class. This will in addition to the executed command mention with each image. Due to `benchkit` limitation, the `cpu_list` variable was set to all cores available for each iteration. The ideal would be that the `cpu_list` matches the `nb_threads` variable but was unsuccessful in the implementation.

The confidence intervals & CoV charts can be found in @charts. The only noticeable remark is the CoV values for the smallest scene 01 is outside of the recommendations. The other scenes are within acceptable range.

=== Base

The benchmarks performed on the base version where executed with the provided `benchmark.py` file. In combination with `taskset` & `perfstat` information was collected.

The numbers of runs was set to *3*, this deviates from the recommendations @paae_cov_range, @number_of_runs, but due to how much time the implementation takes, this was considered an appropriate middle ground.

Additionally for `scene-05`, the number of thread count was limited to *20*, for the same reason as before.

=== Lock

For the lock improvement, the usage of `taskset` was identical as with the base version. The number of runs was capped at *1* all executed variations. For `scene-05` the decision was made to only start benchmarking from the number of threads of 8 until 20.


=== Inline

The number of runs per iteration was again set to *1*. All scenes where executed with the whole thread count range: `[1..33]`.


=== Pool

Due to the improvement of the execution time of the application, the decision was made here to set the number of runs for each iteration to *5*, more closely matching the recommendation seen in class. All scenes where executed with the whole thread count range: `[1..33]`.


=== Parallel

Due to the limitation of benchkit  mentioned earlier or not finding a working implementation, the build phase of the pathtracer uses the maximum available of threads it can see on the system. If `taskset` could be set in step with the number of threads given to the render time, the build time would also gradually increase when the thread count is increased. In the current implementation & benchmarking phase, the build time uses the maximum number of available threads.

=== SoA

For this improvement the decision was made to execute *10* runs per iteration. This feels a good middle ground between detecting any instability and execution time for the benchmark. During previous benchmarks, the time variance between run _seems_ quite stable.


=== Final

// TODO: Measure the final version?

== Platform

The benchmarks were executed on a KUbuntu 25.04 desktop, with the specifications listed in @desktop.

// TODO: Update
#figure(
  table(
    columns: (0.8fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [Ryzen 9 5950X],
    [RAM], [64GB (3200 Mhz)],
    [OS], [Ubuntu 25.10],
    [Kernel Version], [6.17.0-23-generic],
    [Scheduling], [Default],
    [Make], [GNU Make 4.4.1],
    [GCC], [gcc (Ubuntu 15.2.0-4ubuntu4) 15.2.0],
  ),
  caption: [Desktop Specifications],
) <desktop>

Note: for the scheduling, all benchmark are executed using `taskset`. Due to `benchkit` limitation, the `taskset` cpu list is set to all available cores and the `thread`variable is varied.

== Charts <charts>


#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5pt,
    inset: 2pt,
    [
      #image("charts/all/ci/ci_box.pdf")
    ],
    [
      #image("charts/all/cov/cov_heatmap_box.pdf")
    ],
  ),
  caption: [Scene 01 - CI & CoV],
)


#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5pt,
    inset: 2pt,
    [
      #image("charts/all/ci/ci_cornell-box.pdf")
    ],
    [
      #image("charts/all/cov/cov_heatmap_cornell-box.pdf")
    ],
  ),
  caption: [Scene 02 - CI & CoV],
)


#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5pt,
    inset: 2pt,
    [
      #image("charts/all/ci/ci_cornell-spheres.pdf")
    ],
    [
      #image("charts/all/cov/cov_heatmap_cornell-spheres.pdf")
    ],
  ),
  caption: [Scene 04 - CI & CoV],
)


#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5pt,
    inset: 2pt,
    [
      #image("charts/all/ci/ci_dragon.pdf")
    ],
    [
      #image("charts/all/cov/cov_heatmap_dragon.pdf")
    ],
  ),
  caption: [Scene 05 - CI & CoV],
)
