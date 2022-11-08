#!/bin/bash

# Please modify the following paths appropriately
#export DYLD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$DYLD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$LD_LIBRARY_PATH

# Binaries 
#LAMMPS=${HOME}/src/lammps/_build/lmp
#LAMMPS=/usr/local/bin/lmp
#LAMMPS=/usr/bin/lmp
#ALAMODE_ROOT=${HOME}/src/alamode
#ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
ALAMODE_ROOT=${HOME}/alamode/_build
#input_file=in.lmp
SC222_data=Al222.lammps

cd ./displace

# Collect data
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic

cd ../

# Extract harmonic force constants
cat << EOF > al_alm1.in
&general
  PREFIX = al222_harm
  MODE = optimize
  NAT = 32; NKD = 1
  KD = Al
/

&optimize
 DFSET = displace/DFSET_harmonic
/

&interaction
  NORDER = 1  # 1: harmonic, 2: cubic, ..
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
${ALAMODE_ROOT}/alm/alm al_alm1.in >> alm.log

# Phonon dispersion
cat << EOF > phband.in
&general
  PREFIX = al222
  MODE = phonons
  FCSXML =al222_harm.xml

  NKD = 1; KD = Al
  MASS = 26.9815
/

&cell
  7.634
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/

&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 X 0.5 0.5 0.0 51
  X 0.5 0.5 1.0 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 L 0.5 0.5 0.5 51
/

EOF

${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log

