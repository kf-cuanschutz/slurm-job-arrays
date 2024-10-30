#!/bin/bash

#SBATCH --nodes=1 # Number of nodes or computers. Should always be 1 for now.
#SBATCH --ntasks=10 # Number of CPU cores. As you request more CPU cores, you are also getting more CPU memory. You have about 3.8G per core
#SBATCH --time=03:00:00 # Walltime
#SBATCH --partition=aa100 # This is the name of the NVIDIA GPU partition. Made of nodes containing 3x A100 gpus.
#SBATCH --gres=gpu:1 # Here we are requesting 1 gpu
#SBATCH --job-name=cellbender_gpu # Name of the job that will be submitted.
#SBATCH --output=cellbender_gpu.%j.out
#SBATCH --error=cellbender_gpu.%j.err
#SBATCH --mail-type=BEGIN,FAIL,END # Feel free to change it.
# Whom to send the email to
#SBATCH --mail-user=foo.foo@cuanschutz.edu

export TMP=/gpfs/alpine1/scratch/$USER/cache_dir
export TEMP=$TMP
export TMPDIR=$TMP
export TEMPDIR=$TMP
export PIP_CACHE_DIR=$TMP
mkdir -pv $TMP

module load anaconda
conda activate cellbender


#bash cellBender_loop.sh

# Loop through samples from ARA08_01 to ARA08_72
for i in {01..72}
do
    # Create the sample name (e.g., ARA08_01, ARA08_02...)
    SAMPLE="ARA08_${i}"
    # Create a directory for each sample
    mkdir $SAMPLE
    # Run cellbender remove-background for each sample
    cellbender remove-background \
        --cuda \
        --fpr 0.1 \
        --input /pl/active/foolab/shared/ACE_ARA08/03_Assay_Data/CITEseq/$SAMPLE/outs/multi/count/raw_feature_bc_matrix.h5 \
        --output $SAMPLE/output.h5
done
