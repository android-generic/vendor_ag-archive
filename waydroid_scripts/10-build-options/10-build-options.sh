#!/bin/bash

############################################################
# Test for dependencies                                    #
############################################################
if ! command -v simg2img &> /dev/null
then
    echo "simg2img could not be found. Please install first"
    exit
fi

if ! command -v 7zz &> /dev/null
then
    echo "7zz could not be found. Please install first"
    exit
fi

rompath="$PWD"
ag_vendor_path="ag"
temp_path="$rompath/vendor/$ag_vendor_path/tmp"
config_type="$1"
modulepath="$rompath/vendor/$ag_vendor_path/scripts"
privmodulepath="$rompath/vendor/$ag_vendor_path/private-scripts"
export supertitle="Android Generic Project - Build Options"
export supericon="$rompath/vendor/$ag_vendor_path/ag-core/includes/ag-logo.png"
source $rompath/vendor/$ag_vendor_path/ag-core/gui/easybashgui

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

echo "loading build menu"
echo "Project Working Directory: $rompath"

# Build Command Parts
# . build/envsetup.sh && make clean && lunch bliss_waydroid_x86-userdebug && export BLISS_BUILD_VARIANT=foss && export USE_CROS_HOUDINI_NB=true && export NO_KERNEL_CROSS_COMPILE=true && export IS_VBOX_x86_BUILD=false && mka iso_img
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
make_type=""
desktop_mode=""
wd_package=""
wd_rom_name="Lineage-17.1"
wd_rom_type="lineage"
product_variant=""
prefix=""

if [ -d vendor/bliss ]; then
	wd_rom_type=bliss
	wd_rom_name="Bliss-12"
fi

productType() {
	# Device type selection	
	#~ alert_message 'Which device type do you plan on building?'
	echo -e ${CL_CYN}"(default is 'waydroid_x86_64')"
	TMOUT=10
	title="Choose a device type"
	selection=("${wd_rom_type}_waydroid_x86_64" 
		"${wd_rom_type}_waydroid_x86"
		"${wd_rom_type}_waydroid_arm"
		"${wd_rom_type}_waydroid_arm64")
	menu "${wd_rom_type}_waydroid_x86_64" "${wd_rom_type}_waydroid_x86" "${wd_rom_type}_waydroid_arm" "${wd_rom_type}_waydroid_arm64"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	product="${answer}"
	prefix="${wd_rom_type}_"
	product_variant=$(echo ${product} | sed -e "s/^$prefix//")
	echo -e ${product} > $temp_path/product.config
	echo -e ${product_variant} > $temp_path/product_variant.config
	
}

variantType() {
	# Device type selection	
	#~ alert_message 'Which variant type do you plan on building?'
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
	echo -e ${variant} > $temp_path/variant.config
	
	
}

