---
hide:
  - navigation
  - toc
---

# SMASH-vHLLE-Hybrid

Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom. It consists of the following modules:

- SMASH hadronic transport approach to provide the initial conditions
- vHLLE 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)
- Cooper-Frye sampler to perform particlization of the elements on the freezeout hypersurface
- SMASH hadronic transport approach to perform the afterburner evolution

!!! info "Give credit appropriately"

    If you are using the SMASH-vHLLE-hybrid, please cite [Eur.Phys.J.A 58(2022)11,230](https://arxiv.org/abs/2112.08724).
    You may also consult this reference for further details about the hybrid approach.
