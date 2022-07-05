#!/bin/bash

fname=$1

nla=`awk '{if($2=="ATOMS"){print NR}}' ${fname}`
awk -v nla=${nla} '{if(NR>nla){printf " %6d %20.15f %20.15f %20.15f %20.15f %20.15f %20.15f \n",$1,$2,$3,$4,$5,$6,$7}else{print $0}}' ${fname} > ${fname}.reax