appsType() {
	# Apps type selection	
	#~ alert_message 'Which app variant would you like to include?'
	echo -e ${CL_CYN}"(default is 'foss')"
	TMOUT=10
	title="Choose an apps type"
	selection=("FOSS"
		"GMS"
		"EMU-Gapps"
		"OpenGapps"
		"Vanilla")
	menu "FOSS" "GMS" "EMU-Gapps" "OpenGapps" "Vanilla"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "FOSS" ]; then
		echo "you chose ${answer}"		
		if [ ! -d $rompath/vendor/foss ]; then
			echo -e "Cloning foss vendor"
			git clone https://github.com/BlissRoms-x86/vendor_foss vendor/foss
		else
			apps="&& export USE_FOSS_APPS=true "
			echo -e ${apps} > $temp_path/apps.config
			if [ -d $rompath/vendor/foss/bin ]; then
				echo -e "Foss vendor apps already pulled"
				echo ${purple}"Default Answer = N, Timeout in $TMOUT sec."${CL_RST}
				menu "Update FOSS apps" "Do not update"
				choice="$( 0< "${dir_tmp}/${file_tmp}" )"
				if [ "${choice}" = "Do not update" ]
					then
					ok_message "doing nothing"
				elif [ "${choice}" = "Update FOSS apps" ]; then
					if [ "$product" == "waydroid_x86_64" ]; then
						ok_message "updating x86_64 foss apps now"
						cd $rompath/vendor/foss/
						bash $rompath/vendor/foss/update.sh 1
						cd $rompath
					elif [ "$product" == "waydroid_arm64" ]; then
						ok_message "updating arm64 foss apps now"
						cd $rompath/vendor/foss/
						bash $rompath/vendor/foss/update.sh 2
						cd $rompath
					elif [ "$product" == "waydroid_x86" ]; then
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
				if [ "$product" == "waydroid_x86_64" ]; then
					ok_message "updating x86_64 foss apps now"
					cd $rompath/vendor/foss/
					bash $rompath/vendor/foss/update.sh 1
					cd $rompath
				elif [ "$product" == "waydroid_arm64" ]; then
					ok_message "updating arm64 foss apps now"
					cd $rompath/vendor/foss/
					bash $rompath/vendor/foss/update.sh 2
					cd $rompath
				elif [ "$product" == "waydroid_x86" ]; then
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
			apps="&& export USE_GMS=true "
			echo -e ${apps} > $temp_path/apps.config
		fi
	elif [ "${answer}" = "EMU-Gapps" ]; then
		echo "you chose ${answer}"
		if [ ! -d $rompath/vendor/google/emu-gapps ]; then
			echo -e "You will need to clone the emu-gapps into $rompath/vendor/google/emu-gapps first"
			git clone https://gitlab.com/BlissRoms/vendor_google_emu-gapps.git vendor/google/emu-gapps
			cd $rompath/vendor/google/emu-gapps
			git checkout origin/r11
			cd $rompath
			if [ -d $rompath/vendor/foss/bin ]; then
				echo -e "Removing foss apps so gapps will work properly"
				rm -rf $rompath/vendor/foss/bin
				rm -rf $rompath/vendor/foss/Android.mk
				rm -rf $rompath/vendor/foss/apps.mk
			fi
			apps="&& export USE_EMU_GAPPS=true"
			echo -e ${apps} > $temp_path/apps.config
		else
			if [ -d $rompath/vendor/foss/bin ]; then
				echo -e "Removing foss apps so gapps will work properly"
				rm -rf $rompath/vendor/foss/bin
				rm -rf $rompath/vendor/foss/Android.mk
				rm -rf $rompath/vendor/foss/apps.mk
			fi
			apps="&& export USE_EMU_GAPPS=true"
			echo -e ${apps} > $temp_path/apps.config
		fi
	elif [ "${answer}" = "OpenGapps" ]; then
		echo "you chose ${answer}"
		if [ ! -d $rompath/vendor/opengapps ]; then
			echo -e "You will need to clone the gms into $rompath/vendor/opengapps first"
		else
			apps="&& export USE_OPENGAPPS=true "
			echo -e ${apps} > $temp_path/apps.config
		fi
	elif [ "${answer}" = "Vanilla" ]; then
		echo "you chose ${answer}"
		apps="none"
		echo -e "none" > $temp_path/apps.config
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

# nb_type

