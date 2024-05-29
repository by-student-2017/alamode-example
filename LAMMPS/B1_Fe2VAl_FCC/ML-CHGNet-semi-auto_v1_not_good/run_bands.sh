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
# Lammps SNAP potential case
#coeff=Si_Zuo_Arxiv2019.snapcoeff
#param=Si_Zuo_Arxiv2019.snapparam
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
input_file=in.lmp
if [ -f SC444.lammps ]; then
  SC222_data=SC444.lammps
  mode=cubic
elif [ -f SC222.lammps ]; then
  SC222_data=SC222.lammps
  mode=cubic
else
  SC222_data=SC111.lammps
  mode=random
fi
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
# XxYxZ supercell to primitive cell for band dispersion.
sc_X=`echo ${SC222_data:2:1}`
sc_Y=`echo ${SC222_data:3:1}`
sc_Z=`echo ${SC222_data:4:1}`
sc_type=${sc_X}
echo "band dispersion: ${sc_X}x${sc_Y}x${sc_Z} supercell => primitive cell: ${sc_type} vs. 1"
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
# Set space group of Bands and RTA: Auto, FCC, BCC, HCP or SC
fix_sg="Auto"
echo "Space group of Bands and RTA (Auto, FCC, BCC, HCP or SC): ${fix_sg}"
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
# Anharmonic calculation mode (cubic or random)
echo "set anharmonic calculation mode (cubic or random): ${mode}"
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
# I feel like there is no problem with leaving it at 12.0.
distance=12.0
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
echo "----- Get informaions form ${SC222_data} file -----"
#-----------------------------------------------------------------------------------------------
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
#-----------------------------------------------------------------------------------------------
la_bohr=`awk '{if($3=="xlo"){printf "%12.6f",($2*1.88973)}}' ${SC222_data}`
la=`awk '{if($3=="xlo"){printf "%f",$2}}' ${SC222_data}`
xx=`awk -v la=${la} '{if($3=="xlo"){printf "%12.6f",($2/la)}}' ${SC222_data}`
yy=`awk -v la=${la} '{if($3=="ylo"){printf "%12.6f",($2/la)}}' ${SC222_data}`
zz=`awk -v la=${la} '{if($3=="zlo"){printf "%12.6f",($2/la)}}' ${SC222_data}`
xy=`awk -v la=${la} 'BEGIN{XY=0.0}{if($4=="xy"){XY=$1}}END{printf "%12.6f",(XY/la)}' ${SC222_data}`
xz=`awk -v la=${la} 'BEGIN{XZ=0.0}{if($5=="xz"){XZ=$2}}END{printf "%12.6f",(XZ/la)}' ${SC222_data}`
yz=`awk -v la=${la} 'BEGIN{YZ=0.0}{if($6=="yz"){YZ=$3}}END{printf "%12.6f",(YZ/la)}' ${SC222_data}`
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
## VASP: [A] + [fx,fy,fz], Lammps (Ovito): [A] + [x,y,z], Alamode (alm): [A] + [fx,fy,fz]
## [x,y,z] = [fx,fy,fz][A] => [fx,fy,fz] = [x,y,z][A]^-1
#-----------------------------------------------------------------------------------------------
## Calculating the inverse of a 3x3 lower triangular matrix
#-----------------------------------------------------------------------------------------------
det=`echo "${xx} ${yy} ${zz}" | awk '{printf "%f",($1*$2*$3)}'`
vol=`echo "${det} ${la}" | awk '{printf "%f",($1*$2^3)}'`
random_num=`echo "${vol}" | awk '{printf "%d",int(20*$1/(5.68^3)+0.5)}'`
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

#-----------------------------------------------------------------------------------------------
# lattice vector of lammps
a1=`echo "${xx}   0.0   0.0 ${la} " | awk '{printf "%f",($4*($1^2+$2^2+$3^2)^0.5)}'`
a2=`echo "${xy} ${yy}   0.0 ${la} " | awk '{printf "%f",($4*($1^2+$2^2+$3^2)^0.5)}'`
a3=`echo "${xz} ${yz} ${zz} ${la} " | awk '{printf "%f",($4*($1^2+$2^2+$3^2)^0.5)}'`
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
#Note: 1/0.529176 = 1.88973
la_bohr_primitive=`awk -v sc_type=${sc_type} '{if($3=="xlo"){printf "%-12.6f",($2/sc_type/0.529)}}' ${SC222_data}` # 2x2x2 supercell vs. 1x1x1 primitive cell
la_bohr_r3=`awk -v sc_type=${sc_type} '{if($3=="xlo"){printf "%-12.6f",($2/sc_type/0.529*0.8660)}}' ${SC222_data}` 
#-----------------------------------------------------------------------------------------------

