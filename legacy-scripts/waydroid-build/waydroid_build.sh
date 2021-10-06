#!/bin/bash

############################################################
# Test for dependencies                                    #
############################################################
if ! command -v simg2img &> /dev/null
then
    echo "simg2img could not be found. Please install first"
    exit
fi

if ! command -v 7zz &> /dev/null
then
    echo "7zz could not be found. Please install first"
    exit
fi

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Compiles and packages Waydroid for target arch"
   echo
   echo "Syntax: "
   echo "	waydroid_build [-a|--arch arm|arm64|x86|x86_64] [-c|--clean] [-p|--package] [-r|--rom_name Name]"
   echo "options:"
   echo "	-a|--arch (option) Specify arch for build (arm, arm64, x86, x86_64)"
   echo "	-c|clean     Run 'make clean' before build"
   echo "	-p|--package     Package build using ROM_NAME"
   echo "	-r|--rom_name (ROM_NAME) Name used for package build filename (ex: Lineage-17.1)"
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
WaydroidArch=""
cleanup="false"
package="false"
rom_name=""

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while test $# -gt 0
do
  case $1 in

  # Normal option processing
    -h | --help)
      Help
	  exit
      ;;
    -c | --clean)
      cleanup="true"
      echo "Waydroid cleanup: $cleanup "
      ;;
    -a | --arch)
      WaydroidArch=$2
	  echo "Building Waydroid for: $WaydroidArch "
	  shift
      ;;
    -p | --package)
      package="true"
      echo "Waydroid package: $package "
      ;;
    -r | --rom_name)
      rom_name=$2
	  echo "Waydroid package ROM name: $rom_name "
	  shift
      ;;
  # ...

  # Special cases
    --)
      break
      ;;
    --*)
      # error unknown (long) option $1
      ;;
    -?)
      # error unknown (short) option $1
      ;;

  # FUN STUFF HERE:
  # Split apart combined short options
    -*)
      split=$1
      shift
      set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
      continue
      ;;

  # Done with options
    *)
      break
      ;;
  esac

  # for testing purposes:
  shift
done

if [[ $1 == "" ]]
then
	echo "!!No Arguments Specified!!"
	Help
	exit
fi

############################################################
# Start using the arguments to process the build commands  #
############################################################

. build/envsetup.sh
lunch lineage_waydroid_$WaydroidArch-userdebug

if [[ $cleanup == "true" ]]
then
	make clean
fi

make systemimage -j$(nproc --all) && \
make vendorimage -j$(nproc --all)

if [[ $package == "true" ]]
then
	cd out/target/product/waydroid_$WaydroidArch && \
	mv system.img system2.img && \
	mv vendor.img vendor2.img && \
	simg2img system2.img system.img && \
	simg2img vendor2.img vendor.img && \
	rm -rf system2.img && \
	rm -rf vendor2.img && \
	export WAYDROID_DATE=$(date +%Y%m%d%H%M) && \
	7zz a $rom_name-waydroid_$WaydroidArch-$WAYDROID_DATE.zip system.img vendor.img && \
	cd $(PWD)
fi
