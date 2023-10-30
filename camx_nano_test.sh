#!/bin/bash

# set output and error output
#SBATCH --time 70:30:00
#SBATCH -o /lustre/groups/anenberggrp/srunkel/camx/camx_runs/camx.mpi.nyc.%j.out
#SBATCH -e /lustre/groups/anenberggrp/srunkel/camx/camx_runs/camx.mpi.nyc.%j.err

# default queue, single node
#SBATCH -p defq -n 128
# SBATCH --mail-user=sara.runkel@email.gwu.edu
# SBATCH --mail-type=ALL

#SBATCH -D /lustre/groups/anenberggrp/srunkel/camx/camx_runs
#SBATCH -J camx.mpi.nyc

module load gcc
module load intel/parallel_studio_xe/2019.3
module load netcdf-fortran/4.5.2
module load netcdf/4.6.1

# Create a file which contains the list of cpu-nodes allocated by slurm for running this job.
srun hostname > nodes

csh CAMx_ifort.run.job
