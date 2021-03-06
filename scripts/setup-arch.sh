#!/usr/bin/env bash
echo
echo "Starting Setup..."
echo

# update
sudo pacman -Syu

# install ansible
sudo pacman -S ansible

if [ ! -f vault.yml ]; then
  cp vault.example-linux.yml vault.yml
fi

echo
echo "Setup Finished!"
echo
