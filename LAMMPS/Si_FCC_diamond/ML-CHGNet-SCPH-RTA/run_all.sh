#!/bin/bash

# Please modify the following paths appropriately
#export DYLD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$DYLD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$LD_LIBRARY_PATH

# Binaries 
#LAMMPS=${HOME}/src/lammps/_build/lmp
#LAMMPS=/usr/local/bin/lmp
#LAMMPS=/usr/bin/lmp
#LAMMPS="mpirun -np 2 $HOME/lammps-stable_23Jun2022/src/lmp_mpi"
#LAMMPS=$HOME/lammps/src/lmp_serial
LAMMPS=/mnt/d/lammps/src/lmp_serial
#ALAMODE_ROOT=${HOME}/src/alamode
#ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
ALAMODE_ROOT=/mnt/d/alamode-v.1.4.1/_build
#coeff=Si_Zuo_Arxiv2019.snapcoeff
#param=Si_Zuo_Arxiv2019.snapparam
input_file=in.lmp
SC222_data=Si222.lammps

# Generate displacement patterns

cat << EOF > si_alm0.in
&general
  PREFIX = si222
  MODE = suggest
  NAT = 64; NKD = 1
  KD = Si
/

&interaction
  NORDER = 3  # 1: harmonic, 2: cubic, ..
  NBODY = 2 3 3
/

&cell
  20.406 # factor in Bohr unit
  1.0 0.0 0.0 # a1
  0.0 1.0 0.0 # a2
  0.0 0.0 1.0 # a3
/

&cutoff 
  Si-Si 8.1 8.1 8.1
/


&position
  1 0.0000000000000000 0.0000000000000000 0.0000000000000000   
  1 0.0000000000000000 0.0000000000000000 0.5000000000000000
  1 0.0000000000000000 0.2500000000000000 0.2500000000000000
  1 0.0000000000000000 0.2500000000000000 0.7500000000000000
  1 0.0000000000000000 0.5000000000000000 0.0000000000000000
  1 0.0000000000000000 0.5000000000000000 0.5000000000000000
  1 0.0000000000000000 0.7500000000000000 0.2500000000000000
  1 0.0000000000000000 0.7500000000000000 0.7500000000000000
  1 0.1250000000000000 0.1250000000000000 0.1250000000000000
  1 0.1250000000000000 0.1250000000000000 0.6250000000000000
  1 0.1250000000000000 0.3750000000000000 0.3750000000000000
  1 0.1250000000000000 0.3750000000000000 0.8750000000000000
  1 0.1250000000000000 0.6250000000000000 0.1250000000000000
  1 0.1250000000000000 0.6250000000000000 0.6250000000000000
  1 0.1250000000000000 0.8750000000000000 0.3750000000000000
  1 0.1250000000000000 0.8750000000000000 0.8750000000000000
  1 0.2500000000000000 0.0000000000000000 0.2500000000000000
  1 0.2500000000000000 0.0000000000000000 0.7500000000000000
  1 0.2500000000000000 0.2500000000000000 0.0000000000000000
  1 0.2500000000000000 0.2500000000000000 0.5000000000000000
  1 0.2500000000000000 0.5000000000000000 0.2500000000000000
  1 0.2500000000000000 0.5000000000000000 0.7500000000000000
  1 0.2500000000000000 0.7500000000000000 0.0000000000000000
  1 0.2500000000000000 0.7500000000000000 0.5000000000000000
  1 0.3750000000000000 0.1250000000000000 0.3750000000000000
  1 0.3750000000000000 0.1250000000000000 0.8750000000000000
  1 0.3750000000000000 0.3750000000000000 0.1250000000000000
  1 0.3750000000000000 0.3750000000000000 0.6250000000000000
  1 0.3750000000000000 0.6250000000000000 0.3750000000000000
  1 0.3750000000000000 0.6250000000000000 0.8750000000000000
  1 0.3750000000000000 0.8750000000000000 0.1250000000000000
  1 0.3750000000000000 0.8750000000000000 0.6250000000000000
  1 0.5000000000000000 0.0000000000000000 0.0000000000000000
  1 0.5000000000000000 0.0000000000000000 0.5000000000000000
  1 0.5000000000000000 0.2500000000000000 0.2500000000000000
  1 0.5000000000000000 0.2500000000000000 0.7500000000000000
  1 0.5000000000000000 0.5000000000000000 0.0000000000000000
  1 0.5000000000000000 0.5000000000000000 0.5000000000000000
  1 0.5000000000000000 0.7500000000000000 0.2500000000000000
  1 0.5000000000000000 0.7500000000000000 0.7500000000000000
  1 0.6250000000000000 0.1250000000000000 0.1250000000000000
  1 0.6250000000000000 0.1250000000000000 0.6250000000000000
  1 0.6250000000000000 0.3750000000000000 0.3750000000000000
  1 0.6250000000000000 0.3750000000000000 0.8750000000000000
  1 0.6250000000000000 0.6250000000000000 0.1250000000000000
  1 0.6250000000000000 0.6250000000000000 0.6250000000000000
  1 0.6250000000000000 0.8750000000000000 0.3750000000000000
  1 0.6250000000000000 0.8750000000000000 0.8750000000000000
  1 0.7500000000000000 0.0000000000000000 0.2500000000000000
  1 0.7500000000000000 0.0000000000000000 0.7500000000000000
  1 0.7500000000000000 0.2500000000000000 0.0000000000000000
  1 0.7500000000000000 0.2500000000000000 0.5000000000000000
  1 0.7500000000000000 0.5000000000000000 0.2500000000000000
  1 0.7500000000000000 0.5000000000000000 0.7500000000000000
  1 0.7500000000000000 0.7500000000000000 0.0000000000000000
  1 0.7500000000000000 0.7500000000000000 0.5000000000000000
  1 0.8750000000000000 0.1250000000000000 0.3750000000000000
  1 0.8750000000000000 0.1250000000000000 0.8750000000000000
  1 0.8750000000000000 0.3750000000000000 0.1250000000000000
  1 0.8750000000000000 0.3750000000000000 0.6250000000000000
  1 0.8750000000000000 0.6250000000000000 0.3750000000000000
  1 0.8750000000000000 0.6250000000000000 0.8750000000000000
  1 0.8750000000000000 0.8750000000000000 0.1250000000000000
  1 0.8750000000000000 0.8750000000000000 0.6250000000000000
