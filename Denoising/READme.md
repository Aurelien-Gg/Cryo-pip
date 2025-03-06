# ddw_cc.py

A pipeline tool supporting CryoCARE and DeepDeWedge denoising for cryo-EM data.

## Basic Usage

```ddw_cc.py [OPTIONS]```
```ddw_cc.py --help```

Use `--help` to see all available options.

## Workflows

The pipeline supports three main workflows, each with its own set of required parameters:

### 1. Starting from Raw Data (.mdoc and .mrc)

#### Required Parameters:
- `--mdoc (-m)`: Path to .mdoc file
- `--mrc  (-r)`: Path to original stack (.mrc). The files eraser.com, newst.com, tilt.com, .xf, .tlt, .xtilt must be in the same folder
- `--gain (-g)`: Path to gain reference file (optional, will be auto-detected if possible)

#### Denoising Parameters:
- `--cryocare    (-cc)`: Use CryoCARE denoising
- `--deepdewedge (-dd)`: Use DeepDeWedge denoising

#### Example:

```ddw_cc.py -m /path/to/data.mdoc -r /path/to/stack.mrc -cc```

Output will be located in original stack (`--mrc`) folder.

### 2. Starting from Even & Odd Stacks

#### Required Parameters:
- `--evenstack (-es)`: Path to even stack (.mrc)
- `--oddstack  (-os)`: Path to odd stack (.mrc)
- `--mrc       (-r)` : Path to original stack (.mrc)

#### Example:

```ddw_cc.py -es /path/to/even.mrc -os /path/to/odd.mrc -r /path/to/stack.mrc -dd```

Output will be located in original stack (`--mrc`) folder.

### 3. Starting from Even & Odd Tomograms

#### Required Parameters:
- `--even (-et)`: Path to even tomogram (.mrc)
- `--odd (-ot)`: Path to odd tomogram (.mrc)
- `--output (-out)`: Output directory path. Will be created if doesn't exist. If CryoCARE or DeepDeWedge folder already exist, will create new with _# appended to foldername.

## Workflow Examples ##

#### Example 1: Full Pipeline from Raw Data with CryoCARE ####
```
ddw_cc.py \
    --mdoc /path/to/tilt.mdoc \
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

#### Example 2: DeepDeWedge Denoising on Existing Tomograms ####

```
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

# Options # 
### General Parameters ### 

```markdown
| Parameter    | Alias  | Description                         | Default                         |
|--------------|--------|-------------------------------------|---------------------------------|
| `--output`   | `-out` | Output directory                    | None                            |
| `--epochs`   | `-ep`  | Number of epochs for training       | 100 (CryoCARE), 200 (DeepDeWedge) |
| `--binning`  | `-b`   | Binning factor for denoising input  | 1                               |
```

### CryoCARE Specific Parameters### 

```markdown
| Parameter  | Alias | Description                  | Default |
|------------|-------|------------------------------|---------|
| `--steps`  | `-s`  | Steps per epoch for training | 200     |
```

### DeepDeWedge Specific Parameters### 

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
