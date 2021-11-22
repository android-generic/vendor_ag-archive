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
make_type=""
desktop_mode=""

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
	echo -e ${product} > $temp_path/product.config
	
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
	echo -e ${variant} > $temp_path/variant.config
	
	
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
		"OpenGapps"
		"Vanilla")
	menu "FOSS" "GMS" "EMU-Gapps" "OpenGapps" "Vanilla"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "FOSS" ]; then
		echo "you chose ${answer}"		
		if [ ! -d $rompath/vendor/foss ]; then
			echo -e "Cloning vendor/foss now. You will need to re-run this command"
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
		apps="None"
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

# nb_type

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

makeType() {
	# Apps type selection	
	alert_message 'Which make type do you want?'
	echo -e ${CL_CYN}"(default is 'Standard .iso Image')"
	TMOUT=10
	title="Choose an apps type"
	selection=("Standard .iso Image"
		"EFI .img file"
		"RPM Linux Installer")
	menu "Standard .iso Image" "EFI .img file" "RPM Linux Installer"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "Standard .iso Image" ]; then
		echo "you chose ${answer}"
		make_type="iso_img"
		echo -e ${make_type} > $temp_path/make_type.config
	elif [ "${answer}" = "EFI .img file" ]; then
		echo "you chose ${answer}"
		make_type="efi_img"
		echo -e ${make_type} > $temp_path/make_type.config
	elif [ "${answer}" = "RPM Linux Installer" ]; then
		echo "you chose ${answer}"
		make_type="rpm"
		echo -e ${make_type} > $temp_path/make_type.config
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

extraOptions() {
	list "Make Clean before build" "No Kernel Cross-Compile"
	IFS=$'\n'
	array=$(0< "${dir_tmp}/${file_tmp}" )
	for option in "$array"; do
		if _contains "${option}" "Make Clean before build"; then
		  clean="&& make clean "
		  echo -e ${clean} > $temp_path/clean.config
		fi
		if _contains "${option}" "No Kernel Cross-Compile"; then
		  nkcc="&& export NO_KERNEL_CROSS_COMPILE=true "
		  echo -e ${nkcc} > $temp_path/nkcc.config
		fi
		if ! _contains "${option}" "Make Clean before build"; then
		  clean=""
		  echo -e ${clean} > $temp_path/clean.config
		fi
		if ! _contains "${option}" "No Kernel Cross-Compile"; then
		  nkcc=""
		  echo -e ${nkcc} > $temp_path/nkcc.config
		fi
	done
}

desktopMode() {
	# Apps type selection
	if [ -d $rompath/vendor/prebuilts/agp-apps ]; then
		alert_message 'Which make type of Desktop Mode do you want?'
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
	else
		echo -e ${CL_CYN} "agp-apps are needed for Desktop Mode options."${CL_RST}
		echo -e ${CL_CYN} "cloning that now and adding to device tree..."${CL_RST}
		. vendor/ag/pc_scripts/tools-add-ag-prebuilt-apps/tools-add-ag-prebuilt-apps.sh
		echo -e ${CL_CYN} "You can nor run the desktop mode selection again to choose desired mode"${CL_RST}
	fi
	
}


runMakeClean() {
	alert_message 'Are you sure you want to make clean? It will wipe your compile progress and start over'
	
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

enableRustik() {
	# Enable rusgik
	shell_cmd="$SHELL"
	if [ "$product" == "" ]; then
		alert_message 'you need to select a product type'
	else
		if [ "$product" == "android_x86_64" ]; then
			if [ -d "$HOME/.cargo/bin" ] ; then
				export PATH="$HOME/.cargo/bin:$PATH"
			fi
			cd $rompath/rusgik
			rcmd1="rustup target add x86_64-unknown-linux-musl"
			rcmd2="RUSTFLAGS='-C link-arg=-s' cargo build --release --target x86_64-unknown-linux-musl"
			echo -e ${rcmd1} > $temp_path/rcmd1.sh
			chmod -x $temp_path/rcmd1.sh
			cp $temp_path/rcmd1.sh $rompath/rusgik
			echo -e ${rcmd2} > $temp_path/rcmd2.sh
			chmod -x $temp_path/rcmd2.sh
			cp $temp_path/rcmd2.sh $rompath/rusgik
			cat rcmd1.sh
			bash rcmd1.sh
			cat rcmd2.sh
			bash rcmd2.sh
			cd $rompath
		elif [ "$product" == "android_x86" ]; then
			if [ -d "$HOME/.cargo/bin" ] ; then
				export PATH="$HOME/.cargo/bin:$PATH"
			fi
			cd $rompath/rusgik
			rcmd1="rustup target add i686-unknown-linux-musl"
			rcmd2="RUSTFLAGS='-C link-arg=-s' cargo build --release --target i686-unknown-linux-musl"
			echo -e ${rcmd1} > $temp_path/rcmd1.sh
			chmod -x $temp_path/rcmd1.sh
			cp $temp_path/rcmd1.sh $rompath/rusgik
			echo -e ${rcmd2} > $temp_path/rcmd2.sh
			chmod -x $temp_path/rcmd2.sh
			cp $temp_path/rcmd2.sh $rompath/rusgik
			cat rcmd1.sh
			bash rcmd1.sh
			cat rcmd2.sh
			bash rcmd2.sh
			cd $rompath
		else 
			alert_message 'The current product type is not supported'
		fi
	fi
	
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
	if [ "$make_type" == "" ]; then
		alert_message 'you need to select a make type'
	fi
	if [ ! "$variant" == "" ] | [ ! "$product" == "" ] | [ ! "$apps" == "" ] | [ ! "$nb_type" == "" ]| [ ! "$make_type" == "" ]; then
		if [ "$apps" = "none" ]; then
			apps=""
		fi
		if [ "$nb_type" = "none" ]; then
			nb_type=""
		fi
		
		lunchtype="$product-$variant"
		echo -e ${lunchtype} > $temp_path/lunch.config
		full_command="$env && lunch $lunchtype $clean $apps $nb_type $desktop_mode $nkcc && make -j$(nproc --all) $make_type"
		echo -e ${full_command} > $temp_path/command.sh 
		chmod -x $temp_path/command.sh
		echo -e "Full Command saved"
		echo -e "$full_command"
		echo ""
		echo "Project Working Path: $rompath"
		echo ""
		cd $rompath
		bash $temp_path/command.sh
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
if [ -f $temp_path/nkcc.config ]; then
	nkcc=$(cat $temp_path/nkcc.config)
	echo "nkcc command loaded: ${nkcc}"
fi

while :
	do
	menu "Select Product Type" "Select Variant Type" "Select Apps Type" "Select Native-Bridge Type" "Select make type" "Select Desktop Mode integration" "Select Extra Options" "Run Make Clean" "Enable Rusty-Magisk" "Start the Build" 
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
	if [ "${answer}" = "Select make type" ]; then
		echo "Selected ${answer}"
		makeType
	fi
	if [ "${answer}" = "Select Desktop Mode integration" ]; then
		echo "Selected ${answer}"
		desktopMode
	fi
	if [ "${answer}" = "Run Make Clean" ]; then
		echo "Selected ${answer}"
		runMakeClean
	fi
	if [ "${answer}" = "Enable Rusty-Magisk" ]; then
		echo "Selected ${answer}"
		enableRustik
	fi
	
done

lunch="$product-$variant"
echo -e "$lunch"
clean_temp