/

EOF

${ALAMODE_ROOT}/alm/alm si_alm0.in > alm.log


# Generate structure files of LAMMPS
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../si222.pattern_HARMONIC >> run.log
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix random --random --mag 0.04 -nd 20 >> run.log

#cp ../${coeff} .
#cp ../${param} .
cp ../${input_file} .

# Run LAMMPS
for ((i=1; i<=1; i++))
do
   cp harm${i}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.harm${i}
done

for ((i=1; i<=20; i++))
do
   suffix=`echo ${i} | awk '{printf("%02d", $1)}'`
   cp random${suffix}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.random${suffix}
done

# Collect data
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.random* > DFSET_random

cd ../

# Extract harmonic force constants
cat << EOF > si_alm1.in
&general
  PREFIX = si222_harm
  MODE = optimize
  NAT = 64; NKD = 1
  KD = Si
/

&optimize
 DFSET = displace/DFSET_harmonic
/

&interaction
  NORDER = 1  # 1: harmonic, 2: cubic, ..
/

&cell
  20.406 # factor in Bohr unit
  1.0 0.0 0.0 # a1
  0.0 1.0 0.0 # a2
  0.0 0.0 1.0 # a3
/

&cutoff 
  Si-Si 7.3 7.3
/


&position
  1 0.0000000000000000 0.0000000000000000 0.0000000000000000   
  1 0.0000000000000000 0.0000000000000000 0.5000000000000000
  1 0.0000000000000000 0.2500000000000000 0.2500000000000000
  1 0.0000000000000000 0.2500000000000000 0.7500000000000000
  1 0.0000000000000000 0.5000000000000000 0.0000000000000000
  1 0.0000000000000000 0.5000000000000000 0.5000000000000000
  1 0.0000000000000000 0.7500000000000000 0.2500000000000000
  1 0.0000000000000000 0.7500000000000000 0.7500000000000000
  1 0.1250000000000000 0.1250000000000000 0.1250000000000000
  1 0.1250000000000000 0.1250000000000000 0.6250000000000000
  1 0.1250000000000000 0.3750000000000000 0.3750000000000000
  1 0.1250000000000000 0.3750000000000000 0.8750000000000000
  1 0.1250000000000000 0.6250000000000000 0.1250000000000000
  1 0.1250000000000000 0.6250000000000000 0.6250000000000000
  1 0.1250000000000000 0.8750000000000000 0.3750000000000000
  1 0.1250000000000000 0.8750000000000000 0.8750000000000000
  1 0.2500000000000000 0.0000000000000000 0.2500000000000000
  1 0.2500000000000000 0.0000000000000000 0.7500000000000000
  1 0.2500000000000000 0.2500000000000000 0.0000000000000000
  1 0.2500000000000000 0.2500000000000000 0.5000000000000000
  1 0.2500000000000000 0.5000000000000000 0.2500000000000000
  1 0.2500000000000000 0.5000000000000000 0.7500000000000000
  1 0.2500000000000000 0.7500000000000000 0.0000000000000000
  1 0.2500000000000000 0.7500000000000000 0.5000000000000000
  1 0.3750000000000000 0.1250000000000000 0.3750000000000000
  1 0.3750000000000000 0.1250000000000000 0.8750000000000000
  1 0.3750000000000000 0.3750000000000000 0.1250000000000000
  1 0.3750000000000000 0.3750000000000000 0.6250000000000000
  1 0.3750000000000000 0.6250000000000000 0.3750000000000000
  1 0.3750000000000000 0.6250000000000000 0.8750000000000000
  1 0.3750000000000000 0.8750000000000000 0.1250000000000000
  1 0.3750000000000000 0.8750000000000000 0.6250000000000000
  1 0.5000000000000000 0.0000000000000000 0.0000000000000000
  1 0.5000000000000000 0.0000000000000000 0.5000000000000000
  1 0.5000000000000000 0.2500000000000000 0.2500000000000000
  1 0.5000000000000000 0.2500000000000000 0.7500000000000000
  1 0.5000000000000000 0.5000000000000000 0.0000000000000000
  1 0.5000000000000000 0.5000000000000000 0.5000000000000000
  1 0.5000000000000000 0.7500000000000000 0.2500000000000000
  1 0.5000000000000000 0.7500000000000000 0.7500000000000000
  1 0.6250000000000000 0.1250000000000000 0.1250000000000000
  1 0.6250000000000000 0.1250000000000000 0.6250000000000000
  1 0.6250000000000000 0.3750000000000000 0.3750000000000000
  1 0.6250000000000000 0.3750000000000000 0.8750000000000000
  1 0.6250000000000000 0.6250000000000000 0.1250000000000000
  1 0.6250000000000000 0.6250000000000000 0.6250000000000000
  1 0.6250000000000000 0.8750000000000000 0.3750000000000000
  1 0.6250000000000000 0.8750000000000000 0.8750000000000000
  1 0.7500000000000000 0.0000000000000000 0.2500000000000000
  1 0.7500000000000000 0.0000000000000000 0.7500000000000000
  1 0.7500000000000000 0.2500000000000000 0.0000000000000000
  1 0.7500000000000000 0.2500000000000000 0.5000000000000000
  1 0.7500000000000000 0.5000000000000000 0.2500000000000000
  1 0.7500000000000000 0.5000000000000000 0.7500000000000000
  1 0.7500000000000000 0.7500000000000000 0.0000000000000000
  1 0.7500000000000000 0.7500000000000000 0.5000000000000000
  1 0.8750000000000000 0.1250000000000000 0.3750000000000000
  1 0.8750000000000000 0.1250000000000000 0.8750000000000000
  1 0.8750000000000000 0.3750000000000000 0.1250000000000000
  1 0.8750000000000000 0.3750000000000000 0.6250000000000000
  1 0.8750000000000000 0.6250000000000000 0.3750000000000000
  1 0.8750000000000000 0.6250000000000000 0.8750000000000000
  1 0.8750000000000000 0.8750000000000000 0.1250000000000000
  1 0.8750000000000000 0.8750000000000000 0.6250000000000000
