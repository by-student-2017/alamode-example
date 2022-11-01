#!/bin/bash

fname=$1

natoms=`awk '{if($2=="atoms"){printf "%d",$1}}' tmp.lammps`
nat=`awk '{if($2=="atom" && $3=="types"){printf "%d",$1}}' tmp.lammps`
nma=`awk '{if($1=="Masses"){print NR}}' tmp.lammps`
echo $natoms $nat $nma
for ((i=1;i<=${nat};i++));do
  elem[$i]=`awk -v nma=${nma} -v i=$i '{if(NR==nma+1+i){printf "%s",$4}}' tmp.lammps`
  RMTv[$i]=`awk -v nma=${nma} -v i=$i '{if(NR==nma+1+i){printf "%f",$5}}' tmp.lammps`
    Zv[$i]=`awk -v nma=${nma} -v i=$i '{if(NR==nma+1+i){printf "%f",$6}}' tmp.lammps`
done
echo ${elem[@]}
echo ${RMTv[@]}
echo ${Zv[@]}

echo "Title" > ${fname}.struct
echo "P   LATTICE,NONEQUIV.ATOMS: ${natoms}" >> ${fname}.struct
echo "MODE OF CALC=RELA unit=ang" >> ${fname}.struct

xx=`awk '{if($3=="xlo"){print $2}}' tmp.lammps`
yy=`awk '{if($3=="ylo"){print $2}}' tmp.lammps`
zz=`awk '{if($3=="zlo"){print $2}}' tmp.lammps`
#xy=`awk '{if($4=="xy"){print $1}}' tmp.lammps`
#xz=`awk '{if($5=="xz"){print $2}}' tmp.lammps`
#yz=`awk '{if($6=="yz"){print $3}}' tmp.lammps`
echo " ${xx} ${yy} ${zz} 90.000000 90.000000 90.000000" >> ${fname}.struct

nla=`awk '{if($1=="Atoms"){print NR}}' tmp.lammps`
awk -v nla=${nla} -v elem1=${elem1} -v xx=${xx} -v yy=${yy} -v zz=${zz} '{if(NR>nla && $1>0){
		printf "ATOM %3d: X=%8.6f Y=%8.6f Z=%8.6f \n",-$1,($3/xx),($4/yy),($5/zz);
		printf "          MULT= 1          ISPLIT= 8 \n";
		printf "Xx%d%-3d      NPT=  781  R0=0.00010000 RMT= RMTv%d   Z: Zv%d \n",$2,$1,$2,$2;
		printf "LOCAL ROT MATRIX:    1.0000000 0.0000000 0.0000000 \n";
		printf "                     0.0000000 1.0000000 0.0000000 \n";
		printf "                     0.0000000 0.0000000 1.0000000 \n";
	}}' tmp.lammps >> ${fname}.struct
for ((i=1;i<=${nat};i++));do
	sed -i "s/Xx$i/${elem[$i]}/g" ${fname}.struct
	sed -i "s/RMTv$i/${RMTv[$i]}/g" ${fname}.struct
	sed -i "s/Zv$i/${Zv[$i]}/g" ${fname}.struct
done

echo "   1      NUMBER OF SYMMETRY OPERATIONS" >> ${fname}.struct
echo " 1 0 0 0.00000000" >> ${fname}.struct
echo " 0 1 0 0.00000000" >> ${fname}.struct
echo " 0 0 1 0.00000000" >> ${fname}.struct
echo "       1"  >> ${fname}.struct
