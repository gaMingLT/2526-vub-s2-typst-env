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


== Problem

The first problem that was identified & solved is the lock contention in the `random.c` file. When first benchmarking the application, it became clear that increasing the thread count made the application significantly slower.

Initial sourcing for this became clear after using `perf record` & `perf lock`, for which the result can be seen in (*TODO/ADD*). This same behavior is visible in @lock-before, where the gray lines between the thread activity is the thread waiting for a lock to be finished.

// TODO: Add perf record & perf lock image!

#figure(
  image("images/pool-uprof/pool-base.png", width: 80%),
  caption: [AMD μProf - Lock Contention Threads ],
) <lock-before>


Further investigating the file, the offending function was identified to be `rand()`. Looking up the man page of the function @rand, it becomes clear that the function is not thread safe and suffers from heavy lock contention in thread heavy workloads.



== Solution

Included in the man page of the `rand()` function is a recommendation to use the safe function `rand_r()`, but this function seems to require enabling some posix standard and is deprecated.

The recommendation from online forum is a random value per  thread using a thread local variable see in @random-seed-thread-local.

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```c
    static __thread uint32_t tls_seed = 0;
    ```,
  ),
  caption: [],
) <random-seed-thread-local>

In combination with `xorshift32` from @xorshift32 as shown in @xorshift.

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```c
    static uint32_t xorshift32(void) {
      if (tls_seed == 0)
        tls_seed = (uint32_t)(uintptr_t)pthread_self() ^ (uint32_t)time(NULL);
      tls_seed ^= tls_seed << 13;
      tls_seed ^= tls_seed >> 17;
      tls_seed ^= tls_seed << 5;
      return tls_seed;
    }
    ```,
  ),
  caption: [],
) <xorshift>

With the updated `random_double()` shown in @randomdouble-updated, there are some additional operations on the result and multiplication to further increase the randomness of the result.

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```c
    double random_double(void) { return (xorshift32() >> 8) * (1.0 / 16777216.0); }
    ```,
  ),
  caption: [],
) <randomdouble-updated>



// == Results

// TODO: Add some images to show improvements in result, or something?


#pagebreak()
= Improvement 2: Inlining

// Explain the practice of inlining the `vec3*` operations

This section will discuss the process of inlining @inlining compute & time intensive operations to improve performance.

== Problem

// TODO: Add image of overhead of vec3!


== Solution



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
    image("images/pool-tilling/PAE-AS2-Tiling-Old.png"),
    caption: [Renderer - Image Slicing Before],
  ) <thread-util-before>
][
  #figure(
    image("images/pool-uprof/pool-base.png"),
    caption: [AMD μProf - Thread behavior ],
  ) <pool-before>
]

Depending on the image to be rendered, some vertical slices may have less work than other vertical slices. Additionally, the last vertical slice of the image is padded so it rendered the full with of the image.

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```c
    // renderer_render
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
    ```,
  ),
  caption: [],
) <vertical-slice-code-before>

== Solution

// Add some source also
The problem identified above was solved by two additions. First, instead of vertical slices, the image is now split in smaller (32x32) square tiles, as illustrated in @thread-util-after. In addition to the image tilling, render tasks are now based on pool design @c_pool_1 @c_pool_2.

The improvement in evenly shared work between the threads can be seen in @pool-updated. The end of the timeline, the threads finish more at the same time and there are no more threads that are sitting idle.

#grid(
  columns: (1fr, 1fr)
)[
  // TODO: Fix image
  #figure(
    image("images/pool-tilling/PAE-AS2-Tiling-New.png", width: 80%),
    caption: [...],
  ) <thread-util-after>
][
  #figure(
    image("images/pool-uprof/pool-updated.png"),
    caption: [...],
  ) <pool-updated>
]

=== Implementation

// *TODO*: Continue here!



#pagebreak()
= Improvement 4: Parallel Build

// Explain the process of multi threaded `bvh_build`





#pagebreak()
= Improvement 5: Structure of Arrays & SIMD

// Explain the process of SoA & SIMD






#pagebreak()
= Miscellaneous improvements <misc-improvement>

// List of miscellaneous  (minor) improvements

- render pixel, 'lanes', store, multiple samples together
- post process pixels add the end and SIMD




#pagebreak()
= Benchmarking <benchmarking>

// Analyze the performance of current implementation






= Conclusion

// Overall conclusion


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
    [RAM], [64GB (3200 Mhz)],
    [OS], [*TODO*],
    [Kernel Version], [*TODO*],
    [Scheduling], [*TODO*],
    [Make], [*TODO*],
    [GCC], [*TODO*],
  ),
  caption: [Desktop Specifications],
) <desktop>

Note: for the scheduling, all benchmark are executed using `taskset`. Due to `benchkit` limitation, the `taskset` cpu list is set to all available cores and the `thread`variable is varied.
