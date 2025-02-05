# IMOD on UNIL Cluster

How to use IMOD commands on cluster:

1. Add IMOD singularity path to the end of your bashrc (this only needs to be done once)

Type: `nano ~/.bashrc`

Add at end of file: export PATH="/work/FAC/FBM/DMF/pnavarr1/default/Aurelien/IMOD/imod_singularity/:$PATH"

(To make these changes take effect use source ~/.bashrc, or simply re-log in to the cluster)

You can now use IMOD commands in the following way:

```imod 3dmod /path/to/my/mrc/file.mrc```  (example)

2. Load necessary module and software pack

Simply type 

```module load apptainer```
```dcsrsoft use 20240303```

Everytime you log in to the cluster and want to use IMOD

