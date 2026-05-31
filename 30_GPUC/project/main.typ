// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)


#set text(lang: "en")

#show: ilm.with(
  title: [Project: Genetic Algorithm],
  authors: "Milan Lagae",
  // TODO: Change date!
  date: datetime(year: 2026, month: 06, day: 17),

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

This report presents "Project: Genetic Algorithm" assignment for the GPU Computing course. It begins by establishing the context of applying a Genetic Algorithm to the specific problem space in @context. @pipeline then outlines the data preparation pipeline and provides further details on the problem itself.

Following, the updated sequential implementation and initial naive speedup methods are detailed @sequential. Finally, the report focuses on the parallel implementation discussed in @parallel — before concluding with a comparative performance analysis of both versions in @analysis.


// == Declaration of AI Usage

// For starting the project and the start up phases AI was used. The repository for preprocessing the DEM data can be found here @dem_preprocessing. As a starting point, the following repository was used for both the sequential & parallel version of the algorithm: @cuda_starting_point. The initial repository was updated to reflect the modern features, such as the deprecated `rand()` function and more. After the code was updated, some AI help was used to think through the genetic algorithm structures.


// #pagebreak()
= Context <context>

The problem addressed by this genetic algorithm is a well-known challenge in wireless networking: optimizing service tower placement to maximize coverage while accounting for terrain variations @yoonEfficientGeneticAlgorithm2013b. Specifically, wireless internet providers must strategically position their infrastructure to ensure optimal signal distribution across complex geographic landscapes.

An identical problem arises within the military domain, where a limited set of sensors must be strategically deployed to maximize total coverage or detection probability @ridderMissionPlanningJoint2005.

For these very reasons, there have been historically been several attempts with success in applying Genetic Algorithms to solve this particular problem @dhillonSensorPlacementEffective.

A notable variation of this problem involves the deployment of two distinct sensor types, Forward-Looking Infrared (FLIR) and seismic, across hilly terrain to detect approaching military vehicles @seoEfficientLargeScaleSensor2016. In this scenario, the algorithm is utilized to optimize the placement strategy for both sensor types.

Consequently, this paper implements a scoped-down version of the genetic algorithm presented in @seoEfficientLargeScaleSensor2016. The implementation focuses exclusively on a single sensor type: a Forward-Looking Infrared (FLIR) sensor positioned 1.8 m above the ground—as illustrated in Figure @terrain-sensor.



#pagebreak()
= Pipeline & Genetic Algorithm <pipeline>

This section will discuss the pipeline of preparing and retrieving required DEM (Digital Elevation Model) data and the outputs the python preprocessing scripts generated for use in the genetic algorithm.

== Overview

The complete pipeline can be viewed in @pipeline-overview.

#figure(
  image("assets/images/context/GPUC-Pipeline.png", width: 80%),
  caption: [Pipeline Overview],
) <pipeline-overview>

The process starts with downloading the DEM data from a public source. Once the data is downloaded, the preprocessing step, based on the specified range, generates a Viewshed LUT (Look-Up-Table), Terrain Map and other `*.tiff` files. The viewshed LUT, is a 4D array: `viewshed[sx][sy][tx][ty]`, consisting of ones and zero, based on if source & target can see each other. The terrain map, is a 2D array which includes the elevation of the particular cell in question.

After the viewshed & terrain files are generated, the genetic algorithm is executed with those files as input. The GA takes input parameters and computes a result based on input parameters. The Ga generates a `sensors.csv` file, which contains the sensors positions based on grid coordinates.

The `*.tiff` files are created for visualization reasons and can later be imported into QGIS #footnote[https://qgis.org]. The generated `sensors.csv` file is later converted into GEO spatial coordinates file called: `geo_sensors.csv` using `convert_sensors.py`, which can also be imported into QGIS.

== DEM

The genetic algorithm itself requires appropriate terrain data for a more realistic scenario. This type of data can be downloaded from public sources easily. Therefore, the data for the country of Belgium was used. In this case, the source of the data came from OpenTopography.org #footnote[https://portal.opentopography.org/raster?opentopoID=OTSDEM.032021.4326.2] and was downloaded on 8 April 2026.

