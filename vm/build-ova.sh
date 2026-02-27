#!/bin/bash
set -euo pipefail

VM_NAME="${1:-"Maestro-Ubuntu"}"
OUT_FILE="maestro-ubuntu-v0.1.ova"

echo "=========================================================="
echo "Preparing to export $VM_NAME to $OUT_FILE"
echo "=========================================================="
echo "Instructions for a clean VirtualBox snapshot:"
echo "1. Ensure the VM is fully shut down (Power Off)."
echo "2. Remove any shared folders that are specific to the host."
echo "3. Remove any inserted ISOs from optical drives."
echo "4. (Optional) Zero out free space inside the VM and shrink the disk."
echo "=========================================================="

echo "Exporting VM to $OUT_FILE..."
VBoxManage export "$VM_NAME" --output "$OUT_FILE"

echo "Calculating SHA256 checksum..."
sha256sum "$OUT_FILE" > "${OUT_FILE}.sha256"
cat "${OUT_FILE}.sha256"

echo "=========================================================="
echo "Export complete!"
echo "Distribution instructions:"
echo "1. Upload $OUT_FILE to the distribution server (e.g., S3, Google Drive)."
echo "2. Provide the SHA256 checksum to users for verification."
echo "3. Update the download link in the central repository/docs."
echo "=========================================================="
