#!/usr/bin/env bash

set -eu

echo
echo "Starting Provisioning..."
echo

tags=""
tag_names="$@"
echo $tag_names
if [ -n "${tag_names}" ]; then
  tags="-t $tag_names"
fi

ansible-playbook base.yml -e @vault.yml --ask-sudo-pass $tags

echo
echo "Provisioning Finished!"
echo