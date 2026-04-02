#!/usr/bin/env python3
"""
Auto-Sorting Kernel Config Sharder

- Parses a kernel .config
- Sorts entries into groups based on keywords or regex
- Supports architecture overrides
- Writes separate shard files per group
"""

import os
import re
import argparse
from collections import defaultdict

# -----------------------------
# Keyword-based group definitions
# -----------------------------
GROUP_PATTERNS = {
    'core': [r'^CONFIG_ARM64', r'^CONFIG_X86_64', r'^CONFIG_EFI_STUB', r'^CONFIG_MMC', r'^CONFIG_PRINTK', r'^CONFIG_SERIAL'],
    'fs': [r'^CONFIG_BTRFS', r'^CONFIG_EXT4', r'^CONFIG_OVERLAY_FS', r'^CONFIG_FAT', r'^CONFIG_VFAT'],
    'media': [r'^CONFIG_SND', r'^CONFIG_VIDEO', r'^CONFIG_DRM', r'^CONFIG_V4L2'],
    'io': [r'^CONFIG_USB', r'^CONFIG_NET', r'^CONFIG_I2C', r'^CONFIG_SPI'],
    'risky': [r'^CONFIG_CFG80211', r'^CONFIG_MAC80211', r'^CONFIG_NFC', r'^CONFIG_BT', r'^CONFIG_WLAN'],
    'sysfs': [r'^CONFIG_SYSFS', r'^CONFIG_PROC_FS', r'^CONFIG_CGROUP', r'^CONFIG_NAMESPACES', r'^CONFIG_SECURITY', r'^CONFIG_AUDIT'],
    'extras': [r'^CONFIG_PREEMPT_RT', r'^CONFIG_LIVEPATCH']
}

# -----------------------------
# Architecture overrides
# -----------------------------
ARCH_OVERRIDES = {
    'arm64': {'CONFIG_ARM64': 'y', 'CONFIG_X86_64': 'n'},
    'x64': {'CONFIG_ARM64': 'n', 'CONFIG_X86_64': 'y'}
}

# -----------------------------
# Parse .config into dict
# -----------------------------
def parse_config(path):
    config = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith('#') and 'is not set' in line:
                key = line.split()[1]
                config[key] = 'n'
                continue
            if '=' in line:
                key, val = line.split('=', 1)
                config[key.strip()] = val.strip()
    return config

# -----------------------------
# Auto-assign config entries to groups
# -----------------------------
def assign_groups(config):
    grouped = defaultdict(dict)
    for key, val in config.items():
        matched = False
        for group, patterns in GROUP_PATTERNS.items():
            for pattern in patterns:
                if re.match(pattern, key):
                    grouped[group][key] = val
                    matched = True
                    break
            if matched:
                break
        if not matched:
            grouped['ungrouped'][key] = val
    return grouped

# -----------------------------
# Write shards to files
# -----------------------------
def write_shards(grouped, out_dir='shards'):
    os.makedirs(out_dir, exist_ok=True)
    for group, entries in grouped.items():
        path = os.path.join(out_dir, f'{group}.config')
        with open(path, 'w') as f:
            for k, v in entries.items():
                f.write(f'{k}={v}\n')
    print(f"Shards written to '{out_dir}/'")

# -----------------------------
# Apply architecture overrides
# -----------------------------
def apply_arch(config, arch):
    for k, v in ARCH_OVERRIDES.get(arch, {}).items():
        config[k] = v

# -----------------------------
# Rebuild .config from selected shards
# -----------------------------
def rebuild_config(shards, out_file='.config', shards_dir='shards'):
    with open(out_file, 'w') as outf:
        for shard in shards:
            shard_path = os.path.join(shards_dir, f'{shard}.config')
            if os.path.isfile(shard_path):
                with open(shard_path) as sf:
                    outf.write(sf.read())
    print(f"Rebuilt .config as '{out_file}'")

# -----------------------------
# CLI
# -----------------------------
def main():
    parser = argparse.ArgumentParser(description='Auto-Sorting Kernel Config Sharder')
    parser.add_argument('action', choices=['shard', 'rebuild'], help='Action to perform')
    parser.add_argument('--config', '-c', default='.config', help='Input kernel config')
    parser.add_argument('--arch', choices=['arm64', 'x64'], default=None, help='Apply arch override')
    parser.add_argument('--shards', '-s', nargs='+', default=None, help='Shards to rebuild')
    parser.add_argument('--out', '-o', default='.config', help='Output .config file')
    args = parser.parse_args()

    if args.action == 'shard':
        cfg = parse_config(args.config)
        if args.arch:
            apply_arch(cfg, args.arch)
        grouped = assign_groups(cfg)
        write_shards(grouped)
    elif args.action == 'rebuild':
        if not args.shards:
            print("Specify shards to rebuild with --shards")
            return
        rebuild_config(args.shards, out_file=args.out)
    else:
        print("Unknown action")

if __name__ == '__main__':
    main()
