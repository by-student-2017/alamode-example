#!/bin/bash

fname=$1

echo "ITEM: TIMESTEP" > XFSET
echo "0" >> XFSET
echo "ITEM: NUMBER OF ATOMS" >> XFSET
natom=`awk '{if($2=="atoms"){print $1}}' tmp.lammps`
echo "${natom}" >> XFSET
echo "ITEM: BOX BOUNDS xy xz yz pp pp pp" >> XFSET
xhi=`awk '{if($4=="xhi"){printf "%18.16e",$2}}' tmp.lammps`
echo "0.0000000000000000e+00 ${xhi} 0.0000000000000000e+00" >> XFSET
yhi=`awk '{if($4=="yhi"){printf "%18.16e",$2}}' tmp.lammps`
echo "0.0000000000000000e+00 ${yhi} 0.0000000000000000e+00" >> XFSET
zhi=`awk '{if($4=="zhi"){printf "%18.16e",$2}}' tmp.lammps`
echo "0.0000000000000000e+00 ${zhi} 0.0000000000000000e+00" >> XFSET
echo "ITEM: ATOMS id xu yu zu fx fy fz" >> XFSET

nla=`awk '{if($1=="Total" && $2=="Forces"){print NR}}' ${fname}`
for ((i=1; i<=64; i++)); do
  #id=`awk -v i=${i} '{if(NR==2+i){printf "%6d",$1}}' geometry.gen`
  # Angstrom unit
  xu=`awk -v i=${i} '{if(NR==2+i){printf "%20.15f",$3}}' geometry.gen`
  yu=`awk -v i=${i} '{if(NR==2+i){printf "%20.15f",$4}}' geometry.gen`
  zu=`awk -v i=${i} '{if(NR==2+i){printf "%20.15f",$5}}' geometry.gen`
  id=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%6d",$1}}' ${fname}`
  # convert Ha/au (Hartree/Bohr) to eV/Anstrom
  fx=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%20.15f",$2*51.42208619}}' ${fname}`
  fy=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%20.15f",$3*51.42208619}}' ${fname}`
  fz=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%20.15f",$4*51.42208619}}' ${fname}`
  echo "${id} ${xu} ${yu} ${zu} ${fx} ${fy} ${fz}" >> XFSET
done