The two areas chosen as a comparison of the GA between flat terrain and a bit more hilly terrain can be seen in @ardennes-area & @flanders-area.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("assets/images/context/Ardennes.pdf"),
      caption: [The Ardennes Geolocation Area],
    ) <ardennes-area>
  ],
  [
    #figure(
      image("assets/images/context/Flanders.pdf"),
      caption: [Flanders Geolocation Area],
    ) <flanders-area>
  ],
)

The coordinates of both areas are the following: (Gdal format):
- The Ardennes: $5.4, 49.8, 5.540, 49.890$
- Flanders: $2.58, 51.00, 2.72, 51.09$

== Preprocessing

After the DEM data is available, the preprocessing step using `python` may begin. For this type of data & problem, there is a library available which does the heavy preprocessing lifting that is required, called: `gdal` @gdal_library.

The repository, which includes the preprocessing files, can be found at @dem_preprocessing. A short description and workings of the preprocessing will be made here. The repository consists of the following files: `preprocess_dem.py`, `preprocess_viewshed.py`, `convert_sensors.py`, `check_sizes.py`, `check_visbility.py`.

The `preprocess_dem.py` is responsible for converting a given square area based on ROI (Gdal coordinates) into a binary file containing area elevation data. The script creates several output files, the 2 files important for the GA are: `elevation.bin` and `elevation_meta.txt`. The remaining output files where used to verify the GA algorithm in QGIS as shown in @ardennes-area, @flanders-area.

#pagebreak()
#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("assets/images/context/GPUC-Terrain.png"),
      caption: [Terrain Elevation Grid],
    ) <terrain-grid>
  ],
  [
    #figure(
      image("assets/images/context/GPUC-Terrain-Sensor.png"),
      caption: [Terrain Sensor],
    ) <terrain-sensor>
  ],
)


The viewshed is generated by `preprocess_viewshed.py` file. It uses the `gdal.ViewshedGenerate` function to calculate the visibility of a source sensor 1.8m high and 0m (on the ground). Depending on the problem, these parameters can be tuned. This script creates several files, two files are used as input for the GA: `viewshed_lut.bin` and `viewshed_meta.txt`.

There are two verification files included: `check_sizes.py` is the first one: checks the size of each cell depending on the size of the area and the number of cells of the grid. The second one: `check_visibility.py` uses Gdal functions to check the general visibility of the area by reading in the `viewshed_lut.bin` file.

Closing the list of scripts: `convert_sensors.py` is responsible for converting the `*-sensors.csv` file generated by the GA algorithm from the coordinates on the GRID to GEO based coordinates for import and visualization in QGIS.

#pagebreak()
= Sequential <sequential>

This section will briefly discuss the updates made to the sequential genetic algorithm and naive attempt at speedup up the code by using OpenMP #footnote[https://www.openmp.org/].

== Implementation

The algorithm's reproduction loop begins by calling the `generateOffspring` function, which scales up the fitness value of all chromosomes by a large multiplier ($1000000$). The chromosome list is then iterated over to select pairs of parents. For each selection, a roulette wheel mechanism is used -- if the roulette value is lower than a randomly generated threshold, a parent is chosen; otherwise, a random index is returned.

Both parents are passed to the `crossover` function, for which both parents in the `population` are retrieved and both child values from the original chromosome in the `buffer` population. A random cross over point is selected using `rng`. The list of genes (sensors) is iterate, if once the crossover point is reached, the sensor position values are swapped, before they are just copied.

The next step is two `mutate` calls, iterate the current chromosome and next chromosome value, by iterating the list of genes and mutating the sensors x & y coordinates by a delta. The mutation probability is decided by RNG `prob_dist` and `delta_dist` for position delta.

The mutated population is evaluated by the `evaluate` function, each chromosomes genes are evaluated by the `computeChromosomeFitness` function. First, reusable sensor values are calculated. Proceeding, `GRID_SIZE` x `GRID_SIZE` cells are iterated, for each cell the visibility factor is checked using `getVisibilityFactor`, the POD table is used to look up POD using `lookupPOD`.

If the population has not reached maximum convergence, the generation loop continues until convergence is reached or generations loop is complete.

== OpenMP

