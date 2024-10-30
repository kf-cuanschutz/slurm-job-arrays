#!/bin/bash

#SBATCH --nodes=1 # Number of nodes or computers. Should always be 1 for now.
#SBATCH --ntasks=10 # Number of CPU cores. As you request more CPU cores, you are also getting more CPU memory. You have about 3.8G per core
#SBATCH --time=03:00:00 # Walltime
#SBATCH --partition=aa100 # This is the name of the NVIDIA GPU partition. Made of nodes containing 3x A100 gpus.
#SBATCH --gres=gpu:1 # Here we are requesting 1 gpu
#SBATCH --job-name=cellbender_gpu # Name of the job that will be submitted.
#SBATCH --output=cellbender_gpu.%j.out # Name of the file where all the benign outputs and logs related to the run will be redirected. %j is the variable that will capture the jobID
#SBATCH --error=cellbender_gpu.%j.err # Name of the file where all the errors related to the run will be redirected.
#SBATCH --mail-type=BEGIN,FAIL,END #  I get the Slurm notification in my email inbox when it begins, ends and fails.
# Whom to send the email to
#SBATCH --mail-user=foo.foo@cuanschutz.edu # My email address where I wish to get all the notifications.
#SBATCH --array=1-72 # Call for the job array with 72 indexes representing each job for the 72 samples 

# /home filesystem is very small so we need to redirect tmp and cache related files to 
# the scratch filesystem.
export TMP=/gpfs/alpine1/scratch/$USER/cache_dir
export TEMP=$TMP
export TMPDIR=$TMP
export TEMPDIR=$TMP
export PIP_CACHE_DIR=$TMP
mkdir -pv $TMP

# Loading my anaconda module and activating my conda ENV
module load anaconda
conda activate cellbender


# Exporting the sampleID with SLURM_ARRAY_TASK_ID.
echo "The Slurm array taskID is ${SLURM_ARRAY_TASK_ID}"
export PatientID=$SLURM_ARRAY_TASK_ID

# Each $SLURM_ARRAY_TASK_ID represents an  RESULT_ number
# Create the sample name (e.g., RESULT_01, RESULT_02...)
SAMPLE="RESULT_${PatientID}"
# Create a directory for each sample
mkdir $SAMPLE
# Run cellbender remove-background for each sample
cellbender remove-background \
       --cuda \
       --fpr 0.1 \
       --input /pl/active/foolab/shared/$SAMPLE/raw_feature_bc_matrix.h5 \
       --output $SAMPLE/output.h5

~
