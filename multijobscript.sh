#!/bin/bash

# What must be changed/checked before each run:
# * The number of jobs and wavelength interval
# * The time limit for each job
#	For guidance: Running with phistep 0.1, thetastep 2.5 and 50 fourier coefficients
#	with single layer on DBR takes about 14 min per wavelength

# Set number of jobs to be used and which wavelengths are to be simulated
numberOfJobs=41;
minWavelength=1625
maxWavelength=1665

# Calculate how many wavelengths each job should simulate
noPerJob=$(( (maxWavelength - minWavelength + 1)/numberOfJobs ))
rest=$(( (maxWavelength - minWavelength + 1)%numberOfJobs ))

# Each job should simulate wavelengths from $first to $last inclusive
first=$minWavelength

for job in `seq $numberOfJobs`
do
    echo $job
    if [ $job -le $rest ]
    then
        last=$((first + noPerJob))
    else
        last=$((first + noPerJob - 1))
    fi

    tmpscriptfile="tmpscript_${job}.lua"
    sed "1i wavelength_start=$first\nwavelength_end=$last" s4script.lua > $tmpscriptfile

    tmpdatafile="tmpdata_${job}.txt"

    tmpbashscriptfile="tmpbash_${job}.sh"
    echo "#!/bin/bash" > $tmpbashscriptfile
    echo "time /proj/snic2020-14-92/builds/S4/build/S4 ${tmpscriptfile} > ${tmpdatafile}" >> $tmpbashscriptfile
    
    # Initial simulations indicate about one minute per wavelength
    sbatch -n 1 -t 08:00:00 $tmpbashscriptfile

    first=$((last + 1))
done
