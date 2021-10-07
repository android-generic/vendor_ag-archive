#!/bin/bash
rompath="$PWD"
processes=$(nproc --all)
proc=$(( $processes / 2 + 1 ))

repo sync -c --force-sync --no-tags --no-clone-bundle -j$proc --optimized-fetch --prune
