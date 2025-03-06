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
- `--mrc (-r)`: Path to original stack (.mrc). The files eraser.com, newst.com, tilt.com, .xf, .tlt, .xtilt must be in the same folder
- `--gain (-g)`: Path to gain reference file (optional, will be auto-detected if possible)

#### Denoising Parameters:
- `--cryocare (-cc)`: Use CryoCARE denoising
- `--deepdewedge (-dd)`: Use DeepDeWedge denoising

#### Example:

```ddw_cc.py -m /path/to/data.mdoc -r /path/to/stack.mrc -cc```

Output will be located in original stack (`--mrc`) folder.

### 2. Starting from Even & Odd Stacks

#### Required Parameters:
- `--evenstack (-es)`: Path to even stack (.mrc)
- `--oddstack (-os)`: Path to odd stack (.mrc)
- `--mrc (-r)`: Path to original stack (.mrc)

#### Example:

```ddw_cc.py -es /path/to/even.mrc -os /path/to/odd.mrc -r /path/to/stack.mrc -dd```

Output will be located in original stack (`--mrc`) folder.

### 3. Starting from Even & Odd Tomograms

#### Required Parameters:
- `--even (-et)`: Path to even tomogram (.mrc)
- `--odd (-ot)`: Path to odd tomogram (.mrc)
- `--output (-out)`: Output directory path. Will be created if doesn't exist. If CryoCARE or DeepDeWedge folder already exist, will create new with _# appended to foldername.

#### Example:

```ddw_cc.py -et /path/to/even_tomo_rec.mrc -ot /path/to/odd_tomo_rec.mrc -out /path/to/output -cc```

Output will be located in original stack (`--mrc`) folder.





