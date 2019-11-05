#!/bin/bash

if [[ "$#" -ne 4 ]]; then
    echo "Find all modules, compile binaries and copy those to this directory."
    echo
    echo "Usage: $0 PATH_TO_SMASH PATH_TO_VHLLE PATH_TO_SAMPLER PATH_TO_PYTHIA"
    exit 1
fi

smash_path=$1
vhlle_path=$2
sampler_path=$3
pythia_path=$4
hybrid_dir=$(pwd)

# Create directories that will contain all necessary binaries
binaries=$hybrid_dir/binaries
mkdir $binaries

# Compile and copy SMASH
echo "Compiling SMASH ..."
mkdir $smash_path/build_hybrid
cd $smash_path/build_hybrid
cmake .. -DPythia_CONFIG_EXECUTABLE=$pythia_path/bin/pythia8-config
make smash -j8
cp smash $binaries/smash
cd ..
rm -r build_hybrid
echo "Succesfully compiled and copied SMASH."

# Compile and copy vHLLE
echo "Compiling vHLLE ..."
cd $vhlle_path
git checkout schaefer/Output_for_Sampler_Ryu_inMilne
make
cp hlle_visc $binaries/hlle_visc
# also copy eos files that are necessary for the hydro run
cp -r eos $binaries/eos
echo "Succesfully compiled and copied vHLLE."

# Compile and copy sampler
echo "Compiling Cooper-Frye sampler ..."
cd $sampler_path
make
cp mpiCooperFrye.x86_64 $binaries/samplerCooperFrye
echo "Succesfully compiled and copied sampler."


# Call CMake Script to configure hybrid run with all collected ingredients
cd $hybrid_dir
mkdir build
cd build
cmake .. -DSMASH_PATH=$binaries -DVHLLE_PATH=$binaries -DSAMPLER_PATH=$binaries
