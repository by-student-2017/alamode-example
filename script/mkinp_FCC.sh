#!/bin/bash

fname=*.vasp
#nkf -w -Lu --overwirte $fname # LF(UNIX/Linux/Mac), CR+LF(Windows)
sed -i 's/r//g' $fname # convert CR+LF(Windows) to LF(UNIX/Linux/Mac)
name=`basename $fname .vasp`
echo "File name = "$name

a11=`awk '{if(NR==3){printf "%9.6f", $1}}' $fname`
a12=`awk '{if(NR==3){printf "%9.6f", $2}}' $fname`
a13=`awk '{if(NR==3){printf "%9.6f", $3}}' $fname`
#-----
a21=`awk '{if(NR==4){printf "%9.6f", $1}}' $fname`
a22=`awk '{if(NR==4){printf "%9.6f", $2}}' $fname`
a23=`awk '{if(NR==4){printf "%9.6f", $3}}' $fname`
#-----
a31=`awk '{if(NR==5){printf "%9.6f", $1}}' $fname`
a32=`awk '{if(NR==5){printf "%9.6f", $2}}' $fname`
a33=`awk '{if(NR==5){printf "%9.6f", $3}}' $fname`

telem=`awk '{if(NR==6){printf "%s",$0}}' $fname`
elem=(${telem//,/})
nat=${#elem[@]};
echo "Number of atom types = "$nat
#-----
#tnatoms=`awk '{if(NR==7){printf "%s", $0}}' $1`
#pnatoms=(${tnatoms//,/})
#-----
natoms=0
for((i=0;i<$nat;i++));do
	elem[$i]=`awk -v i=$i '{if(NR==6){printf "%.2s", $(i+1)}}' $fname`
	pnatoms[$i]=`awk -v i=$i '{if(NR==7){printf "%d", $(i+1)}}' $fname`
	echo  "${elem[$i]} : ${pnatoms[$i]}"
        natoms=$((natoms+pnatoms[$i]))
done
echo "Number of atoms = "$natoms

# data
#-----
element_list=(H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf Df Sg Bh Hs Mt Ds Rg Cn Nh Fl Mc Lv Ts Og)
#-----
mass_list=(1.00794 4.00260 6.941 9.01218 10.81 12.01 14.007 16.00 18.9984 20.180 22.99 24.305 26.98 28.1 30.97 32.1 35.45 39.95 39.10 40.08 44.955912 47.867 50.9415 51.9961 54.938045 55.845 58.933195 58.6934 63.546 65.38 69.723 72.63 74.92160 78.96 79.904 83.798 85.4678 87.62 88.90585 91.224 92.90638 95.96 98 101.07 102.90550 106.42 107.8682 112.411 114.818 118.710 121.760 127.60 126.90447 131.293 132.9054519 137.33 138.90547 140.116 140.90765 144.242 145 150.36 151.964 157.25 158.92535 162.500 164.93032 167.259 168.93421 173.054 174.9668 178.49 180.94788 183.84 186.207 190.23 192.217 195.084 196.966569 200.59 204.3833 207.2 208.98040 209 210 222 223 226 227 232.0381 231.03588 238.02891 237 244 243 247 247 251 252 257 258 259 262 261.11 268 271 270 269 278 281 281 285 286 289 289 293 294 294)
#-----
ion_charge_list=(1.0 0.0 1.0 2.0 0.0 0.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 0.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 4.0 3.0 3.0 2.0 3.0 2.0 2.0 2.0 2.0 3.0 4.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 3.0 3.0 2.0 1.0 2.0 3.0 4.0 3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 3.0 4.0 5.0 6.0 7.0 4.0 4.0 4.0 3.0 2.0 1.0 2.0 3.0 2.0 1.0 0.0 1.0 2.0 3.0 4.0 5.0 6.0 5.0 4.0 3.0 3.0 3.0 3.0 3.0 3.0 2.0 2.0 3.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)
#-----
for((i=0;i<$nat;i++));do
	for((j=0;j<118;j++));do
		if [ ${elem[$i]} = ${element_list[$j]} ]; then
			atomic_num[$i]=$j
			mass[$i]=${mass_list[$j]}
			#echo ${elem[$i]} ${atomic_num[$i]} ${mass[$i]}
		fi
	done
done

# lammps
cat << EOF > $name"222.lammps"
# Structure data of $name (2x2x2 conventional)

$natoms atoms
$nat types

0.000000   $a11   xlo xhi
0.000000   $a22   ylo yhi
0.000000   $a33   zlo zhi
0.000000    0.000000    0.000000   xy xz yz

Masses

EOF
#-----
for((i=0;i<$nat;i++));do
	#echo ${elem[$i]} ${atomic_num[$i]} ${mass[$i]}
	echo "$((i+1)) ${mass[$i]} # ${elem[$i]} 2.22 ${atomic_num[$i]}" >> $name"222.lammps" 
done
#----
echo "" >> $name"222.lammps"
echo "Atoms" >> $name"222.lammps"
echo "" >> $name"222.lammps"
#----
nstart=0
for((i=0;i<$nat;i++));do
	#echo $nstart ${pnatoms[$i]}
	awk -v nst=$nstart -v pna=${pnatoms[$id]} -v i=$i '{
		if(NR==3){x=$1}; if(NR==4){y=$2}; if(NR==5){z=$3};
		#if(NR==8 && ! $1=="Diect"){x=1.0;y=1.0;z=1.0};
		if(NR>(8+nst) && NR<=(8+nst+pna)){
			printf "%3d %2d %9.6f %9.6f %9.6f \n",(NR-8),(i+1),$1*x,$2*y,$3*z}
		}' $fname >> $name"222.lammps"
	nstart=$((nstart+pnatoms[$i]))
done

#alamode-input
# Generate displacement patterns
cat << EOF > ${name}_alm0.in
&general
  PREFIX = ${name}222
  MODE = suggest
  NAT = ${natoms}; NKD = ${nat}
  KD = ${elem[@]}
/

&interaction
  NORDER = 2  # 1: harmonic, 2: cubic, ..
/

&cell
EOF
awk '{if(NR==3){printf "  %9.6f  # factor in Bohr unit \n", $1*1.889726;
		factor=$1;
		printf "  %9.6f %9.6f %9.6f # a1 \n", $1/factor, $2/factor, $3/factor};
      if(NR==4){printf "  %9.6f %9.6f %9.6f # a2 \n", $1/factor, $2/factor, $3/factor};
      if(NR==5){printf "  %9.6f %9.6f %9.6f # a3 \n", $1/factor, $2/factor, $3/factor};
}' $fname >> ${name}_alm0.in
echo "/" >> ${name}_alm0.in
echo " " >> ${name}_alm0.in
echo "&cutoff" >> ${name}_alm0.in
for((i=0;i<$nat;i++));do
	for((j=$i;j<$nat;j++));do
		echo "  "${elem[$i]}"-"${elem[$j]}" 7.3 7.3" >> ${name}_alm0.in
	done
