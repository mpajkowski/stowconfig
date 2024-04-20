#!/bin/sh

SOURCE="$(git rev-parse --show-toplevel)"
TARGET="$SOURCE/.."

stow --dotfiles --dir=$SOURCE --target=$TARGET . --no-folding
