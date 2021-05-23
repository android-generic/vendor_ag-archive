rompath=$(pwd)
vendor_path="ag"

function apply-x86-patches
{

	vendor/${vendor_path}/utils/autopatch.sh

}

function apply-x86-extras
{

	vendor/${vendor_path}/utils/ap_extras.sh

}

function apply-kernel-patches()
{

	vendor/${vendor_path}/utils/ap_kernel.sh $1

}

function ag-menu()
{
	bash vendor/${vendor_path}/ag-core/ag-menu.sh $1 $2 $3 $4
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
