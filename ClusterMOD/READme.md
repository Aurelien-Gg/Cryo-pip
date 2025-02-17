### IMOD is now available on the cluster !

# Using IMOD within login node

All IMOD commands can be used by typing:

```imod [imod_command] [options]```

Example:

```imod 3dmod ./Stack_MC.mrc```

> [!IMPORTANT]
> This method will run the command on the login node which is not meant for heavy usage.
>
> Use this only for 3dmod or other light computation

# Submitting IMOD commands as cluster jobs

All IMOD commands can be run as cluster jobs by typing

```jmod [imod_command] [options]```

This will send the job to the SLURM queue

![image](https://github.com/user-attachments/assets/72131164-fa43-4aa0-9dba-029ea00bedeb)


# Custom IMOD functions

## Excluding views

Two step method for removing views from an MRC file

1. Creating model file

```imod 3dmod example.mrc exclude.mod```

Will open 3dmod and create a model file called "exclude.mod"

Switch to 'model' mode and add a Contour/Point on any frame you wish to exclude

2. Running excludeviews

Use custom function "navexclude" to remove views by running job on cluster

```navexclude example.mrc exclude.mod```

![image](https://github.com/user-attachments/assets/23a3c561-fb7e-48c7-9859-5a9dabdf66fc)


