#!/bin/bash
#---------------Script SBATCH - NLHPC ----------------
#SBATCH -J HRR
#SBATCH -p general
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --mem-per-cpu=4250
#SBATCH --mail-user=digenova@gmail.com
#SBATCH --mail-type=ALL
#SBATCH -o HRR_%j.out
#SBATCH -e HRR_%j.err

#-----------------Toolchain---------------------------
# ----------------Modulos----------------------------
# ----------------Comando--------------------------


micromamba activate hrr_env

make -j 20 -f genome.mk all 
