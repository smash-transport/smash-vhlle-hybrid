# Adding a new module

Although the SMASH-vHLLE-hybrid, as implied in the name, was built with a defined set of software modules, it is designed to be easily extensible with new modules. This allows, amongst other things, to test new algorithms and study model dependency.

Adding a new module to the SMASH-vHLLE-hybrid is a straightforward process. The following steps are required:

* In case the stage has no other modules, add a field to the `HYBRID_module` array in the `global_variables.bash` script. At the same place, add alternative base config files for the stages named `${STAGE_NAME}_${MODULE_NAME}` and add `[MODULE]` to the valid keys of the stage
* Add a base configuration in the `configs` folder for the new module
* Adapt the check for valid modules in the `sanity_checks.bash` script, and add a function to choose the base configuration file dependent on the module.
* Add versions of the affected stage functionality script for the new module. Shared logic stays in the common functionality script, whereas module-specific logic is implemented in the module-specific script. The module dependent logic is implemented in functions with the suffix `_${MODULE_NAME}`. Therefore, if-clauses in the main stage script can be avoided.
* Don't forget to source the new files!
* Add a mock for the new module in the mocks folder.
