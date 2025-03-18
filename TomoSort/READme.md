# 🧬 TomoSort

A streamlined tool for organizing and processing cryo-electron tomography data files with automated workflow.

## 📋 Overview

TomoSort is a script that automatically organizes your tomography data files (`.mdoc`, `.eer`, `.gain`) into a well-structured directory hierarchy and optionally submits alignment jobs to the SLURM scheduler. It eliminates the tedious manual organization steps in your tomography processing pipeline!

## ✨ Features

- **📊 Automatic File Organization**: Intelligently sorts `.mdoc` and `.eer` files into appropriate directories
- **📁 Directory Structure Creation**: Creates all necessary subdirectories for a smooth tomography workflow
- **🚀 SLURM Integration**: Seamlessly submits alignment jobs to the cluster
- **🔍 CTF Processing**: Optional CTF parameter estimation using CTFfind4
- **🔧 IMOD Integration**: Sets up files for efficient batch processing with BatchRunTomo

## 💻 Usage

Basic usage:

```bash
TomoSort.sh /path/to/data
```

With alignframes processing:

```bash
TomoSort.sh /path/to/data -alignframes "alignframes [options]"
```

With CTF processing enabled (-CTF flag must be written before -alignframes flag):

```bash
TomoSort.sh /path/to/data -CTF -alignframes "alignframes [options]"
```

## 🗂️ Directory Structure

For each `.mdoc` file, the script creates a clean organization:

```
/data_path/mdoc_rootname/
├── frames/           # 📊 Raw .eer files
├── CTFfind/          # 🔍 CTF estimation results
├── IMOD/             # 🔄 Pre-aligned stacks and reconstruction data
└── CryoCARE/         # ✨ Folder for denoising
```

## 🔄 Workflow

1. 📥 Place your `.mdoc`, `.eer`, and `.gain` files in a single directory
2. 🚀 Run the script on that directory
3. 🔧 The script organizes files and optionally submits processing jobs
4. 📈 Results will be available in the created directory structure

## ⚙️ Advanced Options

- **`-CTF`**: 🔬 Enables CTF estimation with CTFfind4 after alignment
- **`-alignframes`**: 🛠️ Specifies command-line options for IMOD's alignframes program. Pixel size is determined automotically from .mdoc header. Gain reference files is detected automatically or can be specified

## ✅ Requirements

No installation required! 🎉 This tool is designed to work directly on your lab's computing environment without any setup.

## 📝 Notes

- The script requires access to IMOD, Apptainer, and CTFfind4 modules (pre-configured in your lab environment)
- Processing uses the configured template `/work/FAC/FBM/DMF/pnavarr1/default/tools/AurelienTemplate241024.adoc`
- Gain reference files are detected automatically or can be specified in the alignframes command

---

🌟 **Happy tomography processing!** 🌟