/

EOF
${ALAMODE_ROOT}/alm/alm si_alm1.in >> alm.log

# Extract cubic and quartic force constants
cat << EOF > si_alm2.in
&general
  PREFIX = si222_anharm
  MODE = optimize
  NAT = 64; NKD = 1
  KD = Si
/

&optimize
 DFSET = displace/DFSET_random
 FC2XML = si222_harm.xml
 LMODEL = enet
 NDATA = 20
 CV = 4
 L1_RATIO = 1.0
 CONV_TOL = 1.0e-8
/

&interaction
  NORDER = 3  # 1: harmonic, 2: cubic, ..
  NBODY = 2 3 3
/

&cell
  20.406 # factor in Bohr unit
  1.0 0.0 0.0 # a1
  0.0 1.0 0.0 # a2
  0.0 0.0 1.0 # a3
/

&cutoff 
  Si-Si 8.1 8.1 8.1
/


&position
  1 0.0000000000000000 0.0000000000000000 0.0000000000000000   
  1 0.0000000000000000 0.0000000000000000 0.5000000000000000
  1 0.0000000000000000 0.2500000000000000 0.2500000000000000
  1 0.0000000000000000 0.2500000000000000 0.7500000000000000
  1 0.0000000000000000 0.5000000000000000 0.0000000000000000
  1 0.0000000000000000 0.5000000000000000 0.5000000000000000
  1 0.0000000000000000 0.7500000000000000 0.2500000000000000
  1 0.0000000000000000 0.7500000000000000 0.7500000000000000
  1 0.1250000000000000 0.1250000000000000 0.1250000000000000
  1 0.1250000000000000 0.1250000000000000 0.6250000000000000
  1 0.1250000000000000 0.3750000000000000 0.3750000000000000
  1 0.1250000000000000 0.3750000000000000 0.8750000000000000
  1 0.1250000000000000 0.6250000000000000 0.1250000000000000
  1 0.1250000000000000 0.6250000000000000 0.6250000000000000
  1 0.1250000000000000 0.8750000000000000 0.3750000000000000
  1 0.1250000000000000 0.8750000000000000 0.8750000000000000
  1 0.2500000000000000 0.0000000000000000 0.2500000000000000
  1 0.2500000000000000 0.0000000000000000 0.7500000000000000
  1 0.2500000000000000 0.2500000000000000 0.0000000000000000
  1 0.2500000000000000 0.2500000000000000 0.5000000000000000
  1 0.2500000000000000 0.5000000000000000 0.2500000000000000
  1 0.2500000000000000 0.5000000000000000 0.7500000000000000
  1 0.2500000000000000 0.7500000000000000 0.0000000000000000
  1 0.2500000000000000 0.7500000000000000 0.5000000000000000
  1 0.3750000000000000 0.1250000000000000 0.3750000000000000
  1 0.3750000000000000 0.1250000000000000 0.8750000000000000
  1 0.3750000000000000 0.3750000000000000 0.1250000000000000
  1 0.3750000000000000 0.3750000000000000 0.6250000000000000
  1 0.3750000000000000 0.6250000000000000 0.3750000000000000
  1 0.3750000000000000 0.6250000000000000 0.8750000000000000
  1 0.3750000000000000 0.8750000000000000 0.1250000000000000
  1 0.3750000000000000 0.8750000000000000 0.6250000000000000
  1 0.5000000000000000 0.0000000000000000 0.0000000000000000
  1 0.5000000000000000 0.0000000000000000 0.5000000000000000
  1 0.5000000000000000 0.2500000000000000 0.2500000000000000
  1 0.5000000000000000 0.2500000000000000 0.7500000000000000
  1 0.5000000000000000 0.5000000000000000 0.0000000000000000
  1 0.5000000000000000 0.5000000000000000 0.5000000000000000
  1 0.5000000000000000 0.7500000000000000 0.2500000000000000
  1 0.5000000000000000 0.7500000000000000 0.7500000000000000
  1 0.6250000000000000 0.1250000000000000 0.1250000000000000
  1 0.6250000000000000 0.1250000000000000 0.6250000000000000
  1 0.6250000000000000 0.3750000000000000 0.3750000000000000
  1 0.6250000000000000 0.3750000000000000 0.8750000000000000
  1 0.6250000000000000 0.6250000000000000 0.1250000000000000
  1 0.6250000000000000 0.6250000000000000 0.6250000000000000
  1 0.6250000000000000 0.8750000000000000 0.3750000000000000
  1 0.6250000000000000 0.8750000000000000 0.8750000000000000
  1 0.7500000000000000 0.0000000000000000 0.2500000000000000
  1 0.7500000000000000 0.0000000000000000 0.7500000000000000
  1 0.7500000000000000 0.2500000000000000 0.0000000000000000
  1 0.7500000000000000 0.2500000000000000 0.5000000000000000
  1 0.7500000000000000 0.5000000000000000 0.2500000000000000
  1 0.7500000000000000 0.5000000000000000 0.7500000000000000
  1 0.7500000000000000 0.7500000000000000 0.0000000000000000
  1 0.7500000000000000 0.7500000000000000 0.5000000000000000
  1 0.8750000000000000 0.1250000000000000 0.3750000000000000
  1 0.8750000000000000 0.1250000000000000 0.8750000000000000
  1 0.8750000000000000 0.3750000000000000 0.1250000000000000
  1 0.8750000000000000 0.3750000000000000 0.6250000000000000
  1 0.8750000000000000 0.6250000000000000 0.3750000000000000
  1 0.8750000000000000 0.6250000000000000 0.8750000000000000
  1 0.8750000000000000 0.8750000000000000 0.1250000000000000
  1 0.8750000000000000 0.8750000000000000 0.6250000000000000
