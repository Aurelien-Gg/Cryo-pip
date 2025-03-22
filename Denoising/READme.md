# 🧬 DDW_CC: CryoCARE & DeepDeWedge Pipeline Tool

A comprehensive pipeline tool supporting CryoCARE and DeepDeWedge denoising for cryo-electron microscopy (cryo-EM) data. Streamlining your tomography workflow from raw data to denoised tomograms.

[![Python 3.8+](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![IMOD](https://img.shields.io/badge/IMOD-Compatible-green.svg)](https://bio3d.colorado.edu/imod/)
[![CryoCARE](https://img.shields.io/badge/CryoCARE-Supported-orange.svg)](https://github.com/juglab/cryoCARE)
[![DeepDeWedge](https://img.shields.io/badge/DeepDeWedge-Supported-red.svg)](https://github.com/deepdewedge)

## ✨ Features

- **Complete Pipeline**: Process data from raw .mdoc/.eer files all the way to denoised tomograms
- **Multiple Entry Points**: Start from raw data, stacks, or tomograms
- **Neural Network Denoising**: Integrated support for CryoCARE and DeepDeWedge algorithms
- **Interactive Mode**: User-friendly menu system for beginners
- **Command-line Interface**: For power users and scripting
- **SLURM Integration**: Automatically submits jobs to HPC environments

### 🌟 Quality of Life Improvements

- **Auto-detection**: Automatically finds gain reference files
- **Smart Validation**: Checks inputs before submitting jobs to avoid wasted compute time
- **Interactive Job Summary**: Clear overview of what will be processed
- **Tilt Angle Comparisons**: Identifies missing or problematic tilt angles
- **Tab Completion**: For file paths in interactive mode
- **Rich Terminal Output**: Color-coded progress and status updates
- **Flexible Output Naming**: Avoids overwriting existing data

## 🚀 Usage

```
ddw_cc.py [OPTIONS]
ddw_cc.py --help
```

Use `--help` to see all available options.

## 🧩 Workflows

The pipeline supports three main workflows, each with its own set of required parameters:

### 1. Starting from Raw Data (.mdoc and .mrc)

#### Required Parameters:
- `--mdoc (-m)`: Path to .mdoc file. Must be in same folder as .eer images
- `--mrc  (-r)`: Path to original stack (.mrc). The files eraser.com, newst.com, tilt.com, .xf, .tlt, .xtilt must be in the same folder
- `--gain (-g)`: Path to gain reference file (optional, will be auto-detected if possible)

#### Denoising Parameters:
- `--cryocare    (-cc)`: Use CryoCARE denoising
- `--deepdewedge (-dd)`: Use DeepDeWedge denoising

#### Example:

```bash
ddw_cc.py -m /path/to/stack.mdoc -r /path/to/stack.mrc -cc
```

Output will be located in original stack (`--mrc`) folder.

### 2. Starting from Even & Odd Stacks

#### Required Parameters:
- `--evenstack (-es)`: Path to even stack (.mrc)
- `--oddstack  (-os)`: Path to odd stack (.mrc)
- `--mrc       (-r)` : Path to original stack (.mrc). The files eraser.com, newst.com, tilt.com, .xf, .tlt, .xtilt must be in the same folder

#### Example:

```bash
ddw_cc.py -es /path/to/even.mrc -os /path/to/odd.mrc -r /path/to/stack.mrc -dd
```

Output will be located in original stack (`--mrc`) folder.

### 3. Starting from Even & Odd Tomograms

#### Required Parameters:
- `--even (-et)`: Path to even tomogram (.mrc)
- `--odd (-ot)`: Path to odd tomogram (.mrc)
- `--output (-out)`: Output directory path. Will be created if doesn't exist. If CryoCARE or DeepDeWedge folder already exist, will create new with _# appended to foldername.

## 📋 Detailed Workflow Examples

### Example 1: Full Pipeline from Raw Data with CryoCARE

```bash
ddw_cc.py \
    --mdoc /path/to/stack.mdoc \
    --mrc /path/to/stack.mrc \
    --cryocare \
    --epochs 150 \
    --steps 300 \
    --binning 2
```
    
This command will:
- Process raw data from .mdoc and .mrc files
- Create even and odd stacks and tomograms
- Apply CryoCARE denoising with 150 epochs and 300 steps per epoch
- Apply a binning factor of 2 to the tomograms before denoising

### Example 2: DeepDeWedge Denoising on Existing Tomograms

```bash
ddw_cc.py \
    --even /path/to/even_tomo_rec.mrc \
    --odd /path/to/odd_tomo_rec.mrc \
    --output /path/to/denoised \
    --deepdewedge \
    --boxsize 96 \
    --zstride 96 \
    --depth 4 \
    --nfirst 64 \
    --gpu "[0,1]" \
    --binning 2 \
    --ngpu 2
```

This command will:
- Use existing even and odd tomograms
- Apply DeepDeWedge denoising with custom parameters
- Use 2 GPUs (devices 0 and 1) for processing


## 📖 Options

![image](https://github.com/user-attachments/assets/1950b6cb-5ba6-4d5e-bc4b-4df47ed7fa22)

#### Reconstruction Parameters
```markdown
| Parameter     | Alias  | Description                                                   | Default |
|---------------|--------|---------------------------------------------------------------|---------|
| `--mdoc`      | `-m`   | Path to .mdoc file                                            | None    |
| `--gain`      | `-g`   | Path to gain reference file                                   | None    |
| `--mrc`       | `-r`   | Path to original stack (.mrc, where eraser, newst, tilt, .tlt, .xf, .xtilt are) | None    |
| `--evenstack` | `-es`  | Path to even stack (.mrc)                                     | None    |
| `--oddstack`  | `-os`  | Path to odd stack (.mrc)                                      | None    |
| `--even`      | `-et`  | Path to even tomogram (.mrc)                                  | None    |
| `--odd`       | `-ot`  | Path to odd tomogram (.mrc)                                   | None    |
``` 
#### Denoising Methods
```markdown
| Parameter      | Alias  | Description                    | Default |
|----------------|--------|--------------------------------|---------|
| `--cryocare`   | `-cc`  | Use CryoCARE denoising         | False   |
| `--deepdewedge`| `-dd`  | Use DeepDeWedge denoising      | False   |
```
#### General Parameters
```markdown
| Parameter      | Alias  | Description                         | Default                         |
|----------------|--------|-------------------------------------|---------------------------------|
| `--output`     | `-out` | Output directory                    | None                            |
| `--epochs`     | `-ep`  | Number of epochs for training       | 100 (CryoCARE), 200 (DeepDeWedge) |
| `--binning`    | `-b`   | Binning factor for denoising input  | 1                               |
```
#### CryoCARE Specific Parameters
```markdown
| Parameter      | Alias | Description                  | Default |
|----------------|-------|------------------------------|---------|
| `--steps`      | `-s`  | Steps per epoch for training | 200     |
```
#### DeepDeWedge Specific Parameters
```markdown
| Parameter          | Alias  | Description                                              | Default |
|--------------------|--------|----------------------------------------------------------|---------|
| `--mask`           | N/A    | Binary mask for subtomogram extraction                   | None    |
| `--boxsize`        | `-box` | Box size in pixels                                       | 72      |
| `--zstride`        | `-z`   | Z interval to sample subtomograms                        | 72      |
| `--splitval`       | `-sp`  | Fraction of subtomograms for validation                  | 0.1     |
| `--mwangle`        | `-mw`  | Width of missing wedge in degrees                        | 70.0    |
| `--depth`          | `-dep` | Depth of neural network                                  | 3       |
| `--nfirst`         | `-nf`  | Number of initial feature channels                       | 32      |
| `--batch`          | N/A    | Number of subtomograms per batch                         | 5       |
| `--nworkers`       | N/A    | Number of data loading workers                           | 8       |
| `--dropprob`       | N/A    | Dropout probability                                      | 0.0     |
| `--seed`           | N/A    | Random seed                                              | 42      |
| `--skiptraining`   | N/A    | Skip training phase ("y" or "n")                         | "n"     |
| `--skipprediction` | N/A    | Skip prediction phase ("y" or "n")                       | "n"     |
| `--bytes`          | N/A    | Convert output to bytes to save space ("y" or "n")       | "n"     |
```