nbType() {
	# Apps type selection	
	#~ alert_message 'Which type of native-bridge would you like to include?'
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
	elif [ "${answer}" = "Intel's Houdini" ]; then
		echo "you chose ${answer}"
		if [ ! -d $rompath/vendor/google/chromeos-x86 ]; then
			echo -e "You don't have it yet. Cloning that into $rompath/vendor/google/chromeos-x86 first"
			git clone https://github.com/BlissRoms-x86/android_vendor_google_chromeos-x86 vendor/google/chromeos-x86
			cd $rompath/vendor/google/chromeos-x86
			bash $rompath/vendor/google/chromeos-x86/extract-files.sh
			cd $rompath
			nb_type="&& export USE_CROS_HOUDINI_NB=true "
			echo -e ${nb_type} > $temp_path/nb_type.config
		else
			nb_type="&& export USE_CROS_HOUDINI_NB=true "
			echo -e ${nb_type} > $temp_path/nb_type.config
			if [ -d $rompath/vendor/google/chromeos-x86/proprietary ]; then 
				echo "files already downloaded"
			else
				cd $rompath/vendor/google/chromeos-x86
				bash $rompath/vendor/google/chromeos-x86/extract-files.sh
				cd $rompath
			fi
		fi
	elif [ "${answer}" = "Google's libndk-translation" ]; then
		echo "you chose ${answer}"
		nb_type="&& export USE_LIBNDK_TRANSLATION_NB=true "
		echo -e ${nb_type} > $temp_path/nb_type.config
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

# make_type

extraOptions() {
	list "Make Clean before build" "Generate Package .zip"
	IFS=$'\n'
	array=$(0< "${dir_tmp}/${file_tmp}" )
	for option in "$array"; do
		if _contains "${option}" "Make Clean before build"; then
		  clean="&& make clean "
		  echo -e ${clean} > $temp_path/clean.config
		fi
		if _contains "${option}" "Generate Package .zip"; then
		  wd_package="true"
		  echo "Packaging set to: ${wd_package}"
		  echo -e ${wd_package} > $temp_path/wd_package.config
		fi
		if ! _contains "${option}" "Make Clean before build"; then
		  clean=""
		  echo -e ${clean} > $temp_path/clean.config
		fi
		if ! _contains "${option}" "Generate Package .zip"; then
		  wd_package=""
		  echo -e ${wd_package} > $temp_path/wd_package.config
		fi
	done
	if [ "${wd_package}" = "true" ]; then
		wd_rom_name=$(zenity --entry --title="Specify ROM Title" --text="Enter name of ROM:" --entry-text "${wd_rom_name}" )
		#~ message 'Verify name of ROM in the next dialog'
		#~ wd_rom_name=$(echo -e "${wd_rom_name}" | text)
		#~ wd_rom_name=$(echo -e "What is the name of ROM" | text)
		if [ ! "${wd_rom_name}" == "" ]; then
			echo "ROM Name set to: ${wd_rom_name}"
			echo -e ${wd_rom_name} > $temp_path/wd_rom_name.config
		else
			echo "No name entered"
		fi
	fi
}

desktopMode() {
	# Apps type selection	
	#~ alert_message 'Which make type of Desktop Mode do you want?'
	echo -e ${CL_CYN}"(default is 'Taskbar')"
	TMOUT=10
	title="Choose a type"
	selection=("Taskbar" "Smart-Dock" "None")
	menu "Taskbar" "Smart-Dock" "None"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "Taskbar" ]; then
		echo "you chose ${answer}"
		desktop_mode="&& export USE_TASKBAR_UI=true "
		echo -e ${desktop_mode} > $temp_path/desktop_mode.config
	elif [ "${answer}" = "Smart-Dock" ]; then
		echo "you chose ${answer}"
		desktop_mode="&& export USE_SMARTDOCK=true "
		echo -e ${desktop_mode} > $temp_path/desktop_mode.config
	elif [ "${answer}" = "None" ]; then
		echo "you chose ${answer}"
		desktop_mode=""
		echo -e ${desktop_mode} > $temp_path/desktop_mode.config
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}


runMakeClean() {
	#~ alert_message 'Are you sure you want to make clean? It will wipe your compile progress and start over'
	
	# Apps type selection	
	alert_message 'Which make type do you want?'
	echo -e ${CL_CYN}"(default is 'Standard .iso Image')"
	TMOUT=10
	title="Choose an apps type"
	selection=("Make Clean just once on it's own")
	menu "Make Clean just once on it's own"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "Make Clean just once on it's own" ]; then
		run_clean_command="$env && make clean"
		echo -e ${run_clean_command} > $temp_path/run_clean_command.sh 
		chmod -x $temp_path/run_clean_command.sh
		echo -e "Clean Command saved"
		echo -e "$run_clean_command"
		echo ""
		echo "Project Working Path: $rompath"
		echo ""
		cd $rompath
		bash $temp_path/run_clean_command.sh
	else
		echo "invalid option ${answer}"
		exit
	fi
}


