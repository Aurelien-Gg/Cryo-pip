Table of contents:

[Short description of files](#Short-description-of-files)


## Short description of files
```
Full_pipeline.m
```
Full_pipeline.m  is full pipeline. Takes a series of .Tiff images and reconstructs them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files **& prepares files for denoising using CryoCARE**

```
AF_Fullpipe.sh
```
AF_Fullpipe.sh  is called by Full_pipeline.m to run Alignframes on .Tiff images to align the subframes **& creates the Even/Odd images (using -debug 10000)**

```
SortEvenOdd.sh
```
SortEvenOdd.sh  is used to move the Even and Odd .mrc images created with AF_atoz.sh (Alignframes -debug 10000) into Even and Odd folders respectively

```
IMOD_pipeline.m
```
IMODpip.m is pipeline **without CryoCARE**. Takes a series of .Tiff images and reconstructs them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files

```
AF_IMODpipe.sh
```
AF_IMODpipe.sh is called by IMODpipeline.m to run Alignframes on .Tiff images to align the subframes

```
ValidateGreat.m
```
ValidateGreat.m plots and saves the Defocus values from ctfcorrection.log  &  Residual values from align.log

# How to use Full_pipeline.m

The following files
```
AF_Fullpipe.sh
SortEvenOdd.sh
```
need to be in the same folder as
```
Full_pipeline.m
```
Full_pipeline.m can be run from anywhere as long as full paths are provided
> [!IMPORTANT]
> Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc" need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder

Denoised Tomogram output can be found in **'/output_dirpath/imod_folder/stack_name/CryoCAREful/denoised.rec/'**

###### MODIFY PATHS TO FIT YOUR CONFIG

```
template_filepath = '/path/to/AurelienTemplateAutoFid2.adoc';   **Path of template file** 
cryo_path         = '/path/to/Cryo/JSon/files/';                **Path of cryocare json files** 
frame_dirpath     = '/path/to/frames/'                          **Directory with frames and .Mdoc** 
gain_path         = '/path/to/gain/'                            **Gain path (optional). If left empty it will take the one in 'frame_direpath'**
output_dirpath    = '/choose/path/to/output/'                   **Choose directory path to output files. Usually same as frame_directory**
imod_folder       = 'choose output folder name'                 **Choose directory that will be created to output results of Alignframes**
stack_name        = 'choose stack name'                         **Choose name for .mrc stack output**
```

# How to use IMOD_pipeline.m

The following files
```
AF_IMODpipe.sh
```
need to be in the same folder as
```
IMOD_pipeline.m
```
IMOD_pipeline.m can be run from anywhere as long as full paths are provided. Check **How to use Full_pipeline.m** for config paths to be modified details

> [!IMPORTANT]
> Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc" need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder

## How to use SortEvenOdd.sh

SortEvenOdd.sh looks for all faimg-*.mrc files in given path. It takes all even number of * and puts them in a folder called /even/. Same for /odd/.
```
Usage: ./SortEvenOdd.sh /path/to/EvenOdd/to/be/sorted/
```
