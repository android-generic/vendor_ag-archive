#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
config_type="$1"

#~ command=$(repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune)
#~ string="remove*project"

#~ var=$($command | grep -c $string)

#~ if [ $var > 0 ];
#~ then
    #~ echo -e "You will need to either remove a project from .repo/local_manifests/01-remove.xml or check the output for a different error"
#~ else
    #~ echo "Done"
#~ fi
processes=$(nproc --all)
proc=$(( $processes / 2 + 1 ))

repo sync --force-sync -j$proc
