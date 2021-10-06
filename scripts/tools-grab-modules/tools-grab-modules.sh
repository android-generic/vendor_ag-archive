rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"
popt=0

rm -rf $temp_path/modules.lst
rm -rf $temp_path/priv-modules.lst

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


# Run the functions

if [ "$1" == "" ]; then
	echo "You must specify a target type (pc, waydroid)"
fi
echo -e ${reset}"$1 specified"${reset}

prefix="$rompath/vendor/$vendor_path/scripts/"
privprefix="$rompath/vendor/$vendor_path/private-scripts/"

if [ "$1" == "pc" ]; then
	config_type_prefix="$rompath/vendor/$vendor_path/pc_scripts/"
fi

if [ "$1" == "waydroid" ]; then
	config_type_prefix="$rompath/vendor/$vendor_path/waydroid_scripts/"
fi

if [ -f $temp_path/modules.lst ]; then
	echo -e ${reset}""${reset}
	echo -e ${teal}"Modules List Already Created, cleaning up"${reset}
	echo -e ${reset}""${reset}
	rm -rf "$temp_path/modules.lst"
fi

echo -e ${reset}""${reset}
echo -e ${ltgreen}"AG Modules Found:"${reset}
echo -e ${reset}""${reset}

ls -d $config_type_prefix* | grep -oP "^$config_type_prefix\K.*" | while read d
do
	echo -e ${green}"\t$d"${reset}
	echo -e "$d" >> "$temp_path/modules.lst"
done

ls -d $prefix* | grep -oP "^$prefix\K.*" | while read d
do
	echo -e ${green}"\t$d"${reset}
	echo -e "$d" >> "$temp_path/modules.lst"
done

echo -e ${reset}""${reset}
if [ -d $privprefix ]; then
	if [ -f $temp_path/priv-modules.lst ]; then
		echo -e ${reset}""${reset}
		echo -e ${teal}"Private Modules List Already Created, cleaning up"${reset}
		echo -e ${reset}""${reset}
		rm -rf "$temp_path/priv-modules.lst"
	fi
	
	
	echo -e ${reset}""${reset}
	echo -e ${ltpurple}"AG Private Modules Found:"${reset}
	echo -e ${reset}""${reset}
	
	ls -d $privprefix* | grep -oP "^$privprefix\K.*" | while read d
	do
		echo -e ${purple}"\t$d"${reset}
		echo -e "$d" >> "$temp_path/priv-modules.lst"
	done
fi


echo -e ${reset}""${reset}
echo -e ${green}"Done"${reset}
echo -e ${reset}""${reset}
