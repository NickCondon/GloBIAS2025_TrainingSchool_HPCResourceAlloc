#!/usr/bin/env python3
import os, time, sys
from glob import glob
import numpy as np
from scipy.ndimage import gaussian_filter
from imageio import imwrite

def generate_test_data(outdir="input_images", n_images=100, size=(1024, 1024)):
    os.makedirs(outdir, exist_ok=True)
    for i in range(n_images):
        img = np.random.randint(0, 255, size, dtype=np.uint8)
        imwrite(os.path.join(outdir, f"img_{i:04d}.tif"), img)
    print(f"Generated {n_images} images in {outdir}")

def process_images(input_dir, output_dir, sigma=2):
    os.makedirs(output_dir, exist_ok=True)
    images = sorted(glob(os.path.join(input_dir, "*.tif")))
    start = time.time()
    for img_path in images:
        img = np.asarray(np.loadtxt(img_path, dtype=np.uint8)) if img_path.endswith(".txt") else None
        if img is None:
            import imageio
            img = imageio.imread(img_path)
        result = gaussian_filter(img, sigma)
        imwrite(os.path.join(output_dir, os.path.basename(img_path)), result)
    end = time.time()
    print(f"Processed {len(images)} images in {end - start:.2f} seconds")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: blur_benchmark.py <input_dir> <output_dir> [sigma]")
        sys.exit(1)

    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    sigma = float(sys.argv[3]) if len(sys.argv) > 3 else 2
    process_images(input_dir, output_dir, sigma)
