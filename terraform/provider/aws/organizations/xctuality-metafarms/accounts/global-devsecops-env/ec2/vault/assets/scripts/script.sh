#!/bin/bash

set -e

# Function to print info messages
info() {
  echo -e "\e[1;34m[INFO]\e[0m $1"
}

# Function to print error messages
error() {
  echo -e "\e[1;31m[ERROR]\e[0m $1"
}

# Detect OS and install prerequisites
info "Detecting operating system..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
else
  error "Unsupported OS."
  exit 1
fi

case "$ID" in
  ubuntu|debian)
    info "Installing prerequisites for Debian/Ubuntu..."
    sudo apt-get update -y
    sudo apt-get install -y curl gnupg software-properties-common
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y
    sudo apt-get install -y vault
    ;;
  centos|rhel|fedora|amzn)
    info "Installing prerequisites for RHEL/CentOS/Amazon Linux..."
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/$ID/hashicorp.repo
    sudo yum install -y vault
    ;;
  *)
    error "Unsupported Linux distribution: $ID"
    exit 1
    ;;
esac

# Enable and start the Vault service
info "Enabling and starting Vault service..."
sudo systemctl enable vault
sudo systemctl start vault

# Check Vault installation
info "Verifying Vault installation..."
vault version

info "Vault installation complete."
