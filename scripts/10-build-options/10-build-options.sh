#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
config_type="$1"
modulepath="$rompath/vendor/$vendor_path/scripts"
privmodulepath="$rompath/vendor/$vendor_path/private-scripts"
export supertitle="Android Generic Project - Build Options"
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

_contains () {
  echo "$1" | grep -q "$2"
}

# Build Command Parts
# . build/envsetup.sh && make clean && lunch android_x86-userdebug && export BLISS_BUILD_VARIANT=foss && export USE_CROS_HOUDINI_NB=true && export NO_KERNEL_CROSS_COMPILE=true && export IS_VBOX_x86_BUILD=false && mka iso_img
# - Envsetup
env=". build/envsetup.sh "
# - Clean Steps
clean=""
# - Lunch Option (product + variant)
lunch=""
product=""
variant=""
# - Export Options (emugapps,gms,foss,vanilla, etc)
exp=""
apps=""
nb_type=""
magisk=""
gearlock=""
# - Make Command (iso_img, efi_img, rpm)
mak=""

productType() {
	# Device type selection	
	alert_message 'Which device type do you plan on building?'
	echo -e ${CL_CYN}"(default is 'android_x86_64')"
	TMOUT=10
	title="Choose a device type"
	selection=("android_x86_64" 
		"android_x86")
	menu "android_x86_64" "android_x86"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	product="${answer}"
	
}

variantType() {
	# Device type selection	
	alert_message 'Which variant type do you plan on building?'
	echo -e ${CL_CYN}"(default is 'userdebug')"
	TMOUT=10
	title="Choose a device type"
	selection=("Build Variant:userdebug"
		"Build Variant:user"
		"Build Variant:eng")
	menu "Build Variant:userdebug" "Build Variant:user" "Build Variant:eng"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "Build Variant:userdebug" ]; then
		echo "you chose ${answer}"
		variant="userdebug"
	elif [ "${answer}" = "Build Variant:user" ]; then
		echo "you chose ${answer}"
		variant="user"
	elif [ "${answer}" = "Build Variant:eng" ]; then
		echo "you chose ${answer}"
		variant="eng"
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

appsType() {
	# Apps type selection	
	alert_message 'Which app variant would you like to include?'
	echo -e ${CL_CYN}"(default is 'foss')"
	TMOUT=10
	title="Choose an apps type"
	selection=("FOSS"
		"GMS"
		"EMU-Gapps"
		"Vanilla")
	menu "FOSS" "GMS" "EMU-Gapps" "Vanilla"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "FOSS" ]; then
		echo "you chose ${answer}"		
		if [ ! -d $rompath/vendor/foss ]; then
			echo -e "You will need to clone the emu-gapps into $rompath/vendor/google/emu-gapps first"
		else
			apps="foss"
			export USE_FOSS_APPS=true
			export USE_EMU_GAPPS=false
			export USE_GMS=false
			if [ -d $rompath/vendor/foss/bin ]; then
				echo -e "Foss vendor apps already pulled"
				#~ TMOUT=10
				echo ${purple}"Default Answer = N, Timeout in $TMOUT sec."${CL_RST}
				#~ question "Do you want to refresh/update FOSS apps?"
				menu "Update FOSS apps" "Do not update"
				choice="$( 0< "${dir_tmp}/${file_tmp}" )"
				#~ answer="${?}"
				if [ "${choice}" = "Do not update" ]
					then
					ok_message "doing nothing"
				elif [ "${choice}" = "Update FOSS apps" ]; then
					if [ "$product" == "android_x86_64" ]; then
						ok_message "updating x86_64 foss apps now"
						cd $rompath/vendor/foss/
						bash $rompath/vendor/foss/update.sh 1
						cd $rompath
					elif [ "$product" == "android_x86" ]; then
						ok_message "updating x86 foss apps now"
						cd $rompath/vendor/foss/
						bash $rompath/vendor/foss/update.sh 3
						cd $rompath
					else
						ok_message "updating foss apps now"
						cd $rompath/vendor/foss/
						bash $rompath/vendor/foss/update.sh
						cd $rompath
					fi
				else
					
					exit 0
				fi

			else
				if [ "$product" == "android_x86_64" ]; then
					ok_message "updating x86_64 foss apps now"
					cd $rompath/vendor/foss/
					bash $rompath/vendor/foss/update.sh 1
					cd $rompath
				elif [ "$product" == "android_x86" ]; then
					ok_message "updating x86 foss apps now"
					cd $rompath/vendor/foss/
					bash $rompath/vendor/foss/update.sh 3
					cd $rompath
				else
					ok_message "updating foss apps now"
					cd $rompath/vendor/foss/
					bash $rompath/vendor/foss/update.sh
					cd $rompath
				fi
			fi
		fi		
	elif [ "${answer}" = "GMS" ]; then
		echo "you chose ${answer}"
		if [ ! -d $rompath/vendor/gms ]; then
			echo -e "You will need to clone the gms into $rompath/vendor/gms first"
		else
			apps="gms"
			export USE_GMS=true
			export USE_EMU_GAPPS=false
			export USE_FOSS_APPS=false
		fi
	elif [ "${answer}" = "EMU-Gapps" ]; then
		echo "you chose ${answer}"
		if [ ! -d $rompath/vendor/google/emu-gapps ]; then
			echo -e "You will need to clone the emu-gapps into $rompath/vendor/google/emu-gapps first"
		else
			apps="emugapps"
			export USE_EMU_GAPPS=true
			export USE_GMS=false
			export USE_FOSS_APPS=false
		fi
	elif [ "${answer}" = "Vanilla" ]; then
		echo "you chose ${answer}"
		apps="none"
		export USE_EMU_GAPPS=false
		export USE_GMS=false
		export USE_FOSS_APPS=false
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

