# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.194.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    python3-pip autoconf flex bison ccache \ 
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev zlibc zlib1g zlib1g-dev \ 
    build-essential clang libreadline-dev \
    gawk tcl-dev libffi-dev git mercurial graphviz \
    xdot pkg-config libftdi-dev gperf \
    libboost-program-options-dev libgmp-dev \
    cmake

RUN pip3 install --upgrade fusesoc

# Install verilator
RUN git clone https://github.com/verilator/verilator && \
    unset VERILATOR_ROOT && \
    cd verilator && \
    git pull && \
    autoconf && \
    ./configure && \
    make -j && \
    make install

# Install Yosys
RUN git clone https://github.com/YosysHQ/yosys.git yosys && \
    cd yosys && \
    make -j$(nproc) && \
    make install

# Install Symbiyosys
RUN git clone https://github.com/YosysHQ/SymbiYosys.git SymbiYosys && \
    cd SymbiYosys && \
    make install

# begin Install Formal Prover Dependencies
RUN git clone https://github.com/SRI-CSL/yices2.git yices2 && \
    cd yices2 && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install

RUN git clone https://github.com/Z3Prover/z3.git z3 && \
    cd z3 && \ 
    python scripts/mk_make.py && \ 
    cd build && \ 
    make -j$(nproc) && \ 
    make install

RUN git clone https://bitbucket.org/arieg/extavy.git && \
    cd extavy && \
    git submodule update --init && \
    mkdir build; cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    sudo cp avy/src/{avy,avybmc} /usr/local/bin/ 

RUN git clone https://github.com/boolector/boolector && \
    cd boolector && \
    ./contrib/setup-btor2tools.sh && \
    ./contrib/setup-lingeling.sh && \
    ./configure.sh && \
    make -C build -j$(nproc) && \
    sudo cp build/bin/{boolector,btor*} /usr/local/bin/ && \
    sudo cp deps/btor2tools/bin/btorsim /usr/local/bin/

# end Install Formal Prover Dependencies

RUN git clone https://github.com/zachjs/sv2v.git && \
    cd sv2v && \
    make