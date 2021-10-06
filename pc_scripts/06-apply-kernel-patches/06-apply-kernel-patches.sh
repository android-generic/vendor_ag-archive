#!/bin/bash
# -*- coding: utf-8; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-

# autopatch.sh: script to manage patches on top of repo
# Copyright (c) 2018, Intel Corporation.
# Author: sgnanase <sundar.gnanasekaran@intel.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
rompath="$PWD"
top_dir=`pwd`
vendor_path="ag"
utils_dir="$top_dir/vendor/$vendor_path/utils"
patch_dir="$utils_dir/android_r/google_diff/x86"
private_utils_dir="$top_dir/vendor/$vendor_path/PRIVATE/utils"
private_patch_dir="$private_utils_dir/android_r/google_diff/$TARGET_PRODUCT"
config_type="$1"
#~ popt=0
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

kernelType() {
	# Kernel type selection	
	PS3='Which kernel do you want to build with?: '
	echo -e ${CL_CYN}"(default is 'Kernel-5.4')"
	TMOUT=10
	selection=("Kernel-5.4"
			 "Kernel-5.10"
			 "Kernel-5.11"
			 "Kernel-5.12")
	menu "Kernel-5.4" "Kernel-5.10" "Kernel-5.11" "Kernel-5.12"
	echo "Timeout in $TMOUT sec."${CL_RST}
	answer=$(0< "${dir_tmp}/${file_tmp}" )
	
	if [ "${answer}" = "Kernel-5.4" ]
		then
		echo "you chose ${answer}"
		k_version="5.4"
		opt2="${answer}"
	elif [ "${answer}" = "Kernel-5.10" ]
		then
		echo "you chose ${answer}"
		k_version="5.10"
		opt2="${answer}"
	elif [ "${answer}" = "Kernel-5.11" ]
		then
		echo "you chose ${answer}"
		k_version="5.11"
		opt2="${answer}"
	elif [ "${answer}" = "Kernel-5.12" ]
		then
		echo "you chose ${answer}"
		k_version="5.12"
		opt2="${answer}"
	else
		echo "invalid option ${answer}"
		k_version="5.4"
		exit
	fi
	
}

kernelType

#~ k_version="$1"
if [ -d $utils_dir/android_r/google_diff/x86-kernels/kernel-$k_version ]; then
	patch_dir="$utils_dir/android_r/google_diff/x86-kernels/kernel-$k_version"
else
	echo "Kernel patches do not exist for that version"
	exit
fi
#~ patch_dir="$utils_dir/android_r/google_diff/kernel-$k_version"
private_utils_dir="$top_dir/vendor/x86/PRIVATE/utils"
private_patch_dir="$private_utils_dir/android_r/google_diff/$TARGET_PRODUCT"

current_project=""
previous_project=""
conflict=""
conflict_list=""

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

#~ apply_patch() {

  #~ pl=$1
  #~ pd=$2

  #~ echo ""
  #~ echo "Applying Patches"

  #~ for i in $pl
  #~ do
    #~ current_project=`dirname $i`
    #~ if [[ $current_project != $previous_project ]]; then
      #~ echo ""
      #~ echo ""
      #~ echo "Project $current_project"
    #~ fi
    #~ previous_project=$current_project

    #~ cd $top_dir/$current_project
    #~ remote=`git remote -v | grep "https://android.googlesource.com/"`
    #~ if [[ -z "$remote" ]]; then
      #~ default_revision="remotes/m/master"
    #~ else
      #~ if [[ -f "$top_dir/.repo/manifest.xml" ]]; then
        #~ default_revision=`grep default $top_dir/.repo/manifest.xml | grep -o 'revision="[^"]\+"' | cut -d'=' -f2 | sed 's/\"//g'`
      #~ else
        #~ echo "Please make sure .repo/manifest.xml"
        #~ # return 1
      #~ fi
    #~ fi

    #~ cd $top_dir/$current_project
    #~ a=`grep "Date: " $pd/$i | sed -e "s/Date: //"`
    #~ b=`grep "Subject: " $pd/$i | sed -e "s/Subject: //" | sed -e "s/^\[PATCH[^]]*\] //"`
    #~ c=`git log --pretty="format:%aD, %s" $project_revision.. | grep -F "$a, $b"`

    #~ if [[ "$c" == "" ]] ; then
      #~ git am -3 $pd/$i >& /dev/null
      #~ if [[ $? == 0 ]]; then
        #~ echo "        Applying          $i"
      #~ else
        #~ echo "        Conflicts          $i"
        #~ git am --abort >& /dev/null
        #~ conflict="y"
        #~ conflict_list="$current_project $conflict_list"
      #~ fi
    #~ else
      #~ echo "        Already applied         $i"
    #~ fi
  #~ done
#~ }

#Apply common patches
cd $patch_dir
patch_list=`find * -iname "*.patch" | sort -u`
apply_patch "$patch_list" "$patch_dir"

#Apply Embargoed patches if exist
if [[ -d "$private_patch_dir" ]]; then
    echo ""
    echo "Embargoed Patches Found"
    cd $private_patch_dir
    private_patch_list=`find * -iname "*.patch" | sort -u`
    apply_patch "$private_patch_list" "$private_patch_dir"
fi

echo ""
if [[ "$conflict" == "y" ]]; then
  echo "==========================================================================="
  echo "           ALERT : Conflicts Observed while patch application !!           "
  echo "==========================================================================="
  for i in $conflict_list ; do echo $i; done | sort -u
  echo "==========================================================================="
  echo "WARNING: Please resolve Conflict(s). You may need to re-run build..."
  # return 1
else
  echo "==========================================================================="
  echo "           INFO : All patches applied fine !!                              "
  echo "==========================================================================="
fi
