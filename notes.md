## Getting started

### Prerequisite
- [FuseSoC](https://fusesoc.readthedocs.io/en/stable/user/installation.html#installation-under-linux)
- [SymbiYosys and Yosys](https://symbiyosys.readthedocs.io/en/latest/)
- [Verilator](https://verilator.org/guide/latest/install.html) 

```bash
git clone git@github.com:saw235/riscv-core-dev.git

cd riscv-core-dev

git checkout -b <my_feature_branch> 
fusesoc library add riscv-core-dev .

```

## Instruction to be implemented

### Mem related
LUI
AUIPC
JAL
JALR
BEQ
BNE
BLT
BGE
BLTU
BGEU
LB
LH
LW
LBU
LHU
SB
SH
SW

### ALU
ADDI
SLTI
SLTIU
XORI
ORI
ANDI
SLLI
SRLI
SRAI
ADD
SUB
SLL
SLT
SLTU
XOR
SRL
SRA
OR
AND

### Others
FENCE
FENCE.I
ECALL
EBREAK

### CSR
CSRRW
CSRRS
CSRRC
CSRRWI
CSRRSI
CSRRCI
