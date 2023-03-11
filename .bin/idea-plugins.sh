#!/usr/bin/env sh

for plugin in $(cat idea-plugins.txt); do
  /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea installPlugins $plugin
done
