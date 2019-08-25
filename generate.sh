#!/usr/bin/env bash
#SBATCH --job-name=FinalProject
#SBATCH--partition=slurm_shortgpu
#SBATCH --gres=gpu:1
#SBATCH --time=0-0:10:00

./generate 
