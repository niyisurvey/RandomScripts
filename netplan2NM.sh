#!/usr/bin/env bash

# netplan2NM.sh
# Ubuntu server 20.04 - Change from netplan to NetworkManager for all interfaces
# Updated for Ubuntu 22.04 LTS
# Works as of 10/06/24 (still nice!)

echo 'Starting script to change netplan to NetworkManager on all interfaces'

# Update package lists and upgrade system
echo 'Updating package lists and upgrading system...'
apt update && apt upgrade -y
echo 'System updated.'

# Install NetworkManager without starting it
echo 'Installing NetworkManager...'
apt install -y network-manager
echo 'NetworkManager installed.'

# Backup existing yaml files
echo 'Backing up existing YAML files...'
cd /etc/netplan
cp *.yaml *.yaml.BAK
echo 'Backup complete.'

# Overwrite the yaml file to ensure clean configuration
echo 'Creating new netplan configuration...'
cat << EOF > /etc/netplan/00-installer-config.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: NetworkManager
EOF
echo 'New netplan configuration created.'

# Apply the new netplan configuration
echo 'Generating netplan configuration...'
netplan generate
echo 'Applying netplan configuration...'
netplan apply
echo 'Netplan configuration applied.'

# Ensure NetworkManager is running
echo 'Enabling NetworkManager service...'
systemctl enable NetworkManager.service
echo 'Restarting NetworkManager service...'
systemctl restart NetworkManager.service
echo 'NetworkManager service restarted.'

# Stop, disable, and mask systemd-networkd-wait-online.service
echo 'Stopping systemd-networkd-wait-online.service...'
systemctl stop systemd-networkd-wait-online.service
echo 'Disabling systemd-networkd-wait-online.service...'
systemctl disable systemd-networkd-wait-online.service
echo 'Masking systemd-networkd-wait-online.service...'
systemctl mask systemd-networkd-wait-online.service
echo 'systemd-networkd-wait-online.service stopped, disabled, and masked.'

echo 'Done!'
