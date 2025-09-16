# IMOD on UNIL Cluster

How to use IMOD commands on cluster:

1. Add IMOD singularity path to the end of your bashrc file (this only needs to be done once)

```echo 'export PATH="/work/FAC/FBM/DMF/pnavarr1/default/Aurelien/IMOD/imod_singularity/:$PATH"' >> ~/.bashrc && source ~/.bashrc```

2. Load necessary module and software pack (everytime you log in to the cluster)

```module load apptainer```

```dcsrsoft use 20241118```


You can now use IMOD commands in the following way:

```imod 3dmod /path/to/my/mrc/file.mrc```  (example)


generate_images:

# Generate Images Script - Usage Guide

## Overview

The `generate_images` script is a tool for generating images & gifs of raw, pre-aligned, aligned, and reconstructed tomograms, and plots of alignment residuals (nm) and defocus estimation (nm).

## Syntax

```bash
generate_images <ts_basename> [folder_path] [image_size]
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `ts_basename` | ✅ Yes | - | Base name of the tilt series (without file extensions) |
| `folder_path` | ❌ No | `.` (current directory) | Path to the folder containing the data files |
| `image_size` | ❌ No | `1024` | Target size for image resizing (pixels) |

## Usage Examples

```bash
# Basic usage - process files in current directory
generate_images Position_1

# Specify folder and custom image size
generate_images Position_1 /path/to/data 512
```

## Input Files

The script automatically searches for and processes the following files:

| File Pattern | Description |
|--------------|-------------|
| `align.log` | Alignment log file containing residual values |
| `{basename}.defocus` | Defocus values for each tilt image |
| `{basename}.mrc` | Raw tilt series stack |
| `{basename}_preali.mrc` | Pre-aligned tilt series stack |
| `{basename}_ali.mrc` | Aligned tilt series stack |
| `{basename}*_rec*.mrc` | Reconstruction/tomogram files |

## Output Files Generated

### 1. Alignment and Defocus Plots
- `{basename}_alignment_plot.png` - Plot of alignment residuals vs. image view
- `{basename}_defocus_plot.png` - Plot of defocus values vs. image view

### 2. Animated GIFs (Tilt Series)
- `{basename}.gif` - Animation from raw tilt series
- `{basename}_preali.gif` - Animation from pre-aligned tilt series
- `{basename}_ali.gif` - Animation from aligned tilt series

### 3. Representative Images
- `{basename}_middle.jpg` - Middle image from raw tilt series
- `{basename}_preali_middle.jpg` - Middle image from pre-aligned series
- `{basename}_ali_middle.jpg` - Middle image from aligned series

### 4. Tomogram Slices
- `{basename}*_rec*_middle.jpg` - Middle slice from each reconstruction file

## File Location

- All output files are generated in the specified folder path
- Original input files are never modified
