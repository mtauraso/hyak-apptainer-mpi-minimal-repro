#!/bin/bash
#BATCH --job-name=appt-mpi
#SBATCH --mail-type=NONE
#SBATCH --mail-user=mtauraso
#SBATCH --account=gwastro
#SBATCH --partition=compute
#
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=2
# SBATCH --mem-per-node=8G
#
#Don't move any environment variables into slurm-land
#SBATCH --export=NONE
#
# 5 minute timeout
#SBATCH --time=00:05:00


#Load and bind MPI and UCX
OMPI_VERSION="4.1.1-2"
UCX_VERSION="1.10.0"
module load ompi/$OMPI_VERSION
module load ucx/$UCX_VERSION


mpirun -np $SLURM_NTASKS build//osu-micro-benchmarks-7.0.1-install/libexec/osu-micro-benchmarks/mpi/startup/osu_hello
mpirun -np $SLURM_NTASKS build//osu-micro-benchmarks-7.0.1-install/libexec/osu-micro-benchmarks/mpi/collective/osu_bcast

