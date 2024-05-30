#!/bin/bash

fname=$1

nat=`awk '{if($2=="atom" && $3=="types"){printf "%d",$1}}' tmp.lammps`
nma=`awk '{if($1=="Masses"){print NR}}' tmp.lammps`
echo $nat $nma
for ((i=1;i<=${nat};i++));do
  elem[$i]=`awk -v nma=${nma} -v i=$i '{if(NR==nma+1+i){printf "%s",$4}}' tmp.lammps`
done
echo ${elem[@]}

natom=`awk '{if($2=="atoms"){printf "%d",$1}}' ${fname}`
echo "${natom} S" > geometry.gen
echo "${elem[@]}" >> geometry.gen

nla=`awk '{if($1=="Atoms"){print NR}}' ${fname}`
# Angstrom unit
awk -v nla=${nla} -v elem1=${elem1} '{if(NR>nla && $1>0){printf " %2s %2s %8.6f %8.6f %8.6f \n",$1,$2,$3,$4,$5}}' ${fname} >> geometry.gen

echo "0.000000 0.000000 0.000000" >> geometry.gen

# Angstrom unit
xx=`awk '{if($3=="xlo"){print $2}}' ${fname}`
yy=`awk '{if($3=="ylo"){print $2}}' ${fname}`
zz=`awk '{if($3=="zlo"){print $2}}' ${fname}`
xy=`awk '{if($4=="xy"){print $1}}' ${fname}`
xz=`awk '{if($5=="xz"){print $2}}' ${fname}`
yz=`awk '{if($6=="yz"){print $3}}' ${fname}`
echo "${xx} 0.000000 0.000000" >> geometry.gen
echo "${xy} ${yy}    0.000000" >> geometry.gen
echo "${xz} ${yz}    ${zz}"    >> geometry.gen
