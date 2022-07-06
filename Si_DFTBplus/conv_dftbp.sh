#!/bin/bash

fname=$1
elem1=$2

natom=`awk '{if($2=="atoms"){print $1}}' ${fname}`
echo "${natom} S" > geometry.gen
echo "${elem1}" >> geometry.gen

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
echo "${xx} ${xy} ${xz}" >> geometry.gen
echo "0.000000 ${yy} ${yz}" >> geometry.gen
echo "0.000000  0.000000 ${zz}" >> geometry.gen
