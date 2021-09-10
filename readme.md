## Getting started

### Prerequisite
- [FuseSoC](https://fusesoc.readthedocs.io/en/stable/user/installation.html#installation-under-linux)
- [SymbiYosys and Yosys](https://symbiyosys.readthedocs.io/en/latest/)
- [Verilator](https://verilator.org/guide/latest/install.html) 

The command below pulls all the necesary rtl packages.
```bash
git clone git@github.com:saw235/riscv-core-dev.git

cd riscv-core-dev

git checkout -b <my_feature_branch> 
fusesoc library add riscv-core-dev .
fusesoc library add pulp_common_cells https://github.com/pulp-platform/common_cells

```

### To run simulation

```
fusesoc run --target=sim riscv-sv
```