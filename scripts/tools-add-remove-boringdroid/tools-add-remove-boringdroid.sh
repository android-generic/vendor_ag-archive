#!/bin/bash
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp"
#~ config_type="$1"
top_dir=`pwd`
vendor_path="ag"
utils_dir="$rompath/vendor/$vendor_path/utils"
patch_dir="$utils_dir/android_r/google_diff/x86-boringdroid"
private_utils_dir="$rompath/vendor/$vendor_path/PRIVATE/utils"
private_patch_dir="$private_utils_dir/android_r/google_diff/$TARGET_PRODUCT"
export supertitle="Android Generic Project - Boringdroid Options"
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
current_project=""
previous_project=""
conflict=""
conflict_list=""

project_revision=""

tag_project() {
  cd $top_dir/$1
  git tag -f autopatch/`basename $patch_dir` > /dev/null
}

apply_patch() {

  pl=$1
  pd=$2

  echo -e ${reset}""${reset}
  echo -e ${teal}"Applying Patches"${reset}
  echo -e ${reset}""${reset} 

  for i in $pl
  do
    current_project=`dirname $i`
    if [[ $current_project != $previous_project ]]; then
      if [[ -n "$previous_project" ]]; then
        tag_project $previous_project
      fi
      echo -e ${reset}""${reset}
      echo -e ${ltblue}"Project $current_project"${reset}
      echo -e ${reset}""${reset} 
      cd $top_dir
      project_revision=`repo info $current_project | grep 'Current revision: ' | sed 's/Current revision: //'`
    fi
    previous_project=$current_project

    conflict_project=`echo $conflict_list | grep " $current_project "`
    if [[ -n "$conflict_project" ]]; then
      echo -e ${reset}""${reset}
      echo -e ${ltgreen}"        Skipping          $i"${reset}
      echo -e ${reset}""${reset} 
    fi

    cd $top_dir/$current_project
    a=`grep "Date: " $pd/$i | sed -e "s/Date: //"`
    b=`grep "Subject: " $pd/$i | sed -e "s/Subject: //" | sed -e "s/^\[PATCH[^]]*\] //"`
    c=`git log --pretty="format:%aD, %s" $project_revision.. | grep -F "$a, $b"`

    if [[ "$c" == "" ]] ; then
      git am -3 $pd/$i >& /dev/null
      
      if [[ $? == 0 ]]; then
        echo -e ${reset}""${reset}
        echo -e ${ltgreen}"        Applying          $i"${reset}
        echo -e ${reset}""${reset}
        
      else
        echo -e ${reset}""${reset}
        echo -e ${ltred}"        Conflicts         $i"${reset}
        echo -e ${reset}""${reset}
		git am --abort >& /dev/null
		conflict="y"
		conflict_list=" $current_project $conflict_list"
      fi
    else
	  echo -e ${reset}""${reset}
	  echo -e ${green}"        Already applied   $i"${reset}
	  echo -e ${reset}""${reset}
    fi
  done

  if [[ -n "$previous_project" ]]; then
    tag_project $previous_project
  fi
}

processes=$(nproc --all)
proc=$(( $processes / 2 + 1 ))


useBoringdroid() {
	# Gearlock selection	
	alert_message 'Select to add/remove Boringdroid from your setup'
	echo -e ${CL_CYN}"(default is 'Add')"
	TMOUT=10
	title="Select the option you wish"
	selection=("Include Boringdroid"
		"Remove Boringdroid")
	menu "Include Boringdroid" "Remove Boringdroid"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	if [ "${answer}" = "Include Boringdroid" ]; then
		echo "you chose ${answer}"
		if [ ! -d "$rompath/vendor/boringdroid" ]; then
			echo "Cloning Boringdroid repo"
			git clone https://github.com/boringdroid/vendor_boringdroid vendor/boringdroid
		fi
		if [ ! -d "$rompath/vendor/prebuilts/bdapps" ]; then
			echo "Cloning BD-Apps repo"
			git clone https://github.com/boringdroid/vendor_prebuilts_bdapps vendor/prebuilts/bdapps
		fi

		cd device/generic/common 
		command=`git log --pretty="format:%aD, %s" | grep -F "Add Boringdroid"`

		if [ -n "$command" ]; then
			echo "ALREADY THERE"
		else
			echo "NOT THERE, ADDING"
			
		cat >> device.mk <<\EOF

# Boringdroid
$(call inherit-product-if-exists, vendor/boringdroid/boringdroid.mk)

EOF

			git add .
			git commit -a -m "Add Boringdroid" --author="AGP-BOT <contact@blisslabs.org>"
			cd $rompath
		fi

		#Apply common patches
		cd $patch_dir
		patch_list=`find * -iname "*.patch" | sort -u`

		apply_patch "$patch_list" "$patch_dir"
		#~ apply_patch "$patch_list" "$patch_dir" 2>&1 | tee $top_dir/vendor/$vendor_path/tmp/conflicts.script

		echo ""
		if [[ "$conflict" == "y" ]]; then
		  echo -e ${yellow} "==========================================================================="${reset}
		  echo -e ${yellow} "           ALERT : Conflicts Observed while patch application !!           "${reset}
		  echo -e ${yellow} "==========================================================================="${reset}
		  for i in $conflict_list ; do echo $i; done | sort -u
		  echo -e ${yellow} "==========================================================================="${reset}
		  echo -e ${yellow} "WARNING: Please resolve Conflict(s). You may need to re-run build..."${reset}
		  # return 1
		else
		  echo -e ${green} "==========================================================================="${reset}
		  echo -e ${green} "           INFO : All patches applied fine !!                              "${reset}
		  echo -e ${green} "==========================================================================="${reset}
		fi

		echo "Boringdroid is ready"
		
	elif [ "${answer}" = "Remove Boringdroid" ]; then
		echo "you chose ${answer}"
		if [ -d "$rompath/vendor/Boringdroid" ]; then
			echo "You wqill have to manually revert Commits in frameworks/base"
			echo ""
			echo "Removing Boringdroid repo"
			rm -rf $rompath/vendor/Boringdroid
			echo "Removing bdapps repo"
			rm -rf $rompath/vendor/prebuilts/bdapps
		fi
		echo "Boringdroid is removed"
	else
		echo "invalid option ${answer}"
		exit
	fi
	
}

useBoringdroid

