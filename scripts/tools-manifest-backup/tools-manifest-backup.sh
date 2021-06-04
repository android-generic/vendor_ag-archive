#!/bin/bash

rom_fp="$(date +%y%m%d)"
rompath=$(pwd)
vendor_path="ag"

#setup colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
teal=`tput setaf 6`
light=`tput setaf 7`
dark=`tput setaf 8`
CL_CYN=`tput setaf 12`
CL_RST=`tput sgr0`
reset=`tput sgr0`

echo -e ${blue}"Backup starting..."${CL_RST}
	
echo "making a revisional manifest backup now"
echo "This might take a while..."
repo manifest -o agmanifest.xml -r
echo -e ${CL_CYN}""${CL_RST}
echo -e ${green}"manifest created"${CL_RST}
if [ -d $rompath/vendor/$vendor_path/vendor-manifests/ ]; then
	mv agmanifest.xml $rompath/vendor/$vendor_path/vendor-manifests/manifest.xml
	echo -e ${CL_CYN}""${CL_RST}
	echo "Moving manifest to $rompath/vendor/$vendor_path/vendor-manifests/manifest.xml"
else
	mkdir -p $rompath/vendor/$vendor_path/vendor-manifests/
	mv agmanifest.xml $rompath/vendor/$vendor_path/vendor-manifests/manifest.xml
	echo -e ${CL_CYN}""${CL_RST}
	echo "Moving manifest to $rompath/vendor/$vendor_path/vendor-manifests/manifest.xml"
fi
	