#--------------------------------
# Set the elements to be calculated in the lammps control file template (in_tmp.lmp) and output it as in.lmp.
cp in_tmp.lmp in.lmp
els=${elem[@]}
sed -i "s/XXXXXX/${els}/g" in.lmp
#--------------------------------

#-----------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#### alm0.log
log_file="alm0.log"
if [ -e ${log_file} ]; then
  CF=`awk '{if($1=="Job"){printf "%s",$2}}' ${log_file}`
  if [ ${CF} == "finished" ]; then
    echo "----- skip ${log_file} -----"
  else
    rm -f ${log_file}
  fi
fi
#
if [ ! -e ${log_file} ]; then

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

fi
#### alm0.log
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Get information on the number of files for calculating the structure with displacement using lammps.
grep "Space group" alm0.log
grep "Number of disp. patterns" alm0.log
NHARM=`awk '{if($1=="Number" && $3=="disp." && $6=="HARMONIC"){printf "%d",$8}}' alm0.log`
echo "harmonic file: ${NHARM}"
NANHA=`awk '{if($1=="Number" && $3=="disp." && $6=="ANHARM3"){printf "%d",$8}}' alm0.log`
echo "anharmonic file: ${NANHA}"
#-------------------------------------------------------------------------------


echo "----- Generate structure files of LAMMPS (displace.py) -----"
mkdir displace; cd displace


#-------------------------------------------------------------------------------
####
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../sc222.pattern_HARMONIC >> run.log

#if [ ${mode} == "cubic" ]; then
#  echo "cubic displacement case"
#  python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix ${mode} --mag 0.04 -pf ../sc222.pattern_ANHARM3 >> run.log
#else
#  echo "random displacement case"
#  python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix ${mode} --random --mag 0.04 -nd ${random_num} >> run.log
#fi
####
#-------------------------------------------------------------------------------


#cp ./../${coeff} ./
#cp ./../${param} ./
cp ./../${input_file} ./


#-------------------------------------------------------------------------------
echo "----- Run LAMMPS -----"
#-------------------------------------------------------------------------------
##### lammps calculation for HARMONIC
if [ -f NHARM_restart.txt ]; then
  if [ -e DFSET_harmonic${NHARM} ]; then
    NHARM_restart=${NHARM}
  else
    NHARM_restart=`cat NHARM_restart.txt`
  fi
else
  NHARM_restart=0
fi
#
if [ ! "${NHARM_restart}" == "${NHARM}" ]; then
  if [ "${NHARM_restart}" == "0" ]; then
    NHARM_restart=1
  fi
for i in $(seq -w ${NHARM_restart} ${NHARM})
do
   cp harm${i}.lammps tmp.lammps
   $LAMMPS < ${input_file} >> run.log
   mv XFSET XFSET.harm${i}
   echo "----- XFSET.harm${i} / ${NHARM} -----"
   echo ${i} > NHARM_restart.txt
done
else
  echo "HARMONIC step ${NHARM_restart} / ${NHARM} case"
  echo "----- skip HARMONIC calculation -----"
fi
#-------------------------------------------------------------------------------
##### lammps calculation for ANHARM3
#if [ -f NANHA_restart.txt ]; then
#  if [ -e DFSET_${mode}${NANHA} ]; then
#    NANHA_restart=${NANHA}
#  else
#    NANHA_restart=`cat NANHA_restart.txt`
#  fi
#else
#  NANHA_restart=1
#fi
#
#if [ ! "${NANHA_restart}" == "${NANHA}" ]; then
#for i in $(seq -w ${NANHA_restart} ${NANHA})
#do
#   cp ${mode}${i}.lammps tmp.lammps
#   $LAMMPS < ${input_file} >> run.log
#   mv XFSET XFSET.${mode}${i}
#   echo "----- XFSET.${mode}${i} / ${NANHA} -----"
#   echo ${i} > NANHA_restart.txt
#done
#else
#  echo "ANHARM3 step ${NANHA_restart} / ${NANHA} case"
#  echo "----- skip ANHARM3 calculation -----"
#fi
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
echo "----- Collect data (extract.py) -----"
#-------------------------------------------------------------------------------
if [ ! -e DFSET_harmonic ]; then
  python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic
