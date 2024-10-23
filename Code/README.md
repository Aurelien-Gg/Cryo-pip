## Short description of files
```
AtoZ.m
```
is the main script which will take a series of .Tiff images and reconstruct them into a 3D Tomogram using .Mdoc (metadata) and .md4 (gain) files

```
Pipeline.sh
```
is called by main script to run Alignframes on .Tiff images to align the subframes. It also creates the Even/Odd images (using -debug 10000, remove this option in the file to skip this)

```
SortEvenOdd.sh
```
is used to move the Even and Odd .mrc images created with Alignframes into Even and Odd folders respectively
Usage: ./SortEvenOdd.sh </path/to/EvenOdd/to/be/sorted/>

```
ValidateGreat.m
```
Plots and saves the Defocus values from ctfcorrection.log  &  Residual values from align.log

# How to use

The following files
```
AtoZ.m
Pipeline.sh
SortEvenOdd.sh
```
need to be in the same folder
