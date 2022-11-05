WIEN2k(ver.16) + Alamode(v.1.4.1)

1. git clone https://github.com/by-student-2017/alamode-example.git
2. cd alamode-example/Ref_WIEN2k/Al_WIEN2k
3. chmod +x run_harm_step1.sh
4. ./run_harm_step1.sh
5. cd displace
6. cp harm1.lammps tmp.lammps
7. ./conv_struct.sh 1
8. cd $W2WEB_CASE_BASEDIR
9. mkdir Al-phonon; cd Al-phonon
10. mkdir 1; cd ./1
11. cp $CURRENT_DIR/1.struct ./1.struct
12. w2web
13. (Reduce RMTs by [3] % (old scheme) on StructGenTM.)
14. (Individual mode on Initialize calc.)
  Select "No" on "view outputnn"
  Select "No" on "view outputsgroup"
  Set R-MT*K-MAX=5.0 on "check Al-phonon.sin1_st"
  Number of k-points: [123 ] on "x kgen" (Shift k-mesh (if applicable) [yes])
  Select "No" on "Perform spin-polarized calc.?"
15. run_lapw -fc 0.1
16. cp 1.scf $CURRENT_DIR/1.scf
17. cd $CURRENT_DIR
18. ./conv_force.sh 1.scf
19. mv XFSET XFSET.harm1
20. cd ..
21. chmod +x run_harm_step2.sh
22. ./run_harm_step2.sh
23. gnuplot < plot_band.gpl