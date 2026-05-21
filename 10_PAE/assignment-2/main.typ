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

// TODO: Maybe use flamegraph and use differential one to compare between implementations?

// #colbreak()
= Intro

// Explain structure of report

This report will discuss the improvements made to the CPU based pathtracer for Assignment-2 of the course: 'Performance Analysis & Evaluation'. Each major improvement will be discussed in their respective sections. A collection of miscellaneous improvements will be discussed in @misc-improvement. Finally, the latest version of the implementation will be thoroughly discussed in @benchmarking.


// = Base Version

// Short analysis of base version results?


= Improvement 1: Lock Contention

// Explain the lock contention with random

This section will discuss the improvement of removing lock contention in the pathtracer implementation.


== Problem

The first problem that was identified & solved is the lock contention in the `random.c` file. When first benchmarking the application, it became clear that increasing the thread count made the application significantly slower.

Initial sourcing for this became clear after using `perf record` & `perf lock`, for which the result can be seen in (*TODO/ADD*). This same behavior is visible in @lock-before, where the gray lines between the thread activity is the thread waiting for a lock to be finished.

// TODO: Add perf record & perf lock image!

#figure(
  image("images/3-pool/pool-uprof/pool-base.png", width: 80%),
  caption: [AMD μProf - Lock Contention Threads ],
) <lock-before>


Further investigating the file, the offending function was identified to be `rand()`. Looking up the man page of the function @rand, it becomes clear that the function is not thread safe and suffers from heavy lock contention in thread heavy workloads.

This behavior becomes clear when the total time of each scene is plotted vs the thread count in @base-tt_vs_thread_count.

#figure(
  image("images/charts/0-base/total_time_vs_thread_count.pdf", width: 80%),
  caption: [*TODO*],
) <base-tt_vs_thread_count>

In the scenes 01, 02 and 04 increasing the thread count from 8 to 12 increases the total time taking for rendering said image. For the larger scene 05 this behavior is not as clearly visible, but there is slight increase in time when increasing the number of threads. This increase can be attributed to the use of the non reentrant safe `rand()` function.


== Solution

// Included in the man page of the `rand()` function is a recommendation to use the safe function `rand_r()`, but this function seems to require enabling some posix standard and is deprecated.

// The recommendation from online forum is a random value per  thread using a thread local variable see in @random-seed-thread-local.

// #figure(
//   zebraw(
//     lang: false,
//     // numbering: false,
//     ```c
//     static __thread uint32_t tls_seed = 0;
//     ```,
//   ),
//   caption: [],
// ) <random-seed-thread-local>

// In combination with `xorshift32` from @xorshift32 as shown in @xorshift.

// #figure(
//   zebraw(
//     lang: false,
//     // numbering: false,
//     ```c
//     static uint32_t xorshift32(void) {
//       if (tls_seed == 0)
//         tls_seed = (uint32_t)(uintptr_t)pthread_self() ^ (uint32_t)time(NULL);
//       tls_seed ^= tls_seed << 13;
//       tls_seed ^= tls_seed >> 17;
//       tls_seed ^= tls_seed << 5;
//       return tls_seed;
//     }
//     ```,
//   ),
//   caption: [],
// ) <xorshift>

// With the updated `random_double()` shown in @randomdouble-updated, there are some additional operations on the result and multiplication to further increase the randomness of the result.

// #figure(
//   zebraw(
//     lang: false,
//     // numbering: false,
//     ```c
//     double random_double(void) { return (xorshift32() >> 8) * (1.0 / 16777216.0); }
//     ```,
//   ),
//   caption: [],
// ) <randomdouble-updated>



== Results

// TODO: Add some images to show improvements in result, or something?


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

// === Implementation


== Results

The benchmark results of this section are the combination of the previous improvement and this improvement applied.

// TODO: Add benchmark results!

#pagebreak()
= Improvement 3: Thread Pooling

// Explain the process of adding a thread pool to better share the workload during rendering

This section will discuss the implementation of adding a thread pool which contains image rendering tasks. Each task will be responsible for a square tile of the image to be rendered.


// == Analysis



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

#figure(
  zebraw(
    lang: false,
    highlight-lines: (
      ..range(9, 11),
      (10, [The thread padding alluded to earlier, resulting in uneven work shared.]),
    ),
    // numbering: false,
    ```c
    // renderer_render
    // (...)
    for (int thread = 0; thread < renderer->threads; thread++)
    {
        thread_infos[thread].renderer = renderer;
        thread_infos[thread].width_start = thread * width_per_thread;
        if (thread == renderer->threads - 1)
        {
            // The last thread will take care of any remaining pixels if the width is not perfectly divisible by the number of threads.
            thread_infos[thread].width_end = renderer->width;
        }
        else
        {
            thread_infos[thread].width_end = (thread + 1) * width_per_thread;
        }

        pthread_create(&threads[thread], NULL, (void *(*)(void *))renderer_render_part, &thread_infos[thread]);
    }
    // (...)
    ```,
  ),
  caption: [],
) <thread-code-before>