fi
#-------------------------------------------------------------------------------
#if [ ! -e DFSET_${mode} ]; then
#  python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.${mode}* > DFSET_${mode}
#fi
#-------------------------------------------------------------------------------


cd ./../


#-------------------------------------------------------------------------------
echo "----- Extract harmonic force constants (alm1.in) -----"
#-------------------------------------------------------------------------------
#### alm1.log
log_file="alm1.log"
if [ -e ${log_file} ]; then
  CF=`awk '{if($1=="Job"){printf "%s",$2}}' ${log_file}`
  if [ ${CF} == "finished" ]; then
    echo "----- skip ${log_file} -----"
  else
    rm -f ${log_file}
  fi
fi
#
if [ ! -e ${log_file} ]; then

sed -e "s/PREFIX = sc222/PREFIX = sc222_harm/" alm0.in > alm1.in
sed -i "s/suggest/optimize/" alm1.in
sed -i "/&interaction/i &optimize" alm1.in
sed -i "/&interaction/i \  DFSET = displace/DFSET_harmonic" alm1.in
sed -i "/&interaction/i /" alm1.in
sed -i "/&interaction/i \ " alm1.in
sed -i "s/NORDER = 2/NORDER = 1/" alm1.in
${ALAMODE_ROOT}/alm/alm alm1.in > alm1.log

fi
#### alm1.log
#-------------------------------------------------------------------------------
grep "Space group" alm1.log
grep "Fitting error" alm1.log
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
sg=`awk '{if($1=="Space" && $2=="group:"){printf "%1s",$3}}' alm1.log`
if [ ${sg:0:1} == "F" ]; then
  echo "space group: "${sg:0:1}" settings"
  SG=FCC
elif [ ${sg:0:1} == "I" ]; then
  echo "space group: "${sg:0:1}" settings"
  SG=BCC
elif [ ${sg:0:8} == "P6_3/mmc" ]; then
  echo "space group: "${sg:0:8}" (HCP) settings"
  SG=HCP
else
  echo "space group: "${sg}" (P) settings"
  SG=SC
fi
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#echo "----- Extract ${mode} force constants (alm2.in) -----"
#-------------------------------------------------------------------------------
#### alm2.log
#log_file="alm2.log"
#if [ -e ${log_file} ]; then
#  CF=`awk '{if($1=="Job"){printf "%s",$2}}' ${log_file}`
#  if [ ${CF} == "finished" ]; then
#    echo "----- skip ${log_file} -----"
#  else
#    rm -f ${log_file}
#  fi
#fi
#
#if [ ! -e ${log_file} ]; then
#
#sed -e "s/PREFIX = sc222_harm/PREFIX = sc222_${mode}/" alm1.in > alm2.in
#sed -i "s/DFSET_harmonic/DFSET_${mode}/" alm2.in
#if [ ${mode} == "cubic" ]; then
#  sed -i "/DFSET = displace\/DFSET_harmonic/a \  FC2XML = sc222_harm.xml" alm2.in
#else
#  sed -i "/DFSET = displace\/DFSET_harmonic/a \  FC2XML = sc222_harm.xml/a \  LMODEL = enet/a \  NDATA = ${random_num}/a \ CV = 4/a \ L1_RATIO = 1.0/a \ CONV_TOL = 1.0e-8" alm2.in
#fi
#sed -i "s/NORDER = 1/NORDER = 2/" alm2.in
#${ALAMODE_ROOT}/alm/alm alm2.in > alm2.log

