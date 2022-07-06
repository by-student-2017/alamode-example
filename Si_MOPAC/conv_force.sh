#!/bin/bash

fname=$1

echo "ITEM: TIMESTEP" > XFSET
echo "0" >> XFSET
echo "ITEM: NUMBER OF ATOMS" >> XFSET
natom=`awk '{if($2=="atoms"){printf "%d",$1}}' tmp.lammps`
echo "${natom}" >> XFSET
echo "ITEM: BOX BOUNDS xy xz yz pp pp pp" >> XFSET
xhi=`awk '{if($4=="xhi"){printf "%18.16e",$2}}' tmp.lammps`
echo "0.0000000000000000e+00 ${xhi} 0.0000000000000000e+00" >> XFSET
yhi=`awk '{if($4=="yhi"){printf "%18.16e",$2}}' tmp.lammps`
echo "0.0000000000000000e+00 ${yhi} 0.0000000000000000e+00" >> XFSET
zhi=`awk '{if($4=="zhi"){printf "%18.16e",$2}}' tmp.lammps`
echo "0.0000000000000000e+00 ${zhi} 0.0000000000000000e+00" >> XFSET
echo "ITEM: ATOMS id xu yu zu fx fy fz" >> XFSET

nla=`awk '{if($1=="FINAL" && $2=="POINT" && $3=="AND" && $4=="DERIVATIVES"){print NR+2}}' ${fname}`
for ((i=1; i<=${natom}; i++)); do
  id=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+1){printf "%6d",$2}}' ${fname}`
  xu=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+1){printf "%20.15f",$6}}' ${fname}`
  yu=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+2){printf "%20.15f",$6}}' ${fname}`
  zu=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+3){printf "%20.15f",$6}}' ${fname}`
  fx=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+1){printf "%20.15f",(-$7*0.043361254529175)}}' ${fname}`
  fy=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+2){printf "%20.15f",(-$7*0.043361254529175)}}' ${fname}`
  fz=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+3*(i-1)+3){printf "%20.15f",(-$7*0.043361254529175)}}' ${fname}`
  echo "${id} ${xu} ${yu} ${zu} ${fx} ${fy} ${fz}" >> XFSET
  #awk -v nla=${nla} '{if(NR>nla){printf " %6d %20.15f %20.15f %20.15f %20.15f %20.15f %20.15f \n",$1,$2,$3,$4,($5*0.043361254529175),($6*0.043361254529175),($7*0.043361254529175)}else{print $0}}' ${fname} > ${fname}.reax
done
