# Keep your dotfiles in git

## Introduction

Why ? No extra tooling, no symlinks, files are tracked on a version control system, you can use different branches for different computers, you can replicate you configuration easily on new installation.

## Requirements

- git
- curl

The technique consists in storing a Git bare repository in a "side" folder (like `$HOME/.dotfiles`) using a specially crafted alias so that commands are run against that repository and not the usual .git local folder, which would interfere with any other Git repositories around.

## Starting from scratch

If you haven't been tracking your configurations in a Git repository before, you can start using this technique easily with these lines:

    git init --bare $HOME/.dotfiles
    alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    dot config --local status.showUntrackedFiles no

The first line creates a folder `~/.dotfiles` which is a Git bare repository that will track our files.
Then we create an alias `dot` which we will use instead of the regular git when we want to interact with our configuration repository.
We set a flag `--local` to the repository - to hide files we are not explicitly tracking yet. This is so that when you type `dot status` and other commands later, files you are not interested in tracking will not show up as untracked.
Also you can add the alias definition by hand to your .bashrc or use the the fourth line provided for convenience.

After you've executed the setup any file within the $HOME folder can be versioned with normal commands, replacing git with your newly created `dot` alias, like:

    dot status
    dot add .vimrc
    dot commit -m "Add vimrc"
    dot add .bashrc
    dot commit -m "Add bashrc"
    dot push

## Install your dotfiles onto a new system (or migrate to this setup)

If you have stored your configuration/dotfiles in a Git repository, and want to migrate to a new system, you can setup with the following steps:

### Install homebrew

Homebrew is a very convenient package manager for MacOS. On a fresh machine, you'll need to install Homebrew first:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

This step should also install the XCode Command Line Tools, which includes Git. You'll need Git installed for the next steps.

### Setup your private key

Goto the website of the password manager of your choice (e.g. bitwarden.com) to grab your private key, save in .ssh

### Clone your dotfiles

First clone your dotfiles into a bare repository in a "dot" folder of your $HOME, then checkout the actual content from the bare repository to your $HOME:

    git clone --bare <git-repo-url> $HOME/.dotfiles
    alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    dot config --local status.showUntrackedFiles no
    dot checkout

The step above might fail with a message like:

    error: The following untracked working tree files would be overwritten by checkout:
        .bashrc
        .gitignore
    Please move or remove them before you can switch branches.
    Aborting

This is because your $HOME folder might already have some stock configuration files which would be overwritten by Git. The solution is simple: back up (move) the files if you care about them, remove them if you don't care.
Then retry `dot checkout` until all local files are resolved.

You're done, from now on you can now type `dot` commands to add and update your dotfiles:

    dot status
    dot add .vimrc
    dot commit -m "Add vimrc"
    dot add .bashrc
    dot commit -m "Add bashrc"
    dot push

## Encrypting sensitive files

Some files might contain passwords or other sensitive data. You can encrypt them using `git-crypt`:

    dot crypt unlock

Update the .gitattributes file in your home-dir to specify which files require encryption.

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

## NPM

To get a list of globally installed NPM packages, use the following command:

    npm list -g --depth=0 --json > npm-global-package.json

Then on a new machine, use the following command to install them again:

    npm install -g $(jq -r '.dependencies | keys | join("\n")' npm-global-package.json | sed '/npm/d;/corepack/d')