done
echo "/" >> ${name}_alm0.in
echo " " >> ${name}_alm0.in
echo "&position" >> ${name}_alm0.in
nstart=0
for((i=0;i<$nat;i++));do
	#echo $nstart ${pnatoms[$i]}
	awk -v nst=$nstart -v pna=${pnatoms[$id]} -v i=$i '{
		#if(NR==3){x=$1}; if(NR==4){y=$2}; if(NR==5){z=$3};
		#if(NR==8 && $1=="Diect"){x=1.0;y=1.0;z=1.0};
		if(NR>(8+nst) && NR<=(8+nst+pna)){
			printf " %2d %9.6f %9.6f %9.6f \n",(i+1),$1,$2,$3}
		}' $fname >> ${name}_alm0.in
	nstart=$((nstart+pnatoms[$i]))
done
echo "/" >> ${name}_alm0.in

# Extract harmonic force constants
cp ${name}_alm0.in ${name}_alm1.in
sed -i 's/'${name}'222/'${name}'222_harm/' ${name}_alm1.in
sed -i 's/suggest/optimize/' ${name}_alm1.in
sed -i 's/NORDER = 2/NORDER = 1/' ${name}_alm1.in
sed  -i '8i&optimize' ${name}_alm1.in
sed  -i '9i\  DFSET = displace/DFSET_harmonic' ${name}_alm1.in
sed  -i '10i /\n' ${name}_alm1.in

# Extract cubic force constants
cp ${name}_alm0.in ${name}_alm2.in
sed -i 's/'${name}'222/'${name}'222_cubic/' ${name}_alm2.in
sed -i 's/suggest/optimize/' ${name}_alm2.in
sed  -i '8i&optimize' ${name}_alm2.in
sed  -i '9i\  DFSET = displace/DFSET_cubic' ${name}_alm2.in
sed  -i '10i\  FC2XML = al222_harm.xml' ${name}_alm2.in
sed  -i '11i /\n' ${name}_alm2.in

# Phonon dispersion
cat << EOF > phband.in
&general
  PREFIX = ${name}222
  MODE = phonons
  FCSXML =${name}222_harm.xml

  NKD = ${nat}; KD = ${elem[@]}
  MASS = ${mass[@]}
/
EOF
unit_bohr=`awk '{if(NR==3){printf "%-9.6f", $1*1.889726/2.0}}' $fname`
cat << EOF >> phband.in
  ${unit_bohr}
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/
&kpoint
  1  # KPMODE = 1: line mode
  G 0.0 0.0 0.0 X 0.5 0.5 0.0 51
  X 0.5 0.5 1.0 G 0.0 0.0 0.0 51
  G 0.0 0.0 0.0 L 0.5 0.5 0.5 51
