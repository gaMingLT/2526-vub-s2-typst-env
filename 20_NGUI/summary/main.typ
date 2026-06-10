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

Cave paintings, stylus, progressing further, until modern ballpoint pens and than electronic pens.

And for paper; clax and wax tablets; papyrus; parchment and than paper.


- Coevolution of paper and work practices
- Everybody know how to use pen and paper (expecations)

#linebreak()

Myth of Paperless office, never came to be.

#linebreak()

Affordances of Pen and paper

Affordance: how to use an object

Paper
- light
- flexible
- navigation
  - flipping across Documents
- ...

Paper supports some forms of collaboration and interaction that are difficult to mimic in digital space.

Pen
- robust
- light
- ...


Example: Ikea BookBook

#linebreak()

Replacing pen and Paper? Handwriting is still the best, etc (study)



== Digital pen and paper solutions

Bridging paper-digital divide => integration

#image("assets/pdi.png")

Examples
- telautograph
- memex
  - uses pen for reference & notes
- stylator and RAND tablet
- Sketchpad (1963)
- Light Pen
- Graphics Tablet (modern)
- Ultrasonic Position Detection Pen (clipon)
- Digital Desk (old/history)

#linebreak()

Digital Pen & Paper
- Anoto
  - camera / grid
- NeoLab



== iPaper research

- Link metamodel (RSL)
- Tools
- Cross-Media Server / Publishing
- Applications

Cross-media; interactive document has information stored on server, position on paper links to active page areas and layers (can be image/ video clip / etc)

Link metamodel (RSL); consisting of links, users, layers, plug-ins and active components.

PaperPoint Presentation Tool, control using actions on paper, detected using pen's.

Input device independence

#linebreak()

Digital Pen and Paper Applications
- Enhanced Reading
- Ehhanced writing
- Paper-based interfaces
- Art Installations
- Interactive tabletops

#linebreak()

Examples (cross-media):
- Edfest user trials
- Natural History Museum



== Innovative hardware and materials

- mobile solutions
- fusion of electronic paper and interactive paper
- HoloLens & HoloDoc (feedback)



#pagebreak()
= Chapter 5: Interactive Tabletops and Surfaces


== Multi-user tabletop interfaces

Multi-user, each users has it's own type of zone. Personal space zone, group space, store zone, etc.
- personal territories
- group territories
- storage territories

Ergonomic issues, not as-all purpose computing more for dedicated tasks.


== Enabling technologies and frameworks

Basic components
- touch sensor
- display
- software


Display technologies
- resistive touch panels
- surface capacitive touch panels
- projected capacitive touch panels
- surface acoustic wave (SAW)
- frustrated total internal reflection (FTIR)
- diffused illumination (DI)


== Applications

- digital desk
- diamond touch table
- Jeff Han's multi-touch table
- Benddesk
- Microsoft PixelSense
- ReacTIVISion
- iTtable Interactive Tabletop
- weInspire Room
- HP Sprout Pro
- Microsoft Surface Studio 2

- Oled panels
- Windowless plane



#pagebreak()
= Chapter 6: Gesture-based interaction

== What is a gesture?

- motion of the limbs or body to express
- expression of thought or emphasis
- succesion of postures

Formal: non-verbal comunication; visible bodily actions; particular message(s). (...) movement of the hands, face, or other parts of the body.


== Gesture Types

- semiotic gestures
- ergotic gestures
- epistemic gestures


semiotic gestures
- symbolic (emblems, ...)
- deictic (pointing, ...)
- iconic (size, shape, ...)
- pantomimic gesutres (movement, ...)



== Gesture recognition devices

- wired gloves
- Accelerometers
- Camcorders and webcams
- Skeleton tracking
- Electromyography (EMG)
- Single and multi-touch surfaces
- see lecture on Interactive Tabletops and Surfaces
- Digital pens


== Gesture design guidelines

Gesture vocabularies, common pitfalls:
- hard to perform
- hard to remember
- feel fatigue

Observe the user & evaluated against criteria.



== Gesture spotting and recognition solutions

We introduced a new gesture spotting approach based on a human-readable representation of automatically inferred spatio-temporal constraints.

Recognition algorithms
- template-based
- machine learning-based
- rule-based

Pen-based
- offline
- online
- methods: ...



== Paper

See paper in question.



#pagebreak()
= Chapter 7: Tangible, Embedded and Embodied Interaction


== History of graspable and tangible user interfaces

Marble Answering Machine
- incomming messages by physical marbles
- aesthetically pleasing and enjoyable to use
- one-step actions
- multi-use usage might be a bit difficult, know where a product is used

#linebreak()

Graspable User interfaces
- Physical handles (bricks)
- Brick tightly coupled to a virtual object
- Large horizontal display surface: 'ActiveDesk'

Advantages:
- two-handed interactions
- parallel-input
- affordances of artefacts
- multi-person
- foundations o tangible interaction


#linebreak()

Affordances
- originally: 'all possible actions with an object'
- refined:
  - 'possible actions that can be recognised'
  - 'how to use the object'


Example: The Norman Door

Definition of Tangible Interfaction, umbrella term for:
- graspable user interfaces
- tangible user interfaces
- embodied interaction



== Applications

- Lifewire (1995)
- metaDESK
- ambientROOM
- Urp
- ReacTIVISion
- The Sand Noise Music Device
- ArtVis
- Sifteo Cubes (Siftables)
- ZeroN
- TRANSFORM


