#!/bin/bash
#SBATCH --job-name=blur_single
#SBATCH --output=blur_single_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=00:10:00

module load python/3.10.4

echo "Running single-node Gaussian blur test..."
time python3 blur_benchmark.py input_images output_single
