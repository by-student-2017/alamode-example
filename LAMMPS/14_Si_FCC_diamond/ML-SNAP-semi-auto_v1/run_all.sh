#!/bin/bash

#-----------------------------------------------------------------------------------------------
# Please modify the following paths appropriately
#export DYLD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$DYLD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/Users/tadano/src/spglib/lib/:$LD_LIBRARY_PATH
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
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
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
coeff=Si_Zuo_Arxiv2019.snapcoeff
param=Si_Zuo_Arxiv2019.snapparam
input_file=in.lmp
SC222_data=SC222.lammps
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
distance=12.0
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
echo "----- Get informaions form ${SC222_data} file -----"
natom=`awk '{if($2=="atoms"){printf "%d",$1}}' ${SC222_data}`
nat=`awk '{if($2=="atom" && $3=="types"){printf "%d",$1}}' ${SC222_data}`
nma=`awk '{if($1=="Masses"){print NR}}' ${SC222_data}`
#${nma} is a line number of "Masses"
for ((i=1;i<=${nat}+1;i++));do
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
xy=`awk -v la=${la} 'BEGIN{XY=0.0}{if($4=="xy"){XY=$1}}END{printf "%12.6f",(XY/la)}' ${SC222_data}`
xz=`awk -v la=${la} 'BEGIN{XZ=0.0}{if($5=="xz"){XZ=$2}}END{printf "%12.6f",(XZ/la)}' ${SC222_data}`
yz=`awk -v la=${la} 'BEGIN{YZ=0.0}{if($6=="yz"){YZ=$3}}END{printf "%12.6f",(YZ/la)}' ${SC222_data}`

#-----------------------------------------------------------------------------------------------
## VASP: [A] + [fx,fy,fz], Lammps (Ovito): [A] + [x,y,z], Alamode (alm): [A] + [fx,fy,fz]
## [x,y,z] = [fx,fy,fz][A] => [fx,fy,fz] = [x,y,z][A]^-1
#-----------------------------------------------------------------------------------------------
## Calculating the inverse of a 3x3 lower triangular matrix
#-----------------------------------------------------------------------------------------------
det=`echo "${xx} ${yy} ${zz}" | awk '{printf "%f",($1*$2*$3)}'`
#-----------------------------------------------------------------------------------------------
#ixx=`echo "${xx} ${yy} ${zz} ${xy} ${xz} ${yz} ${det}" | awk '{printf "%f", ($2*$3-0.0)/$7}'`
#iyy=`echo "${xx} ${yy} ${zz} ${xy} ${xz} ${yz} ${det}" | awk '{printf "%f", ($1*$3-0.0)/$7}'`
#izz=`echo "${xx} ${yy} ${zz} ${xy} ${xz} ${yz} ${det}" | awk '{printf "%f", ($1*$2-0.0)/$7}'`
#-----------------------------------------------------------------------------------------------
ixx=`echo "${xx}" | awk '{printf "%f", (1/$1)}'`
iyy=`echo "${yy}" | awk '{printf "%f", (1/$1)}'`
izz=`echo "${zz}" | awk '{printf "%f", (1/$1)}'`
#-----------------------------------------------------------------------------------------------
ixy=`echo "${xx} ${yy} ${zz} ${xy} ${xz} ${yz} ${det} " | awk '{printf "%f",-($4*$3-0.0)/$7}'`
ixz=`echo "${xx} ${yy} ${zz} ${xy} ${xz} ${yz} ${det} " | awk '{printf "%f", ($4*$6-$2*$5)/$7}'`
iyz=`echo "${xx} ${yy} ${zz} ${xy} ${xz} ${yz} ${det} " | awk '{printf "%f",-($1*$6-$4*$5)/$7}'`
#-----------------------------------------------------------------------------------------------

a1=`echo "${xx}   0.0   0.0 ${la} " | awk '{printf "%f",($4*($1^2+$2^2+$3^2)^0.5)}'`
a2=`echo "${xy} ${yy}   0.0 ${la} " | awk '{printf "%f",($4*($1^2+$2^2+$3^2)^0.5)}'`
a3=`echo "${xz} ${yz} ${zz} ${la} " | awk '{printf "%f",($4*($1^2+$2^2+$3^2)^0.5)}'`

#Note: 1/0.529176 = 1.88973
la_bohr_d2=`awk '{if($3=="xlo"){printf "%-12.6f",($2/2/0.529)}}' ${SC222_data}`
la_bohr_r3=`awk '{if($3=="xlo"){printf "%-12.6f",($2/2/0.529*0.8660)}}' ${SC222_data}`

#-----------------------------------------------------------------------------------------------

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
  ${xx} 0.0   0.0   # a1
  ${xy} ${yy} 0.0   # a2
  ${xz} ${yz} ${zz} # a3
/

&cutoff 
  *-* ${distance} ${distance}
/

&position
EOF

nla=`awk '{if($1=="Atoms"){print NR}}' ${SC222_data}`
awk -v nla=${nla} -v ixx=${ixx} -v iyy=${iyy} -v izz=${izz} -v ixy=${ixy} -v ixz=${ixz} -v iyz=${iyz} -v la=${la} '{
  if(NR>nla && $2>0){printf " %4d  %12.8f   %12.8f   %12.8f  \n",$2,($3*ixx+$4*ixy+$5*ixz)/la,($4*iyy+$5*iyz)/la,($5*izz)/la}
}' ${SC222_data} >> alm0.in
echo "/" >> alm0.in

${ALAMODE_ROOT}/alm/alm alm0.in > alm0.log

