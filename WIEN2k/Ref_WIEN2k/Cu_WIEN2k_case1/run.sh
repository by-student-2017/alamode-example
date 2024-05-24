#!/bin/bash

# Binaries 
WIEN2k_init="init_lapw -prec 2n"
WIEN2k_run="run_lapw -fc 0.1"
ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
SC222_data=Cu222.lammps

chmod +x conv_struct.sh
chmod +x conv_force.sh

# Generate displacement patterns
${ALAMODE_ROOT}/alm/alm Cu_alm0.in > alm.log

# Generate structure files
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../Cu222.pattern_HARMONIC >> run.log
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix cubic --mag 0.04 -pf ../Cu222.pattern_ANHARM3 >> run.log

cp ../conv_struct.sh ./
cp ../conv_force.sh ./
CURRENT_DIR=`pwd`
# Run WIEN2k v.21.1
for ((i=1; i<=0; i++));do
   cp harm${i}.lammps tmp.lammps
   ./conv_struct.sh ${i}
   #
   cd $W2WEB_CASE_BASEDIR
   mkdir ${i}; cd ${i}
   cp $CURRENT_DIR/${i}.struct ./${i}.struct
   $WIEN2k_init
   $WIEN2k_run
   cp ${i}.scf ./$CURRENT_DIR/${i}.scf
   cd $CURRENT_DIR
   #
   ./conv_force.sh ${i}.scf
   mv XFSET XFSET.harm${i}
done
for ((i=1; i<=0; i++));do
   suffix=01
   cp cubic${suffix}.lammps tmp.lammps
   ./conv_struct.sh ${i}
   #
   cd $W2WEB_CASE_BASEDIR
   mkdir ${i}; cd ${i}
   cp $CURRENT_DIR/${i}.struct ./${i}.struct
   $WIEN2k_init
   $WIEN2k_run
   cp ${i}.scf ./$CURRENT_DIR/${i}.scf
   cd $CURRENT_DIR
   #
   ./conv_force.sh ${i}.scf
   mv XFSET XFSET.cubic${suffix}
done

# Collect data
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.cubic* > DFSET_cubic

cd ../

# Extract harmonic force constants
${ALAMODE_ROOT}/alm/alm Cu_alm1.in >> alm.log

# Extract cubic force constants
${ALAMODE_ROOT}/alm/alm Cu_alm2.in >> alm.log

# Phonon dispersion
${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log

# Thermal conductivity
${ALAMODE_ROOT}/anphon/anphon RTA.in > RTA.log
