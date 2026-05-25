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

This report will discuss the improvements made to the CPU based pathtracer for Assignment-2 of the course: 'Performance Analysis & Evaluation'. Each major improvement will be discussed in their respective sections: Lock in @lock; Inlining in @inlining; Pool in @pool; Parallel in @parallel. The results in each section will be the improvement added during that section onto the previous version.

Finally, the latest version of the implementation will be thoroughly discussed in @final. The methodology @methodology discusses deviations from the standard. The CoV charts can be found in @charts.


= Methodology <methodology>

This section will briefly explain some of the benchmarking methodology used and why there are some deviations from the recommendations made in class. In combination with `taskset` & `perfstat` information was collected. The list of PMU events tracked during benchmarking are the following: `branches`, `branch-misses`, `cache-misses` `cache-references`, `cycles`, `instructions`, `stalled-cycles-frontend`.

Due to `benchkit` limitation (or not finding how to), the `cpu_list` variable was set to all cores available for each iteration. The ideal would be that the `cpu_list` matches the `nb_threads` variable, but this was unsuccessful in implementation.

The confidence intervals & CoV charts can be found in @charts. The only noticeable remark is the CoV value(s) for the smallest scene 01 are outside of the recommendations. For the other scenes, the values are within acceptable range.

== Base

The numbers of runs was set to *3*, this deviates from the recommendations @paae_cov_range, @number_of_runs, but due to how much time the implementation takes, this was considered an appropriate middle ground. Additionally, for `scene-05`, the number of thread count was limited to *20*, for the same reason as before.

== Lock

For the lock improvement, the usage of `taskset` was identical as with the base version. The number of runs was capped at *1* for each iteration. It is acknowledged that the number of runs is considered inappropriate for proper comparison @paae_crimes. For `scene-05` the decision was made to only benchmark for the thread range of: 4 until 20.


== Inline

The number of runs per iteration was again set to *1*. It is acknowledged that the number of runs is considered inappropriate for proper comparison. All scenes were executed with the whole thread count range: `[1..33]`.


== Pool

Due to the improvement of the execution time of the application, the decision was made here to set the number of runs for each iteration to *5*, more closely matching the recommendation seen in class. All scenes were executed with the whole thread count range: `[1..33]`.


== Parallel

Due to the limitation of benchkit  mentioned earlier, or not finding a working implementation, the build phase of the pathtracer uses the maximum available of threads it can see on the system.

If `taskset` could be set in step with the number of threads given to the render time, the build time would also gradually decrease when the thread count is increased. In the current implementation & benchmarking, the build time uses the maximum number of available threads on the system.

== SoA

For this improvement the decision was made to execute *10* runs per iteration.


== Final

For this improvement *15* runs were executed per iteration.


#pagebreak()
= Improvement 1: Lock Contention <lock>

This section will discuss the improvement of removing lock contention in the pathtracer implementation.


== Problem

The first problem that was identified & solved is the lock contention in the `random.c` file. When first benchmarking the application, it became clear that increasing the thread count made the application significantly slower.

Initial sourcing for this became clear after using `perf stat`, `perf record` & `strace` for which the result can be seen in @perf-annotate-lock. For scene 04, with 20 threads: (04-20).


#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("images/1-lock/select-perf-record-lock-02-04.png"),
      caption: [Perf Record - Overhead (04-20)],
    )
  ],
  [
    #figure(
      image("images/1-lock/select-perf-record-lock-02-10-annotate.png"),
      caption: [Perf Annotate - Lock (04-20)],
    ) <perf-annotate-lock>
  ],
)



This same behavior is visible in @lock-before, where the gray lines between the thread activity is the thread waiting for a lock to be finished.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("images/1-lock/select-uprof-base-04-20.png"),
      caption: [AMD μProf - Lock Time (04-20)],
    )
  ],
  [
    #figure(
      image("images/3-pool/pool-uprof/pool-base.png"),
      caption: [AMD μProf - Lock Contention Threads (04-20)],
    ) <lock-before>
  ],
)


Using the `perf record` annotate, the offending function can be found: `rand()`, as is shown in @perf-annotate-lock. Looking up the man page of the function @rand, it becomes clear that the function is not thread safe and suffers from heavy lock contention in thread heavy workloads.

