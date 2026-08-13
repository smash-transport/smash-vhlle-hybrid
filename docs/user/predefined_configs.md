# The predefined configuration files

## Running a test setup

To test the functionality and to also run it on a local computer, there is the possibility to execute a test setup of the Hybrid-handler, which is a Au+Au collision at $\small\sqrt{s} = 7.7\;\mathrm{GeV}$. The statistics are significantly reduced and the grid for the hydrodynamic evolution is characterized by large cells, too large for a realistic simulation scenario.

!!! danger "Don't use this setup for production!"
    This test setup is only meant to be used in order to test the functionality of the framework and the embedded scripts, but not to study any realistic physical system.

To execute the test, a predefined configuration file is prepared in the :file_folder: **predef_configs** folder. The user needs to insert the paths to the executables in all software sections.

``` title="Example about running the test setup of the Hybrid-handler"
./Hybrid-handler do -c configs/predef_configs/config_TEST.yaml
```

!!! warning "Be aware of computational cost!"
    The setups below are meant to be executed on a computing cluster, we do not recommend executing it locally.
    If you want to test a simple setup on your local machine, refer to the test setup explained above.

## The original hybrid setups
In order to reproduce the original SMASH-vHLLE hybrid calculations in [:newspaper: *Schäfer et al.: Eur.Phys.J.A 58 (2022) 11, 230*](https://link.springer.com/article/10.1140/epja/s10050-022-00872-x), the configuration files in the :file_folder: **predef_configs/EPJA_58-11-230** folder can be used.
The shear viscosities applied are taken from [:newspaper: *Karpenko et al.: Phys.Rev.C 91 (2015)*](https://journals.aps.org/prc/abstract/10.1103/PhysRevC.91.014906) and the longitudinal and transversal smearing parameters are adjusted to improve agreement with experimental data.

They can be found in :file_folder: **configs/predef_configs** folder and the user is only required to insert the paths of the executables in the individual software sections.
They can be executed in the standard manner using `-c` option in the execution mode of the handler.

``` title="Example about running Hybrid-handler for a predefined setup: Au+Au collision @ 4.3 GeV"
./Hybrid-handler do -c configs/predef_configs/EPJA_58-11-230/config_AuAu_4.3.yaml
```

!!! warning "Tradeoff between runtime and precision"
    Although SMASH-vHLLE-hybrid conserves in average all charges and almost all energy, this is strongly dependent on the grid in $\eta$ direction.
    Therefore, there is a tradeoff between the runtime and memory consumption of the hydrodynamic stage and conservation.
    The default in the configuration tries to strike a balance, as there is less than 10% loss of energy for central collisions from $\small\sqrt{s} = 4.3\;\mathrm{GeV}$ to $\small\sqrt{s} = 200\;\mathrm{GeV}$.
    The original publication [:newspaper: *Schäfer et al.: Eur.Phys.J.A 58 (2022) 11, 230*](https://link.springer.com/article/10.1140/epja/s10050-022-00872-x) used a considerably finer grid, resulting in around 8 times higher runtime and memory consumption, but also less than 7% loss for small energies and almost perfect conservation for high energies.

## Dynamic fluidization setup

In order to use the dynamic initial conditions described in [:newspaper: *Góes-Hirayama et al.: Phys.Rev.C 113 (2026) 4, 044906*](https://journals.aps.org/prc/abstract/10.1103/w87d-ps6f), very different base configuration files are necessary.
The base configuration files are provided in the :file_folder: **predef_configs/dynamic_fluidization** folder along with an example for central Au+Au collisions at $\small\sqrt{s} = 4.3\;\mathrm{GeV}$.
After adjusting the paths to executables and the handler, it can be run in the usual manner.

``` title="Running Hybrid-handler with dynamic fluidization: Au+Au collision @ 4.3 GeV"
./Hybrid-handler do -c configs/predef_configs/dynamic_fluidization/config_AuAu_4.3_DynFlu.yaml
```

