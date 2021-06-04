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

addEntry() {
	#~ echo "Adding		$1"
	echo -e "\t$1" >> "$temp_path/06-others.xml"
}

readFile() {
	echo -e ${reset}""${reset}
	echo -e ${green}"00-remove.xml generation starting..."${reset}
	echo -e ${reset}""${reset}
	
	while IFS=$'\t' read -r rpitem rpentry; do
		#~ echo "First Var is $rpitem - Second Var is $rpentry"
		if grep -Rl "$rpitem" $rompath/.repo/manifests/; then
			echo -e ${yellow}"	ROM already includes:	$rpitem"${reset}
		else
			addEntry "$rpentry"
		fi
	done < $rompath/vendor/$vendor_path/configs/$config_type/others.lst
}


if [ -d $temp_path ]; then
	echo -e ${reset}""${reset}
	echo -e ${teal}"Temp Path Already Created, cleaning up"${reset}
	echo -e ${reset}""${reset}
	rm -rf "$temp_path/06-others.xml"
else
	mkdir -p "$temp_path"
fi

if [ -d $rompath/.repo/local_manifests/ ]; then
	echo -e ${reset}""${reset}
	echo -e ${teal}"local_manifests Path Already Created"${reset}

else
	mkdir -p "$rompath/.repo/local_manifests/"
fi

echo -e '<?xml version="1.0" encoding="UTF-8"?>' > "$temp_path/06-others.xml"
echo -e '<manifest>' >> "$temp_path/06-others.xml"

readFile

echo -e '</manifest>' >> "$temp_path/06-others.xml"

cp -r "$temp_path/06-others.xml" $rompath/.repo/local_manifests/
echo -e ${reset}""${reset}
echo -e ${green}"06-others.xml generation complete. File has been copied to $rompath/.repo/local_manifests/06-others.xml"${reset}
echo -e ${reset}""${reset}
