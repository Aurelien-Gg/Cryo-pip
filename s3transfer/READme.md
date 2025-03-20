# 🔄 S3 to HPC Transfer Tool

A robust script for transferring data from Amazon S3 buckets to High-Performance Computing (HPC) environments using `rclone`.

## ✨ Features
- **Interactive or command-line operation** - Use with prompts or direct parameters
- **Smart folder discovery** - Automatically lists available folders from your S3 bucket
- **Transfer verification** - Validates successful transfers with checksums
- **Tmux integration** - Long transfers run in tmux sessions to prevent disconnection issues
- **Parallel transfers** - Optimized for performance with multiple simultaneous transfers
- **Overwrite protection** - Options to skip, overwrite, or abort when files already exist
- **Detailed logging** - Comprehensive logs with transfer statistics
- **Colorized output** - Clear, color-coded terminal interface

## 📋 Prerequisites
- `rclone` - Must be installed and **configured** with an S3 remote named "s3-dci-ro"

## 🔑 Rclone Configuration
Use a text editor to create a configuration file in your home directory. Be sure to replace the S3 server name and the cryptographic key values with the ones sent in the email S3 from DCSR.

```bash
mkdir -p ~/.config/rclone
nano ~/.config/rclone/rclone.conf
```

The configuration file should look like this:
```
[s3-dci-ro]
type = s3
provider = Other
access_key_id = T******************M
secret_access_key = S**************************************i
region =
endpoint = https://scl-s3.unil.ch
```

Next, secure your key file:
```bash
chmod 600 ~/.config/rclone/rclone.conf
```

Now, **s3-dci-ro** is a S3 configured connection alias that you can use in Rclone without repeating the connection information in the CLI.

## 🚀 Usage

### Interactive Mode
Simply run the script without arguments:
```bash
s3transfer
```

The script will:
1. Offers to create a dedicated Tmux session for your transfer
3. List available folders in your S3 bucket
4. Prompt you to select a folder by number or name
5. Ask for a destination path (with tab completion)
6. Show transfer statistics and confirmation before starting
7. Perform the transfer with progress display

### Command-line Mode
Run with explicit parameters:
```bash
s3transfer -copythis SOURCE_FOLDER -tohere DESTINATION_PATH [-dryrun]
```

Options:
- `-copythis FOLDER` - Source folder in S3 bucket
- `-tohere PATH` - Destination path on HPC
- `-dryrun` - Test transfer without copying files
- `-help` - Show help message

## 📝 Examples
```bash
# Interactive mode
s3transfer
```
![image](https://github.com/user-attachments/assets/9152fba7-c40e-4dc5-8664-517960c02423)
![image](https://github.com/user-attachments/assets/8201a929-10a4-492d-8d86-1cd0ef647f5e)

```
# Transfer the "MyData" folder to your work directory
s3transfer -copythis MyData -tohere /work/myproject

# Test a transfer without copying files
s3transfer -copythis MyData -tohere /work/myproject -dryrun
```

## 📊 Logging
Transfer logs are stored in `$HOME/.s3transfer_logs/` with timestamps.

## 🔒 Overwrite Protection
The script includes safeguards to prevent accidental file overwrites:

**Multiple Options** - When files exist, you can:
   - **Skip** existing files (default, preserves existing data)
   - **Overwrite** existing files (use with caution)
   - **Abort** the transfer entirely (if you need to reconsider)

## 📱 Tmux Integration

### Why Tmux?
SSH connections to HPC clusters can disconnect due to network issues or idle timeouts. When this happens, any running transfer would be interrupted. Tmux solves this by allowing your transfer to continue in the background, even if your connection drops.

### Automatic Tmux Detection
The script automatically:
1. Detects if you're already in a tmux session
2. If not, offers to create a dedicated session for your transfer
3. Creates a unique session name (e.g., `s3transfer-1`)
4. Provides instructions for reconnecting if disconnected

### Reconnecting to Transfers
If your connection drops during a transfer:

1. SSH back to the HPC cluster
2. Reconnect to your tmux session with:
   ```bash
   tmux attach -t s3transfer
   ```
   or
   ```bash
   tmux attach -t s3transfer-1
   ```
   (Use the session name shown in the initial output)

### Managing Tmux Sessions
- **View all sessions**: `tmux list-sessions`
- **Attach to a session**: `tmux attach -t SESSION_NAME`
- **Detach from a session**: Press `Ctrl+B` then `D`
- **End a session**: Type `exit` within the session

The system automatically notifies you about existing tmux sessions when you log in, showing:
- Number of active sessions
- Session names and status
- Commands to attach to each session

### Running Multiple Transfers
You can run multiple transfers simultaneously, each in its own tmux session:
```bash
s3transfer -copythis FOLDER1 -tohere /path/to/destination1
```
In another terminal:
```bash
s3transfer -copythis FOLDER2 -tohere /path/to/destination2
```

## 🔍 Troubleshooting
- S3 access issues: Verify your rclone configuration with rclone config
- Transfer verification fails: Check available disk space and file permissions