#-------------------------------------------------------------------
#if [ ${mode} == "random" ]; then
#  # opt.in
#  alpha=`awk '{if($1=="Minimum" && $2=="CVSCORE"){print $6}}' alm.log`
#  echo "Minimum CVSCORE at alpha = "${alpha}
#  sed "15i \ L1_ALPHA = ${alpha}" sc_alm2.in > sc_opt.in
#  sed -i "s/CV = 4/CV = 0/" sc_opt.in
#  awk '{if($1=="CV"){print $0}}' sc_opt.in
#  awk '{if($1=="L1_ALPHA"){print $0}}' sc_opt.in
#  ${ALAMODE_ROOT}/alm/alm sc_opt.in >> alm.log
#fi
#-------------------------------------------------------------------
#
#fi
#### alm2.log
#-------------------------------------------------------------------------------
#grep "Space group" alm2.log
#grep "Fitting error" alm2.log
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#### phband.log
log_file="phband.log"
if [ -e ${log_file} ]; then
  CF=`awk '{if($1=="Job"){printf "%s",$2}}' ${log_file}`
  if [ ${CF} == "finished" ]; then
    echo "----- skip ${log_file} -----"
  else
    rm -f ${log_file}
  fi
fi
#
if [ ! -e ${log_file} ]; then

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
#
if [ "${fix_sg}" == "Auto" ]; then
  sg=`awk '{if($1=="Space" && $2=="group:"){printf "%1s",$3}}' alm1.log`
elif [ "${fix_sg}" == "FCC" ]; then
  sg="F"
elif [ "${fix_sg}" == "BCC" ]; then
  sg="I"
elif [ "${fix_sg}" == "HCP" ]; then
  sg="P6_3/mmc"
else
  sg="SC"
fi
echo "  space group of Band and RTA: ${fix_sg} (${sg}) setting"
#
if [ ${sg:0:1} == "F" ]; then
  echo "space group: "${sg:0:1}" settings"
  #SG=FCC
cat << EOF >> phband.in
&cell
  ${la_bohr_primitive} # factor in Bohr unit
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 X 0.5 0.5 0.0 50
  X 0.5 0.5 1.0 G 0.0 0.0 0.0 50
  G 0.0 0.0 0.0 L 0.5 0.5 0.5 50
/
EOF
elif [ ${sg:0:1} == "I" ]; then
  echo "space group: "${sg:0:1}" settings"
  #SG=BCC
cat << EOF >> phband.in
&cell
  ${la_bohr_primitive} # factor in Bohr unit
  1.0 0.0 0.0
  0.0 1.0 0.0
  0.0 0.0 1.0
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 H 0.0 1.0 0.0 50
  H 0.0 1.0 0.0 P 0.5 0.5 0.5 50
  P 0.5 0.5 0.5 G 0.0 0.0 0.0 50
  G 0.0 0.0 0.0 N 0.5 0.5 0.0 50
/
EOF
elif [ ${sg:0:8} == "P6_3/mmc" ]; then
  echo "space group: "${sg:0:8}" (HCP) settings"
  #SG=HCP
cat << EOF >> phband.in
&cell
  ${la_bohr_primitive} # factor in Bohr unit
  1.00000 0.00000 0.00000
 -0.50000 0.86603 0.00000
  0.00000 0.00000 ${zz}
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 M 0.5 0.0 0.0 50
  M 0.5 0.0 0.0 K 0.333 0.333 0.0 50
  K 0.333 0.333 0.0 G 0.0 0.0 0.0 50
  G 0.0 0.0 0.0 A 0.0 0.0 0.5 50
/
EOF
else
  echo "space group: "${sg}" (P) settings"
  #SG=SC
cat << EOF >> phband.in
&cell
  ${la_bohr_primitive}
  ${xx} 0.0   0.0   # a1
  ${xy} ${yy} 0.0   # a2
  ${xz} ${yz} ${zz} # a3
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 X 0.5 0.5 0.0 50
  X 0.5 0.5 1.0 G 0.0 0.0 0.0 50
  G 0.0 0.0 0.0 R 0.5 0.5 0.5 50
/
EOF
fi

#Memo: F
#&kpoint
#  1  # KPMODE = 1: line mode
#  R 0.5 0.5 0.5 G 0.0 0.0 0.0 50
#  G 0.0 0.0 0.0 X 0.5 0.0 0.0 50
#  X 0.5 0.0 0.0 M 0.5 0.5 0.0 50
#  M 0.5 0.5 0.0 G 0.0 0.0 0.5 50
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
#  G 0.0 0.0 0.0 H 0.0 1.0 0.0 50
#  H 0.0 1.0 0.0 N 0.5 0.5 0.0 50
#  N 0.5 0.5 0.0 G 0.0 0.0 0.0 50
#  G 0.0 0.0 0.0 P 0.5 0.5 0.5 50
#/

