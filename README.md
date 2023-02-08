# Minimal reproduce setup for Apptainer Slurm errors

To reproduce REQ6697004, run the following, ensuring your working directory is the root of your git checkout.

1. Before you start examine the version numbers in `apptainer.def`, and all of the `runme-*.slurm` files. Versions for OMPI and UCX should substantially match. A good cross-check here is `module avail ompi` and `module avail ucx`

1. On a hyak compute node `./build_mpitests.sh` will download the mpi tests and compile them in `/build` This is necessary to do before constructing the apptainer. You can check this worked by running `sbatch runme-bare.slurm` from klone, which will run the newly-built `osu_hello` and `osu_bcast` tests without any apptainer.

1. On a hyak compute node `build_apptainer.sh` will generate the `apptainer.sif` file, which has been constructed such that it will load in either hybrid or bind mode. The apptainer contains both mpi tests from Rocky and the ones built in the prior step. Hyak compiled are in `/opt/ompitest-install/bin/`. Rocky packaged are in `/usr/lib64/openmpi/bin/`

1. On klone `sbatch runme-hybrid.slurm` will try to run both versions of the ompi benchmarks in hybrid mode, along with some diagnostic checking of `LD_LIBRARY_PATH`/`PATH`/`ldd` inside the apptainer. `sbatch runme-bind.slurm` will do the same but in bind mode.

Editing the various `runme-*.slurm` allow runtime changes to MPI configuration

The `runme-*.log` files are logs of the same-named slurm files when I have tried to run them myself.

