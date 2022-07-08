# alamode-example


# Installation (ubuntu 20.04 LTS on windows10)
1. sudo apt update
2. sudo apt -y install cmake g++ liblapack-dev libopenblas-dev libopenmpi-dev 
3. sudo apt -y install libboost-dev libeigen3-dev libfftw3-dev libsymspg-dev
4. cd $HOME
5. wget https://github.com/ttadano/alamode/archive/refs/tags/v.1.4.1.tar.gz
6. tar zxvf v.1.4.1.tar.gz
7. cd alamode-v.1.4.1
8. mkdir _build; cd _build
9. cmake -DUSE_MKL_FFT=no ..
10. make
11. cp -r ~/alamode-v.1.4.1/tools ~/alamode-v.1.4.1/_build/


# test
1. cd ~/alamode-v.1.4.1/test
2. python3 test_si.py


# Note
- The phonon calculation was performed on "alamode" and "DFTB+" code using the skf or GFN2-xTB parameters.
- Phonon calculation was performed on "alamode" and "MOPAC" code.
- Phonon calculations using the Reaxff or ML-SNAP potentials were performed on "alamode" and "Lammps" code.
- These techniques and code are published on github. This is the first time in the world including the result. These are developed based on the original "Si_LAMMPS". Coincidentally, I feel destined to accomplish these feats on July 7, 2022 (Tanabata).
- The interface still has room for improvement. Other systems also need to be verified. I will post it on arXiv as soon as these verifications are completed. However, I'm so busy that it's likely to be years away.
- No one was in favor of these R&Ds. In addition, no research grants have been obtained. It was a lonely development.