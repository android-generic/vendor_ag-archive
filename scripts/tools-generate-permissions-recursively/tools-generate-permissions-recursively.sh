#!/bin/bash
# Generate AOSP Premisisons.xml from folder of .apk files
# Usage: bash generate-permissions.sh apk_folder_location permissions_folder_location permissions-filename.xml
# Example: $ bash generate-permissions.sh device/google/bramble/prebuilts/privapps device/google/bramble/prebuilts/permissions bramble-permissions.xml
#
# Copyright (C) 2021 The Android-Generic Project
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#


# NO EDITING BELOW HERE
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"
popt=0
source $rompath/vendor/$vendor_path/ag-core/gui/easybashgui
#~ include $rompath/vendor/$vendor_path/ag-core/gui/easybashgui

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

ApkLocation() {
	PS3='Where is the folder for your APKs?: '
	ok_message "Select APK folder on the next screen"
	dselect
    APK_FOLDER="$( 0< "${dir_tmp}/${file_tmp}" )"
}

PermsLocation() {
	PS3='Where is the permissions folder?: '
	ok_message 'Select permissions folder on the next screen'
	dselect
    PERMS_LOCATION="$( 0< "${dir_tmp}/${file_tmp}" )"
}

PermsName() {
	ok_message 'Enter the desired permissions.xml filename on the next screen'
	input 1 "foss-permissions.xml"
	IFS=$'\n'
    PERMS_FILENAME="$( 0< "${dir_tmp}/${file_tmp}" )"
}


#~ array=( $( 0< "${dir_tmp}/${file_tmp}" ) )
if [ ! "$2" == "" ]; then
	APK_FOLDER="$1"
	PERMS_LOCATION="$2"
	PERMS_FILENAME="$3"
else
	ApkLocation
	PermsLocation
	PermsName
fi


#~ APK_FOLDER="$1"
#~ PERMS_LOCATION="$2"
#~ PERMS_FILENAME="$3"

PARSED_PERMS_PATH="$PERMS_LOCATION/$PERMS_FILENAME"
FILES="$(find $APK_FOLDER -name \*.apk)"

addPerms() {
perms_list=""
cat >> $PARSED_PERMS_PATH <<EOF
	<privapp-permissions package="$2">
EOF
for i in "$@" ; do
	perms_list+="$i "
done
echo ""
echo -e "Prems List: $perms_list"
echo ""
for i in $perms_list ; do
if [ "$i" == "uses-permission:" ]; then
	echo -e "skipping meaningless line"
elif [[ "$i" == *"package:"* ]]; then
	echo -e "skipping meaningless line"
elif [[ "$i" == *"name="* ]]; then
temp_str=$(echo "$i" | sed -e "s/'/\"/g")
cat >> $PARSED_PERMS_PATH <<EOF
		<permission $temp_str/>
EOF
echo ""
echo -e "Perms string: $temp_str"
echo ""
fi
done
cat >> $PARSED_PERMS_PATH <<EOF
    </privapp-permissions>

EOF
}

echo -e "${LT_BLUE}# Generating Permissions XML ${NC}"
rm -Rf $PARSED_PERMS_PATH
mkdir -p permissions
cat > $PARSED_PERMS_PATH <<EOF
<permissions>

EOF

for f in $FILES ; do
  echo -e ""
  echo "Processing $f file..."
  cmd_list=""
  argumentqa=$(aapt d permissions "$f")
  echo ""
  echo -e "Permissions for $argumentqa"
  echo ""
  for line in $argumentqa; do 
    read -a array <<< $line
    echo ${array[index]}  
    cmd_list+="${array[index]} "
  done
  echo -e "CMD_LIST: $cmd_list"
  addPerms $cmd_list
done

cat >> $PARSED_PERMS_PATH <<EOF
</permissions>

EOF

echo ""
echo -e "All Set, permissions xml generated"
