# 🔄 S3/Local to HPC Transfer Tool (navtransfer.sh)

A versatile script for transferring data to High-Performance Computing (HPC) environments. It supports pulling data from Amazon S3 buckets using `rclone` or copying data from your local filesystem using `rsync`.

## ✨ Features

-   **Dual Source Support (CLI):** Transfer from S3 buckets OR from local filesystem paths in command-line mode.  S3 transfers use `rclone`, local transfers use `rsync`.
-   **Interactive or Command-line Operation:** Use with prompts (S3 only) or direct parameters (S3 or Local).
-   **Smart S3 Folder Discovery:** Automatically lists available folders from your S3 bucket in interactive mode.
-   **Robust Transfer:** Uses `rclone` for optimized S3 transfers and `rsync -avh --progress --backup` for reliable local transfers with backups.
-   **Transfer Verification (S3):** Validates successful S3 transfers with checksums using `rclone check`.
-   **Tmux Integration:** Automatically offers to run transfers in tmux sessions to prevent disconnection issues.
-   **Parallel Transfers (S3):** Optimized for S3 performance with multiple simultaneous `rclone` transfers.
-   **Overwrite Protection (S3):** Options to skip, overwrite, or abort when S3 destination files already exist. (`rsync` uses `--backup` for local transfers).
-   **Detailed Logging:** Comprehensive logs for both S3 and local transfers stored in `$HOME/.s3transfer_logs`.
-   **Colorized Output:** Clear, color-coded terminal interface. 🎨

## 📋 Prerequisites

-   **For S3 Transfers:**
    -   `rclone`: Must be installed and **configured** with an S3 remote named "s3-dci-ro".
-   **For Local Transfers:**
    -   `rsync`: Must be installed.
-   **General:**
    -   `tmux`: Recommended for long transfers.
    -   Standard Unix utilities (`bash`, `grep`, `awk`, `realpath`, `mkdir`, `chmod`, etc.).

## 🔑 Rclone Configuration (for S3)

If using S3 transfers, configure `rclone` first. Create the configuration file:

```bash
mkdir -p ~/.config/rclone
nano ~/.config/rclone/rclone.conf
```

Add your S3 remote configuration (replace placeholders with actual credentials):

```ini
[s3-dci-ro]
type = s3
provider = Other
access_key_id = YOUR_ACCESS_KEY_ID
secret_access_key = YOUR_SECRET_ACCESS_KEY
region = # Optional: specify if needed
endpoint = https://your-s3-endpoint.example.com # Replace with your S3 endpoint URL
```

Secure your key file:

```bash
chmod 600 ~/.config/rclone/rclone.conf
```

Now, `s3-dci-ro` is ready for the script to use for S3 operations.

## 🚀 Usage

### Interactive Mode (S3 Only)

Run the script without arguments for an interactive S3 transfer:

```bash
navtransfer.sh
```

The script will:

1.  Offer to create a dedicated Tmux session.
2.  List available folders in your default S3 bucket (`recn-fac-fbm-dmf-pnavarr1-dci-data-transfer`).
3.  Prompt you to select an S3 folder.
4.  Ask for a destination path on the HPC (with tab completion).
5.  Show S3 transfer statistics and ask for confirmation.
6.  Perform the S3 transfer using `rclone` with progress display.

### Command-line Mode (S3 or Local)

Run with explicit parameters for S3 or local transfers:

```bash
navtransfer.sh -copythis SOURCE_PATH -tohere DESTINATION_PATH [-dryrun]
```

**Options:**

-   `-copythis SOURCE_PATH`: Source path.
    -   If it exists in the default S3 bucket (`s3-dci-ro:recn-fac-fbm-dmf-pnavarr1-dci-data-transfer/SOURCE_PATH`) and has content, it's treated as an S3 source (`rclone`).
    -   Otherwise, if it exists as a local path (relative to where you run the script), it's treated as a local source (`rsync`).
    -   If not found in either location, the script exits with an error.
-   `-tohere DESTINATION_PATH`: Destination path on the HPC. The directory will be created if it doesn't exist.
    -   For S3 sources, a subdirectory matching the source folder name is created inside `DESTINATION_PATH`.
    -   For local sources, the content is copied directly into `DESTINATION_PATH`.
-   `-dryrun`: Test the transfer logic without actually copying files (`rclone --dry-run` or `rsync --dry-run`).
-   `-help`: Show the help message.

## 📝 Examples

```bash
# Interactive mode (S3 only)
navtransfer.sh
```

```bash
# CLI: Transfer the "MyProjectData" folder from S3 to /work/myproject
navtransfer.sh -copythis MyProjectData -tohere /work/myproject
```

```bash
# CLI: Transfer a local directory "./local_analysis_results" to /work/results/
# (This will use rsync)
navtransfer.sh -copythis ./local_analysis_results -tohere /work/results/
```

```bash
# CLI: Transfer a local file "important_data.csv" to /work/archive/
# (This will use rsync)
navtransfer.sh -copythis important_data.csv -tohere /work/archive/
```

```bash
# CLI: Test an S3 transfer without copying files
navtransfer.sh -copythis MyProjectData -tohere /work/myproject -dryrun
```

```bash
# CLI: Test a local transfer without copying files
navtransfer.sh -copythis ./local_analysis_results -tohere /work/results/ -dryrun
```

## 📊 Logging

Transfer logs (both S3 and local) are stored in `$HOME/.s3transfer_logs/` with timestamps. Detailed `rclone` logs for S3 transfers are also saved within that directory.

## 🔒 Overwrite Protection

-   **S3 Transfers:** When the destination *directory* for an S3 transfer already contains files, the script prompts you to:
    -   Skip existing files (default).
    -   Overwrite existing files.
    -   Abort the transfer.
    (This check happens before the `rclone copy` command).
-   **Local Transfers:** `rsync` is used with the `--backup` flag. If `rsync` needs to overwrite a file in the destination, it will rename the existing destination file by appending a `~` (tilde) before writing the new file. This preserves the previous version.

## 📱 Tmux Integration

The script automatically:

1.  Checks if you're running inside `tmux`.
2.  If not, it prompts you to start a new `tmux` session.
3.  Creates a unique session name (e.g., `s3transfer`, `s3transfer-1`).
4.  Restarts itself inside the new `tmux` session.
5.  Provides instructions for re-attaching if you get disconnected.

### Reconnecting

If your connection drops:

1.  SSH back into the HPC.
2.  Re-attach using `tmux attach -t SESSION_NAME` (use the name provided by the script, e.g., `s3transfer-1`).

### Managing Tmux

-   List sessions: `tmux list-sessions`
-   Attach: `tmux attach -t SESSION_NAME`
-   Detach: Press `Ctrl+B` then `D`.
-   Kill session: Type `exit` inside the session, or `tmux kill-session -t SESSION_NAME` from outside.