As is visible in @thread-code-before, the behavior mentioned earlier is visible. And the vertical slice behavior in @vertical-slice-code-before.

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```c
    // renderer_render_part
    // (...)
    for (int w = width_start; w < width_end; w++)
    {
        for (int h = 0; h < renderer->height; h++)
        {
            struct vec3 *color = &renderer->framebuffer[w + h * renderer->width];

            for (int sample = 0; sample < renderer->scene->samples; sample++)
            {
                render_pixel(renderer, color, w, h);
            }
        }
    }
    // (...)
    ```,
  ),
  caption: [],
) <vertical-slice-code-before>

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

=== Implementation

// TODO: Continue here!

*TODO:* also mentioned the pixel lanes & SoA of the frame buffer!


// == Results

// TODO: Results here!


#pagebreak()
= Improvement 4: Parallel Build

// Explain the process of multi threaded `bvh_build`

This section will focus on making the `bvh_build` initialization function faster, by applying fork-join like multi-threading to the build process.


== Problem


Increasing the complexity & number of triangles when the scenes increases, leads to an explosion of the time it takes to build the BVH tree during the inizliation process, this behavior is visible in *ADD*.

// TODO: Add image: build time increasing for large scenes.






#pagebreak()
= Improvement 5: Structure of Arrays & SIMD

// Explain the process of SoA & SIMD

This section will discuss the application of transforming data layout from a AoS to Structure of Arrays (SoA). This to facilitate the application of SIMD vectorization on select functions.


== Problem






== Solution

Implementing the SoA memory layout in combination with `aligned_malloc` allows for the application of SIMD. While it would seem attractive to just use apply SIMD everywhere this is not what the performance numbers said. Choosing which function to transform in to using SIMD must be considered & measured.

Due note, that transforming from a AoS to SoA and (naively) replacing all `LINKED_LIST_FOREACH` macro with `for` loops, considerably reduces the performance of the application. Specifically for scene 05 on threads the times where: $~$25 seconds build; $~$ 60 seconds rendering.

After improving the `aabb_ray_intersect` with a more performant implementation and addition of an `inverse` field on `vec3` the render time was reduced to $~$ 50 seconds; the build time staid the same.

Let's start of with some example of functions where the application of SIMD has negligible or negative impacts. The following numbers and example are measured for `scene-05` and using *20* threads. We note that his is not a statisicaly analyis, but the wide chance in numbers does give an indicatiion of performance.

Implementing a SIMD based version of `aabb_for_triangles` (including `aabb_for_triangle` & `aabb_surrounding`) the build time regressed to $~$ 30 seconds. The same can be said for `postprocess_pixels`, there the SIMD implementation regressed by about $~$ 1 second for the render time.

The function's that did benefit from SIMD application is the `linked_list_ray_intersect` (now called `ray_intersect`) and the 2 downstream functions: `triangle_ray_intersect_simd` &`triangle_ray_intersect_sse`. This resulted in the following improvement: render time to $~$ 35 seconds for scene 05; $~$ 6 seconds for scene 04, coming from 10/8 seconds.


// TODO: add functions with numbers, etc



#pagebreak()
= Miscellaneous improvements <misc-improvement>

// List of miscellaneous  (minor) improvements

// - render pixel, 'lanes', store, multiple samples together
// - post process pixels add the end using SIMD
// - reordering of `bvh_ray_intersect`
// - addition of inverse on `vec3` and `aabb_ray_intersect`


#pagebreak()
= Benchmarking <benchmarking>

// Analyze the performance of current implementation






= Conclusion

// Overall conclusion


#pagebreak()
= Appendix

== Methodology

This section will briefly explain some of the benchmarking methodology used and why there are some diversion from the recommendations made in class. This will in addition to the executed command mention with each image. Due to `benchkit` limitation, the `cpu_list` variable was set to all cores available for each iteration. The ideal would be that the `cpu_list` matches the `nb_threads` variable but was unsuccessful in the implementation.

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

Due to the limitation of benchkit  mentioned earlier or not finding a working implementation, the build phase of the pathtracer uses the maximum available of threads it can see on the system. If `taskset` could be set in step with the number of threads givin to the render time, the build time would also gradualy increase when the thread count is increased. In the current implementation & benchmarking phase, the build time uses the maximum number of available threads.

=== SoA

For this improvement the decision was made to execute *10* runs per iteration. This feels a good middle ground between detecting any instability and execution time for the benchmark. During previous benchmarks, the time variance between _seems_ very stable.


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
