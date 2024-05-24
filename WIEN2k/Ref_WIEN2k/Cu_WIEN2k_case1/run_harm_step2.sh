#!/bin/bash

# Binaries 
ALAMODE_ROOT=${HOME}/alamode/_build
SC222_data=Cu222.lammps

cd ./displace

# Collect data
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic

cd ../

# Extract harmonic force constants
${ALAMODE_ROOT}/alm/alm Cu_alm1.in >> alm.log

# Phonon dispersion
${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log
