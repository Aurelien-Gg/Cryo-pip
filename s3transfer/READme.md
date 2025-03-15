# S3 to HPC Transfer Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

A robust script for transferring data from Amazon S3 buckets to High-Performance Computing (HPC) environments using `rclone`.

## Features

- **Interactive or command-line operation** - Use with prompts or direct parameters
- **Smart folder discovery** - Automatically lists available folders from your S3 bucket
- **Transfer verification** - Validates successful transfers with checksums
- **Tmux integration** - Long transfers run in tmux sessions to prevent disconnection issues
- **Parallel transfers** - Optimized for performance with multiple simultaneous transfers
- **Overwrite protection** - Options to skip, overwrite, or abort when files already exist
- **Detailed logging** - Comprehensive logs with transfer statistics
- **Colorized output** - Clear, color-coded terminal interface

## Prerequisites

- `rclone` - Must be installed and configured with an S3 remote named "s3-dci-ro"
- `tmux` - Recommended for long-running transfers

## Installation

1. Download the script:

```bash
curl -O https://raw.githubusercontent.com/yourusername/s3-hpc-transfer/main/s3transfer.sh
```

2. Make it executable:

```bash
chmod +x s3transfer.sh
```

3. Ensure your rclone configuration includes an S3 remote named "s3-dci-ro"

## Usage

### Interactive Mode

Simply run the script without arguments:

```bash
./s3transfer.sh
```

The script will:
1. List available folders in your S3 bucket
2. Prompt you to select a folder by number or name
3. Ask for a destination path (with tab completion)
4. Show transfer statistics and confirmation before starting
5. Perform the transfer with progress display

### Command-line Mode

Run with explicit parameters:

```bash
./s3transfer.sh -copythis SOURCE_FOLDER -tohere DESTINATION_PATH [-dryrun]
```

Options:
- `-copythis FOLDER` - Source folder in S3 bucket
- `-tohere PATH` - Destination path on HPC
- `-dryrun` - Test transfer without copying files
- `-help` - Show help message

## Examples

```bash
# Interactive mode
./s3transfer.sh

# Transfer the "MyData" folder to your work directory
./s3transfer.sh -copythis MyData -tohere /work/myproject

# Test a transfer without copying files
./s3transfer.sh -copythis MyData -tohere /work/myproject -dryrun
```

## How It Works

1. **Initialization** - Checks for requirements and parses commands
2. **Folder Selection** - Lists S3 folders up to 3 levels deep
3. **Destination Setup** - Confirms or creates the destination directory
4. **Pre-transfer Checks** - Analyzes data size and existing files
5. **Transfer Process** - Performs the copy with 16 parallel transfers
6. **Verification** - Validates transferred files with checksums
7. **Cleanup** - Sets secure permissions and offers to delete S3 source

## Logging

Transfer logs are stored in `$HOME/.s3transfer_logs/` with timestamps.

## Advanced Configuration

The script is configured with the following defaults:

- S3 Remote: `s3-dci-ro` (configured in rclone)
- Default Bucket: `recn-fac-fbm-dmf-pnavarr1-dci-data-transfer`
- Default Destination: `/work/FAC/FBM/DMF/pnavarr1/default/`

To modify these defaults, edit the variables at the top of the script.

## Troubleshooting

- **Script fails to start**: Ensure rclone is installed and configured
- **Permission denied**: Check file permissions with `chmod +x s3transfer.sh`
- **S3 access issues**: Verify your rclone configuration with `rclone config`
- **Transfer verification fails**: Check available disk space and file permissions

## License

This project is licensed under the MIT License - see the LICENSE file for details.