This behavior becomes clear when the Total Time of each scene is plotted vs the thread count in @base-tt_vs_thread_count.

#figure(
  image("charts/0-base/total_time_vs_thread_count.pdf", width: 80%),
  caption: [Total Time - Base],
) <base-tt_vs_thread_count>

In the scenes 01, 02 and 04 increasing the thread count from 8 to 12, increases the total time taking for rendering said image. For the larger (scene 05), this behavior is not as clearly visible, but there is slight increase in time when increasing the number of threads. This increase can be attributed to the use of the non reentrant safe `rand()` function.


== Solution

Included in the man page of the `rand()` function is a recommendation to use the safe function `rand_r()`, but this function seems to require enabling some posix standard and is deprecated.

As a fix, the `rand()` was replaced with a `xoroshiro128plusplus` implementation based on @xorshiroplusplus and `splitmix` for seeding the random number generator @splitmix.



== Results

The improvements in performance when the lock contention is removed, is visible in @time-lock-vs-base and @speedup-lock-vs-base.


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

The behavior where the speedup increases when more threads are used, clearly shows the non re-entrant behavior of the original `rand()` function. The charts in @speedup-lock-vs-base give an indication of how efficiently the implementation makes use of the available threads compared between the versions.


The improvement in performance becomes even more clear, when looking at the IPC of the two implementations in @derived-metrics-lock-vs-base.


#figure(
  image("charts/1-lock/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Lock & Base],
) <derived-metrics-lock-vs-base>


#pagebreak()
= Improvement 2: Inlining <inlining>

This section will discuss the process of inlining @wiki_inlining compute & time intensive `vec3_*` operations.

== Problem

What became clear during the previous improvement & looking at the code, is the heavy usage of `vec3` operation calls. Using the information displayed in @inlining-base-perf-1 & @inlining-base-perf-2, it becomes clear that there is potential performance to be gained.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
)[
  #figure(
    image("images/2-inlining/select-perf-record-base-inline-02-04.png"),
    caption: [Perf Record - Overhead Vec3 (02-20)],
  ) <inlining-base-perf-1>
][
  #figure(
    image("images/2-inlining/select-perf-record-base-inline-04-04.png"),
    caption: [ Perf Record - Overhead Vec3],
  ) <inlining-base-perf-2>
]

When using the AMD μProf profiling application of which the results is shown in @inlining-base-amd-uprof, is that the `vec3_index` function alone is takes *95 seconds*.

#figure(
  image("images/2-inlining/select-uprof-base-inline-04-20.png", width: 80%),
  caption: [ AMD μProf - Vec3 Operations Time (04-20) ],
) <inlining-base-amd-uprof>


== Solution

The most immediate fix for this performance issue is the application of placing all the `vec3_*` functions inside of the `vec3.h` file and placing the `inline` keyword before each function. This 'forces' the compiler to inline the function code in every location where the code is called, -- preventing the compiler from having to use `jumps/goto` -- and performing (registers updates, etc) for each `vec3` call.


== Results

Both, the time and speedup are charted in @time-inline-vs-lock, @speedup-inline-vs-lock respectively. Note that for the speedup in @speedup-inline-vs-lock, the 'speedup' is compared against the time available of the lowest thread count value.



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

Across the board, there is a general reduction in the time needed for rendering all scenes. The increase in time, when increasing the thread count for scene 02, is visible in both states.

The behavior of the application, regrading speedup (= efficiency of thread usage) does not drastically change between the previous version and the current version. All of the smaller scenes almost completely overlap their respective plots. The largest scene 05, deviates from this, by slightly being more efficient in using more threads.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/1-lock/total_time_rel_diff.pdf"),
      caption: [Total Time Relative Difference - Lock vs Base],
    ) <tt-rel-diff-lock>
  ],
  [
    #figure(
      image("charts/2-inlining/total_time_rel_diff.pdf"),
      caption: [Total Time Relative Difference - Inline vs Lock],
    ) <tt-rel-diff-inline>
  ],
)

