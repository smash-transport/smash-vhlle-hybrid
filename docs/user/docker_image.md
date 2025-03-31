# An Ubuntu-based framework

Next to the hybrid handler repository, a Docker image based on Ubuntu to compile all SMASH-vHLLE-hybrid software and use the hybrid handler [is available](https://github.com/smash-transport/smash-vhlle-hybrid/pkgs/container/smash-vhlle-hybrid).
Feel free to download it and use it.
In the container all prerequisites of the hybrid handler are satisfied and the user can easily use it.
The image does not contain the supported software and its installation is left to the user.
However, most libraries are available in the image an a list of them can be obtained inspecting the container.
```console title="A possible output of docker inspect"
$ docker inspect \
> -f '{{index .Config.Labels "installed.software.versions" }}' \
> smash-vhlle-hybrid-framework:latest | sed 's/ | /\n/g'
Doxygen 1.9.1
ROOT 6.26.10
HepMC 3.2.5
Rivet 3.1.7
Yoda 1.9.7
Fastjet 3.4.0
Fjcontrib 1.049
Cppcheck 2.8
Cpplint 1.6.0
yq 4.44.3
```

!!! info "The container working directory"
    Running the Docker image, the container will get you in a :file_folder: **/Software** directory that is containing the installed software which is needed to e.g. compile SMASH.
    Please, note that Pythia is missing and it is up to the user to install the needed version of it.
