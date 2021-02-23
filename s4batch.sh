#!/bin/bash
#
# Bunch of tetralith-commands

# Set number of cores to be used and which wavelengths are to be simulated
numberOfCores=2;
minWavelength=1500
maxWavelength=1501

# Calculate how many wavelengths each core should simulate
noPerCore=$(( (maxWavelength - minWavelength + 1)/numberOfCores ))
rest=$(( (maxWavelength - minWavelength + 1)%numberOfCores ))

# Each core should simulate wavelengths from $first to $last inclusive
first=$minWavelength

for core in `seq $numberOfCores`
do
    echo $core
    if [ $core -le $rest ]
    then
        last=$((first + noPerCore))
    else
        last=$((first + noPerCore - 1))
    fi

    tmpscriptfile="tmpscript_${core}.lua"
    sed "1i wavelength_start=$first\nwavelength_end=$last" s4script.lua > $tmpscriptfile

    tmpFilename="tmp_${core}.txt"
    /home/x_daham/builds/S4/build/S4 $tmpscriptfile > $tmpFilename

    first=$((last + 1))
done

wait

cat <(echo "λ, θ, φ, a, r, d, L, incidence_flux_vacuum, reflection_flux_vacuum, transmission_flux_GAAS") tmp_*.txt > data.txt