grep "Space group" alm0.log
grep "Number of disp. patterns" alm0.log
NHARM=`awk '{if($1=="Number" && $3=="disp." && $6=="HARMONIC"){printf "%d",$8}}' alm0.log`
echo "harmonic file: ${NHARM}"
NANHA=`awk '{if($1=="Number" && $3=="disp." && $6=="ANHARM3"){printf "%d",$8}}' alm0.log`
echo "anharmonic file: ${NANHA}"

echo "----- Generate structure files of LAMMPS (displace.py) -----"
mkdir displace; cd displace

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../sc222.pattern_HARMONIC >> run.log
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix cubic --mag 0.04 -pf ../sc222.pattern_ANHARM3 >> run.log

cp ../${coeff} .
cp ../${param} .
cp ../${input_file} .


echo "----- Run LAMMPS -----"
for i in $(seq -w ${NHARM})
do
   cp harm${i}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.harm${i}
   echo "----- XFSET.harm${i} / ${NHARM} -----"
done

for i in $(seq -w ${NANHA})
do
   cp cubic${i}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.cubic${i}
   echo "----- XFSET.cubic${i} / ${NANHA} -----"
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

# 1x1x1 Primitive cell
sg=`awk '{if($1=="Space" && $2=="group:"){printf "%1s",$3}}' alm1.log`
if [ ${sg:0:1} = "F" ]; then
  echo "space group: "${sg:0:1}" (FCC Primitive cell) settings"
cat << EOF >> phband.in
&cell
  ${la_bohr_d2} # factor in Bohr unit
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
elif [ ${sg:0:1} = "I" ]; then
  echo "space group: "${sg:0:1}" (BCC Primitive cell)  settings"
cat << EOF >> phband.in
&cell
  ${la_bohr_d2} # factor in Bohr unit
  1.0 0.0 0.0
  0.0 1.0 0.0
  0.0 0.0 1.0
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 H 0.0 1.0 0.0 51
  H 0.0 1.0 0.0 P 0.5 0.5 0.5 51
  P 0.5 0.5 0.5 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 N 0.5 0.5 0.0 51
/
EOF
elif [ ${sg:0:8} = "P6_3/mmc" ]; then
  echo "space group: "${sg:0:8}" (HCP Primitive cell) settings"
cat << EOF >> phband.in
&cell
  ${la_bohr_d2} # factor in Bohr unit
  1.00000 0.00000 0.00000
 -0.50000 0.86603 0.00000
  0.00000 0.00000 ${zz}
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 M 0.5 0.0 0.0 51
  M 0.5 0.0 0.0 K 0.333 0.333 0.0 51
  K 0.333 0.333 0.0 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 A 0.0 0.0 0.5 51
/
EOF
else
  echo "space group: "${sg}" (P) settings"
cat << EOF >> phband.in
&cell
  ${la_bohr_d2}
  ${xx} 0.0   0.0   # a1
  ${xy} ${yy} 0.0   # a2
  ${xz} ${yz} ${zz} # a3
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 X 0.5 0.5 0.0 51
  X 0.5 0.5 1.0 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 R 0.5 0.5 0.5 51
/
EOF
fi

#Memo: F
#&kpoint
#  1  # KPMODE = 1: line mode
#  R 0.5 0.5 0.5 G 0.0 0.0 0.0 51
#  G 0.0 0.0 0.0 X 0.5 0.0 0.0 51
#  X 0.5 0.0 0.0 M 0.5 0.5 0.0 51
#  M 0.5 0.5 0.0 G 0.0 0.0 0.5 51
#/

#Memo: I (failed)
#&cell
#  ${la_bohr_r3} # factor in Bohr unit
#  1.00000  0.00000  0.00000
# -0.33333  0.94281  0.00000
# -0.33333 -0.47140  0.81649
#/

#Memo: I
#&kpoint
#  1  # KPMODE = 1: line mode
#  G 0.0 0.0 0.0 H 0.0 1.0 0.0 51
#  H 0.0 1.0 0.0 N 0.5 0.5 0.0 51
#  N 0.5 0.5 0.0 G 0.0 0.0 0.0 51
#  G 0.0 0.0 0.0 P 0.5 0.5 0.5 51
#/


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
  echo "space group: "${sg:0:1}" (FCC Primitive cell) settings"
cat << EOF >> RTA.in
&cell
  ${la_bohr_d2}
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/
EOF
elif [ ${sg:0:1} = "I" ]; then
  echo "space group: "${sg:0:1}" (BCC Primitive cell) settings"
cat << EOF >> RTA.in
&cell
  ${la_bohr_d2} # factor in Bohr unit
  1.0 0.0 0.0
  0.0 1.0 0.0
  0.0 0.0 1.0
/
EOF
elif [ ${sg:0:8} = "P6_3/mmc" ]; then
  echo "space group: "${sg:0:8}" (HCP Primitive cell) settings"
cat << EOF >> RTA.in
&cell
  ${la_bohr_d2}
  1.00000 0.00000 0.00000
 -0.50000 0.86603 0.00000
  0.00000 0.00000 ${zz}
/
EOF
else
  echo "space group: "${sg}" (P) settings"
cat << EOF >> RTA.in
&cell
  ${la_bohr_d2}
  ${xx} 0.0   0.0   # a1
  ${xy} ${yy} 0.0   # a2
  ${xz} ${yz} ${zz} # a3
/
EOF
fi

cat << EOF >> RTA.in
&kpoint
  2
  12 12 12
/
EOF

${ALAMODE_ROOT}/anphon/anphon RTA.in > RTA.log