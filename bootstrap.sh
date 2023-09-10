#!/bin/sh

XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
key="$XDG_STATE_HOME/ssh/id_ed25519_github"
comment="$(whoami)@$(cat /etc/hostname)"

pacman -Syu --noconfirm zsh github-cli git openssh

mkdir -p "$XDG_STATE_HOME/ssh"
ssh-keygen \
    -t ed25519 \
    -C "$comment" \
    -f "$key" \
    -N "" \
    <<< y # overwrite

gh auth login
gh auth setup-git --hostname github.com
printf "{\"title\":\"$comment\",\"key\":\"$(cat "$key")\"}" \
    | gh api user/keys --input - --method POST

cd "$HOME"
git clone \
    -c "core.sshCommand=ssh -i \"$key\" -F /dev/null" \
    git@github.com:SimonBarkehanai/config.git
cd config

zsh ./setup.sh
