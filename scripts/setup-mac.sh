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

extract_keys() { grep -E '^[a-z_][a-z_0-9]*:' "$1" | cut -d: -f1; }

extract_key_block() {
  awk -v k="$1" '
    $0 ~ "^" k ":" { p=1; print; next }
    p && /^[a-z_]/ { exit }
    p { print }
  ' "$2"
}

if [ ! -f vault.yml ]; then
  read -p "1Password vault name: " OP_VAULT
  read -p "Hostname: " HOSTNAME_VAL
  sed \
    -e "s/your-vault/${OP_VAULT}/g" \
    -e "s/^hostname: \"\"/hostname: \"${HOSTNAME_VAL}\"/" \
    vault.example-mac.yml > vault.yml
else
  OP_VAULT=$(grep -oE 'op://[^/]+' vault.yml | head -1 | cut -d/ -f3)
  if [ -z "$OP_VAULT" ]; then
    read -p "1Password vault name: " OP_VAULT
  fi

  missing=$(comm -23 <(extract_keys vault.example-mac.yml | sort -u) <(extract_keys vault.yml | sort -u))
  if [ -n "$missing" ]; then
    echo "Syncing new keys from vault.example-mac.yml into vault.yml:"
    for key in $missing; do
      echo "  + $key"
      extract_key_block "$key" vault.example-mac.yml | sed "s/your-vault/${OP_VAULT}/g" >> vault.yml
    done
  fi
fi

echo
echo "Setup Finished!"
echo