Several `for` loop inside of the code have received a `#pragme` for enabling acceleration with earlier named OpenMP library.

For the function: `computeChromosomeFitness`, the sensor loop has received a `#pragma omp simd`, the loop that iterates over all the cells of the grid has received the following pragma: `#pragma omp simd reduction(+:totalPOD)`

The evaluation function: `evaluate`, has received the following pragma on the loop: `#pragma omp parallel for reduction(+:totalFitness) schedule(dynamic, 4)`. Generating the offsprings is handled by the function: `generateOffsprings`, for which the loop has received the following pragma: `#pragma omp parallel for schedule(dynamic, 4)`.

Due note that this is a naive application of the use of OpenMP pragma's, and are just an indication of how a naive application compares to a more handcrafted version genetic algorithm using Cuda.

== Results

This subsection will showcase the quick results of applying OpenMP pragma's on the genetic algorithm. The result of which can be seen in @openmp-threads.

#figure(
  image("assets/charts/seq/execution_time.pdf", width: 80%),
  caption: [Sequential GA - OpenMP],
) <openmp-threads>


As is visible in the image, the addition of even naive application of OpenMP pragmas, results in a *8x* reduction in execution_time between the single thread variant in the _32_ thread variant.

Expanding the analysis to the fitness value and speedup, both of are shown in @seq-fitness-speedup.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5pt,
    [
      #image("assets/charts/seq/fitness_vs_threads.pdf")
    ],
    [
      #image("assets/charts/seq/speedup.pdf")
    ],
  ),
  caption: [Fitness (right) and Speedup (left)],
)<seq-fitness-speedup>


The left image shows that each terrain has a region of fitness and that increasing the number of threads let's the fitness values fluctuating, but no large increase or decreases are noticed. For right chart, showcasing a speedup based on the 1 thread execution time, indicates the successful application of multiple threads to decrease execution time, while not having to fundamentally change the algorithm.

#pagebreak()
= Parallel <parallel>

This section will discuss the creation & implementation of the Genetic algorithm for computing using Cuda. First, the genetic structure of the algorithm will be discussed in @structure. A list of kernels & helper functions in @overview. A flowchart of how the algorithm interacts in @flow. And to complete, a detailed analysis of each kernel in @kernels.


== Genetic Structure <structure>

The genes of the genetic algorithm are structured as `double` value as shown in @gene-structure.

#figure(
  zebraw(
    lang: false,
    ```cpp
    typedef struct
    {
        double val;
    } gene_t;
    ```,
  ),
  caption: [Gene Structure],
) <gene-structure>

Each gene will contain one of the axis of a sensors coordinates: $(x,y)$. The genes (sensor) location are stored in one continues list as shown in illustration @genes-structure.

#figure(
  image("assets/images/par/GPUC-Genes.pdf", width: 80%),
  caption: [Genes Structure],
) <genes-structure>


Continuing on from the genes, the chromosomes of the algorithm have the following structure as shown in @chromosome-structure.

#figure(
  zebraw(
    lang: false,
    ```cpp
    typedef struct
    {
        double fitness;
        int geneIdx;
    } chromosome_t;
    ```,
  ),
  caption: [Chromosome Structure],
) <chromosome-structure>

Each individual chromosome has a `double` fitness value associated with itself and `geneIdx`, which is the starting index of where the genes for that chromosome begin in the list. Combining both genes & chromosome structure, result in the following organization as illustrated in @overall-structure.

#figure(
  image("assets/images/par/GPUC-Genes-Chromosomes.pdf", width: 80%),
  caption: [Genes & Chromosome Structure],
) <overall-structure>

The `geneIdx` value is an offset within the list of overall genes to which the chromosome stores its responsible genes. Based on this offset, the sensor location can be accessed. Each chromosomes also maintains a `fitnessValue` for the list of responsible genes.

Walking up the ladder of structures of the algorithm, the over arching one is the `population_t` structure, as illustrated in @population-structure.

