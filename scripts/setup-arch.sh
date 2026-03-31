#!/usr/bin/env bash
echo
echo "Starting Setup..."
echo

# update
sudo pacman -Syu

# install ansible
sudo pacman -S ansible

if [ ! -f vault.yml ]; then
  read -p "1Password vault name: " OP_VAULT
  sed "s/your-vault/${OP_VAULT}/g" vault.example-linux.yml > vault.yml
fi

echo
echo "Setup Finished!"
echo