nbType() {
	# Apps type selection	
	alert_message 'Which type of native-bridge would you like to include?'
	echo -e ${CL_CYN}"(default is 'None')"
	TMOUT=10
	title="Choose an apps type"
	selection=("None"
		"Intel's Houdini"
		"Google's libndk-translation")
	menu "None" "Intel's Houdini" "Google's libndk-translation"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "None" ]; then
		echo "you chose ${answer}"
		nb_type="none"
		export USE_LIBNDK_TRANSLATION_NB=false
		export USE_CROS_HOUDINI_NB=false
	elif [ "${answer}" = "Intel's Houdini" ]; then
		echo "you chose ${answer}"
		nb_type="houdini"
		export USE_LIBNDK_TRANSLATION_NB=false
		export USE_CROS_HOUDINI_NB=true
	elif [ "${answer}" = "Google's libndk-translation" ]; then
		echo "you chose ${answer}"
		nb_type="libndk"
		export USE_LIBNDK_TRANSLATION_NB=true
		export USE_CROS_HOUDINI_NB=false
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

extraOptions() {
	list "Make Clean before build"
	IFS=$'\n'
	array=$(0< "${dir_tmp}/${file_tmp}" )
	for option in "$array"; do
		if _contains "${option}" "Make Clean before build"; then
		  clean="make clean"
		fi
	done
}

runBuild() {
	if [ "$nb_type" == "" ]; then
		alert_message 'you need to select a native-bridge option'
	fi
	if [ "$apps" == "" ]; then
		alert_message 'you need to select an apps option'
	fi
	if [ "$variant" == "" ]; then
		alert_message 'you need to select a variant type'
	fi
	if [ "$product" == "" ]; then
		alert_message 'you need to select a product type'
	fi
	if [ ! "$variant" == "" ] | [ ! "$product" == "" ] | [ ! "$apps" == "" ] | [ ! "$nb_type" == "" ]; then
		lunch="$product-$variant"
		echo -e "$lunch"
		echo ""
		echo "Project Working Path: $rompath"
		echo ""
		cd $rompath
		#~ $env
		. build/envsetup.sh
		lunch $lunch
		$clean
		make -j$(nproc --all) iso_img
	fi
}

# Main Program
#~ productType
#~ variantType
#~ appsType
#~ nbType
#~ extraOptions
#~ runBuild

while :
	do
	menu "Select Product Type" "Select Variant Type" "Select Apps Type" "Select Native-Bridge Type" "Select Extra Options" "Start the Build"
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "" ]; then
		exit
	fi
	if [ "${answer}" = "Select Product Type" ]; then
		echo "Selected ${answer}"
		productType
	fi
	if [ "${answer}" = "Select Variant Type" ]; then
		echo "Selected ${answer}"
		variantType
	fi
	if [ "${answer}" = "Select Apps Type" ]; then
		echo "Selected ${answer}"
		appsType
	fi
	if [ "${answer}" = "Select Native-Bridge Type" ]; then
		echo "Selected ${answer}"
		nbType
	fi
	if [ "${answer}" = "Select Extra Options" ]; then
		echo "Selected ${answer}"
		extraOptions
	fi
	if [ "${answer}" = "Start the Build" ]; then
		echo "Selected ${answer}"
		runBuild
	fi
	
done

lunch="$product-$variant"
echo -e "$lunch"
clean_temp
