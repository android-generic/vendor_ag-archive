rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"

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

addRemove() {
	#~ echo "Adding		$1"
	echo -e "\t$1" >> "$temp_path/01-remove.xml"
}

readFile() {
	echo -e ${reset}""${reset}
	echo -e ${green}"00-remove.xml generation starting..."${reset}
	echo -e ${reset}""${reset}
	
	while IFS= read -r rpitem; do
		if grep -Rl "$rpitem" $rompath/.repo/manifests/; then
			echo -e ${yellow}"	ROM already includes:	$rpitem"${reset}
		else
		    addRemove "$rpitem"
		fi
	done < $rompath/vendor/$vendor_path/configs/$config_type/remove.lst
}


if [ -d $temp_path ]; then
	echo -e ${reset}""${reset}
	echo -e ${teal}"Temp Path Already Created, cleaning up"${reset}
	echo -e ${reset}""${reset}
	rm -rf "$temp_path/01-remove.xml"
else
	mkdir -p "$temp_path"
fi


echo -e '<?xml version="1.0" encoding="UTF-8"?>' > "$temp_path/01-remove.xml"
echo -e '<manifest>' >> "$temp_path/01-remove.xml"

readFile

echo -e '</manifest>' >> "$temp_path/01-remove.xml"

cp -r "$temp_path/01-remove.xml" $rompath/.repo/local_manifests/
echo -e ${reset}""${reset}
echo -e ${green}"01-remove.xml generation complete. File has been copied to $rompath/.repo/local_manifests/01-remove.xml"${reset}
echo -e ${reset}""${reset}
