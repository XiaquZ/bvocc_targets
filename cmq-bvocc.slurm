#! /bin/bash
#SBATCH --job-name=cmq-Bvelocity
#SBATCH --ntasks=1 --cpus-per-task=10 --mem-per-cpu=6000mb
#SBATCH --time=30:35:00

source $VSC_HOME/.bashrc

conda activate VoCC_R_new

cd $VSC_DATA/bvocc_targets/

Rscript targets_run_cmq.R
