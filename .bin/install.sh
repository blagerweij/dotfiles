#!/usr/bin/env sh

DOT_REPO=git@github.com:blagerweij/dot-files.git

git clone --bare $DOT_REPO $HOME/.dotfiles
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@'
mkdir -p .config-backup
dot checkout
dot config status.showUntrackedFiles no
