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
MPI_DIR="/sw/ompi/$OMPI_VERSION"
UCX_DIR="/sw/ucx/$UCX_VERSION"


# Put Hyak versions of MPI/UCX first on $PATH / $LD_LIBRARY_PATH in container
export APPTAINERENV_PREPEND_PATH="$MPI_DIR/bin:$UCX_DIR/bin"
# This next line is some hackpants mchacker stuff, but essentially it is the same
# as the prepend path statment above, but for LD_LIBRARY_PATH, and allows
# executables starting on the container to find MPI shared libraries we are binding from
# the outside system.
#
# See here for more discussion and where the workaround was found:
# https://github.com/apptainer/singularity/issues/5781
#
# IMHO there ought to be APPTAINERENV_PREPEND_LD_LIBRARY_PATH, but if you look at
# implementation of APPTAINERENV_PREPEND_PATH at time of writing the bypass on
# apptainer's end is specific only to PATH, and is somewhat awkward to generalize.
export APPTAINERENV_LD_LIBRARY_PATH="$MPI_DIR/lib:$UCX_DIR/lib:\$LD_LIBRARY_PATH"


# The apptainer that binds OMPI and UCX
apptainer_cmd="apptainer run --bind $MPI_DIR:$MPI_DIR:ro,$UCX_DIR:$UCX_DIR:ro apptainer.sif" 

echo "In-Container PATH and LD_LIBRARY_PATH"
${apptainer_cmd} env | grep -e '^PATH' -e '^LD_LIBRARY_PATH'

# Disabling CUDA so it is not in the log. mpitest commands should not need it
#export OMPI_MCA_mpi_cuda_support=0

# Try commenting this in/out to reproduce the two crashes
#
# I found this as a 'solution' on the internet to apptainer and the MPI_Init crash
# but it just causes a different crash in the broadcast test
#export UCX_POSIX_USE_PROC_LINK=n


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
echo "In-Container ldd output for Rocky compiled osu_hello"
${apptainer_cmd} ldd /usr/lib64/openmpi/bin/mpitests-osu_hello | sed -e '1,8d'

echo "In-Container ldd output for Rocky compiled osu_bcast"
${apptainer_cmd} ldd /usr/lib64/openmpi/bin/mpitests-osu_bcast | sed -e '1,8d'

echo "Running Rocky-compiled versions of osu_hello and osu_bcast"
# When the MPI_Init crash happens, both commands should fail.
mpirun -np $SLURM_NTASKS ${apptainer_cmd} mpitests-osu_hello

# When the MPI_Bcast crash happens, only this command fails
mpirun -np $SLURM_NTASKS ${apptainer_cmd} mpitests-osu_bcast


