# Minimal reproduce setup for Apptainer Slurm errors

To reproduce REQ6697004, run the following, ensuring your working directory is the root of your git checkout.

1. On a hyak compute node `build_apptainer.sh` will generate the `apptainer.sif` file

1. On klone `sbatch runme.slurm` will trigger the bug

Editing the final lines of runme.slurm will allow you to trigger both crashes.

