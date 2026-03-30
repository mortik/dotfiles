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

ansible-playbook base.yml -i hosts -e @vault.yml --ask-become-pass $tags

echo
echo "Provisioning Finished!"
echo
