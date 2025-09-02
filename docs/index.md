---
hide:
  - navigation
  - toc
---

# Hybrid-handler

![Image title](images/logo.png){ width="25%", align=right }

Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime.
This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom.
It consists of the following stages and supported software modules are listed within each stage:

:cloud_tornado: &nbsp; **Initial conditions**

:   :simple-ticktick: &nbsp; *SMASH* (hadronic transport approach)

:droplet: &nbsp; **Hydrodynamics** to describe the evolution of the hot and dense fireball

:   :simple-ticktick: &nbsp; *vHLLE* (3+1D viscous hydrodynamics approach)
    :   :material-arrow-right-bottom: &nbsp; including *CORNELIUS* to construct a constant energy density hypersurface from the hydrodynamical evolution

:seedling: &nbsp; **Hadron sampler** to perform Cooper-Frye particlization of the elements on the freezeout hypersurface

:   :simple-ticktick: &nbsp; *SMASH hadron sampler*
:   :simple-ticktick: &nbsp; *FIST sampler*

:fire: &nbsp; **Afterburner** evolution

:   :simple-ticktick: &nbsp; *SMASH* (hadronic transport approach)

!!! info "Give credit appropriately &nbsp; [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15880337.svg){ align=right }](https://doi.org/10.5281/zenodo.15880337)"

    If you are using the Hybrid-handler, please cite the corresponding [:simple-doi: software DOI](https://doi.org/10.5281/zenodo.15880337) of the specific code version employed.
    Depending on the stages and modules you are using, please cite the appropriate papers and software DOIs as well.

    For example, if you use the SMASH-vHLLE-hybrid approach, besides citing the Hybrid-handler itself, you should cite [:newspaper: Eur.Phys.J.A 58(2022)11, 230](https://arxiv.org/abs/2112.08724) for the physics aspects.
    This paper can be also consulted for further details on the underlying physics.
    Additionally, you should cite the individual software package used for each stage, i.e. SMASH, vHLLE, and the SMASH hadron sampler.
