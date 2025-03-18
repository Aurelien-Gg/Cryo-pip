# TomoSort

A file organization and processing tool for electron tomography data. Automatically sorts .mdoc and .eer files into appropriate directories and optionally submits alignment jobs to the SLURM scheduler.

## Features

- Automatically organizes tomography data files into a structured directory hierarchy
- Handles gain reference files for image correction
- Creates appropriate directory structures for each dataset
- Prepares and submits alignframes jobs with customized parameters
- Optional CTF processing integration
- Compatible with IMOD batch processing

## Overview

TomoSort was developed to streamline the organization and initial processing of tomography data. It eliminates the tedious manual file sorting and allows for immediate processing by:

1. Creating organized directories for each tomogram
2. Moving .mdoc and associated .eer files to appropriate locations
3. Setting up SLURM jobs for alignframes and initial tomogram reconstruction

## Usage

```bash
./TomoSort.sh /path/to/data [-CTF] [-alignframes alignframes_command]