These results do not particularly surprise, since the change does not concern itself with more efficient thread usage. The difference in time reduction between thread count is clear when looking at the relative differences in @tt-rel-diff-lock & @tt-rel-diff-inline.



#figure(
  image("charts/2-inlining/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Inline vs Lock],
) <derived-metrics-inline-vs-lock>

For all scenes, there is a _'large'_ increase in the in the branch miss prediction rate, while the cache miss rate did not substantially change between the previous version. For the IPC, there is a substantial reduction to note for the largest scene 05.

#pagebreak()
= Improvement 3: Thread Pooling <pool>


This section will discuss the implementation of adding a thread pool which contains image rendering tasks. Each task will be responsible for a square tile of the image to be rendered.


== Problem

Analyzing the application, using the AMD μProf @amd_uprof application, and viewing the thread section, shows the behavior visible in @pool-before. Specifically the end of the timeline of the renderer is important. The illustration in @thread-util-before shows how the rendered splits the image in non equal workload, by splitting the image vertical slices from top to bottom.


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

Depending on the image to be rendered, some threads may have less work than other threads. This because not all pixels in an image are identically or have equal amount of work to be rendered.  Additionally, the last thread of the image is padded so it rendered the full width of the image.

== Solution


The problem identified above was solved by two additions. First, instead of vertical slices, the image is now split in smaller (16x16) square tiles, as illustrated in @thread-util-after. In addition to the image tilling, render tasks are now based on pool design @c_pool_1 @c_pool_2.

The improvement in evenly shared work between the threads can be seen in @pool-updated. The end of the timeline, the threads finish more at the same time and there are no more threads that are sitting idle.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
)[
  #figure(
    image("images/3-pool/pool-tilling/PAE-AS2-Tiling-New.png"),
    caption: [Image Slicing - Vertical Slices],
  ) <thread-util-after>
][
  #figure(
    image("images/3-pool/pool-uprof/pool-updated.png"),
    caption: [AMD μProf - Thread(s) Non Idling Timeline (04-20)],
  ) <pool-updated>
]

Included in the pooling modifications is the addition of the `ray_color2_soa` and packing the results of several ray's in an array. The framebuffer of the image has also been transformed into a SoA layout.


== Results

There is _small_ reduction in execution time for all scenes with the added improvement, as shown in @time-pool-vs-inline. For scene 02, the 'bulge' that is visible for the treads 16,28 has been eliminated. On glance, the greatest impact of the pool on the execution time is for the largest scene, scene 05.

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

Looking at the speedup in @speedup-pool-vs-inline, the efficiency of using more threads has been increased, with an overall much better usage for scene 02, where the reduction for the 20,24, threads has been eliminated.

Each scenes has their respective execution behavior, depending on image size and computation cost. This behavior & cost, the positioning of each takes a position in the respective charts, and a more clear distinction between scenes is visible.

For the IPC, the lowest bound on scene-05 for 32 threads, compared to the previous improvement has been reduced from $~$1.2 to $~$1.1.


#figure(
  image("charts/3-pool/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Pool vs Inline],
) <derived-metrics-pool-vs-inline>


#pagebreak()
= Improvement 4: Parallel Build <parallel>

This section will focus on making the `bvh_build` initialization function faster, by applying fork-join like multi-threading to the build process.


== Problem

Increasing the complexity & number of triangles when the scenes increases, leads to an explosion of the time it takes to build the BVH tree during the initialization process.


== Solution

This solution consists, of using a separate thread to compute the right side of the current node, while the current thread computes the left side. There is a spawn parallel condition, which guards between the thread overhead creation and compute remaining.

== Results

For the parallel improvement, the total time reduction for the smaller scenes is not really noticeable. With time plots for the scenes 01,02 and 04 matching their previous version. The largest reduction in execution time is for scene 05, as can be seen in @time-parallel-vs-pool.



#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/4-parallel/total_time_comparison.pdf"),
      caption: [Total Time - Parallel vs Pool],
    ) <time-parallel-vs-pool>
  ],
  [
    #figure(
      image("charts/4-parallel/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Parallel vs Pool],
    ) <speedup-parallel-vs-pool>
  ],
)

