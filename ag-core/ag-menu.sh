#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
config_type="$1"
modulepath="$rompath/vendor/$vendor_path/scripts"
privmodulepath="$rompath/vendor/$vendor_path/private-scripts"
export supertitle="Android Generic Project - Main Menu"
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

if [ ! -d "$temp_path" ]; then
	echo "Grabbing initial modules list"
	mkdir -p $temp_path
fi

# Add desktop icon if there isn't one yet
if [ ! -f "~/Desktop/$prj_folder_name-ag-$config_type.desktop" ]; then
	echo "Creating Desktop Icon"
	shell_cmd="$SHELL"
	prj_folder_name="${PWD##*/}"
	cat > $temp_path/$prj_folder_name-ag-$config_type.desktop <<EOF
[Desktop Entry]
Version=1.0
Name=ag-$config_type
Comment=AG for $rompath
Exec=sh -c 'cd $rompath && bash vendor/ag/ag-core/ag-menu.sh $config_type;$shell_cmd'
Icon=$rompath/vendor/$vendor_path/ag-core/includes/ag-logo.png
Terminal=true
Type=Application
Categories=Application;
Name[en_US.UTF-8]=$prj_folder_name-ag-$config_type

EOF

chmod 777 $temp_path/$prj_folder_name-ag-$config_type.desktop
cp $temp_path/$prj_folder_name-ag-$config_type.desktop ~/Desktop/

fi

rm -rf $temp_path/modules.lst
rm -rf $temp_path/priv-modules.lst
echo "Refreshing modules list"
bash $modulepath/tools-grab-modules/tools-grab-modules.sh $config_type
modules=$(cat $temp_path/modules.lst |tr "\n" " ")
privatemodules=$(cat $temp_path/priv-modules.lst |tr "\n" " ")

modulesString="$modules $privatemodules"
moduleStringArray=($modulesString)
# notify -t "Good tooltip:OK#Bad tooltip:BAD" -i "/usr/local/share/pixmaps/nm-signal-100.png#gtk-fullscreen" "Xclock" "xclock" "Xcalc" "xcalc"
#
while :
	do
	menu $modulesString
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	#
	for i in $modulesString ; do
		if [ "${answer}" = "${i}" ]; then
			notify_message "Starting \"${i}\" ..."
			notify_change "${i}"
			
			echo -e ${reset}""${reset}
			echo -e ${teal}"${i}"${reset}
			echo -e ${reset}""${reset} 
			if [ -d $modulepath/${i} ];then
				bash $modulepath/${i}/${i}.sh $config_type
			elif [ -d $privmodulepath/${i} ];then
				bash $privmodulepath/${i}/${i}.sh $config_type
			fi
		fi
		
	done
	if [ "${answer}" = "" ]; then
		exit
	fi
	
	#~ if [ "${answer}" = "add-astian-apps" ]
		#~ then
		#~ notify_message "Starting \"add-astian-apps\" ..."
		#~ notify_change "add-astian-apps"
		
		#~ echo -e ${reset}""${reset}
		#~ echo -e ${teal}"add-astian-apps"${reset}
		#~ echo -e ${reset}""${reset} 
		#~ if [ -d $modulepath/add-astian-apps ];then
			#~ bash $modulepath/add-astian-apps/add-astian-apps.sh
		#~ elif [ -d $privmodulepath/add-astian-apps ];then
			#~ bash $privmodulepath/add-astian-apps/add-astian-apps.sh
		#~ fi
				
	#~ elif [ "${answer}" = "generate-base" ]
		#~ then
		#~ notify_message "Starting \"generate-base\" ..."
		#~ notify_change "generate-base"
		
		#~ echo -e ${reset}""${reset}
		#~ echo -e ${teal}"generate-base"${reset}
		#~ echo -e ${reset}""${reset} 
		#~ if [ -d $modulepath/generate-base ];then
			#~ bash $modulepath/generate-base/generate-base.sh
		#~ elif [ -d $privmodulepath/generate-base ];then
			#~ bash $privmodulepath/generate-base/generate-base.sh
		#~ fi
				
	#~ elif [ "${answer}" = "generate-others" ]
		#~ then
		#~ notify_message "Starting \"generate-others\" ..."
		#~ notify_change "generate-others"
		
		#~ echo -e ${reset}""${reset}
		#~ echo -e ${teal}"generate-others"${reset}
		#~ echo -e ${reset}""${reset} 
		#~ if [ -d $modulepath/generate-others ];then
			#~ bash $modulepath/generate-others/generate-others.sh
		#~ elif [ -d $privmodulepath/generate-others ];then
			#~ bash $privmodulepath/generate-others/generate-others.sh
		#~ fi
	#~ else
		#~ exit
	#~ fi
	
done



clean_temp #(since v.6.X.X this function is no more required if easybashlib is present and then successfully loaded by easybashgui)
