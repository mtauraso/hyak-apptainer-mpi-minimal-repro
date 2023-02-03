# Minimal reproduce setup for Apptainer Slurm errors

To get this started, run the following, ensuring your pwd is the root of your git checkout.

On a hyak compute node `build_apptainer.sh` will generate the `apptainer.sif` file

On klone `sbatch runme.slurm` will trigger the bug

Editing the final lines of runme.slurm will allow you to trigger both crashes.

