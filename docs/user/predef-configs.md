# The predefined configuration files

## Configuring the collision setups
There are several complete handler configuration files prepared for the user to run the hybrid handler in its entirety for different collision systems and energies. 
The shear viscosities applied are taken from *Karpenko et al.: Phys.Rev.C 91 (2015)* and the longitudinal and transversal smearing parameters are adjusted to improve agreement with experimental data. 
The supported collision systems are:

| System      |  $\mathbf{s_{NN} \; (GeV)}$ |
| :---------: | :----------------------------------: |    
| Au + Au     |  4.3     |
| Pb + Pb     |  6.4     |
| Au + Au     |  7.7     |
| Pb + Pb     |  8.8     |
| Pb + Pb     |  17.3    |
| Au + Au     |  27.0    |
| Au + Au     |  39.0    |
| Au + Au     |  62.4    |
| Au + Au     |  130.0   |
| Au + Au     |  200.0   |
| Pb + Pb     |  2760.0  |
| Pb + Pb     |  5020.0  |

They can be found in **predef_configs** subdirectory of the configs folder and the user is only required to insert the paths of the executables in the individual software sections. 
They can be executed in the standard manner  using *-c* option in the execution mode of the handler, i.e.:

``` title="Example about running hybrid handler for a predefined setup: Au+Au collision @ 4.3 GeV"
./Hybrid-handler do -c configs/predef_configs/config_AuAu_4.3.yaml
```
**Note:** The default predefined setup is meant to be executed on a computing cluster, we do not recommend executing it locally. 

## Running a test setup

To test the functionality and to also run it on a local computer, there is the possibility to execute a test setup of the hybrid handler, which is a Au+Au collision at sqrt(s) = 7.7 GeV. 
The statistics are significantly reduced however and the grid for the hydrodynamic evolution is characterized by large cells, too large for a realistic simulation scenario. <br>
**This test setup is hence only meant to be used in order to test the functionality of the framework and the embedded scripts, but not for production runs.**

To execute the test, a predefined configuration file is prepared in the same **predef_configs** subdirectory of the configs folder. Again, the user needs to insert the paths to the executables in all the software sections. 

``` title="Example about running the test setup of the hybrid handler"
./Hybrid-handler do -c configs/predef_configs/config_TEST.yaml 
```