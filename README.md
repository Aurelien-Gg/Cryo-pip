How use much good few words?

# Cryo-pip
Cryo-EM tomogram reconstruction and analysis pipeline
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

Go where file is downloaded, open Terminal window, and type
```
imod_4.11.25_RHEL7-64_CUDA10.1.sh
```
You need to add IMOD to your PATH so that Linux can find the commands.

Open your .bashrc through Terminal window:
```
nano ~/.bashrc
```
Add IMOD to your PATH: At the end of the file, add the following lines, replacing /path/to/IMOD with the actual path to your IMOD installation (type "which imod" in Terminal to get path):
```
export IMOD_DIR=/path/to/IMOD
export PATH=$PATH:$IMOD_DIR:$IMOD_DIR/bin
```

Apply the changes: After saving the file, either restart your terminal or run:
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