== Tangible bits and radical atoms

Tangible Bits (1997)
- Beyond GUIs - Tangible User Interfaces (TUIs) augment the physical space by coupling digital information to everyday objects and environments.

#linebreak()

Radical Atoms (2012)
- leap beyond Tangible Bits
- bidirectionally coupled
- human-material interaction
- Material User Interface (MUI)

Concept
- Transform: 'shape'
- Conform: 'physical laws'
- Inform: 'inform user'

Interactions with Radical Atoms
- direct touch and gestural interaction
- context-aware transformation
- shape-memory clay: *Perfect Red*

#linebreak()

Vision-Driven Design Research
- strong vision can last beyond our lifespan
- have to wait for enabling technologies but exploration of interaction design can already start



== Tangible Holograms (TangHo)

Data Physicalisation: (how) dynamic data Physicalisation with dynamic affordances? -> tangible holograms.

#image("assets/tangho.png")


== Paper

See paper in question.




#pagebreak()
= Chapter 8: Virtual and Augmented Reality


== Definition

#image("assets/mixed.png")

- Reaility-Virtuality continumm
- Merging
  - physical and digital object co-exist
  - mixed reaility
  - augmented reality and augmented virtuality

#linebreak()

Virtual Reality (VR) is an artificial environment which is experienced through sensory stimuli (e.g.sight or sound) provided by a computer and in which a user's actions partially determine what happens in the environment.

main issues
- create acceptable substitutes for real world objects or environments
- sense
- navigate
- interact

First VR: The Sword of Damocles

#linebreak()

Applications
- architecture
- education
- medicine
- engineering
- military
- entertainment

#linebreak()

Perceptual immersion (physical immersion or sensory
immersion) is about the perception of being physically present in a non-physical virtual environment which is created by surrounding images, sound or other stimuli by the VR system.

#linebreak()

Non-immersive virtual environments show a real-time 3D environment on a desktop screen.
- "desktop virtual reality"

== Technologies

#grid(
  columns: (1fr, 1fr),
  rows: (auto, auto),
  column-gutter: 5pt,
  row-gutter: 10pt,
  [
    #image("assets/screens.png")

    Large Screens
  ],
  [
    #image("assets/boom.png")

    Binocular Omni-Orientation Monitor (BOOM)
  ],

  [
    #image("assets/cave.png")

    Cave Automatic Virtual Environment (CAVE)
  ],
  [
    #image("assets/hmd.png")

    Head-mounted Display (HMD)
  ],
)



== VR Navigation and Interaction Techniques

- computed generated scenes (...) navigate and interact

*Navigation* is the ability to move around and explore the features of the virtual environment (3D scene).

*Interaction* involves the selection and moving of objects in a scene.

#linebreak()

- grabbing in the air
- lean-based velocity
- path drawing
- walking in place


Example: Disney HoloTile Treadmill

#linebreak()

Two types
- non-immersive interaction
- immersive interaction

Interaction Techniques
- virtual hand
- ray casting
- image plane

Example: Haptic PIVOT


== Augmented Reality Techniques

Augmented Reality (AR) is a variation of Virtual
Environments (VE), (..). (...) allows the user to see the real world, (...) virtual objects superimposed upon or composited with the real world. (...) suplements reality, rather than completely replacing it. (...) virtual and real objects coexisted (...).

#grid(
  columns: (1fr, 1fr),
  rows: (auto, auto, auto),
  column-gutter: 5pt,
  row-gutter: 10pt,
  [
    #image("assets/video.png")


    Video Compositing
  ],
  [
    #image("assets/hud.png")

    Head-up displays
  ],

  [
    #image("assets/direct.png")

    Direct Projection
    - SixthSense
  ],
  [

    #image("assets/wikitude.png")


    Magic lens metaphor
    - Wikitude World Browser
  ],

  [
    #image("assets/mirror.png")

    Magic mirror metaphor
  ],
  [
    #image("assets/eyeglass.png")

    Magic Eyeglass metaphor
  ],
)

- Optical see-through HMDs
- Video see-through HMDs
- Virtual Retinal Displays (VRD)
- Google Glass
- Microsoft HoloLens 2
- Dynamic 365 Remote Assistant
- Computing Glasses

== Applications

- Maintenance
- Architecture
- Education
- Medicine
- (...)



#pagebreak()
= Chapter 9: Data Physicalisation

== Advantages

== Enabling Technologies


== Examples


== Research Challenges


== Dynamic Data Physicalisation Framework



#pagebreak()
= Chapter 10: Implicit Human-Computer Interaction


== Context


== Intelligibility


== Affective Computing



== Emotion Classification Models



== Emotion Recognition Modalities



#pagebreak()
= Chapter 11: Human-AI Interaction

== Challenges

== Guidelines


== Human-centered artificial intelligence (HCAI)


== HCAI Framework


== Prometheus Design principles



#pagebreak()
= Chapter 12: Case Studies and Future Research


== Applications

*TODO*


== Role of Visions in HCI Research

Think of interactions and designs that one would normally think about and thinking further that what is available and letting creativity go 'wild'.


== Future of work and workers

*TODO*


== Human-AI Collaboration

Instead of interialy realying on AI, using AI in a such a way to critically think of the text is to be read and use that for critical thinking.
