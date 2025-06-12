#!/bin/bash 
# CPU Configuration Menu
### set-cpu-flags.sh 
# /etc/portage/package.use/00-cpu
# echo "/ $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags via app-portage/cpuid2cpuflag /etc/portage/custom/hardware/ cpu$Dir/cpu-name 
### or added by wiki articles , anyway set cpu/s on box. based on arch$ and hardware if avlible... 

# Set the correct CONFIG_DIR based on architecture
OPTIONS=($(ls "$CONFIG_DIR" | grep -v "$Ignore"))
Ignore=".keep"


ARCH=$(uname -m)

case "$ARCH" in
  x86_64) CONFIG_DIR="/etc/portage/custom/hardware/cpu/" ;;
  aarch64) CONFIG_DIR="/etc/portage/custom/hardware/arm64_cpu/" ;;
  riscv64) CONFIG_DIR="/etc/portage/custom/hardware/riscv_cpu/" ;;
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

# Populate options dynamically
OPTIONS=($(ls "$CONFIG_DIR"))

echo "Select a CPU configuration:"
select CHOICE in "${OPTIONS[@]}"; do
  if [[ -n "$CHOICE" ]]; then
    echo "Applying configuration: $CHOICE"
    ln -sf "$CONFIG_DIR/$CHOICE" /etc/portage/package.use/00cpu-flags
    break
  else
    echo "Invalid selection. Try again."
  fi
done
