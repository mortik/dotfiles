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
  cp vault.example-mac.yml vault.yml
fi

echo
echo "Setup Finished!"
echo
