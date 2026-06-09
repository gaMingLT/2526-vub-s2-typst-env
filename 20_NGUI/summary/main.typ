// #import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string
#import "@preview/ilm:2.0.0": *


// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)


#set text(lang: "en")

#show: ilm.with(
  title: [Summary],
  authors: "Milan Lagae",
  date: datetime(year: 2026, month: 03, day: 28),

  table-of-contents: outline(depth: 2),


  figure-index: (enabled: false),
  table-index: (enabled: false),
  listing-index: (enabled: false),

  chapter-pagebreak: false,

  affiliations: (
    university: "Vrije Universiteit Brussel",
    faculty: "Sciences and Bioengineering Sciences",
    course: "",
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

This is a *very* short summary based on the list of topics in the lecture 13 overview slides.


#pagebreak()
= Chapter 1: Introduction


== History of human computer interaction

Original Macintosh to current Mac Studio, evolution and better specs & also interfaces!

Emergence of new techologies, allow for:
- innovative interaction
- combining the physical and digital
- collaborative interfaces


== Interface types and Natural User interfaces

Interface Types (blue ones):
- Virtual Reality
- Speech (voice)
- Pen
- Touch
- Gesture
- Haptic
- Multimodal
- Tangible
- Augmented and mixed reality
- Smart Interfaces


*Natural User Interfaces* (NUI): enable a user to interact with a computer in the same way as they interact with the physical world.


== Interaction design process (lifecycle model)

What to design?
- Who (user)
- How (task)
- Where (context)


#image("assets/idp.png")


Designing alternatives: use the creativity of the designer.


== Types of requirements

- Functional
- Data
- Environmental (context of user)
  - physical
  - social
  - organisational
  - technical
- User characteristics
  - user profile
- Usability goals
  - user objective measure for these evaluation's!
- User experience goals



== User-centered Design

+ Early focus on user and tasks
+ Empirical measurement
  - help choose between alternative designs
+ Iterative design


== Prototyping

- allow for stakeholder to interact early in the design process
- help choose between design alternatives
- allow for reflection in design

Low-Fidelity:
- Sketching
- Prototyping with index cards
- Wizard of Oz experiment
- Powerpoint


== Evaluation

For: Usability of the system; user experience!


- Why
  - fullfill user requirements
- What
  - Low-fidelity prototypes
- Where
  - setting where evaluation takes place
- When
  - formative
  - summative (avoid only this)


#pagebreak()
= Chapter 2: Information Architectures

Information architectures (IAs) address the organisation, structuring and labelling of content.


== Personal Information Management

(short) definition: acquire, organise, maintain, retrieve, use and control (...) documents (...) everyday (...) complete tasks.

=> keeping, organising and re-finding information.

#linebreak()

*Filers*: Instances are explicitly titled and arranged in some systematic order and these structures may themselves be explicitly titled and systematically organised.

*Pilers*: Piles tend not to have internal structure, other than access frequency; their spatial location is often the key to finding them



== Memory Types

Long Term Memory / Permanent memory store: intended for the long-term storage of information (...)
- huge
- slow access time

Subsystems
- episodic memory: 'events and experiences'
- semantic memory: 'facts and concepts'
- procedural skills: 'know-how'

#linebreak()

"As We May Think" (1945)
- human mind operates in association's -> associative indexing
- essential feature of the *memex*
- The process of tying 2 items together is the important thing
- memex
  - Memory Extender
  - trails (cross-references)


"Digital Documents as a Paper Simulator"
- Paper Under Glass
- digital documents take over affordances of the paper document (has it's limits)



== PIM Systems

- Lifestreams
  - stream of information, can apply filters, etc
- MyLifeBits
  - Photo's, recall & dynamic collections
- Microsoft SenseCam
- Presto
  - Properties
- Haystack


== RSL Metamodel, cross-media PIM and MindXpres


RSL Metamodel: make everything linkable, extensible, instead of copying data, link to content and reference it.

For filesystems: instead of path's use properties instead etc, new file system manager, have a hybrid between current FS and new types.

Examples:
- OC2
- PimVis Setup
  - Document View
  - Focus View
  - Context View

#linebreak()

MindXpres
- issue with slideware, limited to physical slides
  - limited space; linear navigation; difficult to reuse content
- flexible represntation
  - use of structurel RSL links
  - content-based approach
  - content reuse
  - non-linear navigation

#linebreak()

Cross-Media
- plugins: code, data visualization
- internal or external resources visualization


== Paper (homework)

See paper in question.


#pagebreak()
= Chapter 3: MultiModel Interaction


== Human Senses

#image("assets/senses.png")



== Bolt's "Put-that-there"

- combination of 2 input modalities
- *complementary* use of both modalities

In the video it shows that at one point the interaction/system breaks and the expected command is not executed.

#linebreak()

Another: SpeeG2, spelling correction using hand gesture, must take into account neutral position for the hand.


== Multimodal fusion and fission

#image("assets/fusion.png")

- data level
  - low semantics
  - highly sensitive to noise
- feature level
- decision level
  - highly resistant to noise and failures

#linebreak()

Advantages
- support user's perceptual and communicative capabilities
- more natural ways of human-machine interaction
- enhanced robustness
- flexible personalisation


== Ten *myths* of multimodal interaction

+ If you build a multimodal system, users will interact multimodally
+ Speech and pointing is the dominant multimodal integration pattern
+ Multimodal input involves simulataneous signals
+ Speech is the primary input mode in any multimodal system that includes it
+ Multimodal language does not differ linguisticallt from unimodal language
+ Multimodal interaction involves redudancy of content between modes
+ Individual error-prone recognition technologies combine multimodally to produce even greater unrealibility
+ All user's multimodal commands are integrated in a uniform way
+ Different input modes are capable of transmitting comparable content
+ Ehanced efficiency is the main advantage of multimodal systems.


== CARE Properties

CARE:
- Complementary
- Assignment
- Redudancy
- Equivalence
  - example: Edfest 2004 - pen + speech


== Multimodal interaction frameworks

Interfaces:
- Squidy
- OpenInterface
- Hephais TK
- Mudra


Families
- Stream
- Event-Based
- Hybrid


#pagebreak()
= Chapter 4: Pen-based Interaction


== History and affordances of pen and paper



== Digital pen and paper solutions



== iPaper research



== Innovative hardware and materials
