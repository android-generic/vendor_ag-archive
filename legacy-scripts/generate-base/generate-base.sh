rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"
popt=0

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

ask() {
    # https://djm.me/ask
    local prompt default reply

    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}


checkOptions() {
	if [ -f "$temp_path/device-options.lst" ]; then
		TMOUT=10
		echo ${purple}"Default Answer = N, Timeout in $TMOUT sec."${CL_RST}
		if ask "Previous device selection found. Do you want to create a new one?" "N"; then
			popt=0
		else
		
			while IFS=$'\t' read -r dopt kopt; do
				case $dopt in
					"Generic-x86/x86_64")
						echo "you chose choice $REPLY which is $dopt"
						cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/devices/generic/* $rompath/.repo/local_manifests
						break
						;;
					"Intel-x86/x86_64-with-Intel-iGPU")
						echo "you chose choice $REPLY which is $dopt"
						cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/devices/intel/* $rompath/.repo/local_manifests
						break
						;;
					*) echo "invalid option $REPLY";;
				esac
				case $kopt in
					"AOSP-Kernel-5.4-lts")
						echo "you chose choice $REPLY which is $kopt"
						cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.4/* $rompath/.repo/local_manifests
						break
						;;
					"Bliss-OS-kernel-5.8")
						echo "you chose choice $REPLY which is $kopt"
						cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.8/* $rompath/.repo/local_manifests
						break
						;;
					"Darkmatter-kernel-5.10")
						echo "you chose choice $REPLY which is $kopt"
						cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.10/* $rompath/.repo/local_manifests
						break
						;;
					*) echo "invalid option $REPLY";;
				esac
			done < $temp_path/device-options.lst
			popt=1
		fi
	else
		popt=0
	fi
}

deviceType() {
	# Device type selection	
	PS3='Which device type do you plan on building?: '
	echo -e ${CL_CYN}"(default is 'Generic x86/x86_64')"
	TMOUT=10
	options=("Generic-x86/x86_64"
			 "Intel-x86/x86_64-with-Intel-iGPU")
	echo "Timeout in $TMOUT sec."${CL_RST}
	select opt1 in "${options[@]}"
	do
		case $opt1 in
			"Generic-x86/x86_64")
				echo "you chose choice $REPLY which is $opt1"
				cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/devices/generic/* $rompath/.repo/local_manifests
				break
				;;
			"Intel-x86/x86_64-with-Intel-iGPU")
				echo "you chose choice $REPLY which is $opt1"
				cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/devices/intel/* $rompath/.repo/local_manifests
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
	if [ "$opt1" == "" ]; then
		cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/devices/generic/* $rompath/.repo/local_manifests
		opt1="Generic-x86/x86_64"
	fi
}

kernelType() {
	# Kernel type selection	
	PS3='Which kernel do you want to build with?: '
	echo -e ${CL_CYN}"(default is 'AOSP Kernel-5.4-lts')"
	TMOUT=10
	options=("AOSP-Kernel-5.4-lts"
			 "Bliss-OS-kernel-5.8"
			 "Darkmatter-kernel-5.10")
	echo "Timeout in $TMOUT sec."${CL_RST}
	select opt2 in "${options[@]}"
	do
		case $opt2 in
			"AOSP-Kernel-5.4-lts")
				echo "you chose choice $REPLY which is $opt2"
				cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.4/* $rompath/.repo/local_manifests
				break
				;;
			"Bliss-OS-kernel-5.8")
				echo "you chose choice $REPLY which is $opt2"
				cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.8/* $rompath/.repo/local_manifests
				break
				;;
			"Darkmatter-kernel-5.10")
				echo "you chose choice $REPLY which is $opt2"
				cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.10/* $rompath/.repo/local_manifests
				break
				;;
			*) echo "invalid option $REPLY";;
		esac
	done
	if [ "$opt2" == "" ]; then
		cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/kernels/kernel-5.4/* $rompath/.repo/local_manifests
		opt2="AOSP-Kernel-5.4-lts"
	fi
}

# Run the functions

checkOptions

if [ $popt == 0 ]; then
	deviceType
	kernelType
	rm -rf "$temp_path/device-options.lst"
	printf "${opt1} ${opt2}" >> "$temp_path/device-options.lst"
fi

cp -r $rompath/vendor/$vendor_path/configs/$config_type/manifests/*.xml $rompath/.repo/local_manifests


echo -e ${reset}""${reset}
echo -e ${green}"Base generation complete. Files have been copied to $rompath/.repo/local_manifests/"${reset}
echo -e ${reset}""${reset}
