# Template SLURM script

Template for SLURM script: `run_alphafold_template.sh` (can be found in /work/FAC/FBM/DMF/pnavarr1/default/AlphaFold/ )
```
#!/bin/bash

#SBATCH -c 24                # 24 CPUs (matches CPU-heavy parts)
#SBATCH -p gpu               # GPU partition
#SBATCH --gres=gpu:1         # 1 GPU
#SBATCH --mem 200G           # 200GB RAM
#SBATCH -t 6:00:00           # 6-hour runtime
#SBATCH -J alphafold_job     # Job name
#SBATCH -o %x-%j.out         # Output log

# Load modules and bind paths
module purge
module load singularityce
export SINGULARITY_BINDPATH="/scratch,/users,/work,/reference"

# Run AlphaFold via helper script
bash /dcsrsoft/singularity/containers/run_alphafold_032e2f2.sh \
  -f /work/FAC/FBM/DMF/pnavarr1/default/AlphaFold/.../YOUR_INPUT.fasta \ # REQUIRED: Path to input FASTA file(s). For multiple files, separate with commas.
  -o /scratch/$USER/alphafold_output \ # REQUIRED: Path to output directory (replace with your desired location)
  -m monomer \                         # REQUIRED: Model preset. Options: "monomer", "monomer_casp14", "monomer_ptm", "multimer"
  -n 24 \                              # REQUIRED: Number of CPUs to use (matches SBATCH -c value)
  -d /reference/alphafold/20221206 \   # REQUIRED: Path to AlphaFold databases (update if newer exists)
  -t 2022-12-06 \                      # REQUIRED: Max template date (match database date, ISO-8601 format: YYYY-MM-DD)
  -g true \                            # REQUIRED: Enable GPU (true/false)

  # -r true \                         # OPTIONAL: Run relaxation step (true/false). Default: true. Turn off for faster runs.
  # -e true \                         # OPTIONAL: Run relaxation on GPU if GPU is enabled (true/false). Default: true.
  # -a 0 \                            # OPTIONAL: Comma-separated list of GPU devices (e.g., "0" or "0,1"). Default: 0.
  # -c full_dbs \                     # OPTIONAL: Database preset. Options: "full_dbs" (default) or "reduced_dbs".
  # -p false \                        # OPTIONAL: Use precomputed MSAs (true/false). Default: false. WARNING: Does not check for changes in sequence/database.
  # -l 5 \                            # OPTIONAL: Number of multimer predictions per model (only for "multimer" preset). Default: 5.
  # -b false \                        # OPTIONAL: Run benchmark mode (true/false). Default: false. Measures timing without compilation overhead.
  # --is_prokaryote_list=true,false \ # OPTIONAL: For multimer only. List of booleans (one per FASTA) indicating prokaryotic origin. Default: unknown.
  # --random_seed=42 \                # OPTIONAL: Set random seed for reproducibility. Default: randomly generated.
```
# User Instructions
### Step 1: Prepare Input
Place your protein sequence(s) in a single/multi-sequence FASTA file (e.g., my_protein.fasta).

### Step 2: Customize the Template

Make your own AlphaFold SLURM script (by copying /work/FAC/FBM/DMF/pnavarr1/default/AlphaFold/run_alphafold_template.sh or creating your own)

Replace `-f /work/FAC/FBM/DMF/pnavarr1/default/AlphaFold/.../YOUR_INPUT.fasta` with your FASTA file path.

Replace `-o /scratch/$USER/alphafold_output` with your desired output directory.

For multimer predictions, change -m monomer to -m multimer.

etc...

Uncomment (by removing the `#`) the optional parameters in order to use them

### Step 3: Submit the Job
```
sbatch run_alphafold.sh
```

### Step 4: Monitor Outputs
Results will be saved to your specified -o directory, including PDB files, scores, and logs.

Check slurm-<JOBID>.out for progress/errors.

# AlphaFold job parameters:

### Required Parameters:

| Command | Description | Default Value |
|---------|------------|--------------|
| `-d <data_dir>` | Path to directory of supporting data | N/A |
| `-o <output_dir>` | Path to a directory that will store the results | N/A |
| `-f <fasta_paths>` | Path to FASTA files containing sequences. If a FASTA file contains multiple sequences, it will be folded as a multimer. To fold more sequences sequentially, separate them with a comma | N/A |
| `-t <max_template_date>` | Maximum template release date to consider (ISO-8601 format, YYYY-MM-DD). Important for historical test sets | N/A |

### Optional Parameters:

| Command | Description | Default Value |
|---------|------------|--------------|
| `-g <use_gpu>` | Enable NVIDIA runtime to run with GPUs | `true` |
| `-r <run_relax>` | Whether to run the final relaxation step on the predicted models. Turning it off may result in stereochemical violations but can help with relaxation issues | `true` |
| `-e <enable_gpu_relax>` | Run relaxation on GPU if GPU is enabled | `true` |
| `-n <openmm_threads>` | Number of OpenMM threads | All available cores |
| `-a <gpu_devices>` | Comma-separated list of devices for CUDA_VISIBLE_DEVICES | `0` |
| `-m <model_preset>` | Choose model configuration: monomer, monomer with extra ensembling, monomer with pTM head, or multimer | `monomer` |
| `-c <db_preset>` | Choose MSA database configuration: `reduced_dbs` (smaller) or `full_dbs` (full genetic database) | `full_dbs` |
| `-p <use_precomputed_msas>` | Whether to read MSAs from disk. WARNING: Does not check if the sequence, database, or configuration has changed | `false` |
| `-l <num_multimer_predictions_per_model>` | Number of predictions per model (only applies if `model_preset=multimer`). If set to 2 and there are 5 models, there will be 10 predictions per input | `5` |
| `-b <benchmark>` | Run multiple JAX model evaluations to get a timing that excludes compilation time (useful for benchmarking) | `false` |


# Expected Output Structure:

Output directories will contain:
```
├── ranked_[0-4].pdb         # Ranked structures (most confident first)
├── relaxed_model_[1-5].pdb  # Relaxed structures (if relaxation enabled)
├── timings.json             # Time spent per step
└── logs/                    # Detailed logs for debugging
```
