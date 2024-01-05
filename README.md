# Steps to setting up CAMx on Pegasus							#

## Step 1. Download CAMX

#### From the command line:
	cd /GWSPH/groups/anenberggrp/camx_mpi
	wget https://camx-wp.azurewebsites.net/getmedia/CAMx_v7.20.src.220430.tgz
	wget https://camx-wp.azurewebsites.net/getmedia/v7.20.specific.inputs.220430.tgz

	tar -xvzf CAMx_v7.20.src.220430.tgz
	tar -xvzf v7.20.specific.inputs.220430.tgz

## Step 2. Download test files

#### From the command line:
	cd /GWSPH/groups/anenberggrp/camx_mpi/test/
	wget https://camx-wp.azurewebsites.net/getmedia/CAMx7-20-test_run-inputs_met-220616.tgz
	wget https://camx-wp.azurewebsites.net/getmedia/CAMx7-20-test_run-inputs_emiss-220616.tgz
	wget https://camx-wp.azurewebsites.net/getmedia/CAMx7-20-test_run-inputs_other-220616.tgz
	wget https://camx-wp.azurewebsites.net/getmedia/CAMx7-20-test_run-outputs-Intel_compiler-220616.tgz
	wget https://camx-wp.azurewebsites.net/getmedia/v7.20.specific.inputs.220430.tgz

	tar -xvzf CAMx7-20-test_run-inputs_emiss-220616.tgz
	tar -xvzf CAMx7-20-test_run-inputs_met-220616.tgz
	tar -xvzf CAMx7-20-test_run-inputs_other-220616.tgz
	tar -xvzf CAMx7-20-test_run-outputs-Intel_compiler-220616.tgz
	tar -xvzf v7.20.specific.inputs.220430.tgz

## Step 3. Compile MPICH3

### Download MPICH3 source code 

#### Veronica installed this on her home directory because she was getting an error that couldn't compile something on the shared directory. There is a version now in the shared directory /GWSPH/groups/anenberggroup/camx_mpi/mpich-3.0.4

	cd /GWSPH/home/vtinney/mpi
	wget https://www.mpich.org/static/downloads/3.0.4/mpich-3.0.4.tar.gz

#### From the command line:
	module load gcc
	module load intel/parallel_studio_xe/2019.3
	module load netcdf-fortran/4.5.2
	module load netcdf/4.6.1
	module load mpiexec/0.84_432
	csh
	setenv FC ifort
	setenv CC gcc

	setenv FC ifort
	
	tar xvzf mpich-3.0.4.tar.gz
	cd mpich-3.0.4
	unset F90
	unset F90FLAGS
	setenv FC ifort
	./configure --prefix= /YOUR/INSTALL/DIRECTORY/
	make
	make install

### Verify that libraries and executables were built

	ls -l /YOUR/INSTALL/DIRECTORY/lib/libmpich.a
	ls -l /YOUR/INSTALL/DIRECTORY/lib/libmpl.a
	ls -l /YOUR/INSTALL/DIRECTORY/bin/mpiexec


## Step 4. Load required packages

#### In the new folder created as a result of unzipping the camx model (this version called CAMXv7.20), there will be a makefile. You need to update the makefile to ensure the references to the MPI and netcdf match the versions of those dependencies that are set up on pegasus. 

#### From the command line:
	cd /GWSPH/groups/anenberggrp/camx_mpi/CAMxv7.20

#### Load the dependencies before compilation. Here, I am going to use the mpich for MPI and netcdf 4.6.1, which should link to netcdf fortran, so load that as well. The ifort compiler is available through the intel package.

#### From the command line:
	module load gcc
	module load intel/parallel_studio_xe/2019.3
	module load netcdf-fortran/4.5.2
	module load netcdf/4.6.1


## Step 5. Change the make file

#### Within the makefile in the /CAMx7.20 folder - You need to change the makefile to ensure it is linking to the packages you just loaded. Open the make file and change the following links towards the top of the makefile. You should also ensure that the netcdf packages are enabled with compression by changing the below links of code.

	MPI_INST = /GWSPH/home/vtinney/mpi
	NCF_INST = /c1/apps/netcdf/4.6.1

## Step 6. Compile CAMx
#### From within the /CAMXv7.20 folder in the command line run the following. It should take about 15 minutes

	cd /GWSPH/groups/anenberggrp/camx_mpi/CAMxv7.20
	make COMPILER=ifort NCF=NCF4_C MPI=mpich3

## Step 7. Edit the run file

### Once the compilation is complete, you will have a new file labeled according to the way the model was compiled. This you need to link to in your run file. In the test model runfiles folder, you need to change the following lines of code.

#### Run file: /GWSPH/groups/anenberggrp/camx_mpi/test/runfiles/CAMx_v7.20.36.12.20160610-11.MPICH3.job

### Change the following code to include the directories of the executable file and the test files. Currently the input files all live in the /GWSPH/groups/anenberggrp/camx_mpi/nyc and the outputs are saved onto lustre
	set EXEC      = "/GWSPH/groups/anenberggrp/camx_mpi/CAMxv7.20/CAMx.v7.20.MPICH3.NCF4.ifort"

	set RUN     = "v7.20.36.12"
	set ICBC    = "/GWSPH/groups/anenberggrp/camx_mpi/test/icbc"
	set INPUT   = "/GWSPH/groups/anenberggrp/camx_mpi/test/inputs"
	set MET     = "/GWSPH/groups/anenberggrp/camx_mpi/test/met"
	set EMIS    = "/GWSPH/groups/anenberggrp/camx_mpi/test/emiss"
	set PTSRCE  = "/GWSPH/groups/anenberggrp/camx_mpi/test/ptsrce"
	set OUTPUT  = "/GWSPH/groups/anenberggrp/camx_mpi/test/outputs"

#### Change the nodes code (to create nodes.txt) to the nodes you'll be using in your run. This is called the "-hostfile" name in the mpiexec code at the bottom of the runfile. Specify the name of the nodes you are going to allocate. Here I am allocating 4 nodes with one processor each from the debug partition.
	#  --- Create the nodes file ---
	#
	cat << ieof > nodes
	cpu001:1
	cpu002:1
	gpu013:1
	gpu014:1

#### Under "NUMPROCS" this is the number of processors you are allocating and is the sum of the processors (:1) for the nodes specified above.

	set NUMPROCS = 4


## Step 8. Specify the bash script - saved as "camx_mpi_test.sh"

#### Create the below bash script to run the test model with MPI. The nodes specified should match those that you specified in the runfile (CAMx_v7.20.36.12.20160610-11.MPICH3.job)

	#!/bin/bash

	# set output and error output
	#SBATCH --time 4:00:00
	#SBATCH -o /GWSPH/groups/anenberggrp/camx_mpi/test/runfiles/camx.mpi.test.%j.out
	#SBATCH -e /GWSPH/groups/anenberggrp/camx_mpi/test/runfiles/camx.mpi.test.%j.err

	# default queue, single node
	#SBATCH -p debug -N 4
	#SBATCH --mail-user=vtinney@gwu.edu
	#SBATCH --mail-type=ALL

	#SBATCH -D /GWSPH/groups/anenberggrp/camx_mpi/test/runfiles/
	#SBATCH -J camx.mpi.test

	module load gcc
	module load intel/parallel_studio_xe/2019.3
	module load netcdf-fortran/4.5.2
	module load netcdf/4.6.1

	csh CAMx_v7.20.36.12.20160610-11.MPICH3.job

## Step 9. Run the test model

#### From the command line:

	cd /GWSPH/groups/anenberggrp/camx_mpi/test
	sbatch camx_mpi_test.sh

