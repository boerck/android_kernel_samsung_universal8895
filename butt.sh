#!/bin/bash
##
#  Copyright (C) 2015, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
#
#  Edited by Diep Quynh Nguyen (diepquynh1501)
##

set -e -o pipefail

DATE=$(date +'%Y%m%d-%H%M')
NAME=RZ_kernel

export ARCH=arm64
export LOCALVERSION=-${VERSION}${DATE}-ReZero

KERNEL_PATH=$(pwd)
KERNEL_ZIP=${KERNEL_PATH}/zip_kernel
KERNEL_ZIP_NAME=${NAME}_${VERSION}.zip
KERNEL_IMAGE=${KERNEL_ZIP}/Image
DT_IMG=${KERNEL_ZIP}/dtb*.img
OUTPUT_PATH=${KERNEL_PATH}/output

export CROSS_COMPILE=$(pwd)/linaro-6.2-aarch64/bin/aarch64-linux-gnu-;

JOBS=`grep processor /proc/cpuinfo | wc -l`

# Colors
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

function build() {
	clear;

	BUILD_START=$(date +"%s");
	echo -e "$cyan"
	echo "***********************************************";
	echo "              Compiling RZ kernel          	     ";
	echo -e "***********************************************$nocol";
	echo -e "$red";

	if [ ! -e ${OUTPUT_PATH} ]; then
		mkdir ${OUTPUT_PATH};
	fi;

	echo -e "Initializing defconfig...$nocol";
	make O=output ${DEFCONFIG}
	echo -e "$red";
	echo -e "Building kernel...$nocol";
	make O=output -j${JOBS}
	make O=output -j${JOBS} dtbs;
	find ${KERNEL_PATH} -name "Image" -exec mv -f {} ${KERNEL_ZIP} \;
	find ${KERNEL_PATH} -name "dtb_*.img" -exec mv -f {} ${KERNEL_ZIP} \;

	BUILD_END=$(date +"%s");
	DIFF=$(($BUILD_END - $BUILD_START));
	echo -e "$yellow";
	echo -e "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol";
}

function make_zip() {
	echo -e "$red";
	echo -e "Making flashable zip...$nocol";

	if [ "$DEVICE" == "greatlte" ]; then
		cp -rf ${KERNEL_ZIP}/rz_system/vendor/firmware_n8/ ${KERNEL_ZIP}/rz_system/vendor/firmware;
	elif [ "$DEVICE" == "dreamlte-dream2lte" ]; then
		cp -r ${KERNEL_ZIP}/rz_system/vendor/firmware_s8/ ${KERNEL_ZIP}/rz_system/vendor/firmware;
	fi;

	cd ${KERNEL_ZIP};
	make -j${JOBS};
}

function rm_if_exist() {
	if [ -e $1 ]; then
		rm -rf $1;
	fi;
}

function clean() {
	echo -e "$red";
	echo -e "Cleaning build environment...$nocol";
	make -j${JOBS} mrproper;

	rm_if_exist ${OUTPUT_PATH};
	rm_if_exist ${DT_IMG};
	rm_if_exist ${KERNEL_ZIP}/rz_system/vendor/firmware;

	cd ${KERNEL_ZIP};
	make -j${JOBS} clean;
	rm -rf ${DT_IMG};
	rm -rf ${KERNEL_IMAGE};

	echo -e "$yellow";
	echo -e "Done!$nocol";
}

function menu() {
	echo;
	echo -e "***********************************************************************";
	echo "      RZ Kernel for ${DEVICE_NAME}";
	echo -e "***********************************************************************";
	echo "Choices:";
	echo "1. Cleanup source";
	echo "2. Build kernel";
	echo "3. Build kernel then make flashable ZIP";
	echo "4. Make flashable ZIP package";
	echo "Leave empty to exit this script (it'll show invalid choice)";
}

function select_device() {
	echo "Select which device you want to build for";
	echo "1. Samsung Galaxy S8/S8+ (Exynos) (SM-G95(0/5)(N/F/FD))";
	echo "2. Samsung Galaxy Note 8 (Exynos) (SM-N950F/FD)";
	read -n 1 -p "Choice: " -s device;	
	case ${device} in
		1) export DEFCONFIG=exynos8895_dreamlte_dream2lte_defconfig
		   export DEVICE="dreamlte-dream2lte"
		   export DEVICE_NAME="Samsung Galaxy S8/S8+ (Exynos) (SM-G95(0/5)(N/F/FD))"
		   menu;;
		2) export DEFCONFIG=exynos8895_greatlte_defconfig
		   export DEVICE="greatlte"
		   export DEVICE_NAME="Samsung Galaxy Note 8 (Exynos) (SM-N950F/FD)"
		   menu;;
		*) echo
		   echo "Invalid choice entered. Exiting..."
		   sleep 2;
		   exit 1;;
	esac
}

function main() {
	clear;
	if [ "${USE_CCACHE}" == "1" ]; then
		CCACHE_PATH=/usr/local/bin/ccache;
		export CROSS_COMPILE="${CCACHE_PATH} ${CROSS_COMPILE}";
		export JOBS=8;
		echo -e "$red";
		echo -e "You have enabled ccache through *export USE_CCACHE=1*, now using ccache...$nocol";
	fi;

	select_device;

	read -n 1 -p "Select your choice: " -s choice;
	case ${choice} in
		1) clean;;
		2) build;;
		3) build
		   make_zip;;
		4) make_zip;;
		*) echo
		   echo "Invalid choice entered. Exiting..."
		   sleep 2;
		   exit 1;;
	esac
}

main $@
