WIEN2k(ver.16) + Alamode(v.1.4.1)

1. git clone https://github.com/by-student-2017/alamode-example.git
2. cd alamode-example/Si_WIEN2k
3. chmod +x run_harm_step1.sh
4. ./run_harm_step1.sh
5. cd displace
6. cp harm1.lammps tmp.lammps
7. ./conv_struct.sh 1
8. cd $W2WEB_CASE_BASEDIR
9. mkdir Si-phonon; cd Si-phonon
10. mkdir 1; cd ./1
11. export CURRENT_DIR=`pwd`
12. cp $CURRENT_DIR/1.struct ./1.struct
13. w2web
14. (Reduce RMTs by [3] % (old scheme) on StructGenTM.)
15. (Individual mode on Initialize calc.)
  Select "No" on "view outputnn"
  Select "No" on "view outputsgroup"
  Set R-MT*K-MAX=5.0 on "check Si-phonon.sin1_st"
  Number of k-points: [1 ] on "x kgen" (Shift k-mesh (if applicable) [yes])
  Select "No" on "Perform spin-polarized calc.?"
16. run_lapw -fc 0.02
17. cp 1.scf $CURRENT_DIR/1.scf
18. cd $CURRENT_DIR
19. ./conv_force.sh 1.scf
20. mv XFSET XFSET.harm1
21. cd ..
22. chmod +x run_harm_step2.sh
23. ./run_harm_step2.sh
24. gnuplot < plot_band.gpl