#!/bin/bash

# Please modify the following paths appropriately
#export DYLD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$DYLD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$LD_LIBRARY_PATH

# Binaries 
#LAMMPS=${HOME}/src/lammps/_build/lmp
#LAMMPS=/usr/local/bin/lmp
#LAMMPS=/usr/bin/lmp
LAMMPS="mpirun -np 2 $HOME/lammps-stable_23Jun2022/src/lmp_mpi"
#ALAMODE_ROOT=${HOME}/src/alamode
ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
coeff=Si_Zuo_Arxiv2019.snapcoeff
param=Si_Zuo_Arxiv2019.snapparam
input_file=in.lmp
SC222_data=SC222.lammps
distance=12.0

echo "----- Get informaions form ${SC222_data} file -----"
natom=`awk '{if($2=="atoms"){printf "%d",$1}}' ${SC222_data}`
nat=`awk '{if($2=="atom" && $3=="types"){printf "%d",$1}}' ${SC222_data}`
nma=`awk '{if($1=="Masses"){print NR}}' ${SC222_data}`
#${nma} is a line number of "Masses"
for ((i=1;i<=${nat};i++));do
  elem[$i]=`awk -v nma=${nma} -v i=$i '{if(NR==nma+1+i){printf "%s",$4}}' ${SC222_data}`
  mass[$i]=`awk -v nma=${nma} -v i=$i '{if(NR==nma+1+i){printf "%s",$2}}' ${SC222_data}`
done
echo "Number of atom type:" ${nat}
echo "Elements: "${elem[@]}
echo "Masses  : "${mass[@]}
la_bohr=`awk '{if($3=="xlo"){printf "%12.6f",($2*1.88973)}}' ${SC222_data}`
la=`awk '{if($3=="xlo"){printf "%f",$2}}' ${SC222_data}`
xx=`awk -v la=${la} '{if($3=="xlo"){printf "%12.6f",($2/la)}}' ${SC222_data}`
yy=`awk -v la=${la} '{if($3=="ylo"){printf "%12.6f",($2/la)}}' ${SC222_data}`
zz=`awk -v la=${la} '{if($3=="zlo"){printf "%12.6f",($2/la)}}' ${SC222_data}`
xy=`awk -v la=${la} '{if($4=="xy"){printf "%12.6f",($1/la)}}' ${SC222_data}`
xz=`awk -v la=${la} '{if($5=="xz"){printf "%12.6f",($2/la)}}' ${SC222_data}`
yz=`awk -v la=${la} '{if($6=="yz"){printf "%12.6f",($3/la)}}' ${SC222_data}`


echo "----- Generate displacement patterns -----"
cat << EOF > alm0.in
&general
  PREFIX = sc222
  MODE = suggest
  NAT = ${natom}; NKD = ${nat}
  KD = ${elem[@]}
/

&interaction
  NORDER = 2  # 1: harmonic, 2: cubic, ..
/

&cell
  ${la_bohr} # factor in Bohr unit
  ${xx} ${xy} ${xz} # a1
  ${xy} ${yy} ${yz} # a2
  ${xz} ${yz} ${zz} # a3
/

&cutoff 
  *-* ${distance} ${distance}
/


&position
EOF

nla=`awk '{if($1=="Atoms"){print NR}}' ${SC222_data}`
awk -v nla=${nla} -v la=${la} '{if(NR>nla && $2>0){printf " %4d  %12.8f   %12.8f   %12.8f  \n",$2,($3/la),($4/la),($5/la)}}' ${SC222_data} >> alm0.in
echo "/" >> alm0.in

${ALAMODE_ROOT}/alm/alm alm0.in > alm0.log
grep "Space group" alm0.log
grep "Number of disp. patterns" alm0.log


echo "----- Generate structure files of LAMMPS (displace.py) -----"
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../sc222.pattern_HARMONIC >> run.log
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix cubic --mag 0.04 -pf ../sc222.pattern_ANHARM3 >> run.log

cp ../${coeff} .
cp ../${param} .
cp ../${input_file} .


echo "----- Run LAMMPS -----"
for ((i=1; i<=1; i++))
do
   cp harm${i}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.harm${i}
done

for ((i=1; i<=20; i++))
do
   suffix=`echo ${i} | awk '{printf("%02d", $1)}'`
   cp cubic${suffix}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.cubic${suffix}
done


echo "----- Collect data (extract.py) -----"
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.cubic* > DFSET_cubic