#figure(
  zebraw(
    lang: false,
    ```cpp
    typedef struct
    {
        // FLIR range parameters
        (...)

        // Terrain parameters
        (...)

        // GA parameters
        (...)

        // Chromosomes & Genes
        chromosome_t *chromosomes;
        gene_t *genes;

        // GPU-side data tables
        double *pod_table_sq;
        float *terrain_elevation;
        uint32_t *packed_terrain_viewshed;
    } population_t;
    ```,
  ),
  caption: [Population Structure],
) <population-structure>

It stores the FLIR parameters, terrain parameters, GA parameters (mutation, etc), the earlierly listed chromosomes & genes list and the pod table, terrain elevation data and finally viewshed LUT.


== Kernels Overview <overview>

This subsection will briefly discuss the list of implemented kernels and their purposes before going in depth in the following section.

The following is the list of specific kernels:
- `initBufferKernel`: initializes chromosome values with default values for a population
- `setupCurand`: seeds a list randomness values in a shared state object
- `initIslandBufferKernel`: initializes per island chromosome values with defaults for a population
- `buildRouletteKernel`: initializes roulette values for each island
- `gaIslandKernel`: per island GA: `roulette`, `crossover`, `mutate`
- `migrateRingKernel`: migrates population between islands, shared ring buffer
- `evaluateIsland`: evaluates each island's list of chromosomes

The next is a list of helper kernels which are executed by the previously list of kernels:
- `cudaInitPopulation`: initializes each island population
- `rouletteSelect`: performs selection of chromosome
- `crossover`: performs genes crossover between current & new population
- `mutate`: mutates the genes for selection chromosome
- `getVisibilityFactor`: retrieves the visibility factor based on source & target coordinates
- `lookupPODSq`: POD (Probability of Detection) lookup
- `calculateOverlapPenalty`: calculates penalty if sensor overlap
- `calculateCellPOD`: calculate sensor POD based on sensor coordinates


#set page(columns: 2)


== Flow <flow>


#figure(
  grid(
    [
      #image("assets/images/par/GPUC-Flow.pdf", page: 1)
    ],
    [
      #image("assets/images/par/GPUC-Flow.pdf", page: 2)
    ],
  ),
  caption: [Genetic Algorithm Flow],
) <ga-flow>

The explanation of the algorithm flow will use the following parameters:
- population size: $1000$
- sensors: $100$
- islands: $5$
- generation: $100$
- \#threads/block: $512$

The genetic algorithm starts of with initializing two populations, a `buffer` and main `population` population. The `cudaInitPopulation` is the function where all the CPU code is copied into the GPU's memory.

Once the buffers have been initialized, the size of the `sharedMemSize` object is calculated for use later in the `evaluateIsland` kernel. The `d_pop1` is set to `cudaPopulation` and `d_pop2` is set to `cudaBuffer`.

The `d_pop1` kernel is initialized using `initBufferKernel`. For the example parameters, this will result in 3 blocks being launched.

Each island requires a `curand` state, this initialization is handled by the `setupCurand` kernel, in the example, it will launch $5$ blocks.

In an attempt at speeding up the execution of the evaluation of the chromosomes, `cudaStream`'s #footnote[https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/asynchronous-execution.html] where used. The numbers of streams equals the number of islands.

After the setup, the generation loops initiates.

The first step is the `initIslandBufferKernel`, it will initialize each kernel separately in the `d_pop2` population variable. Each separate island may now execute the GA algorithm independently after initialization.

Before the GA can be executed, the roulette selection must be setup by `buildRouletteKernel`, this is a single block & single thread execution.

Each `gaIsland` kernel will launch 1 block and in total 5 blocks will be executed. Each thread will perform some iterations to select some participants for selection.

#set page(columns: 1)

Selection is performed by `rouletteSelect`, for 2 parents, the 2 parents are passed to `crossOver`, and result is passed to `mutate` (x, y) coordinates. The results of which are written to the `buffer` population. At the end the `threadState` is saved into global states.

After the population of each kernel is 'updated' each island can be evaluated for its fitness. Before doing so, a pointer swap is performed. The previously `buffer` population (`d_pop2`) becomes `d_pop1` and is evaluated.

Each island and population is evaluated separately `evaluateIsland`, for each island, 200 blocks are spawned, matching the number of chromosomes.

