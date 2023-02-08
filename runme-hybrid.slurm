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


#Load MPI and UCX that match the container as close as possible
OMPI_VERSION="4.1.1-2"
UCX_VERSION="1.10.0"
module load ompi/$OMPI_VERSION
module load ucx/$UCX_VERSION
MPI_DIR="/sw/ompi/$OMPI_VERSION"
UCX_DIR="/sw/ucx/$UCX_VERSION"


# Command to run the apptainer
apptainer_cmd="apptainer run apptainer.sif" 

# Check on in-container environment before we do anything
echo "In-Container PATH and LD_LIBRARY_PATH"
${apptainer_cmd} env | grep -e '^PATH' -e '^LD_LIBRARY_PATH'

# Commands to check LD library path and then run the Hyak-compiled
# mpi test commands

#Check ldd for both of these executables just to make sure loading is working
echo "In-Container ldd output for hyak compiled osu_hello"
${apptainer_cmd} ldd /opt/ompitest-install/bin/osu_hello | sed -e '1,8d'

echo "In-Container ldd output for hyak compiled osu_bcast"
${apptainer_cmd} ldd /opt/ompitest-install/bin/osu_bcast | sed -e '1,8d'

echo "Running Hyak-compiled versions of osu_hello and osu_bcast"
# When the MPI_Init crash happens, both commands should fail.
mpirun -np $SLURM_NTASKS ${apptainer_cmd} /opt/ompitest-install/bin/osu_hello

# When the MPI_Bcast crash happens, only this command fails
mpirun -np $SLURM_NTASKS ${apptainer_cmd} /opt/ompitest-install/bin/osu_bcast


#Check ldd for both of these executables just to make sure loading is working
echo "In-Container ldd output for rocky compiled osu_hello"
${apptainer_cmd} ldd /usr/lib64/openmpi/bin/mpitests-osu_hello | sed -e '1,8d'

echo "In-Container ldd output for rocky compiled osu_bcast"
${apptainer_cmd} ldd /usr/lib64/openmpi/bin/mpitests-osu_bcast | sed -e '1,8d'

echo "Running Rocky compiled osu_hello and osu_bcast"
# When the MPI_Init crash happens, both commands should fail.
mpirun -np $SLURM_NTASKS ${apptainer_cmd} /usr/lib64/openmpi/bin/mpitests-osu_hello

# When the MPI_Bcast crash happens, only this command fails
mpirun -np $SLURM_NTASKS ${apptainer_cmd} /usr/lib64/openmpi/bin/mpitests-osu_bcast

