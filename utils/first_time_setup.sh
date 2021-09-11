#!/bin/bash
sudo apt-get -y install git perl python3 make autoconf g++ flex bison ccache
sudo apt-get -y install libgoogle-perftools-dev numactl perl-doc
sudo apt-get -y install libfl2  # Ubuntu only (ignore if gives error)
sudo apt-get -y install libfl-dev  # Ubuntu only (ignore if gives error)
sudo apt-get -y install zlibc zlib1g zlib1g-dev  # Ubuntu only (ignore if gives error)


git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make -j$(nproc)
make install

cd ..

git clone https://github.com/YosysHQ/SymbiYosys.git SymbiYosys
cd SymbiYosys
make install

cd ..

git clone https://github.com/SRI-CSL/yices2.git yices2
cd yices2
autoconf
./configure
make -j$(nproc)
make install

cd ..

git clone https://github.com/Z3Prover/z3.git z3
cd z3
python scripts/mk_make.py
cd build
make -j$(nproc)
make install

cd ../..

git clone https://bitbucket.org/arieg/extavy.git
cd extavy
git submodule update --init
mkdir build; cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
cp avy/src/{avy,avybmc} /usr/local/bin/

cd ../..

git clone https://github.com/boolector/boolector
cd boolector
./contrib/setup-btor2tools.sh
./contrib/setup-lingeling.sh
./configure.sh
make -C build -j$(nproc)
cp build/bin/{boolector,btor*} /usr/local/bin/
cp deps/btor2tools/bin/btorsim /usr/local/bin/

cd ..

git clone https://github.com/verilator/verilator   # Only first time

# Every time you need to build:
unsetenv VERILATOR_ROOT  # For csh; ignore error if on bash
unset VERILATOR_ROOT  # For bash
cd verilator
git pull        # Make sure git repository is up-to-date
git tag         # See what versions exist
#git checkout master      # Use development branch (e.g. recent bug fixes)
#git checkout stable      # Use most recent stable release
#git checkout v{version}  # Switch to specified release version

autoconf        # Create ./configure script
./configure     # Configure and create Makefile
make -j         # Build Verilator itself
sudo make install