Global migration between the island only occurs every *5* generations as set by the `migration_interval`. This allows each island grow, without incurring migration cost every generation. At the same time, every *5* generations, the chromosomes are checked to see if any have reached the converged.

If the `maxFitness` value has not reached the convergence value, the generation execution continues.


== Kernels <kernels>

This subsection will discuss some of the kernels more in depth.


=== `gaIslandKernel`

Each island is responsible for executing the genetic algorithm in isolation. The genetic algorithm includes the same steps as with the sequential version.

Since each island is constrained to an island, it has to work of the main list of chromosome, thus each island has a size based on the number of island and population size (\#chromosomes).

For each island, each thread is responsible for generating several pairs `(x,y)` of offspring, the offspring is selected by calling `rouletteSelect`. The global parent coordinates are found by adding the island offset. Than the `crossOver` step is executed using parent indices, followed by two `mutate` calls on the `buffer` population.


=== `evaluateIsland`

The next step after the GA algorithm has been applied on each respective island is to check the fitness of each island's chromosomes. For this particular kernel, the number of blocks launched, match the size (\#chromosomes) for each island.

The first step in the evaluation process, is the `extern __shared__ char rawSharedData[]` is populated by a single thread. Once the shared data object is populated the grid cell loop can start.

For each cell for which the kernel is responsible for the `calculateCellPOD` function is called. The function will iterate the list of sensors, calculate the visibility factor between sensor & target coordinates, apply a overlap penalty if needed and return the combined POD value.

The localPOD is added to a `blockSum` variable indexed by `threadIdx.x`, the array of local POD values is than summed by using parallel reduction on the `blockSum` array.

The thread with id 0, will divided the POD by the number of grid cells. The resulting fitness value is writen to the `fitnessOut` value, an array of all chromosome fitness values.


=== `migrateRingKernel`

The configuration of the migration of chromosomes between the islands can be seen in @kernel-ring.

#figure(
  image("assets/images/par/GPUC-Kernel.pdf", width: 60%),
  caption: [Kernel Ring Blocks],
) <kernel-ring>

Since each island has a particular size, each is responsible for a set of chromosomes. By viewing the chromosomes list as a ring, which wraps around to the beginning again, when the end is reach using `%`, migration between islands can be performed. The process of the migration step is visualized in illustration @migrate-kernel.


#figure(
  image("assets/images/par/GPUC-Migrate.pdf", width: 80%),
  caption: [Migrate Kernel Workings],
) <migrate-kernel>

The migration step is performed from the point of view from island $k$ and target island $k+1$. Each island has its own offset, respectively identified by `src_offset` and `dst_offset`.

A random `src` index will be found using randomness, than the chromosome with the worst fitness value in target island will be found. Than, if the fitness value of the `src` is greater than that of `dst`, the `geneIdx` are retrieved and the genes from `src` are copied to `dst`.

#pagebreak()
= Analysis <analysis>

This section will perform an analysis of the parallel GA implementation and its metrics. After an analysis of the parallel implementation is performed, a execution time comparison will be made to the sequential version.

== Methodology

The timing data collected for the sequential version executed *5* runs per configuration. The accompanying charts for the Cov & Std dev can be found in @charts-seq.

For the parallel implementation the timing data collection was made using the `std::chrono` library inside of the program. For each program execution *5* runs were collected. The accompanying charts for the Cov & Std dev can be found in @charts-par-timing.

Execution timing data for the sequential & parallel version are all within guidelines.

Collection metrics for the parallel version regarding bandwidth, etc, was a bit more difficult, due to the number of kernels launched. For this reason the `ncu` #footnote[https://developer.nvidia.com/nsight-compute] CLI was used in combination with `benchkit`i #footnote[https://github.com/open-s4c/benchkit]. This allowed for collecting targeted per kernel metrics using preset profiles for the wanted kernels.

The kernels that where profiled are the following: `initBufferKernel`, `initIslandBufferKernel`, `gaIslandKernel` and `evaluateIsland`. These kernels are the most involved in the algorithm, based on previous Nvidia Nsight Compute analysis. The collected metrics for each kernel where based on the `detailed` set. Due to how much time each profiling run takes, the number of iterations was reduced compared to the timing dataset. For all parallel benchmarks, the number of threads per block was fixed to *512*.