/

EOF
# si_alm2.in = si_CV.in
${ALAMODE_ROOT}/alm/alm si_alm2.in >> alm.log
# opt.in
alpha=`awk '{if($1=="Minimum" && $2=="CVSCORE"){print $6}}' alm.log`
echo "Minimum CVSCORE at alpha = "${alpha}
sed "15i \ L1_ALPHA = ${alpha}" si_alm2.in > si_opt.in
sed -i "s/CV = 4/CV = 0/" si_opt.in
awk '{if($1=="CV"){print $0}}' si_opt.in
awk '{if($1=="L1_ALPHA"){print $0}}' si_opt.in
${ALAMODE_ROOT}/alm/alm si_opt.in >> alm.log

# Phonon dispersion
cat << EOF > scph.in
&general
  PREFIX = si222_scph
  MODE = SCPH
  FCSXML =si222_anharm.xml
  TMIN = 0; TMAX = 1000; DT = 50

  NKD = 1; KD = Si
  MASS = 28.0855
/

&scph
  SELF_OFFDIAG = 0
  MAXITER = 1000
  MIXALPHA = 0.2
  KMESH_INTERPOLATE = 2 2 2
  KMESH_SCPH = 2 2 2
/

&cell
  10.203
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

${ALAMODE_ROOT}/anphon/anphon scph.in > scph.log
grep "conv" scph.log

