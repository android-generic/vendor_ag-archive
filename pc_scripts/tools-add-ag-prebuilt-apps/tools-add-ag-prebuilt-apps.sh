#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
config_type="$1"

processes=$(nproc --all)
proc=$(( $processes / 2 + 1 ))
if [ ! -d "$rompath/vendor/prebuilts/agp-apps" ]; then
	echo "Cloning repo"
	git clone https://gitlab.com/android-generic/vendor_prebuilts_agp-apps.git vendor/prebuilts/agp-apps
fi

cd device/generic/common 
command=`git log --pretty="format:%aD, %s" | grep -F "Add AGP-Apps"`

if [ -n "$command" ]; then
	echo "ALREADY THERE"
else
    echo "NOT THERE, ADDING"
	
cat >> device.mk <<\EOF

# Add agp-apps
$(call inherit-product-if-exists, vendor/prebuilts/agp-apps/agp-apps.mk)

EOF

	git add .
	git commit -a -m "Add AGP-Apps" --author="AGP-BOT <contact@blisslabs.org>"
	cd $rompath
fi
