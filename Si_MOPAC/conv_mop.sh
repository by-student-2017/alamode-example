#!/bin/bash

fname=$1
elem1=$2

echo "PM7 CHARGE=0 LET 1SCF GRADIENTS" > ${fname}.mop
echo "force calculation" >> ${fname}.mop
echo "comment line" >> ${fname}.mop

nla=`awk '{if($1=="Atoms"){print NR}}' ${fname}`
awk -v nla=${nla} -v elem1=${elem1} '{if(NR>nla && $1>0){printf " %2s  %8.6f 1  %8.6f 1  %8.6f 1 \n",elem1,$3,$4,$5}}' ${fname} >> ${fname}.mop

xx=`awk '{if($3=="xlo"){print $2}}' ${fname}`
yy=`awk '{if($3=="ylo"){print $2}}' ${fname}`
zz=`awk '{if($3=="zlo"){print $2}}' ${fname}`
xy=`awk '{if($4=="xy"){print $1}}' ${fname}`
xz=`awk '{if($5=="xz"){print $2}}' ${fname}`
yz=`awk '{if($6=="yz"){print $3}}' ${fname}`
echo " Tv ${xx} 0 ${xy} 0 ${xz} 0" >> ${fname}.mop
echo " Tv  0.000000 0 ${yy} 0 ${yz} 0" >> ${fname}.mop
echo " Tv  0.000000 0  0.000000 0 ${zz} 0" >> ${fname}.mop
