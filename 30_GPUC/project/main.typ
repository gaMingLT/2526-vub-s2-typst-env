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

This report will discuss the assignment 'Project' for the course: 'GPU Computing'. First, the context of the application of a Genetic Algorithm will be discussed for the problem space add hand. After the context, the pipeline for data preparation and more information about the problem will be discussed in @pipeline. Continuing from the pipeline, the updated sequential will be discussed including the naive speedup methods. Finally, the focus of the assignment the parallel version in @parallel. Concluding, both version will be analyzed in @analysis.

// FIXME: Make sure this is present in the final version!
== Declaration of AI Usage

For starting the project and the start up phases AI was used. The repository for preprocessing the DEM data can be found here @dem_preprocessing. As a starting point, the following repository was used for both the sequential & parallel version of the algorithm: @cuda_starting_point. The initial repository was updated to reflect the modern features, such as the deprecated `rand()` function and more. After the code was updated, some AI help was used to think through the genetic algorithm structures.

// #pagebreak()
= Context <context>

The problem for which the genetic algorithm is used, is a problem widely occurring in the wireless networking world @yoonEfficientGeneticAlgorithm2013b. Where, wireless internet providers must decide where to position there service towers to provided the maximum or greatest coverage, taking into account terrain features.

This identical problem, occurs in the military domain, were with a limited set of sensors, the greatest coverage (or detection probability) must be gained with the available sensors @ridderMissionPlanningJoint2005.

// This type problem is considered an *TODO: add*, where the problem is to large to compute with normal methods and therefor different methods are found to look for optimal algorithms: (*TODO: source*).

For this reasons, there have been historically been several attempts with success add using Genetic Algorithms to solve this particular problem @dhillonSensorPlacementEffective.

There is also a variation on this problem, where two types of sensors are placed on the ground in hilly terrain and are used to check detection of vehicles trying to pass @seoEfficientLargeScaleSensor2016. The algorithm is used to place two types of sensors: FLIR & Seismic.

For this reason, this paper is the implementation of a scoped down version of the genetic algorithm in @seoEfficientLargeScaleSensor2016. It uses only one type of sensor FLIR placed, 1.8m above the ground, illustration can be seen in @terrain-sensor.


#pagebreak()
= Pipeline & Genetic Algorithm <pipeline>

This section will discuss the pipeline of preparing and retrieving required DEM (Digital Elevation Model) data and the outputs the python preprocessing scripts generated for use in the genetic algorithm.

== Overview

The complete pipeline can be viewed in @pipeline-overview.

#figure(
  image("assets/images/GPUC-Pipeline.png", width: 80%),
  caption: [Pipeline Overview],
) <pipeline-overview>

The process start with downloading the DEM data from a public source. Once the data is downloaded, the preprocessing step, based on the specified range generates a Viewshed LUT, Terrain Map and other `*.tiff` files. The viewshed LUT, is a 4D array: `viewshed[sx][sy][tx][ty]`, consisting of ones and zero, based on if source & target can see each other. The terrain map, is a 2D array which includes the elevation of the particular cell in question.

After the viewshed & terrain files are generated, the genetic algorithm is executed with those files as input. The GA takes input parameters and computes a result based on input parameters. The Ga generates a `sensors.csv` file, which contains the sensors positions based on grid coordinates.

// TODO: Rewrite
For visualization purposes, the several `*.tiff` files and `sensors.csv` file converted to GEO based coordinates in `geo_sensor.csv` into QGIS which is used for visualization.

== DEM

The genetic algorithm itself requires appropriate terrain data for a more realistic scenario. This type of data can be downloaded from public sources easily, and for this reason, the data for the country of Belgium was used. In this case, the source of the data came from #footnote[https://portal.opentopography.org/raster?opentopoID=OTSDEM.032021.4326.2] and was downloaded on 10 April 2026.

The two areas chosen as a comparison of the GA between flat terrain and a bit more hilly terrain can be seen in @ardennes-area & @flanders-area.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5pt,
  [
    #figure(
      image("assets/images/Ardennes.pdf"),
      caption: [Ardennes Geolocation Area],
    ) <ardennes-area>
  ],
  [
    #figure(
      image("assets/images/Flanders.pdf"),
      caption: [Flanders Geolocation Area],
    ) <flanders-area>
  ],
)

The coordinates of both areas are the following: (Gdal format):
- Ardennes: $5.4, 49.8, 5.540, 49.890$
- Flanders: $2.58, 51.00, 2.72, 51.09$

== Preprocessing

After the DEM data is available, the preprocessing step using `python` may begin. For this type of data & problem, there is a library available which does the heavy preprocessing lifting that is required, called: `gdal` @gdal_library.

The repository which includes the preprocessing files can be found at @dem_preprocessing. A short description and workings of the preprocessing will be made here. The repository consists of the following files: `preprocess_dem.py`, `preprocess_viewshed.py`, `conver_sensors.py`, `check_sizes.py`, `check_visbility.py`.

The `preprocess_dem.py` is responsible for converting a given square area based on ROI (Gdal coordinates) into a binary file containing area elevation data. The script creates several output files, some are important for important into QGIS but the two important files for the GA are: `elevation.bin` and `elevation_meta.txt`.

#figure(
  image("assets/images/GPUC-Terrain.png", width: 70%),
  caption: [Terrain Elevation Grid],
) <terrain-grid>

The viewshed is generated by `preprocess_viewshed.py` file -- it uses the `gdal.ViewshedGenerate` function to calculate the visibility of a source sensor 1.8m heigh and 0m (on the ground). Depending on the problem, these parameters can be tuned. This scripts also exports several files, two files matter for the GA: `viewshed_lut.bin` and `viewshed_meta.txt`.

#figure(
  image("assets/images/GPUC-Terrain-Sensor.png", width: 70%),
  caption: [Terrain Sensor],
) <terrain-sensor>

There are two verification files included: `check_sizes.py` this one checks the size of each cell depending on the size of the area & the number of cells of the grid; `check_visibility.py` uses Gdal functions to check the general visibility of the area by reading in the `viewshed_lut.bin` file.

Closing the list of scripts: `convert_sensors.py` is responsible for converting the `*-sensors.csv` file generated by the GA algorithm from the coordinates on the GRID to GEO based coordinates for import and visualization in QGIS.

#pagebreak()
= Sequential <sequential>

This section will briefly discuss the updates made to the sequential genetic algorithm and naive attempt at speedup up the code by using OpenMP #footnote[https://www.openmp.org/].

== Updates

*TODO:* Quickly go over the update's and changes made to the code / algorithm.

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



// TODO: Add paragraph

#pagebreak()
= Parallel <parallel>

This section will discuss the creation & implementation of the Genetic algorithm for computing using Cuda.


== Genetic Structure



== Kernel Overview




#pagebreak()
= Analysis <analysis>

// Compare Sequential vs parallel & more in depth of the parallel version

== Methodology

// TODO: Short section about how many runs


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
    [WSL Version], [2],
    [WSL Distro], [24.04],
    [Kernel Version], [6.6.87.2-microsoft-standard-WSL2],
    [NVCC], [13.2, V13.2.51],
    [NCU], [Version 2026.1.0.0 (build 37166530)],
    [GCC], [*TODO*],
    [OpenMP], [*TODO*],
  ),
  caption: [Desktop Specifications],
) <desktop>


== Charts

=== Sequential

#figure(
  image("assets/charts/seq/cov_heatmap.pdf"),
  caption: [*TODO:*],
)

#figure(
  image("assets/charts/seq/std_dev.pdf"),
  caption: [*TODO:*],
)
