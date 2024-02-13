# The predefined configuration files

## Configuring the collision setups
There are several complete handler configuration files prepared for the user to run the hybrid handler in its entirety for different collision systems and energies.
The shear viscosities applied are taken from [:newspaper: *Karpenko et al.: Phys.Rev.C 91 (2015)*](https://journals.aps.org/prc/abstract/10.1103/PhysRevC.91.014906) and the longitudinal and transversal smearing parameters are adjusted to improve agreement with experimental data.
The supported collision systems are listed in the following table.

<div class="center-table" markdown>

| System      |  $\mathbf{\sqrt{s_{NN}} \;\: \{GeV\}}$ | System      |  $\mathbf{\sqrt{s_{NN}} \;\: \{GeV\}}$ |
| :---------: | :------------------------------------: | :---------: | :------------------------------------: |
| Au + Au     |  4.3     |     Pb + Pb     |  6.4     |
| Au + Au     |  7.7     |     Pb + Pb     |  8.8     |
| Au + Au     |  27.0    |     Pb + Pb     |  17.3    |
| Au + Au     |  39.0    |     Pb + Pb     |  2760.0  |
| Au + Au     |  62.4    |     Pb + Pb     |  5020.0  |
| Au + Au     |  130.0   |||
| Au + Au     |  200.0   |||

</div>

They can be found in :file_folder: **configs/predef_configs** folder and the user is only required to insert the paths of the executables in the individual software sections.
They can be executed in the standard manner using `-c` option in the execution mode of the handler.

``` title="Example about running hybrid handler for a predefined setup: Au+Au collision @ 4.3 GeV"
./Hybrid-handler do -c configs/predef_configs/config_AuAu_4.3.yaml
```

!!! warning "Be aware of computational cost!"
    The default predefined setup is meant to be executed on a computing cluster, we do not recommend executing it locally.
    If you want to test a simple setup on your local machine, refer to the test setup explained here below.

## Running a test setup

To test the functionality and to also run it on a local computer, there is the possibility to execute a test setup of the hybrid handler, which is a Au+Au collision at $\small\sqrt{s} = 7.7\;\mathrm{GeV}$.
The statistics are significantly reduced and the grid for the hydrodynamic evolution is characterized by large cells, too large for a realistic simulation scenario.

!!! danger "Don't use this setup for production!"
    This test setup is only meant to be used in order to test the functionality of the framework and the embedded scripts, but not to study any realistic physical system.

To execute the test, a predefined configuration file is prepared in the same :file_folder: **predef_configs** folder. Again, the user needs to insert the paths to the executables in all the software sections.

``` title="Example about running the test setup of the hybrid handler"
./Hybrid-handler do -c configs/predef_configs/config_TEST.yaml
```
