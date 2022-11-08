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
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix cubic --mag 0.04 -pf ../al222.pattern_ANHARM3 >> run.log

cp ../conv_struct.sh ./
cp ../conv_force.sh ./
CURRENT_DIR=`pwd`

# Run WIEN2k v.21.1
for ((i=1; i<=1; i++))
do
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

for ((i=1; i<=20; i++))
do
   suffix=`echo ${i} | awk '{printf("%02d", $1)}'`
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

# Extract cubic force constants
cat << EOF > al_alm2.in
&general
  PREFIX = al222_cubic
  MODE = optimize
  NAT = 32; NKD = 1
  KD = Al
/

&optimize
 DFSET = displace/DFSET_cubic
 FC2XML = al222_harm.xml
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
${ALAMODE_ROOT}/alm/alm al_alm2.in >> alm.log

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

# Thermal conductivity
cat << EOF > RTA.in
&general
  PREFIX = al222_10
  MODE = RTA
  FCSXML = al222_cubic.xml

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
  2
  10 10 10
/

EOF

${ALAMODE_ROOT}/anphon/anphon RTA.in > RTA.log