/
EOF

# Thermal conductivity
cat << EOF > RTA.in
&general
  PREFIX = ${name}222_10
  MODE = RTA
  FCSXML = ${name}222_cubic.xml

  NKD = ${nat}; KD = ${elem[@]}
  MASS = ${mass[@]}
/
EOF
unit_bohr=`awk '{if(NR==3){printf "%-9.6f", $1*1.889726/2.0}}' $fname`
cat << EOF >> RTA.in
&cell
  ${unit_bohr}
  0.0 0.5 0.5
  0.5 0.0 0.5
  0.5 0.5 0.0
/
&kpoint
  2
  10 10 10
/
EOF

cat << EOF > run.sh
#!/bin/bash

# Binaries 
WIEN2k_init="init_lapw -prec 2n"
WIEN2k_run="run_lapw -fc 0.1"
ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
SC222_data=${name}222.lammps

chmod +x conv_struct.sh
chmod +x conv_force.sh

# Generate displacement patterns
${ALAMODE_ROOT}/alm/alm si_alm0.in > alm.log

# Generate structure files
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../si222.pattern_HARMONIC >> run.log
python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix cubic --mag 0.04 -pf ../si222.pattern_ANHARM3 >> run.log

cp ../conv_struct.sh ./
cp ../conv_force.sh ./
CURRENT_DIR=\`pwd\`

# Run WIEN2k v.21.1
for ((i=1; i<=1; i++));do
   cp harm${i}.lammps tmp.lammps
   ./conv_struct.sh ${i}
   #
   cd $W2WEB_CASE_BASEDIR
   mkdir ${i}; cd ${i}
   cp $CURRENT_DIR/${i}.struct ./${i}.struct
   $WIEN2k_init
   $WIEN2k_run
   cp ${i}.scf ./$CURRENT_DIR/${i}.scf
   cd $CURRENT_DIR
   #
   ./conv_force.sh ${i}.scf
   mv XFSET XFSET.harm${i}
done

for ((i=1; i<=20; i++));do
   suffix=`echo ${i} | awk '{printf("%02d", $1)}'`
   cp cubic${suffix}.lammps tmp.lammps
   ./conv_struct.sh ${i}
   #
   cd $W2WEB_CASE_BASEDIR
   mkdir ${i}; cd ${i}
   cp $CURRENT_DIR/${i}.struct ./${i}.struct
   $WIEN2k_init
   $WIEN2k_run
   cp ${i}.scf ./$CURRENT_DIR/${i}.scf
   cd $CURRENT_DIR
   #
   ./conv_force.sh ${i}.scf
   mv XFSET XFSET.cubic${suffix}
done

# Collect data
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.cubic* > DFSET_cubic

cd ../

# Extract harmonic force constants
${ALAMODE_ROOT}/alm/alm si_alm1.in >> alm.log

# Extract cubic force constants
${ALAMODE_ROOT}/alm/alm si_alm2.in >> alm.log

# Phonon dispersion
${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log

# Thermal conductivity
${ALAMODE_ROOT}/anphon/anphon RTA.in > RTA.log
EOF
chmod +x run.sh

cat << EOF > run_harm_step1.sh
#!/bin/bash

# Binaries
WIEN2k_init="init_lapw -prec 2n"
WIEN2k_run="run_lapw -fc 0.1"
ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
SC222_data=${name}222.lammps

chmod +x conv_struct.sh
chmod +x conv_force.sh

# Generate displacement patterns
${ALAMODE_ROOT}/alm/alm si_alm0.in > alm.log

# Generate structure files
mkdir displace; cd displace/

python3 ${ALAMODE_ROOT}/tools/displace.py --LAMMPS ../${SC222_data} --prefix harm --mag 0.01 -pf ../si222.pattern_HARMONIC >> run.log

cp ../conv_struct.sh ./
cp ../conv_force.sh ./

export CURRENT_DIR=\`pwd\`
EOF
chmod +x run_harm_step1.sh

cat << EOF > run_harm_step2.sh
#!/bin/bash

# Binaries 
ALAMODE_ROOT=${HOME}/alamode-v.1.4.1/_build
SC222_data=${name}222.lammps

cd ./displace

# Collect data
python3 ${ALAMODE_ROOT}/tools/extract.py --LAMMPS ../${SC222_data} XFSET.harm* > DFSET_harmonic

cd ../

# Extract harmonic force constants
${ALAMODE_ROOT}/alm/alm si_alm1.in >> alm.log

# Phonon dispersion
${ALAMODE_ROOT}/anphon/anphon phband.in > phband.log
EOF
chmod +x run_harm_step2.sh
