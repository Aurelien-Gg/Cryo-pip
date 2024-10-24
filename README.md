# Cryo-pip
Cryo-EM tomogram reconstruction and analysis pipeline

Table of contents:

[I just want to build a denoised Tomogram from my tilt series !!!](#Quick-guide)

[Install guide](#Install-guide)

[Getting Started](#Getting-started)

## Quick guide

Download all files in [/Code/](Code/), [/ConfigurationFiles/](ConfigurationFiles/), and [/CryoCARE/](CryoCARE/). Set them up like described in [Getting Started](#Getting-started) for best practice.

#### To get denoised Tomogram from tilt series:

  - Open Full_pipeline.m
  - Modify the necessary paths to fit your config
  - Execute the code
  - Follow instructions in [CryoCARE/Summary](CryoCARE/README.md)

#### To only get tomogram only using IMOD (no CryoCARE denoising)

  - Open IMOD_pipeline.m
  - Modify the necessary paths to fit your config
  - Execute the code

## Install guide
#### JAVA installation (needed to run Etomo GUI in IMOD)

Check if correct Java is installed:
```
java -version
```
You should see something close to:
>openjdk version "1.8.0_422"
>
>OpenJDK Runtime Environment (build 1.8.0_422-b05)
>
>OpenJDK 64-Bit Server VM (build 25.422-b05, mixed mode)

If not then install using (redhat):
```
sudo yum install java-1.8.0-openjdk
```

#### IMOD installation for Linux 

Download link (redhat): https://bio3d.colorado.edu/imod/AMD64-RHEL5/imod_4.11.25_RHEL7-64_CUDA10.1.sh

1. Go where file is downloaded, open Terminal window, and type
  ```
  imod_4.11.25_RHEL7-64_CUDA10.1.sh
  ```
2. You need to add IMOD to your PATH so that Linux can find the commands.

  - Open your .bashrc through Terminal window:
  ```
  nano ~/.bashrc
  ```
  - Add IMOD to your PATH: At the end of the file, add the following lines, replacing /path/to/IMOD with the actual path to your IMOD installation (type "which imod" in Terminal to get path):
  ```
  export IMOD_DIR=/path/to/IMOD
  export PATH=$PATH:$IMOD_DIR:$IMOD_DIR/bin
  ```
  - Apply the changes: After saving the file, either restart your terminal or run:
  ```
  source ~/.bashrc
  ```
#### Cryo-CARE
1. You will need CUDA Toolkit: https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=RHEL&target_version=8&target_type=rpm_local

Installation instructions (type these in terminal):

```
wget https://developer.download.nvidia.com/compute/cuda/12.6.2/local_installers/cuda-repo-rhel8-12-6-local-12.6.2_560.35.03-1.x86_64.rpm
sudo rpm -i cuda-repo-rhel8-12-6-local-12.6.2_560.35.03-1.x86_64.rpm
sudo dnf clean all
sudo dnf -y install cuda-toolkit-12-6
```
2. You will need to create a python environment (here we name it "cryocare_11") and install Tensorflow and CryoCARE in it https://pypi.org/project/cryoCARE/  (type these in terminal):
```
conda create -n cryocare_11 python=3.8 cudatoolkit=11.0 cudnn=8.0 -c conda-forge
conda activate cryocare_11
pip install tensorflow==2.4
pip install cryoCARE
```
> [!IMPORTANT]
> You need to type "conda activate cryocare_11" in Terminal window in order to have access to CryoCARE commands

## Getting started

I recommend creating the following folder structure for the various scripts/config files:

```bash
└── Cryo-Pip
    ├── Code
    │   ├── IMODCryo_pipeline.m
    │   ├── AF_IMODCryo.sh
    │   ├── IMOD_pipeline.m
    │   ├── AF_IMOD.sh
    │   ├── SortEvenOdd.sh
    │   └── ValidateGreat.m
    ├── ConfigurationFiles
    │   └── AurelienTemplate241024.adoc 
    └── CryoCARE
        ├── train_data_config.json
        ├── train_config.json
        └── predict_config.json
```

Folder structure for tilt series to be processed:

```bash
└── /path/to/frames/
    ├── <Metadata>.mdoc
    ├── <gain_file>.md4
    ├── Image_1.tiff
    ├── Image_2.tiff
    ├── ...
    ├── ...

```







