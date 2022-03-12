#
# Copyright (C) 2021 The Waydroid project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

top_dir=`pwd`
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
loc_man="${top_dir}/.repo/local_manifests"
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
manifests_url="https://raw.githubusercontent.com/android-generic/vendor_ag/unified/configs/pc"
manifests_path="$rompath/vendor/$vendor_path/configs/pc"
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

echo -e "variables set"

if [ ! -d "${top_dir}/.repo" ]; then
    echo -e ${reset}""${reset}
    echo -e ${ltred}"ERROR: Manifest generation requires repo to be initialized first."${reset}
    echo -e ${reset}""${reset}
    exit
fi
echo -e "Setting up local_manifests"
mkdir -p ${loc_man}

echo -e "determining proper paths for your Android version"
if [ -f build/make/core/version_defaults.mk ]; then
    if grep -q "PLATFORM_SDK_VERSION := 28" build/make/core/version_defaults.mk; then
		echo -e "Setting up PLATFORM_SDK_VERSION := 28 local_manifests"
        manifests_url="${manifests_url}-28"
        manifests_path="${manifests_path}-28"
    fi
    if grep -q "PLATFORM_SDK_VERSION := 29" build/make/core/version_defaults.mk; then
		echo -e "Setting up PLATFORM_SDK_VERSION := 29 local_manifests"
        manifests_url="${manifests_url}-29"
        manifests_path="${manifests_path}-29"
    fi
    if grep -q "PLATFORM_SDK_VERSION := 30" build/make/core/version_defaults.mk; then
		echo -e "Setting up PLATFORM_SDK_VERSION := 30 local_manifests"
        manifests_url="${manifests_url}-30"
        manifests_path="${manifests_path}-30"
    fi
    if grep -q "PLATFORM_SDK_VERSION := 31" build/make/core/version_defaults.mk; then
		echo -e "Setting up PLATFORM_SDK_VERSION := 31 local_manifests"
        manifests_url="${manifests_url}-31"
        manifests_path="${manifests_path}-31"
    fi
    if grep -q "PLATFORM_SDK_VERSION := 32" build/make/core/version_defaults.mk; then
		echo -e "Setting up PLATFORM_SDK_VERSION := 32 local_manifests"
        manifests_url="${manifests_url}-32"
        manifests_path="${manifests_path}-32"
    fi
fi

echo -e ${reset}""${reset}
echo -e ${green}"Placing manifest fragments..."${reset}
echo -e ${reset}""${reset}
if [ -d "${manifests_path}" ]; then
    cp -fpr ${manifests_path}/*.xml "${loc_man}/"
else
    echo -e ${reset}""${reset}
    echo -e ${ltblue}"INFO: Manifests not found, downloading"${reset}
    echo -e ${reset}""${reset}
    wget "${manifests_url}/00-remotes.xml" -O "${loc_man}/00-remotes.xml"
    wget "${manifests_url}/01-removes.xml" -O "${loc_man}/01-removes.xml"
    wget "${manifests_url}/02-android-x86.xml" -O "${loc_man}/02-android-x86.xml"
    wget "${manifests_url}/03-device.xml" -O "${loc_man}/03-device.xml"
    wget "${manifests_url}/04-kernel.xml" -O "${loc_man}/04-kernel.xml"
    wget "${manifests_url}/05-extras.xml" -O "${loc_man}/05-extras.xml"
    wget "${manifests_url}/05-extras.xml" -O "${loc_man}/05-extras.xml"
fi

echo -e ${reset}""${reset}
echo -e ${teal}"INFO: Cleaning up remove manifest entries"${reset}
echo -e ${reset}""${reset}
while IFS= read -r rpitem; do
    if [[ $rpitem == *"remove-project"* ]]; then
        rpitem_trimmed="$(echo "$rpitem" | xargs)"
        if grep -qRlZ "$rpitem_trimmed" "${top_dir}/.repo/manifests/"; then
            echo -e ${yellow}"WARN: ROM already includes: $rpitem"${reset}
        else
            echo -e ${green}"INFO: Needed: $rpitem"${reset}
            prefix="<remove-project name="
            suffix=" />"
            item=${rpitem_trimmed#"$prefix"}
            item=${item%"$suffix"}
            if ! grep -qRlZ "$item" "${top_dir}/.repo/manifests/"; then
                sed -e "$item"'d' "${loc_man}/01-removes.xml"
            fi
        fi
    fi
done < "${loc_man}/01-removes.xml"

echo -e ${reset}""${reset}
echo -e ${green}"Manifest generation complete. Files have been copied to $rompath/.repo/local_manifests/"${reset}
echo -e ${reset}""${reset}
