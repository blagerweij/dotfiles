#!/usr/bin/env sh

npm install -g $(jq -r '.dependencies | keys | join("\n")' npm-global-package.json | sed '/npm/d;/corepack/d')
