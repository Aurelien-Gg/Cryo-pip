## Short description of files
```
AtoZpip.m
```
Full pipeline. Takes a series of .Tiff images and reconstructs them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files & performs denoising using CryoCARE

```
AF_atoz.sh
```
is called by main script to run Alignframes on .Tiff images to align the subframes & creates the Even/Odd images (using -debug 10000)

```
IMODpip.m
```
Pipeline without IsoCARE. Takes a series of .Tiff images and reconstructs them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files

```
SortEvenOdd.sh
```
is used to move the Even and Odd .mrc images created with AF_atoz.sh into Even and Odd folders respectively


```
ValidateGreat.m
```
Plots and saves the Defocus values from ctfcorrection.log  &  Residual values from align.log

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
> Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc", and Gain file "<gain_name>.dm4" need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder (should be changed)

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
IMODpip.m can be run from anywhere as long as full paths are provided

> [!IMPORTANT]
> Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc", and Gain file "<gain_name>.dm4" need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder (should be changed)


## How to use SortEvenOdd.sh

SortEvenOdd.sh looks for all faimg-*.mrc files in given path. It takes all even number of * and puts them in a folder called /even/. Same for /odd/.

```
Usage: ./SortEvenOdd.sh </path/to/EvenOdd/to/be/sorted/>
```
