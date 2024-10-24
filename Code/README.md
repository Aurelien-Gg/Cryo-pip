## Short description of files
```
AtoZpip.m
```
AtoZpip.m  is full pipeline. Takes a series of .Tiff images and reconstructs them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files **& performs denoising using CryoCARE**

```
AF_atoz.sh
```
AF_atoz.sh  is called by AtoZpip.m to run Alignframes on .Tiff images to align the subframes **& creates the Even/Odd images (using -debug 10000)**

```
SortEvenOdd.sh
```
SortEvenOdd.sh  is used to move the Even and Odd .mrc images created with AF_atoz.sh (Alignframes -debug 10000) into Even and Odd folders respectively

```
IMODpip.m
```
IMODpip.m is pipeline **without CryoCARE**. Takes a series of .Tiff images and reconstructs them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files

```
AF_imod.sh
```
AF_imod.sh is called by IMODpip.m to run Alignframes on .Tiff images to align the subframes

```
ValidateGreat.m
```
ValidateGreat.m plots and saves the Defocus values from ctfcorrection.log  &  Residual values from align.log

# How to use AtoZpip.m

The following files
```
AF_atoz.sh
SortEvenOdd.sh
```
need to be in the same folder as
```
AtoZpip.m
```
AtoZ.m can be run from anywhere as long as full paths are provided
> [!IMPORTANT]
> Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc" need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder

Denoised Tomogram can be found in /output_dirpath/imod_folder/stack_name/CryoCAREful/denoised.rec/'

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

# How to use IMODpip.m

The following files
```
AF_pip.sh
```
need to be in the same folder as
```
IMODpip.m
```
IMODpip.m can be run from anywhere as long as full paths are provided. Check **How to use AtoZpip.m** for config paths to be modified details

> [!IMPORTANT]
> Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc" need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder

## How to use SortEvenOdd.sh

SortEvenOdd.sh looks for all faimg-*.mrc files in given path. It takes all even number of * and puts them in a folder called /even/. Same for /odd/.
```
Usage: ./SortEvenOdd.sh /path/to/EvenOdd/to/be/sorted/
```
