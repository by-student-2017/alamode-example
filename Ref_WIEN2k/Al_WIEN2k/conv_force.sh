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

nls=`grep -n "ITERATION" 1.scf | tail -1 | sed -e 's/:.*//'`

#nla=`grep -n "TOTAL FORCE IN mRy" 1.scf | tail -1 | sed -e 's/:.*//'`
for ((i=1; i<=${natom}; i++)); do
  #fx=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%20.15f",(-$4*0.043361254529175)}}' ${fname}`
  #fy=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%20.15f",(-$5*0.043361254529175)}}' ${fname}`
  #fz=`awk -v nla=${nla} -v i=${i} '{if(NR==nla+i){printf "%20.15f",(-$6*0.043361254529175)}}' ${fname}`
  id=`awk -v nls=${nls} -v i=${i} '{if(NR>nls && ($1==":POS00"i":" || $1==":POS0"i":" || $1==":POS"i";")){printf "%6d",i}}' ${fname}`
  xu=`awk -v nls=${nls} -v i=${i} -v xhi=${xhi}  '{if(NR>nls && ($1==":POS00"i":" || $1==":POS0"i":" || $1==":POS"i";")){printf "%20.15f",$6*xhi}}' ${fname}`
  yu=`awk -v nls=${nls} -v i=${i} -v yhi=${yhi} '{if(NR>nls && ($1==":POS00"i":" || $1==":POS0"i":" || $1==":POS"i";")){printf "%20.15f",$7*yhi}}' ${fname}`
  zu=`awk -v nls=${nls} -v i=${i} -v zhi=${zhi} '{if(NR>nls && ($1==":POS00"i":" || $1==":POS0"i":" || $1==":POS"i";")){printf "%20.15f",$8*zhi}}' ${fname}`
  # force Ry/a.u. on WIEN2k, [Ry/a.u.] = [eV/Angstrom]
  # force: 1 [Ry/Bohr] = 25.71104309541616 [eV/Angstrom]
  fx=`awk -v nls=${nls} -v i=${i} '{if(NR>nls && ($1==":FOR00"i":" || $1==":FOR0"i":" || $1==":FOR"i";")){printf "%20.15f",$4/25.71104309541616}}' ${fname}`
  fy=`awk -v nls=${nls} -v i=${i} '{if(NR>nls && ($1==":FOR00"i":" || $1==":FOR0"i":" || $1==":FOR"i";")){printf "%20.15f",$5/25.71104309541616}}' ${fname}`
  fz=`awk -v nls=${nls} -v i=${i} '{if(NR>nls && ($1==":FOR00"i":" || $1==":FOR0"i":" || $1==":FOR"i";")){printf "%20.15f",$6/25.71104309541616}}' ${fname}`
  echo "${id} ${xu} ${yu} ${zu} ${fx} ${fy} ${fz}" >> XFSET
done
