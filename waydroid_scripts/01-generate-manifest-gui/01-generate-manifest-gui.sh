rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"
popt=0
source $rompath/vendor/$vendor_path/ag-core/gui/easybashgui
# include $rompath/vendor/$vendor_path/ag-core/gui/easybashgui

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

if [ -d $rompath/.repo/local_manifests/ ]; then
	echo -e ${reset}""${reset}
	echo -e ${teal}"local_manifests Path Already Created"${reset}
else
	mkdir -p "$rompath/.repo/local_manifests/"
fi

wget -O - https://raw.githubusercontent.com/waydroid/android_vendor_waydroid/lineage-17.1/manifest_scripts/generate-manifest.sh | bash

echo -e ${reset}""${reset}
echo -e ${green}"Manifest generation complete. Files have been copied to $rompath/.repo/local_manifests/"${reset}
echo -e ${reset}""${reset}
