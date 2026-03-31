#!/usr/bin/env bash

set -eu

export PATH="/opt/homebrew/bin:$PATH"

echo
echo "Starting Provisioning..."
echo

tags=""
tag_names="$@"
echo $tag_names
if [ -n "${tag_names}" ]; then
  tags="-t $tag_names"
fi

read -s -p "BECOME password: " BECOME_PASS
echo

op inject -i vault.yml -o vault.resolved.yml
ansible-playbook base.yml -i hosts -e @vault.resolved.yml -e "ansible_become_pass=${BECOME_PASS}" $tags
rm -f vault.resolved.yml

echo
echo "Provisioning Finished!"
echo
