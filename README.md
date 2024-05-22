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




# GPU settings

## Environment
- Windows11
- CPU: 12th Gen Intel(R) Core(TM) i7-12700
- GPU: NVIDIA GeForce RTX 3070 (compute capability, 8.6)
  (see, https://developer.nvidia.com/cuda-gpus )

## Get nvcc
1. sudo apt -y update
(2. sudo apt install nvidia-prime)
(3. sudo apt install cuda)
4. sudo apt -y install nvidia-cuda-toolkit
5. nvidia-smi

## Version check and adress
6. nvcc -V
7. which nvcc
  (/usr/bin/nvcc)

## Linux (ubuntu 22.04 lts) (GPU)
8. nvcc -O2 main-gpu_2d.cu write_vtk_grid_values_2D.cu -o main-gpu_2d.exe -arch=native -lm --std 'c++17'
9. ./main-gpu_2d.exe
10. (use ParaView for time_XX.vtk)

## Linux (ubuntu 22.04 lts) (GPU, using shared memory)
8. nvcc -O2 main-shared_2d.cu write_vtk_grid_values_2D.cu -o main-shared_2d.exe -arch=native -lm --std 'c++17'
9. ./main-shared_2d.exe
10. (use ParaView for time_XX.vtk)

## Linux (ubuntu 22.04 lts) (CPU only)
8. nvcc -O2 main-cpu_2d.cu write_vtk_grid_values_2D.cu -o main-cpu_2d.exe -lm
9. ./main-cpu_2d.exe
10. (use ParaView for time_XX.vtk)

## cmake version (ubuntu 22.04 lts)
8. cmake -S . -B build/ -G"Unix Makefiles"
9. cmake --build build/ --target main-gpu.exe
10. cd ./build
11. ./main-gpu.exe
12. (use ParaView for time_XX.vtk)

## fft version (underconstracting)
- nvcc -O2 main-gpu_2d_cufft.cu write_vtk_grid_values_2D.cu -o main-gpu_2d_cufft.exe -lcufft -arch=sm_86
- ./main-gpu_2d_cufft.exe

## Reference
[T2] http://www.measlab.kit.ac.jp/nvcc.html

## Select Target Platform
- wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.0-1_all.deb
- sudo dpkg -i cuda-keyring_1.0-1_all.deb
- sudo apt-get update
- sudo apt-get -y install cuda
- [S1] https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=WSL-Ubuntu&target_version=2.0&target_type=deb_network

## Environment settings
- vim ~/.bashrc
  export PATH="/usr/local/cuda/bin:$PATH"
  export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
- [S2] https://misoji-engineer.com/archives/ubuntu20-04-cuda.html

nvcc main-cpu.cu -o main-cpu

For CPU: main-cpu.cu
For GPU (Global memory): main-gpu.cu
For GPU (Shard memory): main-shared.cu

- [T1] http://www.cis.kit.ac.jp/~takaki/phase-field/ch22-23/ch22-23.html
- [T2] https://www.gsic.titech.ac.jp/supercon/main/attwiki/index.php?plugin=attach&refer=SupercomputingContest2018&openfile=SuperCon2018-GPU.pdf
- [T3] https://hpc-phys.kek.jp/workshop/workshop190318/aoyama_190318.pdf
- [T4] http://olab.is.s.u-tokyo.ac.jp/~reiji/GPUtut2.pdf


# Installation of CGHNet and M3GNet on Lammps
------------------------------------------------------------------------------
Edit: 22/May/2024

□ Environment
- Windows11
- CPU: 12th Gen Intel(R) Core(TM) i7-12700
- GPU: NVIDIA GeForce RTX 3070 (compute capability, 8.6) (CUDA 11.7) (sm_86)
  (see https://developer.nvidia.com/cuda-gpus)
- python3.10

□ Installation (CHGNet) on Linux or WSL
1. wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.4.0-0-Linux-x86_64.sh
  (see https://repo.anaconda.com/miniconda/)
2. sh Miniconda3-py310_24.4.0-0-Linux-x86_64.sh
  ([Enter], [space], "yes" and [Enter]) (all "Enter" key, "space" key and "yes")
- Press ENTER to confirm the location
  ([Enter] and "yes")
3. echo 'export PATH=$HOME/miniconda3/bin:$PATH' >> ~/.bashrc
4. bash
5. pip install chgnet
6. conda install pytorch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2 pytorch-cuda=11.7 -c pytorch -c nvidia
  (see https://pytorch.org/get-started/previous-versions/)

□ Environment settings of CHGNet
1. echo 'export PATH=$HOME/miniconda3/lib/libgomp.so:$PATH' >> ~/.bashrc
2. echo '# export LD_LIBRARY_PATH=$HOME/miniconda3/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
3. echo 'export PYTHONPATH=$HOME/miniconda3/chgnet:$PYTHONPATH' >> ~/.bashrc
4. bash

□ Check installation (PyTorch)
  python
  import torch
  print(torch.cuda.is_available())
  (Show "True")
  (Ctrl + Z)

□ Installation (Lammps) on Linux or WSL
1. sudo apt update
2. sudo apt -y install python3.10-dev
3. echo 'export CPATH=/usr/include/python3.10:$CPATH' >> ~/.bashrc
4. bash
5. git clone https://github.com/advancesoftcorp/lammps.git
6. cd lammps/src
7. make package-status
8. make yes-KSPACE yes-MANYBODY yes-ML-CHGNET yes-MOLECULE yes-PYTHON yes-RIGID
9. cd MAKE
10. vim Makefile.serial
11. LIB = -I/usr/include/python3.10 -L/usr/lib/x86_64-linux-gnu -lpython3.10
12. cd ../
13. make serial
Note: "make omp" is failed.

□ Environment settings of Lammps
1. echo 'export PATH=$PATH:$HOME/lammps/src' >> ~/.bashrc
  ( In my case (WSL and D drive), $HOME => /mnt/d )
2. bash
3. which lmp_serial
----- (username = your PC name)
/home/username/lammps/src/lmp_serial
-----

□ Test (Total wall time: 0:10:20)
1. cd $HOME/lammps/examples/CHGNET
  ( In my case (WSL and D drive), $HOME => /mnt/d )
2. lmp_serial -in inp.lammps
3. Drag and drop "xyz.lammpstrj" to Octa.

□ Installation (GPU version of lammps) on Linux or WSL
1. sudo apt update
2. sudo apt -y install python3.10-dev
3. echo 'export CPATH=/usr/include/python3.10:$CPATH' >> ~/.bashrc
4. bash
5. git clone https://github.com/advancesoftcorp/lammps.git
6. cd lammps/src
7. make package-status
8. make yes-KSPACE yes-MANYBODY yes-ML-CHGNET yes-MOLECULE yes-PYTHON yes-RIGID yes-GPU
9. cd MAKE
10. vim Makefile.serial
11. LIB = -I/usr/include/python3.10 -L/usr/lib/x86_64-linux-gnu -lpython3.10
12. cd ../
13. cd $HOME/lammps/
  ( In my case (WSL and D drive), $HOME => /mnt/d ) 
14. make lib-gpu args="-m serial -a sm_80 -p mixed -b"
  (In my case sm_86 is rejected.)
15. make serial

□ Test on GPU (Total wall time: 0:05:44)
1. cd $HOME/lammps/examples/CHGNET
  ( In my case (WSL and D drive), $HOME => /mnt/d )
2. lmp_serial -sf gpu -pk gpu 1 -in inp.lammps
3. Drag and drop "xyz.lammpstrj" to Octa.

□ Test on GPU (Total wall time: 0:05:40)
1. cd $HOME/lammps/examples/CHGNET
  ( In my case (WSL and D drive), $HOME => /mnt/d )
2. vim inp.lammps
-----(before)
pair_style    chgnet ../../potentials/CHGNET
#pair_style    chgnet/d3 ../../potentials/CHGNET
#pair_style    chgnet/gpu ../../potentials/CHGNET
#pair_style    chgnet/d3/gpu ../../potentials/CHGNET
-----
-----(after)
#pair_style    chgnet ../../potentials/CHGNET
#pair_style    chgnet/d3 ../../potentials/CHGNET
pair_style    chgnet/gpu ../../potentials/CHGNET
#pair_style    chgnet/d3/gpu ../../potentials/CHGNET
-----
3. lmp_serial -sf gpu -pk gpu 1 -in inp.lammps
4. Drag and drop "xyz.lammpstrj" to Octa.

□ Test on GPU (Total wall time: 0:05:36)
1. cd $HOME/lammps/examples/CHGNET
  ( In my case (WSL and D drive), $HOME => /mnt/d )
2. vim inp.lammps
-----(before)
pair_style    chgnet ../../potentials/CHGNET
#pair_style    chgnet/d3 ../../potentials/CHGNET
#pair_style    chgnet/gpu ../../potentials/CHGNET
#pair_style    chgnet/d3/gpu ../../potentials/CHGNET
-----
-----(after)
#pair_style    chgnet ../../potentials/CHGNET
#pair_style    chgnet/d3 ../../potentials/CHGNET
pair_style    chgnet/gpu ../../potentials/CHGNET
#pair_style    chgnet/d3/gpu ../../potentials/CHGNET
-----
3. lmp_serial -in inp.lammps
4. Drag and drop "xyz.lammpstrj" to Octa.
------------------------------------------------------------------------------
■ Appendix: M3GNet

□ Installation (CHGNet) on Linux or WSL
5. pip install m3gnet matgl
6. conda install simple-dftd3 dftd3-python -c conda-forge

□ Environment settings of M3GNet
3. echo 'export PYTHONPATH=$HOME/miniconda3/m3gnet:$PYTHONPATH' >> ~/.bashrc
4. bash

□ Installation (Lammps) on Linux or WSL
8. make yes-KSPACE yes-MANYBODY yes-ML-M3GNET yes-MOLECULE yes-PYTHON yes-RIGID yes-GPU

□ Test (Total wall time: 0:18:44)
1. cd $HOME/lammps/examples/M3GNET
  ( In my case (WSL and D drive), $HOME => /mnt/d )
2. vim inp.lammps
-----(before)
pair_coeff    * *  MP-2021.2.8-EFS  Zr O
#pair_coeff    * *  M3GNet-MP-2021.2.8-PES  Zr O
-----
-----(after)
#pair_coeff    * *  MP-2021.2.8-EFS  Zr O
pair_coeff    * *  M3GNet-MP-2021.2.8-PES  Zr O
-----
3. lmp_serial -in inp.lammps
4. Drag and drop "xyz.lammpstrj" to Octa.

Note: GPU version of M3GNet is failed.
dgl._ffi.base.DGLError: [22:53:32] /opt/dgl/src/array/array.cc:42: Operator Range does not support cuda device.
ERROR: Cannot calculate energy, forces and stress by python of M3GNet. (../pair_m3gnet.cpp:693)
