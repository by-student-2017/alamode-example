#!/bin/bash

fname=$1

nla=`awk '{if($1=="Atoms"){print NR}}' ${fname}`
awk -v nla=${nla} '{if(NR>nla && $1>0){printf " %3d %3d  0.0  %8.6f %8.6f %8.6f \n",$1,$2,$3,$4,$5}else{print $0}}' ${fname} > ${fname}.reax
