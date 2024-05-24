#!/bin/bash

# Binaries
WIEN2k_init="init_lapw -prec 2n"
WIEN2k_run="run_lapw -fc 0.1"
ALAMODE_ROOT=/home/inukai/alamode/_build
SC222_data=Cu222.lammps

chmod +x conv_struct.sh
chmod +x conv_force.sh

# Generate displacement patterns
${ALAMODE_ROOT}/alm/alm Cu_alm0.in > alm.log

# Generate structure files
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../Cu222.pattern_HARMONIC >> run.log

cp ../conv_struct.sh ./
cp ../conv_force.sh ./

export CURRENT_DIR=`pwd`
