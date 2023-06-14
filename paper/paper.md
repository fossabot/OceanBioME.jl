---
title: 'OceanBioME.jl: A flexible environment for modelling the coupled interactions between ocean biogeochemistry and physics'
tags:
  - julia
  - biogeochemistry
  - climate
  - ocean
  - carbon
authors:
  - name: Jago Strong-Wright
    orcid: 0000-0002-7174-5283
    corresponding: true
    affiliation: "1, 2"
  - name: John R Taylor
    affiliation: "1, 2"
  - name: Si Chen
    affiliation: "1, 2"
  - name: Gregory LeClaire Wagner
    orcid: 0000-0001-5317-2445
    affiliation: 3
  - name: Collaborators
affiliations:
 - name: Department of Applied Mathematics and Theoretical Physics, University of Cambridge, Cambridge, United Kingdom
   index: 1
 - name: Centre for Climate Repair, Cambridge, United Kingdom
   index: 2
 - name: Massachusetts Institute of Technology
   index: 3
date: 15 March 2023
bibliography: paper.bib
---

# Summary

``OceanBioME.jl`` is a flexible modelling environment written in Julia for modelling the coupled interactions between ocean biogeochemistry, carbonate chemistry, and physics.
OceanBioME can be used as a stand-alone box model, or integrated into ``Oceananigans.jl`` [@Oceananigans] simulations of ocean-flavored fluid dynamics in one-, two-, or three-dimensions.
As a result, OceanBioME and Oceananigans can be used to simulate the biogeochemical response across an enormous range, ranging from surface boundary layer turbulence at the meter scale to eddying global ocean simulations at the planetary scale, and on computational systems ranging from laptops to supercomputers.
OceanBioME leverages Julia's multiple dispatch and effective inline capabilities to fuse it's computations directly into existing Oceananigans kernels, thus maintaining Oceananigans' bespoke performance, memory- and cost-efficiency on GPUs in OceanBioME-augmented simulations.

OceanBioME is built with a highly modular design that allows user control and customization.
There are three distinct module types implemented in OceanBioME.jl.
First, tracer-based ecosystem modules are formulated as a set of coupled ordinary differential equations.
These equations can be solved by OceanBioME as box models, which is particularly useful for testing.
The same modules can be integrated by Oceananigans to provide tracer-based ecosystem models.
Second, boundary modules contain sets of equations which provide information at the top and bottom of the ocean.
For example, air-sea gas exchange modules calculate the flux of carbon dioxide and oxygen at the sea surface, while sediment modules calculate fluxes of carbon and oxygen at the seafloor.
The third module type are "biologically active" particles.
These consist of individual-based models which are solved along particle paths and can be coupled with the tracer-based modules and physics from Oceananigans.
The biologically active particles can be advected by the currents, and/or they can move according to prescribed dynamics.
For example, migrating zooplankton or fish can be modelled with biologically active particles and OceanBioME allows these to interact with tracer-based components such as phytoplankton or detritus.

We provide a simple framework and utilities (such as light attenuation integration) to build the necessary components of biogeochemical models.
With the provided models, currently a simple NPZD [@npzd] model, an intermediate complexity model LOBSTER [@lobster], and PISCES [@pisces], we have set up a straightforward "plug and play" framework to add additional tracers such as carbonate and oxygen chemistry systems, and additional forcing.
Additionally, we have implemented comprehensive air-sea flux models [e.g. @wanninkhof:1992] and sediment models [e.g. @soetaert:2000] which can easily be applied to tracers in the models.
We focus on the simulation of idealized sub-mesoscale systems, but this flexible framework allows users to model problems of any scale.
This framework is made possible by our contributions to Oceananigans, adding a streamlined user interface to swap biogeochemical models with no modification to other model configurations.
This interface also facilitates rapid prototyping, as models can be coded to be in a much more accessible way, which is not possible with existing biogeochemical models.

OceanBioME was designed specifically to study ocean carbon dioxide removal (OCDR) strategies.
Assessing the effectiveness and impacts of OCDR is challenging due to the complexities of the interactions between the biological, chemical, and physical processes involved in the carbon cycle.
Moreover, field trials of OCDR interventions are generally small-scale and targeted, while the intervention required to have a climate-scale impact is regional or global.
We have built OceanBioME to meet these challenges by creating tools that provide a modular interface to the different components within the ocean modelling framework provided by Oceananigans.
This allows easy access to a suite of biogeochemical models ranging from simple idealized models to full-complexity models.

