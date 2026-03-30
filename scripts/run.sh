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

ansible-playbook base.yml -i hosts -e @vault.yml -e "ansible_become_pass=${BECOME_PASS}" $tags

echo
echo "Provisioning Finished!"
echo
