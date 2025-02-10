Table of contents:
conda activate /work/FAC/FBM/DMF/pnavarr1/default/Aurelien/Shared/CryoCARE/

[Quick Guide](#Quick-Guide)

[Full Manual](#Full-Manual)

## Quick Guide

If **Full_pipeline.m** was run with no issues, then open a terminal window in **/<output_dirpath>/<imod_folder>/<stack_name>/CryoCAREful/**

- Find out where your CryoCARE commands are installed by typing:

```
which cryoCARE_train.py
```
that should output something like **~/anaconda3/envs/cryocare_11/bin/cryoCARE_train.py**

- Activate the **<cryocare_11>** (replace with your CryoCARE environment name) python environment using:

```
conda activate cryocare_11
```
- Simply run the following three commands sequentially in order to
  - Prepare Training Data
  - Train model
  - Denoise

```
cryoCARE_extract_train_data.py --conf train_data_config.json
cryoCARE_train.py --conf train_config.json
cryoCARE_predict.py --conf predict_config.json
```

Your denoised tomogram will be in **'/denoise.rec/stack_AF.....mrc'**


## Full Manual
cryoCARE uses `.json` configuration files and is run in three steps. If you already have a model <model_name.tar.gz>  then skip to **3.**

### 1. Prepare Training Data
To prepare the training data we have to provide all tomograms on which we want to train. 
Create an empty file called `train_data_config.json`, copy-paste the following template and fill it in.
```
{
  "even": [
    "/path/to/even.rec"
  ],
  "odd": [
    "/path/to/odd.rec"
  ],
  "mask": [
    "/path/to/mask.mrc"
  ],
  "patch_shape": [
    72,
    72,
    72
  ],
  "num_slices": 1200,
  "split": 0.9,
  "tilt_axis": "Y",
  "n_normalization_samples": 500,
  "path": "./"
}
```
#### Parameters:
* `"even"`: List of all even tomograms.
* `"odd"`: List of all odd tomograms. Note the order has to be the same as in `"even"`.
* `"mask"`: If desired, a list of binary masks to limit where subvolumes are extracted, similar to IsoNet. Can be left out to skip masking.
* `"patch_shape"`: Size of the sub-volumes used for training. Should not be smaller than `64, 64, 64`.
* `"num_slices"`: Number of sub-volumes extracted per tomograms. 
* `"tilt_axis"`: Tilt-axis of the tomograms. We split the tomogram along this axis to extract train- and validation data separately.
* `"n_normalization_samples"`: Number of sub-volumes extracted per tomograms, which are used to compute `mean` and `standard deviation` for normalization.
* `"path"`: The training and validation data are saved here.

#### Run Training Data Preparation:
After installation of the package we have access to built in Python-scripts which we can call. 
To run the training data preparation we run the following command:
`cryoCARE_extract_train_data.py --conf train_data_config.json`

### 2. Training
Create an empty file called `train_config.json`, copy-paste the following template and fill it in.
```
{
  "train_data": "./",
  "epochs": 100,
  "steps_per_epoch": 200,
  "batch_size": 16,
  "unet_kern_size": 3,
  "unet_n_depth": 3,
  "unet_n_first": 16,
  "learning_rate": 0.0004,
  "model_name": "model_name",
  "path": "./",
  "gpu_id": 0
}
```

#### Parameters:
* `"train_data"`: Path to the directory containing the train- and validation data. This should be the same as the `"path"` from above.
* `"epochs"`: Number of epochs used to train the network.
* `"steps_per_epoch"`: Number of gradient steps performed per epoch.
* `"batch_size"`: Used training batch size.
* `"unet_kern_size"`: Convolution kernel size of the U-Net. Has to be an odd number.
* `"unet_n_depth"`: Depth of the U-Net.
* `"unet_n_first"`: Number of initial feature channels.
* `"learning_rate"`: Learning rate of the model training.
* `"model_name"`: Name of the model.
* `"path"`: Output path for the model.
* `"gpu_id"`: This is optional. Provide the ID(s) of the GPUs you wish to use. Alternatively, you can specify the GPU ID(s) using the `CUDA_VISIBLE_DEVICES` environment variable. Training supports multiple GPUs (see below).

#### Run Training:
To run the training we run the following command:
`cryoCARE_train.py --conf train_config.json`

### 3. Prediction
Create an empty file called `predict_config.json`, copy-paste the following template and fill it in.
```
{
  "path": "path/to/your/model/model_name.tar.gz",
  "even": "/path/to/even.rec",
  "odd": "/path/to/odd.rec",
  "n_tiles": [1,1,1],
  "output": "denoised.rec",
  "overwrite": false,
  "gpu_id": 0
}
```

#### Parameters:
* `"path"`: Path to your model file.
* `"even"`: Path to directory with even tomograms or a specific even tomogram or a list of specific even tomograms.
* `"odd"`: Path to directory with odd tomograms or a specific odd tomogram or a list of specific odd tomograms in the same order as the even tomograms.
* `"n_tiles"`: Initial tiles per dimension. Gets increased if the tiles do not fit on the GPU.
* `"output"`: Path where the denoised tomograms will be written.
* `"overwrite"`: Allow previous files to be overwritten.
* `"gpu_id"`: This is optional. Provide the ID of the GPU you wish to use. Alternatively, you can specify the GPU ID using the `CUDA_VISIBLE_DEVICES` environment variable. Note that prediction only supports a single GPU currently.

