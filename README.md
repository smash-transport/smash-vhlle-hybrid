# Annas-Hybrid
Hybrid model for the description of relativistic high-energy heavy-ion collisions. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with appropriate degrees of freedom. It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions
- vHLLE 3 +1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)
- Cooper-Frye sampler by S. Ryu to perform particlization of the freezeout hypersurface
- SMASH hadronic transport approach to perform the afterburner evolution

## Prerequisites
- [SMASH](https://github.com/smash-transport/smash) version &ge; 1.7
- [vHLLE](https://github.com/akschaefer/vhlle) branch `schaefer/Output_for_Sampler_Ryu_inMilne`
- Cooper-Frye sampler by S. Ryu
- ([SMASH-analysis](https://github.com/smash-transport/smash-analysis) version &ge; 1.7, if automatic generation of particle spectra is desired)
