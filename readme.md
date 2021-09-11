## Getting started

### Prerequisite
- [FuseSoC](https://fusesoc.readthedocs.io/en/stable/user/installation.html#installation-under-linux)
- [SymbiYosys and Yosys](https://symbiyosys.readthedocs.io/en/latest/)
- [Verilator](https://verilator.org/guide/latest/install.html) 
- [sv2v](https://github.com/saw235/sv2v)

The command below pulls all the necesary rtl packages.
```bash
git clone git@github.com:saw235/riscv-core-dev.git

cd riscv-core-dev

git checkout -b <my_feature_branch> 
fusesoc library add riscv-core-dev .
fusesoc library add pulp_common_cells https://github.com/pulp-platform/common_cells

```

### To run simulation or formal

```
fusesoc run --target=sim riscv-sv
fusesoc run --target=formal riscv-sv

```

### To contribute to microarchitecture
1. Send an email to this [address](sawxuezheng01@gmail.com) titled "uarch contrb request" and I will share with you the link to the folder which host all the drawio files.
2. The updated microarchitecture in SVG format should be located in the `doc/uarch` folder.
3. Pull/merge request related to the microarchitecture should be tagged with the keyword *UARCH*. For example "UARCH - Bitmanip Extension" or "UARCH - FPU"      
