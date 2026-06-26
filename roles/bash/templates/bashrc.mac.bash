#!/bin/bash
# Group-writable by default so files this account creates under shared
# locations (e.g. /opt/homebrew) stay editable by other admin users.
umask 002

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

export CDPATH={{ bash_cdpath }}

# append to the history file, don't overwrite it
shopt -s histappend

# add this configuration to ~/.bashrc
export HH_CONFIG=hicolor         # get more colors
shopt -s histappend              # append new history items to .bash_history
export HISTCONTROL=ignorespace   # leading space hides commands from history
export HISTFILESIZE=10000        # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"   # mem/file sync
# if this is interactive shell, then bind hh to Ctrl-r (for Vi mode check doc)
if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hh -- \C-j"'; fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable bash globbing
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Modify PATH
export PATH=$PATH:$HOME/Applications/bin
export PATH=/usr/local/share/npm/bin:$PATH # Add NPM binaries
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.composer/vendor/bin
export PATH="/usr/local/opt/python@2/libexec/bin:$PATH"

# Set editor
export EDITOR={{ editor }}

export MT_NO_EXPECTATIONS=yes

ssh-add -A 2> /dev/null

# VM Setup
export VM_PATH=~/Documents/Virtual-Machines.localized

# shellcheck source=/dev/null
for config in $HOME/.bashrc.d/*.bash ; do
  [ -e "$config" ] && source $config
done

# shellcheck source=/dev/null
for config in $HOME/.bashrc.d/aliases/*.bash ; do
  [ -e "$config" ] && source $config
done
