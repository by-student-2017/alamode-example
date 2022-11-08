#!/bin/bash

# Please modify the following paths appropriately
#export DYLD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$DYLD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$LD_LIBRARY_PATH

# Binaries 
#LAMMPS=${HOME}/src/lammps/_build/lmp
#LAMMPS=/usr/local/bin/lmp
#LAMMPS=/usr/bin/lmp
#MOPAC=/opt/mopac/bin/mopac
WIEN2k_init="init_lapw -prec 2n"
WIEN2k_run="run_lapw -fc 0.1"
#ALAMODE_ROOT=${HOME}/src/alamode
#ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
ALAMODE_ROOT=${HOME}/alamode/_build
#input_file=in.lmp
SC222_data=Al222.lammps

chmod +x conv_struct.sh
chmod +x conv_force.sh

# Generate displacement patterns

cat << EOF > al_alm0.in
&general
  PREFIX = al222
  MODE = suggest
  NAT = 32; NKD = 1
  KD = Al
/

&interaction
  NORDER = 2  # 1: harmonic, 2: cubic, ..
/

&cell
  15.2689 # factor in Bohr unit
  1.0 0.0 0.0 # a1
  0.0 1.0 0.0 # a2
  0.0 0.0 1.0 # a3
/

&cutoff 
  Al-Al 7.3 7.3
/

&position
  1     0.000000000         0.000000000         0.000000000
  1     0.000000000         0.000000000         0.500000000
  1     0.000000000         0.500000000         0.000000000
  1     0.000000000         0.500000000         0.500000000
  1     0.500000000         0.000000000         0.000000000
  1     0.500000000         0.000000000         0.500000000
  1     0.500000000         0.500000000         0.000000000
  1     0.500000000         0.500000000         0.500000000
  1     0.000000000         0.250000000         0.250000000
  1     0.000000000         0.250000000         0.750000000
  1     0.000000000         0.750000000         0.250000000
  1     0.000000000         0.750000000         0.750000000
  1     0.500000000         0.250000000         0.250000000
  1     0.500000000         0.250000000         0.750000000
  1     0.500000000         0.750000000         0.250000000
  1     0.500000000         0.750000000         0.750000000
  1     0.250000000         0.000000000         0.250000000
  1     0.250000000         0.000000000         0.750000000
  1     0.250000000         0.500000000         0.250000000
  1     0.250000000         0.500000000         0.750000000
  1     0.750000000         0.000000000         0.250000000
  1     0.750000000         0.000000000         0.750000000
  1     0.750000000         0.500000000         0.250000000
  1     0.750000000         0.500000000         0.750000000
  1     0.250000000         0.250000000         0.000000000
  1     0.250000000         0.250000000         0.500000000
  1     0.250000000         0.750000000         0.000000000
  1     0.250000000         0.750000000         0.500000000
  1     0.750000000         0.250000000         0.000000000
  1     0.750000000         0.250000000         0.500000000
  1     0.750000000         0.750000000         0.000000000
  1     0.750000000         0.750000000         0.500000000
/

EOF

${ALAMODE_ROOT}/alm/alm al_alm0.in > alm.log


# Generate structure files of LAMMPS
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../al222.pattern_HARMONIC >> run.log

cp ../conv_struct.sh ./
cp ../conv_force.sh ./

export CURRENT_DIR=`pwd`
