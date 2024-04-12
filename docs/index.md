---
hide:
  - navigation
  - toc
---

# SMASH-vHLLE-Hybrid

![Image title](images/logo.png){ width="25%", align=right }

Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom. It consists of the following modules:

:cloud_tornado: &nbsp; **SMASH** hadronic transport approach to provide the initial conditions

:droplet: &nbsp; **vHLLE** 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball

:   :material-arrow-right-bottom: &nbsp; CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)

:seedling: &nbsp; **Sampler** to perform Cooper-Frye particlization of the elements on the freezeout hypersurface

:fire: &nbsp; **SMASH** hadronic transport approach to perform the afterburner evolution

!!! info "Give credit appropriately"

    If you are using the SMASH-vHLLE-hybrid, please cite [Eur.Phys.J.A 58(2022)11,230](https://arxiv.org/abs/2112.08724).
    You may also consult this reference for further details about the hybrid approach.