${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log

fi
#### phband.log
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#### RTA.log
#log_file="RTA.log"
#if [ -e ${log_file} ]; then
#  CF=`awk '{if($1=="Job"){printf "%s",$2}}' ${log_file}`
#  if [ ${CF} == "finished" ]; then
#    echo "----- skip ${log_file} -----"
#  else
#    rm -f ${log_file}
#  fi
#fi
#
#if [ ! -e ${log_file} ]; then
#
#echo "----- Thermal conductivity (RTA.in) -----"
#cat << EOF > RTA.in
#&general
#  PREFIX = sc222_10
#  MODE = RTA
#  FCSXML = sc222_${mode}.xml
#
#  NKD = ${nat}; KD = ${elem[@]}
#  MASS = ${mass[@]}
#/
#EOF
#
#if [ ${sg:0:1} == "F" ]; then
#  echo "space group: "${sg:0:1}" settings"
#  #SG=FCC
#cat << EOF >> RTA.in
#&cell
#  ${la_bohr_primitive}
#  0.0 0.5 0.5
#  0.5 0.0 0.5
#  0.5 0.5 0.0
#/
#EOF
#elif [ ${sg:0:1} == "I" ]; then
#  echo "space group: "${sg:0:1}" settings"
#  #SG=BCC
#cat << EOF >> RTA.in
#&cell
#  ${la_bohr_primitive} # factor in Bohr unit
#  1.0 0.0 0.0
#  0.0 1.0 0.0
#  0.0 0.0 1.0
#/
#EOF
#elif [ ${sg:0:8} == "P6_3/mmc" ]; then
#  echo "space group: "${sg:0:8}" (HCP) settings"
#  #SG=HCP
#cat << EOF >> RTA.in
#&cell
#  ${la_bohr_primitive}
#  1.00000 0.00000 0.00000
# -0.50000 0.86603 0.00000
#  0.00000 0.00000 ${zz}
#/
#EOF
#else
#  echo "space group: "${sg}" (P) settings"
#  #SG=SC
#cat << EOF >> RTA.in
#&cell
#  ${la_bohr_primitive}
#  ${xx} 0.0   0.0   # a1
#  ${xy} ${yy} 0.0   # a2
#  ${xz} ${yz} ${zz} # a3
#/
#EOF
#fi

#------------------------------------------------------------------------------
#nqx=`echo ${a1} | awk '{printf "%d",int(50/$1+0.5)}'`
#nqy=`echo ${a2} | awk '{printf "%d",int(50/$1+0.5)}'`
#nqz=`echo ${a3} | awk '{printf "%d",int(50/$1+0.5)}'`
#echo "RTA mesh: ${nqx} ${nqy} ${nqz}"
#------------------------------------------------------------------------------

#cat << EOF >> RTA.in
#&kpoint
#  2
#  ${nqx} ${nqy} ${nqz}
#/
#EOF
#
#${ALAMODE_ROOT}/anphon/anphon RTA.in > RTA.log
#
#fi
#### RTA.log
#-------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------
# I wrote awk as a one-liner to make it easier to check, but it is easier to read with line breaks.
# I realized later that I had written the legend function in a way that lacked flexibility. (for "band-%-d" sequence)
#-----------------------------------------------------------------------------------------------
awk '{if(NR==3){printf "# k-axis, Phonon frequency [THz]";for(j=1;j<=(NF+3);j++){printf ", band-%-d",j};printf("\n")}else if(NR>=4){printf("%6d %12.6f"),(NR-3),$1;for(i=2;i<=NF;i++){printf("%12.6f ",$i*0.029979)}{printf("\n")}}}' sc222.bands > sc222_THz.bands
awk '{if(NR==3){printf "# k-axis, Phonon energy [meV]";for(j=1;j<=(NF+3);j++){printf ", band-%-d",j};printf("\n")}else if(NR>=4){printf("%6d %12.6f"),(NR-3),$1;for(i=2;i<=NF;i++){printf("%12.6f ",$i*0.12398)}{printf("\n")}}}' sc222.bands > sc222_meV.bands
#-----------------------------------------------------------------------------------------------
gnuplot < plot_band_${SG}.gpl
#gnuplot < plot_thermal_conductivity.gpl
#-----------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------
rm -f ./displace/NHARM_restart.txt ./displace/NANHA_restart.txt
#-----------------------------------------------------------------------------------------------
