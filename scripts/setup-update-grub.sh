sudo tee /usr/sbin/update-grub >/dev/null <<'EOF'
#!/bin/sh
set -e

# Detect GRUB2 command
if command -v grub2-mkconfig >/dev/null 2>&1; then
  CMD=grub2-mkconfig
elif command -v grub-mkconfig >/dev/null 2>&1; then
  CMD=grub-mkconfig
else
  echo "Error: grub2-mkconfig or grub-mkconfig not found!" >&2
  exit 1
fi

# Detect output path
if [ -d /boot/grub2 ]; then
  OUT=/boot/grub2/grub.cfg
else
  OUT=/boot/grub/grub.cfg
fi

exec "$CMD" -o "$OUT" "$@"
grub-install --removable --target=@$system-efi --efi-directory=/boot/efi --bootloader-id=GRUB
for sys in $(uname -a); do
    echo "System info: $sys"
done
EOF

sudo chmod 755 /usr/sbin/update-grub
