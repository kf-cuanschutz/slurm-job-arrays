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
#SBATCH --mail-user=lauren.vanderlindeno@cuanschutz.edu
#SBATCH --array=1-72 #Call for the job array with 72 indexes representing each job for the 72 samples 


export TMP=/gpfs/alpine1/scratch/$USER/cache_dir
export TEMP=$TMP
export TMPDIR=$TMP
export TEMPDIR=$TMP
export PIP_CACHE_DIR=$TMP
mkdir -pv $TMP

module load anaconda
conda activate cellbender

if [[ $SLURM_ARRAY_TASK_ID -lt 10 ]];then
        
	echo "The Slurm array taskID is less than 10 and is ${SLURM_ARRAY_TASK_ID}"
	export tmp_PatientID=$SLURM_ARRAY_TASK_ID
        export PatientID="0$tmp_PatientID"
else
	echo "The Slurm array taskID is greater than 10 and is ${SLURM_ARRAY_TASK_ID}"
        export PatientID=$SLURM_ARRAY_TASK_ID

fi

# Each $SLURM_ARRAY_TASK_ID represents an  ARA08_ number
# Create the sample name (e.g., ARA08_01, ARA08_02...)
SAMPLE="ARA08_${PatientID}"
# Create a directory for each sample
mkdir $SAMPLE
# Run cellbender remove-background for each sample
cellbender remove-background \
       --cuda \
       --fpr 0.1 \
       --input /pl/active/foolab/shared/ACE_ARA08/03_Assay_Data/CITEseq/$SAMPLE/outs/multi/count/raw_feature_bc_matrix.h5 \
       --output $SAMPLE/output.h5

~
