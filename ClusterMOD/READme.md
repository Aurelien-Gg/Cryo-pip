### IMOD is now available on the cluster !

# Using IMOD within login node

All IMOD commands can be used by typing:

```imod [imod_command] [options]```

Example:

```imod 3dmod ./stack_MC.mrc```

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

1. Creating a model file

```imod 3dmod example.mrc exclude.mod```

Will open 3dmod and create a model file called "exclude.mod"

Switch to 'model' mode and add (middle click for me) atleast one Contour/Point on any frame you wish to exclude. Save model by pressing 's'.

2. Running excludeviews

Use custom function "navexclude [stack_to_process] [model.mod] " to remove views

```navexclude example.mrc exclude.mod```

where example.mrc is the input stack that you want to remove frames from, and exclude.mod is the model file we just created previously.

The output of this function will be:

- example.mrc : your input stack MINUS the frames you wanted to remove
- example_cutviews0.mrc : an .mrc stack containing ONLY the removed frames
- example_cutviews0.info : small file containing information about which frames were removed

![image](https://github.com/user-attachments/assets/8b303de8-51ac-4f89-9e37-41a8eeef5ea4)
  
You can recover the original stack by using the command:

```imod excludeviews -restore example.mrc```
