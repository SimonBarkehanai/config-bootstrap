#!/bin/sh

XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/state}"
key="$XDG_STATE_HOME/ssh/id_ed25519_github"
comment="$(whoami)@$(cat /etc/hostname)"

sudo pacman -Syu --noconfirm zsh github-cli git openssh

mkdir -p "$XDG_STATE_HOME/ssh"
ssh-keygen \
    -t ed25519 \
    -C "$comment" \
    -f "$key" \
    -N "" \
    <<< y # overwrite

gh auth login -s admin:public_key
gh auth setup-git --hostname github.com
gh api \
    --method POST \
    /user/keys \
    -f title="$comment" \
    -f key="$(cat $key.pub)"

cd "$HOME"
git clone \
    -c "core.sshCommand=ssh -i \"$key\" -F /dev/null" \
    git@github.com:SimonBarkehanai/config.git
cd config
git submodule update --init --recursive

zsh ./setup.sh