== Execution Time

Let's start by analyzing the execution time and the impact parameters have on the resulting fitness value. The execution time vs application parameters is shown in @timing-fitness-vs-time.


// TODO: Update chart axis
#figure(
  image("assets/charts/par/timing/fitness_vs_time.pdf"),
  caption: [Timing Dataset - Fitness vs Time],
) <timing-fitness-vs-time>

The first distinction that becomes clear is that between the terrain types, that the Flanders area has a much higher fitness value. Changing the number of generations, regardless of population does not change the resulting value fitness value while, increasing the execution time substantially.

Looking at the impact of the number of islands, for the smallest population there is a very small change in execution time when the population is $500$. There is a _very_ small increase in fitness value & execution time when increasing the population size from 5 until 20. For the larger population, the situation is reversed, the highest number of islands (20), gives a bit higher fitness value with slight reduction in execution time.

The parameter which has the highest impact on fitness & execution time is the number of sensors. This is to be expected, increasing the number of sensors, increases the coverage of the grid and a resulting higher fitness value.

Plotting the execution time in function of algorithm parameters can be found in @timing-time-vs-parameters.

// TODO: Update chart sub titles
// TODO: Update chart axis
#figure(
  image("assets/charts/par/timing/time_vs_parameters.pdf"),
  caption: [Timing Dataset - Time vs Parameters],
) <timing-time-vs-parameters>

The same behavior as noted previously, is more defined here. Both the generations & sensors have a negative impact on the execution time, with the sensors parameter only one resulting in an increase fitness value. For the island parameter, there is a slight increase and than downward trend when increasing the number of islands.

A test was done, to check if increasing the population size to a much larger value, beyond 1000 would have any impact, regardless of previous behavior discussed. The analysis of this can be found in @big-pop-population-vs-fitness.

// TODO: Update chart sub titles
// TODO: Add #islands, generations, to charts
#figure(
  image("assets/charts/par/big-pop/population_vs_fitness.png"),
  caption: [Large Population Dataset - Population Size vs Fitness],
) <big-pop-population-vs-fitness>

The charts make it conclusive, increasing the population size beyond $1000$, does not have any effect on an increasing fitness value. The chart does again show the clear distinciton in fitness value between the Ardennes & Flanders region.

=== Conclusion

Strong conclusion(s) about reason for described behavior above can only be made after a more thorough analysis in @bandwidth. But initial guesses can be made, saying that the GA algorithm is already well optimized for the problem space.


== Profiling  <bandwidth>

The analyzed kernels for this section are the following: `initBufferKernel`, `initIslandBufferKernel`, `gaIslandKernel` and `evaluateIsland`. This is based on previously made analysis using Nvidia Nsight Compute.

The following values are measures with the following parameter config:
- population: $1000$
- sensors: $100$
- generations: $50$

To start, the execution time for each kernel vs \#islands is shown in @profiling-time. This timing is the accumulated duration of $50$ generations!

#figure(
  image("assets/charts/par/profiling/kernel_time_breakdown.pdf"),
  caption: [Kernel Execution Times vs Islands],
) <profiling-time>

From the outset, it is immediately clear that the major bottleneck is the `evaluateIsland` kernel. For this reason, the major focus will be on the kernels: `gaIsland` and `evaluateIsland`.

Each kernel's primary computation throughput is shown in &@gflops-vs-islands.

#figure(
  image("assets/charts/par/profiling/gflops_vs_islands.pdf"),
  caption: [GFLOPs vs Islands],
) <gflops-vs-islands>

Both kernels are dominant in their respective operation type -- the `gaIslandKernel` is dominantly single precision point heavy -- while the `evaluateIsland` is dominated by double precision operations. In both kernels, it is clear that the throughput declines when increasing the number if islands. Before making any conclusion, the bandwidth per kernel must be analyzed, it could be that the kernels are memory bound.