runBuild() {
	if [ "$variant" == "" ]; then
		alert_message 'you need to select a variant type'
	fi
	if [ "$product" == "" ]; then
		alert_message 'you need to select a product type'
	fi
	if [ "$product_variant" == "" ]; then
		alert_message 'you need to select a product type'
	fi
	
	product_variant
	if [ ! "$variant" == "" ] | [ ! "$product" == "" ] ; then
		if [ "$apps" = "none" ]; then
			apps=""
		fi
		if [ "$nb_type" = "none" ]; then
			nb_type=""
		fi
				
		lunchtype="$product-$variant"
		echo -e ${lunchtype} > $temp_path/lunch.config
		full_command="$env && lunch $lunchtype $clean $apps $nb_type $desktop_mode && make systemimage -j$(nproc --all) && make vendorimage -j$(nproc --all)"
		echo -e ${full_command} > $temp_path/command.sh 
		chmod -x $temp_path/command.sh
		echo -e "Full Command saved"
		echo -e "$full_command"
		echo ""
		echo "Project Working Path: $rompath"
		echo ""
		cd $rompath
		bash $temp_path/command.sh
		
		if [[ $wd_package = "true" ]]
		then
			cd out/target/product/${product_variant} && \
			mv system.img system2.img && \
			mv vendor.img vendor2.img && \
			simg2img system2.img system.img && \
			simg2img vendor2.img vendor.img && \
			rm -rf system2.img && \
			rm -rf vendor2.img && \
			export WAYDROID_DATE=$(date +%Y%m%d%H%M) && \
			7zz a $wd_rom_name-${product_variant}-$WAYDROID_DATE.zip system.img vendor.img && \
			cd $rompath
		fi
	fi
}

# Main Program
#~ productType
#~ variantType
#~ appsType
#~ nbType
#~ makeType
#~ extraOptions
#~ runMakeClean
#~ runBuild

echo "Functions Loaded"

if [ -f $temp_path/command.sh ]; then
	full_command=$(cat $temp_path/command.sh)
	echo "Full command loaded: ${full_command}"
fi
if [ -f $temp_path/apps.config ]; then
	apps=$(cat $temp_path/apps.config)
	echo "apps command loaded: ${apps}"
fi
if [ -f $temp_path/nb_type.config ]; then
	nb_type=$(cat $temp_path/nb_type.config)
	echo "nb_type command loaded: ${nb_type}"
fi
if [ -f $temp_path/lunch.config ]; then
	lunch=$(cat $temp_path/lunch.config)
	echo "lunch command loaded: ${lunch}"
fi
if [ -f $temp_path/product.config ]; then
	product=$(cat $temp_path/product.config)
	echo "product command loaded: ${product}"
fi
if [ -f $temp_path/variant.config ]; then
	variant=$(cat $temp_path/variant.config)
	echo "variant command loaded: ${variant}"
fi
if [ -f $temp_path/clean.config ]; then
	clean=$(cat $temp_path/clean.config)
	echo "clean command loaded: ${clean}"
fi
if [ -f $temp_path/desktop_mode.config ]; then
	desktop_mode=$(cat $temp_path/desktop_mode.config)
	echo "desktop_mode command loaded: ${desktop_mode}"
fi
if [ -f $temp_path/make_type.config ]; then
	make_type=$(cat $temp_path/make_type.config)
	echo "make_type command loaded: ${make_type}"
fi
if [ -f $temp_path/wd_package.config ]; then
	wd_package=$(cat $temp_path/wd_package.config)
	echo "wd_package command loaded: ${wd_package}"
fi

if [ -f $temp_path/wd_rom_name.config ]; then
	wd_rom_name=$(cat $temp_path/wd_rom_name.config)
	echo "rom_name command loaded: ${wd_rom_name}"
fi

while :
	do
	menu "Select Product Type" "Select Variant Type" "Select Apps Type" "Select Native-Bridge Type" "Select Desktop Mode integration" "Select Extra Options" "Run Make Clean" "Start the Build" 
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
	if [ "${answer}" = "Select Desktop Mode integration" ]; then
		echo "Selected ${answer}"
		desktopMode
	fi
	if [ "${answer}" = "Run Make Clean" ]; then
		echo "Selected ${answer}"
		runMakeClean
	fi
	
done

lunch="$product-$variant"
echo -e "$lunch"
clean_temp
