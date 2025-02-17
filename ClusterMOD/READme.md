### IMOD is now available on the cluster !

# Using IMOD within login node

All IMOD commands can be used by typing:

```imod [imod_command] [options]```

Example:

```imod 3dmod ./Stack_MC.mrc```

> [!IMPORTANT]
> This method will run the command on the login node which is not meant for heavy usage.
>
> Use this for 3dmod or other light computation

# Submitting IMOD commands as cluster jobs

All IMOD commands can be run as cluster jobs by typing

```jimod [imod_command] [options]```

This will send the job to the SLURM queue

![image](https://github.com/user-attachments/assets/4c51f117-f925-4bd0-a8a7-273e659290f5)
