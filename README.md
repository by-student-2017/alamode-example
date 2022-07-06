# alamode-example

##Installation (ubuntu 20.04 LTS on windows10)
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