The model we saw in class to use to check if a program is memory or compute bound is the roofline model, for both kernels, these can be found in @roofline-fp32-ardennes & @roofline-fp64-ardennes.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("assets/charts/par/profiling/roofline_fp32_ardennes.pdf"),
      caption: [Roofline FP32 - `gaIslandKernel` Ardennes],
    )
    <roofline-fp32-ardennes>
  ],
  [
    #figure(
      image("assets/charts/par/profiling/roofline_fp64_ardennes.pdf"),
      caption: [Roofline FP64 - `evaluateIsland` Ardennes],
    )
    <roofline-fp64-ardennes>
  ],
)

Based on both respective models, it can be concluded that neither kernel are neither compute or memory bound.

// TODO: paragraph

#figure(
  image("assets/charts/par/profiling/warp_occupancy_vs_islands.pdf"),
  caption: [Warp Occupancy - Ardennes],
)
<sm-dram-ardennes>

// TODO: paragraph

== Vs Sequential <vs-seq>

An comparison of the execution time & speedup between the sequential & parallel version is shown in @seq-vs-par-time. Both comparison are done with the same input configurations. For the GPU a mean is taken over all islands configurations.

#figure(
  image("assets/charts/seq-vs-par/comparison.pdf"),
  caption: [Sequential vs Parallel],
) <seq-vs-par-time>

The left chart in image @seq-vs-par-time, shows the execution time of both versions and the speedup on right chart in the image. The speedup chart shows that while the naive application of OpenMP library on the sequential version  delivers an impressive speedup between the 32 thread version and single thread version -- the GPU based algorithm is substantially faster compared to the single threaded version. Proving the usage and implementation of GA algorithm on GPU based devices has clear benefit.


= Conclusion

To summarize the points, both terrain has distinctive fitness values which is expected based on the terrain features. There is no difference in execution time for the terrains. The only factor impacting the fitness value is the \#sensors which is reasonable but no impact of other parameters requires further reasoning.

The throughput & bandwidth based kernels, indicate that there is room for improvement on the GPU GA implementation. But as the analysis in <vs-seq> shows, even an not that optimized GPU implementation achieves a significant speedup compared to a single threaded sequential version and even a 32 thread version.

The reduction in performance when increasing the number of islands per could possible be explained by the recreation of the `rawSharedData` value in each island in the `evaluateIsland` function. Future optimization could be to make this shared between all islands.

The `evaluateIsland` maintains the dominant kernel, even after switching to a island based GA algorithm. Future optimization's should target this kernel and maybe looking at moving from FP64 operations to FP32, due note that the current FP64 peak has not bean reached yet.

Overall the attempt could be considered a success with better improvement's & efficiency available for the parallel algorithm.


#pagebreak()
= Appendix

== Platform

The benchmarks were executed on a KUbuntu 25.04 desktop, with the specifications listed in @desktop.


#figure(
  table(
    columns: (0.8fr, 1fr),
    [*Part*], [*Value*],
    [CPU], [Ryzen 9 5950X],
    [GPU], [RTX 3070],
    [Driver Version], [595.97],
    [RAM], [64GB (3200 Mhz)],
    [OS], [Windows 11 - Version	10.0.22631 Build 22631],
    [WSL Version], [2],
    [WSL Distro], [24.04],
    [Kernel Version], [6.6.87.2-microsoft-standard-WSL2],
    [NVCC], [13.2, V13.2.51],
    [NCU], [Version 2026.1.0.0 (build 37166530)],
    [GCC], [gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0],
    [OpenMP], [201511],
  ),
  caption: [Desktop Specifications],
) <desktop>


== Charts

=== Sequential <charts-seq>

#figure(
  image("assets/charts/seq/cov_heatmap.pdf"),
  caption: [Sequential - Execution Time CoV],
)

#figure(
  image("assets/charts/seq/std_dev.pdf"),
  caption: [Sequential - Execution Time Std Dev],
)


== Parallel

=== Timing <charts-par-timing>

#figure(
  image("assets/charts/par/timing/cov_heatmap.pdf"),
  caption: [Timing Dataset - Execution Time CoV ],
)

#figure(
  image("assets/charts/par/timing/std_heatmap.pdf"),
  caption: [Timing Dataset - Execution Time Std Dev],
)

=== Large Population

#figure(
  image("assets/charts/par/big-pop/variability_heatmaps.png"),
  caption: [Large Population Dataset - Execution Time Cov & Std Dev],
)
