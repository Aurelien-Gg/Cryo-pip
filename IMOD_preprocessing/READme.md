IMOD on UNIL Cluster
dcsrsoft use 20240303
module load apptainer

How to use IMOD commands on cluster:

1. (TO DO ONLY ONCE) Add IMOD singularity path to the end of your bashrc

Type: `nano ~/.bashrc`
Add at end of file: export PATH="/work/FAC/FBM/DMF/pnavarr1/default/Aurelien/IMOD/imod_singularity/:$PATH"

(To make these changes take effect use source ~/.bashrc, or simply re-log in to the cluster)

You can now use IMOD commands in the following way:
```imod 3dmod /path/to/my/mrc/file.mrc```

2. Load necessary module

Simply type ```module load apptainer``` everytime you log in to the cluster and want to use IMOD