For the speedup @speedup-parallel-vs-pool, the greatest improvement in efficiency is for scene 05. Were the efficiency of more threads has made quite a big jump.



#figure(
  image("charts/4-parallel/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Parallel vs Pool],
) <derived-metrics-parallel-vs-pool>

There are no things to note for the IPC, Branch, Cache Miss Rate, with the addition of the new improvement. Above behavior is what could be expected when looking at the implementation, and is also what the problem identified earlier tried to solve. Reducing the build phase of the `bvh` tree could be considered a success when looking at the charts in @derived-metrics-parallel-vs-pool.



#pagebreak()
= Improvement 5: Structure of Arrays & SIMD <soa>


This section will discuss the application of transforming data layout from a AoS to Structure of Arrays (SoA). This to facilitate the application of SIMD vectorization on select functions.


== Problem

The problem to be solved is the usage of linked list, which makes use of pointers to keep track of elements in the list. While also transforming the data from a AoS to a SoA allowing for application of SIMD somewhere in the data path.



== Solution

Implementing the SoA memory layout in combination with `aligned_malloc` allows for the application of SIMD. While it would seem attractive to just use apply SIMD everywhere this is not what the performance numbers indicated. Choosing which function to use SIMD, must be considered & measured.

Due note, that transforming from a AoS to SoA and (naively) replacing all `LINKED_LIST_FOREACH` macro with `for` loops, considerably reduces the performance of the application. Specifically for scene 05 on threads the times were: $~$25s build; $~$60s rendering (1 on @simd-soa-timings).

After improving the `aabb_ray_intersect` with a more performant implementation and addition of an `inverse` field on `vec3`, the render time was reduced to $~$50s; the build time did not change (2 on @simd-soa-timings).

Let's start of with some example of functions where the application of SIMD has negligible or negative impacts. The following numbers and examples are measured for `scene-05` and using *20* threads. We note that his is not a statistical analyis, but the wide chance in numbers does give an indication of performance.

Implementing a SIMD based version of `aabb_for_triangles` (including `aabb_for_triangle` & `aabb_surrounding`) the build time regressed to $~$30s. The same can be said for `postprocess_pixels`. There the SIMD implementation regressed by about $~$1s for the render time (3 on @simd-soa-timings).

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

The functions that did benefit from SIMD application are `linked_list_ray_intersect` (now called `ray_intersect`) and the 2 downstream functions: `triangle_ray_intersect_simd` &`triangle_ray_intersect_sse`. This resulted in the following improvement: render time to $~$35s for scene 05; $~$6s for scene 04, coming from 10/8s (4 on @simd-soa-timings).

Continuing with the improvements, applying SIMD on the `calculate_split_cost` function decreased the build time from around $~$25s to $~$12s (5 on @simd-soa-timings).

Included in this improvement is the addition of the `inverse` field on the `vec3` struct and re-reordering rays in `bvh_ray_intersect` by returning distance from `aab_ray_intersect`. For scene 05, this resulted in the following improvement; From $~$35s render time to $~$22s (6 on @simd-soa-timings).


== Results

The overall execution time with the addition of the SoA & application of SIMD to selective functions has marginally reduced the execution time overall, as seen in @time-soa-vs-parallel. Since the improvement does not partially pertain to more efficiency use of threads, the speedup factors between the version in @speedup-soa-vs-parallel, could be considered identical.


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

The derived metrics from the `perf stat` wrapper can again be viewed in @derived-metrics-soa-vs-parallel.


#figure(
  image("charts/5-soa/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - SoA vs Parallel],
) <derived-metrics-soa-vs-parallel>


The most notable change on the charts to note, is the increase in the IPC for scene-05, with the single thread IPC going from $~1,50$ to $~1.75$

Across all the scenes and for all metrics, starting from thread count 16, there is an increase in the branch mis prediction rate, decrease in cache-miss rate, but a decrease in IPC.



#pagebreak()
= Final <final>

This section will discuss the final version of the pathtracer.

== Improvement

The last improvements for the pathtracer is the addition of an indices based bvh build step. This step is more focused on the reduction of the memory usage, particularly for scene 05. The original implementation in @soa, the maximum memory usage sits around $~$12GB. The added benefit is a slight improvement in performance during the render time of the image, while build time is the same.


