import subprocess
import pytest

def test_verilator_lint():
    completed_process = subprocess.run(["fusesoc", "run", "--target=lint", "riscv-sv"], check=True)
    assert completed_process.returncode == 0

def test_formal_run():
    completed_process = subprocess.run(["fusesoc", "run", "--target=formal", "riscv-sv"], check=True)
    assert completed_process.returncode == 0