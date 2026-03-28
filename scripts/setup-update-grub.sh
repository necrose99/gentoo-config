sudo tee /usr/sbin/update-grub >/dev/null <<'EOF'
#!/usr/bin/env bash
set -e

# -----------------------------
# Detect GRUB mkconfig command
# -----------------------------
if command -v grub-mkconfig >/dev/null 2>&1; then
    GRUB_CMD="grub-mkconfig"
elif command -v grub2-mkconfig >/dev/null 2>&1; then
    GRUB_CMD="grub2-mkconfig"
else
    echo "[ERROR] grub-mkconfig or grub2-mkconfig not found!" >&2
    exit 1
fi

# -----------------------------
# Detect grub.cfg output path
# -----------------------------
if [ -d /boot/grub2 ]; then
    GRUB_CFG="/boot/grub2/grub.cfg"
else
    GRUB_CFG="/boot/grub/grub.cfg"
fi

echo "[INFO] Generating grub.cfg..."
$GRUB_CMD -o "$GRUB_CFG" "$@"

# -----------------------------
# Detect supported EFI target dynamically
# -----------------------------
EFI_DIR="/boot/efi"
EFI_TARGET=""
for t in x86_64-efi i386-efi arm64-efi arm-efi riscv64-efi riscv32-efi loong64-efi ia64-efi; do
    if grub-install --target="$t" --help >/dev/null 2>&1; then
        EFI_TARGET="$t"
        echo "[INFO] Found EFI target: $EFI_TARGET"
        break
    fi
done

# -----------------------------
# Install UEFI GRUB if available
# -----------------------------
if [ -n "$EFI_TARGET" ] && [ -d "$EFI_DIR" ]; then
    echo "[INFO] Installing UEFI GRUB..."
    grub-install --target="$EFI_TARGET" \
                 --efi-directory="$EFI_DIR" \
                 --bootloader-id="GRUB" \
                 --removable \
                 --recheck
else
    echo "[INFO] Skipping UEFI GRUB install (no EFI directory or target detected)"
fi

# -----------------------------
# Detect BIOS GRUB partition for legacy/emergency boot
# -----------------------------
BIOS_PART=""
for disk in /dev/sd* /dev/nvme*; do
    PART=$(parted -ms "$disk" print 2>/dev/null | grep bios_grub | cut -d: -f1 || true)
    if [[ -n "$PART" ]]; then
        BIOS_PART="$disk"
        break
    fi
done

if [[ -n "$BIOS_PART" ]]; then
    echo "[INFO] BIOS GRUB partition detected on $BIOS_PART, installing legacy GRUB..."
    grub-install --target=i386-pc --boot-directory=/boot --force "$BIOS_PART"
else
    echo "[INFO] No BIOS GRUB partition detected, skipping legacy GRUB install."
fi

# -----------------------------
# Optional: add emergency recovery entry
# -----------------------------
RECOVERY_ENTRY="/etc/grub.d/40_custom"
if ! grep -q "Emergency Recovery" "$RECOVERY_ENTRY" 2>/dev/null; then
    echo "[INFO] Adding emergency recovery entry..."
    cat << 'EOF' >> "$RECOVERY_ENTRY"
menuentry "Emergency Recovery Boot" {
    set root=(hd0,1)
    linux /vmlinuz root=/dev/sda1 ro single
    initrd /initramfs
}
EOF
fi

echo "[INFO] update-grub complete. System info: $(uname -a)"
EOF

# Set ownership and executable permissions
sudo chown root:root /usr/sbin/update-grub
sudo chmod 755 /usr/sbin/update-grub

echo "Done! You can now use 'sudo update-grub'."
