rompath=$(pwd)
ag_vendor_path="ag"

function apply-x86-patches
{

	vendor/${ag_vendor_path}/utils/autopatch.sh

}

function apply-x86-extras
{

	vendor/${ag_vendor_path}/utils/ap_extras.sh

}

function apply-x86-kernel-patches()
{

	vendor/${ag_vendor_path}/utils/ap_kernel.sh $1

}

function ag-menu()
{
	if [ "$1" == "" ]; then
		echo -e "You must specify a target type (pc, gsi, emu)"
	elif [ "$1" == "gsi" ]; then
		echo -e "You must wait for that target type to become available. Check repo for updates"
	elif [ "$1" == "emu" ]; then
		echo -e "You must wait for that target type to become available. Check repo for updates"
	else
		bash vendor/${ag_vendor_path}/ag-core/ag-menu.sh $1 $2 $3 $4
	fi
}

function ag-menu-l()
{
	if [ "$1" == "" ]; then
		echo -e "You must specify a target type (pc, gsi, emu)"
	elif [ "$1" == "gsi" ]; then
		echo -e "You must wait for that target type to become available. Check repo for updates"
	elif [ "$1" == "emu" ]; then
		echo -e "You must wait for that target type to become available. Check repo for updates"
	else
		. vendor/${ag_vendor_path}/ag-core/ag-menu.sh $1 $2 $3 $4
	fi
}

function manifest-backup
{
	bash vendor/${ag_vendor_path}/scripts/manifest-backup/manifest-backup.sh
}

function get-cros-files-x86
{
	echo "Setting up Proprietary environment for: $1"
	lunch android_x86-userdebug
	echo "Building proprietary tools... This might take a little..."
	echo "Be prepared to enter root password in order to mount the cros images and unpack things"
	cd vendor/google/chromeos-x86
	./extract-files.sh
	cd ..
	cd ..
	cd ..
}

function get-cros-files-x86_64
{
	echo "Setting up Proprietary environment for: $1"
	lunch android_x86_64-userdebug
	echo "Building proprietary tools... This might take a little..."
	echo "Be prepared to enter root password in order to mount the cros images and unpack things"
	cd vendor/google/chromeos-x86
	./extract-files.sh
	cd ..
	cd ..
	cd ..
}
