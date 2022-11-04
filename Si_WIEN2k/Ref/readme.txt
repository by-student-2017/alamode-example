WIEN2k(ver.16) + Alamode(v.1.4.1)

1. cd alamode-example/Si_WIEN2k
2. chmod +x run_harm_step1.sh
3. ./run_harm_step1.sh
4. cd displace
5. cp harm1.lammps tmp.lammps
6. ./conv_struct.sh 1
7. cd $W2WEB_CASE_BASEDIR
8. mkdir Si-phonon; cd Si-phonon
9. mkdir 1; cd ./1
10. cp $CURRENT_DIR/1.struct ./1.struct
11. w2web
12. (Individual mode on Initialize calc.)
  Select "No" on "view outputnn"
  Select "No" on "view outputsgroup"
  Set R-MT*K-MAX=5.0 on "check Si-phonon.sin1_st"
  Number of k-points: [1 ] on "x kgen" (Shift k-mesh (if applicable) [yes])
  Select "No" on "Perform spin-polarized calc.?"
13. run_lapw -fc 0.02
14. cp 1.scf $CURRENT_DIR/1.scf
15. cd $CURRENT_DIR
16. ./conv_force.sh 1.scf
17. mv XFSET XFSET.harm1
18. cd ..
19. ./run_harm_step2.sh
20. gnuplot < plot_band.gpl