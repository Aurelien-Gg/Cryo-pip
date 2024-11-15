# Cryo-pip
Cryo-EM tomogram reconstruction and analysis pipeline

Table of contents:

[I just want to build a denoised Tomogram from my tilt series !!!](#Quick-guide)

[MAC USERS, please read](#MAC-specific-sht)

[Full Install guide](#Full-Install-guide)


## Quick guide

Download all files  automatically by opening Terminal in desired directory and using the command:
```
git clone https://github.com/Aurelien-Gg/Cryo-pip
```
This will download everything from the Github and place them in the correct directory structure.

#### To get denoised Tomogram from tilt series:

  - Open Full_pipeline2.m
  - Modify the necessary paths to fit your config
  - Execute the code

For CryoCARE:
  - Full_pipeline2.m prepares the three necessary .Json files for CryoCARE and puts them in /output_folder/CryoCAREful/
  - To run CryoCARE simply open terminal in /CryoCAREful/ folder and run the 3 command lines found in: [CryoCARE/Summary](CryoCARE/README.md)

~~More info can be found [HERE](Code/README.md/#How-to-use-Full_pipeline.m)~~

#### To only get tomogram only using IMOD (no CryoCARE denoising or Even/Odd splitting)

OBSOLETE AT THE MOMENT
  - ~~Open IMOD_pipeline.m~~
  - ~~Modify the necessary paths to fit your config~~
  - ~~Execute the code~~

## MAC specific sh*t

### MATLAB

> [!IMPORTANT]
> MATLAB must be opened using the terminal, and *not using your fancy-schmancy Dock*

Your Matlab is likely installed in /Applications/MATLAB_yourversion.app/. To open it use the following command in terminal window:

```bash
open /Applications/MATLAB_2023b.app/
```
Modifiy the command line so it fits your config.

### How to set up environment so you can launch Matlab simply by typing 'Matlab' in any terminal window

1. Locate the MATLAB Installation Path:

Open Finder and navigate to Applications.

Find the MATLAB application, which should look like MATLAB_R2023b.app (substitute R2023b with your version if it's different).

MATLAB’s executable is located in the bin folder within this .app package. For example, for MATLAB R2023b, the path is:
```
/Applications/MATLAB_R2023b.app/bin/
```

2. Edit the Shell Configuration File:

Open Terminal.

Determine your default shell by running:

```bash
echo $SHELL
```
If your shell is zsh (default for macOS Catalina and later), you’ll edit the .zshrc file. If it’s bash (default in earlier versions of macOS), you’ll edit .bash_profile.

3. Add MATLAB to the PATH:

In Terminal, open the appropriate file in a text editor:
```bash
nano ~/.zshrc        # For zsh users
nano ~/.bash_profile  # For bash users
```
Add this line to the end of the file, adjusting the MATLAB version if necessary:
```bash
export PATH="/Applications/MATLAB_R2023b.app/bin:$PATH"
```
Save and close the editor (for nano, press Ctrl + X, then Y, and Enter).
Apply the Changes:

4. Reload your shell’s configuration by running:
```bash
source ~/.zshrc        # For zsh users
source ~/.bash_profile  # For bash users
```
5. Verify the Setup:

Open a new terminal window (or in the same window) and type:
```bash
matlab
```
MATLAB should start up if everything is set up correctly.

## Full Install guide
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
    │   ├── IMOD_pipeline.m
    │   ├── Full_pipeline.m
    │   ├── AF_IMODpipe.sh
    │   ├── AF_Fullpipe.sh
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
Don't put multiple .mdoc or .md4 files in the folders, can confuse the code.



## Patch notes (Version 2.0)

<ins>**Bug Fixes**</ins>

**Tomogram Duplication**: Fixed an issue where processing one tomogram would occasionally lead to duplicate stacks across all directories. (Unless you liked that bug?)

**Random U-Net Seizures**: No more spontaneous convulsions of the U-Net layer. Processing should now be less… dramatic.

**Temperature Drops**: Cryo-ET pipeline should no longer try to make the lab 4K compatible. You can keep the AC off now.

**Nobel Alert System**: Fixed a bug where the software kept notifying users that they deserve a Nobel Prize for their work. Now it only appears every 10 hours.

<ins>**New Features**</ins>

**Hyperchill Mode™**: Added a "Relax and Denoise" button for those tomograms that just need to vibe. Warning: may lead to surreal image reconstructions if used too liberally.

**Virtual Lab Assistant "Cryo-Bob"**: Bob now offers random bits of wisdom during processing (e.g., "Have you tried turning it off and back on?").

**Artifact Whack-a-Mole**: All artifacts should theoretically be removed, but if one shows up, now you can just click it! Each artifact whacked spawns two new ones (work in progress).

<ins>**Improvements**</ins>

**Improved Error Messages**: Now with helpful tips like, “Oops, try again!” or “Consider a different career?” for those elusive error codes.

**Compression 2.0**: Implemented a new compression scheme where everything compresses to the size of an atomic nucleus. (Unfortunately, it's still experimental, so you might need a magnifying glass to read your files.)

**CryoCAREful**: Improved prediction algorithm now offers more personalized predictions about *why* your denoising failed this time.

<ins>**Known Issues**</ins>

**Infinite Training Mode**: Occasionally, training just keeps going, saying "Just one more epoch…" We’re working on this one.

**RAM-ivore Bug**: If you have over 64GB of RAM, expect the pipeline to consume it all and ask for dessert.

