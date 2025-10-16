#!/bin/bash
#SBATCH --job-name=blur_array
#SBATCH --output=blur_array_%A_%a.log
#SBATCH --array=0-3
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=00:10:00

module load python/3.10.4

# Adjust paths
INPUT_DIR="input_images"
OUTPUT_DIR="output_array"
CHUNK_SIZE=125   # 500 images total / 4 jobs = 125 each

mkdir -p ${OUTPUT_DIR}

# Determine image subset for this job
START=$((SLURM_ARRAY_TASK_ID * CHUNK_SIZE))
END=$((START + CHUNK_SIZE))
TMP_INPUT="${INPUT_DIR}_subset_${SLURM_ARRAY_TASK_ID}"

mkdir -p $TMP_INPUT
ls ${INPUT_DIR}/*.tif | sed -n "$((START+1)),$((END))p" | xargs -I {} cp {} $TMP_INPUT/

echo "Processing subset ${SLURM_ARRAY_TASK_ID} from ${START} to ${END}"
time python3 blur_benchmark.py $TMP_INPUT ${OUTPUT_DIR}/part_${SLURM_ARRAY_TASK_ID}

# Clean up subset if desired
rm -rf $TMP_INPUT
