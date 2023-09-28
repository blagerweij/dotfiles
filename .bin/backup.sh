#!/usr/bin/env sh

brew bundle dump --force
npm list -g --json > npm-global-package.json



