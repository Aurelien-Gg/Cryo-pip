# CTFfind Guide

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A guide for using CTFfind4 and CTFfind5 on the cluster installation.

## 📋 Table of Contents

- [Overview](#-overview)
- [Installation](#-installation)
- [Basic Usage](#-basic-usage)
- [Visualizing Results](#-visualizing-results)
- [Example Workflow](#-example-workflow)

## 🔍 Overview

This guide covers how to use CTFfind4 and CTFfind5 for contrast transfer function (CTF) estimation in cryo-electron microscopy.

## 💻 Installation

The CTFfind programs have already been added to the cluster and configured to work without loading any modules.

## 🚀 Basic Usage

### Running CTFfind

To run either version, simply type the appropriate command in your terminal:

```bash
Ctffind4
```

or

```bash
Ctffind5
```

### Input Parameters

The program will prompt you for several parameters:

- Values shown in square brackets `[default]` are the default values
- Press Enter to accept the default value, or type a new value

<details>
<summary>Click to see parameter prompt examples</summary>

```
Input image file path: [input.mrc]
Output file path: [your_output].mrc
Pixel size (Å): [1.0]
Voltage (kV): [300.0]
Spherical aberration (mm): [2.7]
Amplitude contrast: [0.1]
Size of power spectrum to compute (pixels): [512]
Minimum resolution (Å): [30.0]
Maximum resolution (Å): [5.0]
Minimum defocus value (Å): [5000.0]
Maximum defocus value (Å): [50000.0]
Defocus search step (Å): [500.0]
```

</details>

## 📊 Visualizing Results

After CTF estimation is complete, you can generate a PDF containing the CTF curves, fits, and quality metrics:

```bash
ctffind_plot_results.sh [your_output]_avrot.txt
```

This will create a PDF file named `[your_output]_avrot.pdf` in the same directory.

.

## 📝 Example Workflow

1. Run CTFfind:
   ```bash
   Ctffind5
   ```

2. Enter the requested parameters (or accept [defaults] by leaving empty)

![image](https://github.com/user-attachments/assets/839085c4-209e-478c-9d9f-dd6d900357c6)

3. Wait for CTF estimation to complete ( < 1 min)
   
4. Check for the terminal output message:
   ```
   Use this command to plot 1D fit profiles: ctffind_plot_results.sh Position_1_2_stack_output_avrot.txt
   ```
![image](https://github.com/user-attachments/assets/82670a44-e7ce-400e-a1fc-856b9b8620f0)

5. Generate visualization:
   ```bash
   ctffind_plot_results.sh Position_1_2_stack_output_avrot.txt
   ```

6. View the resulting PDF file which shows:
   - CTF curves
   - Fitted parameters
   - Quality of fit metrics

![image](https://github.com/user-attachments/assets/2a0fe33f-9717-43ae-bf0f-f65a26a67a3e)


## 📚 References

- [CTFfind4 Paper](https://doi.org/10.1016/j.jsb.2015.08.008)
- [Official Documentation](https://grigoriefflab.umassmed.edu/ctffind4)

---

*This guide was created for users of the cluster installation of CTFfind*