# Thermal property
cat << EOF > therm.in
&general
  PREFIX = si222_scph
  MODE = SCPH
  FCSXML = si222_anharm.xml
  EMIN = -100; EMAX = 850; DELTA_E = 1.0
  TMIN = 0; TMAX = 1000; DT = 50

  NKD = 1; KD = Si
  MASS = 28.0855
/

&scph
  SELF_OFFDIAG = 0
  MAXITER = 500
  KMESH_INTERPOLATE = 2 2 2
  KMESH_SCPH = 2 2 2
/

&cell
  10.203
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/

&kpoint
  2
  10 10 10
/

&analysis
  PRINTMSD = 1
/

EOF

${ALAMODE_ROOT}/anphon/anphon therm.in > therm.log

# Thermal conductivity
for ((temp=200; temp<=800; temp+=100))
do
# dfc2: Create effective harmonic force constant (ALAMODE XML) from
#       input harmonic force constant (XML format) and PREFIX.scph_dfc2.
${ALAMODE_ROOT}/tools/dfc2 si222_harm.xml si222_scph_${temp}K.xml si222_scph.scph_dfc2 ${temp}
cat << EOF > kappa${temp}.in
&general
  PREFIX = si222_scph_${temp}K
  MODE = RTA
  FCSXML = si222_anharm.xml
  FC2XML = si222_scph_${temp}K.xml
  TMIN = ${temp}; TMAX = ${temp}

  NKD = 1; KD = Si
  MASS = 28.0855
/
&cell
  10.203
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/
&kpoint
  2
  10 10 10
/
EOF
echo "Running kappa calculation at T = " ${temp}
${ALAMODE_ROOT}/anphon/anphon kappa${temp}.in > kappa${temp}.log
echo "Done"
done

