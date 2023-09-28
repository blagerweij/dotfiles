#!/usr/bin/env sh

brew bundle install

npm install -g $(jq -r '.dependencies | keys | join("\n")' npm-global-package.json | sed '/npm/d;/corepack/d')

for plugin in $(cat idea-plugins.txt); do
  /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea installPlugins $plugin
done