The biologically active particles built into OceanBioME are particularly useful for OCDR applications.
Accurate carbon accounting is essential for assessing the effectiveness of OCDR strategies.
Biologically active particles can be used to track carbon from a particular source while accounting for interactions with its surroundings.
Biologically active particles can also be used to model OCDR deployment strategies including seaweed cultivation, alkalinity enhancement, and marine biomass regeneration.
OceanBioME currently includes an extended version of the sugar kelp model presented in @broch:2012 as an example of the utility and implementation of these features.

We have formulated the models such that they are easy to use alongside data assimilation packages such as ``EnsembleKalmanProcesses.jl`` [@ekp] to calibrate their parameter.
This provides a powerful tool utility for integrating observations and models, with the potential to improve model skill and identify key sources of uncertainty.

![Here we show the results of a 1D model, forced by idealised light and mixing, which qualitatively reproduces the biogeochemical cycles in the North Atlantic.
We then add kelp (500 frond / m² in the top 50 m of water) in December of the 3ʳᵈ year (black vertical line) which causes an increase in air-sea carbon dioxide exchange and sinking export, as well as a change in the phytoplankton growth cycle.
Plot made with `Makie` [@makie].](column_example.png)

![Here we replicate the Eady problem where a background buoyancy gradient and corresponding thermal wind generate a sub-mesoscale eddy, roughly following the setup of Taylor (2016).
To this physical setup, we added a medium complexity (9 tracers) biogeochemical model, some of which are shown above.
On top of this, we added particles modelling the growth of sugar kelp which are free-floating and advected by the flow, and carbon dioxide exchange from the air.
A key advantage of writing ``OceanBioME.jl`` in Julia is that it offers accessibility similar to high-level languages such as Python, with the speed of languages like C and Fortran and built-in parallelism.
This means that models can be run significantly faster than the equivalent in other high-level languages.
``OceanBioME.jl`` can run on GPUs, allowing the above model (1 km × 1 km × 100 m with 64 × 64 × 16 grid points) to simulate 10 days of evolution in about 30 minutes of computing time.](eady_example.png)

A key metric for the validity of biogeochemical systems is the conservation of elements such as carbon and nitrogen in the system.
We therefore continuously test the implemented models in a variety of simple scenarios (i.e. isolated, with/without air-sea flux, with/without sediment) to ensure basic conservations are fulfilled, and will continue to add tests for any new models.
Additionally, we check ``OceanBioME.jl`` utilities through standard tests such as comparison to analytical solutions for light attenuation, and conservation of tracers for active particle exudation and sinking.

<!-- Flexible biogeochemical modelling frameworks similar to ``OceanBioME.jl`` are uncommon and tend to require more significant knowledge of each coupled system, a more cumbersome configuration process, provide a narrower breadth of utility, are not openly available, or are more computationally intensive.
For example among the open-source alternatives NEMO [@nemo] provides a comprehensive global biogeochemical modelling framework but requires complex configuration and is unsuited for local ecosystem modelling, while MACMODS [@macmods] provides more limited functionality on a slower platform. -->

Finally, this software is currently facilitating multiple research projects into ocean CDR which would have been significantly harder with other solutions.
For example, Chen (In prep.) is using the active particle coupling provided to investigate the effects of location and planting density of kelp in the open ocean on their carbon drawdown effect, as in the example above.
Additionally, Strong-Wright (In prep.) is using the coupling of both the biogeochemistry and easy interface to couple the physics to study flow interactions with a fully resolved giant kelp forest model including the effects on nutrient transport and distribution.

# Acknowledgements

We would like to thank the ``Oceananigans`` contributors for their fantastic project, and particularly Gregory Wagner for his advice and support, we are also very grateful for the support and funding of the [Centre for Climate Repair at Cambridge](https://www.climaterepair.cam.ac.uk/) and the [Gordon and Betty Moore Foundation](https://www.moore.org/).

# References