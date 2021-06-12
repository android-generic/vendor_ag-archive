#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
config_type="$1"

processes=$(nproc --all)
proc=$(( $processes / 2 + 1 ))
if [ ! -d "$rompath/vendor/gearlock" ]; then
	echo "Cloning repo"
	git clone https://github.com/axonasif/gearlock vendor/gearlock
fi
echo "Gearlock is ready"
