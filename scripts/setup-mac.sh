#!/usr/bin/env bash
echo
echo "Starting Setup..."
echo

# command line tools
xcode-select --install

# brew
echo "Setup Brew..."

export PATH="/opt/homebrew/bin:$PATH"

which -s brew
if [[ $? != 0 ]] ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    brew update && brew upgrade && brew cleanup
fi

brew install ansible

if [ ! -f vault.yml ]; then
  read -p "1Password vault name: " OP_VAULT
  read -p "Hostname: " HOSTNAME_VAL
  sed \
    -e "s/your-vault/${OP_VAULT}/g" \
    -e "s/^hostname: \"\"/hostname: \"${HOSTNAME_VAL}\"/" \
    vault.example-mac.yml > vault.yml
fi

echo
echo "Setup Finished!"
echo
