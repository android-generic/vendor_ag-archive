#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
config_type="$1"

modulepath="$rompath/vendor/$vendor_path/scripts"
privmodulepath="$rompath/vendor/$vendor_path/private-scripts"
export supertitle="Android Generic Project - Gearlock Options"
export supericon="$rompath/vendor/$vendor_path/ag-core/includes/ag-logo.png"
source $rompath/vendor/$vendor_path/ag-core/gui/easybashgui

#setup colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
teal=`tput setaf 6`
light=`tput setaf 7`
dark=`tput setaf 8`
ltred=`tput setaf 9`
ltgreen=`tput setaf 10`
ltyellow=`tput setaf 11`
ltblue=`tput setaf 12`
ltpurple=`tput setaf 13`
CL_CYN=`tput setaf 12`
CL_RST=`tput sgr0`
reset=`tput sgr0`

processes=$(nproc --all)
proc=$(( $processes / 2 + 1 ))

useGearlock() {
	# Gearlock selection	
	alert_message 'Select to add/remove Gearlock from your setup'
	echo -e ${CL_CYN}"(default is 'Add')"
	TMOUT=10
	title="Select the option you wish"
	selection=("Include Gearlock"
		"Remove Gearlock")
	menu "Include Gearlock" "Remove Gearlock"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "Include Gearlock" ]; then
		echo "you chose ${answer}"
		if [ ! -d "$rompath/vendor/gearlock" ]; then
			echo "Cloning repo"
			git clone https://github.com/axonasif/gearlock vendor/gearlock
		fi
		echo "Gearlock is ready"
	elif [ "${answer}" = "Remove Gearlock" ]; then
		echo "you chose ${answer}"
		if [ -d "$rompath/vendor/gearlock" ]; then
			echo "You wqill have to manually revert Commits in bootable/newinstaller and device/generic/common"
			echo ""
			echo "Removing repo"
			rm -rf $rompath/vendor/gearlock
		fi
		echo "Gearlock is removed"
	else
		echo "invalid option ${answer}"
		exit
	fi	
	
}

useGearlock
