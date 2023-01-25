# Keep your dotfiles in git

## Introduction

Why ? No extra tooling, no symlinks, files are tracked on a version control system, you can use different branches for different computers, you can replicate you configuration easily on new installation.

## Requirements

- git
- curl

The technique consists in storing a Git bare repository in a "side" folder (like `$HOME/.myconfig`) using a specially crafted alias so that commands are run against that repository and not the usual .git local folder, which would interfere with any other Git repositories around.

## Starting from scratch

If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

    git init --bare $HOME/.myconfig
    alias my config='/usr/bin/git --git-dir=$HOME/.myconfig/ --work-tree=$HOME'
    myconfig config --local status.showUntrackedFiles no
    echo "alias myconfig='/usr/bin/git --git-dir=$HOME/.myconfig/ --work-tree=$HOME'" >> $HOME/.bashrc

The first line creates a folder `~/.myconfig` which is a Git bare repository that will track our files.
Then we create an alias `myconfig` which we will use instead of the regular git when we want to interact with our configuration repository.
We set a flag `--local` to the repository - to hide files we are not explicitly tracking yet. This is so that when you type config status and other commands later, files you are not interested in tracking will not show up as untracked.
Also you can add the alias definition by hand to your .bashrc or use the the fourth line provided for convenience.

After you've executed the setup any file within the $HOME folder can be versioned with normal commands, replacing git with your newly created config alias, like:

    myconfig status
    myconfig add .vimrc
    myconfig commit -m "Add vimrc"
    myconfig add .bashrc
    myconfig commit -m "Add bashrc"
    myconfig push

## Install your dotfiles onto a new system (or migrate to this setup)

If you already store your configuration/dotfiles in a Git repository, on a new system you can migrate to this setup with the following steps:

First clone your dotfiles into a bare repository in a "dot" folder of your $HOME:

    git clone --bare <git-repo-url> $HOME/.myconfig

Now checkout the actual content from the bare repository to your $HOME:

    git --git-dir=$HOME/.myconfig --work-tree=$HOME checkout

The step above might fail with a message like:

    error: The following untracked working tree files would be overwritten by checkout:
        .bashrc
        .gitignore
    Please move or remove them before you can switch branches.
    Aborting

This is because your $HOME folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up the files if you care about them, remove them if you don't care.

Set the flag showUntrackedFiles to no on this specific (local) repository:

    config config --local status.showUntrackedFiles no

You're done, from now on you can now type config commands to add and update your dotfiles:

    config status
    config add .vimrc
    config commit -m "Add vimrc"
    config add .bashrc
    config commit -m "Add bashrc"
    config push

## Homebrew

Homebrew is a very convenient package manager for MacOS. On a fresh machine, you'll need to install Homebrew first:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then, you can install all packages using the `Brewfile` bundle stored in the .bin folder:

    brew bundle install

## Visual Studio Code extensions

After installing the Homebrew bundle, you should have Visual Studio Code installed. Now you can install all your favorite extensions. Thera are two options:
1) Enable `Settings Sync` in VSCode
2) Install all extensions from the `.vscode/extensions.json` file: From your home directory, run `code .`, then install all workspace recommendations.

## IntelliJ

For Jetbrains IntelliJ IDEA, things work similar: You can either use your Jetbrains account to sync settings (including plugins), or you can use the shell script in the .bin folder:

    .bin/install-idea.sh