Instead of allocating memory for each leaf of a node during the bvh build step, indices are sorted and passed to their respective child nodes while the main triangles list is used through the build process. When a leaf node is reached, the list of indices is used to load and allocated memory into the leaf nodes triangle list.


== Results

The execution time in @time-final-vs-soa is about the same as before. The smaller scenes see no real improvement, with the scene 02 even seeing an increase in execution time. With the largest scenes has the largest reduction in execution time.


#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("charts/6-final/total_time_comparison.pdf"),
      caption: [Total Time - Final vs SoA],
    ) <time-final-vs-soa>
  ],
  [
    #figure(
      image("charts/6-final/speedup_comparison.pdf"),
      caption: [Speedup Total Time - Final vs SoA],
    ) <speedup-final-vs-soa>
  ],
)

There are again no real changes in the speedup charts with the new improvement, as shown in @speedup-final-vs-soa.

The derived metrics are visible in @derived-metrics-final-vs-soa. The most positive thing to note is that for the larger scenes (04,05), the cache miss rate Percentage has seen a large decrease. For scene 04; going from around 20% to < 10% and for scene 05; going from around 25% to < 20%.


#figure(
  image("charts/6-final/derived_metrics_comparison.pdf"),
  caption: [IPC, Branch, Cache Miss Rate Percentage - Final vs SoA],
) <derived-metrics-final-vs-soa>

The improvement has a negative impact on the IPC for the scene 01,02,04, and a positive impact for the larger scene 05. All scenes do see an increase in the branch miss prediction rate compared to the SoA version.



#pagebreak()
= Conclusion

This section will analyze the different improvements made for the pathtracer application and the overall impact on application performance. The first look will be at the change in total time each scene & stage take in @tt-per-stage.


#figure(
  image("charts/all/tt_per_stage.pdf"),
  caption: [],
) <tt-per-stage>


What is clear for the smallest scene 01, is that from the pool improvement on, each following improvement seems to have a negative impact on the time. This might be attributed to the overhead for the new features dominating. While for the larger scenes (02,04,05), all improvements indicate to have a positive improvement on execution time. With the `lock` improvement seeming to have the largest impact, followed by `inline`.

Charting the speedup of each stage relative to the base version, for 3 different thread count (1,20,32), can be seen in @gmean-speedup-overview. The analysis makes use of the geometric mean as seen in class @paae_gmean_summary.

// TODO: Check charts for correctness!
#figure(
  image("charts/all/speedup_vs_base.pdf"),
  caption: [Geometric Mean Speedup, Per Stage & Scene (1, 20, 32 threads)],
) <gmean-speedup-overview>

Due to choices made in data collection, mentioned in @methodology, the 32 thread count chart is incomplete, any conclusions should be guarded. The charts for the 1 & 20 thread count chart, allow for a clear differentiating in speedup between single thread & multi-threaded behavior of the application.

Analyzing the multi-threaded behavior of the final application using Amdahl's law can be seen in @amdahl-overview. While it is more of a diagnostic tool, the application does allow the analysis of the efficiency of the application for each improvement & scene.

#figure(
  image("charts/all/amdahl_fit.pdf"),
  caption: [Amdahl Law: Scene x Threads],
) <amdahl-overview>

For the smaller scenes, the behavior does not deviate between the versions. The greatest improvement of efficiency can is visible for scene 05, when going from the `pool` version to `parallel`. For each subsequent version (`soa`, `final`) there is a reduction of maximum speedup.

Applying the USL law on the application indicated that Amdahl law was a better fit for modeling application behavior. There was no reduction in performance while increasing application thread count. Possible indicating that the application could still benefit from an increased thread count for the largest scene.


// TODO: Check charts for correctness!
// #figure(
//   image("charts/all/usl_fit.pdf"),
//   caption: [Universal Scaling Law: Scene x Threads],
// ) <usl-overview>



#pagebreak()
= Appendix


== Platform

The benchmarks were executed on a KUbuntu 25.04 desktop, with the specifications listed in @desktop.


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
