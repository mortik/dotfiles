#!/usr/bin/env bash
echo
echo "Starting Setup..."
echo

# update
sudo apt update && sudo apt -yq upgrade

# install ansible
sudo apt -yq install ansible

if [ ! -f vault.yml ]; then
  read -p "1Password vault name: " OP_VAULT
  read -p "Hostname: " HOSTNAME_VAL
  sed \
    -e "s/your-vault/${OP_VAULT}/g" \
    -e "s/^hostname: \"\"/hostname: \"${HOSTNAME_VAL}\"/" \
    vault.example-linux.yml > vault.yml
fi

echo
echo "Setup Finished!"
echo