cd ../


echo "----- Extract harmonic force constants (alm1.in) -----"
sed -e "s/PREFIX = sc222/PREFIX = sc222_harm/" alm0.in > alm1.in
sed -i "s/suggest/optimize/" alm1.in
sed -i "/&interaction/i &optimize" alm1.in
sed -i "/&interaction/i \  DFSET = displace/DFSET_harmonic" alm1.in
sed -i "/&interaction/i /" alm1.in
sed -i "/&interaction/i \ " alm1.in
sed -i "s/NORDER = 2/NORDER = 1/" alm1.in
${ALAMODE_ROOT}/alm/alm alm1.in > alm1.log
grep "Space group" alm1.log
grep "Fitting error" alm1.log


echo "----- Extract cubic force constants (alm2.in) -----"
sed -e "s/PREFIX = sc222_harm/PREFIX = sc222_cubic/" alm1.in > alm2.in
sed -i "s/DFSET_harmonic/DFSET_cubic/" alm2.in
sed -i "/DFSET = displace\/DFSET_harmonic/a \  FC2XML = sc222_harm.xml" alm2.in
sed -i "s/NORDER = 1/NORDER = 2/" alm2.in
${ALAMODE_ROOT}/alm/alm alm2.in > alm2.log
grep "Space group" alm2.log
grep "Fitting error" alm2.log


echo "----- Phonon dispersion (phband.in) -----"
cat << EOF > phband.in
&general
  PREFIX = sc222
  MODE = phonons
  FCSXML = sc222_harm.xml

  NKD = ${nat}; KD = ${elem[@]}
  MASS = ${mass[@]}
/
EOF

sg=`awk '{if($1=="Space" && $2=="group:"){printf "%1s",$3}}' alm1.log`
if [ ${sg:0:1} = "F" ]; then
  echo "space group: "${sg:0:1}" settings"
  la_bohr_d2=`awk '{if($3=="xlo"){printf "%-12.6f",($2*1.88973/2)}}' ${SC222_data}`
cat << EOF >> phband.in
&cell
  ${la_bohr_d2}
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
else
cat << EOF >> phband.in
&cell
  ${la_bohr}
  ${xx} ${xy} ${xz}
  ${xy} ${yy} ${yz}
  ${xz} ${yz} ${zz}
/
EOF
fi

if [ ${sg:0:1} = "I" ]; then
  echo "space group: "${sg:0:1}" settings"
cat << EOF >> phband.in
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 H 0.0 1.0 0.0 51
  H 0.0 1.0 0.0 N 0.5 0.5 0.0 51
  N 0.5 0.5 0.0 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 P 0.5 0.5 0.5 51
/
EOF
elif [ ${sg:0:1} = "H" ]; then
  echo "space group: "${sg:0:1}" settings"
cat << EOF >> phband.in
  &kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 M 0.5 0.0 0.0 51
  M 0.5 0.0 0.0 K 0.333 0.333 0.0 51
  K 0.333 0.333 0.0 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 A 0.0 0.0 0.5 51
/
EOF
elif [ ${sg:0:1} != "F" ]; then
  echo "space group: "${sg:0:1}" settings"
cat << EOF >> phband.in
  &kpoint
  1  # KPMODE = 1: line mode
  R 0.5 0.5 0.5 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 X 0.5 0.0 0.0 51
  X 0.5 0.0 0.0 M 0.5 0.5 0.0 51
  M 0.5 0.5 0.0 G 0.0 0.0 0.5 51
/
EOF
fi

${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log


echo "----- Thermal conductivity (RTA.in) -----"
cat << EOF > RTA.in
&general
  PREFIX = sc222_10
  MODE = RTA
  FCSXML = sc222_cubic.xml

  NKD = ${nat}; KD = ${elem[@]}
  MASS = ${mass[@]}
/
EOF

if [ ${sg:0:1} = "F" ]; then
cat << EOF >> RTA.in
&cell
  ${la_bohr_d2}
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/
EOF
else
cat << EOF >> RTA.in
&cell
  ${la_bohr}
  ${xx} ${xy} ${xz}
  ${xy} ${yy} ${yz}
  ${xz} ${yz} ${zz}
/
EOF
fi

cat << EOF >> RTA.in
&kpoint
  2
  10 10 10
/
EOF

${ALAMODE_ROOT}/anphon/anphon RTA.in > RTA.log
