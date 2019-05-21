#!/bin/bash

result_p="output"
at91bootstrap="at91bootstrap"
at91bootstrap_resF="boot.bin"

u_boot="u-boot-at91"
u_boot_resF="u-boot.bin"

u_boot_env_resF="uboot-env.bin"

kernel="linux-at91"
kernel_resF="zImage"
dtb_resF="at91-sama5d2_ptc_ek.dtb"

rootfs="buildroot-at91"

# step 1
# prepare work aread
# remove exist output folder
3cho ""
echo "############################################################"
echo "########## Step 1 : prepare work folder ####################"
echo "############################################################"
if [ -d ${result_p} ]
then
	sudo rm -rf ${result_p}
fi
# create output folder
mkdir -p ${result_p}


# step 2
# download at91bootstrap
echo ""
echo "############################################################"
echo "########## Step 2 : download and make at91bootstrap ########"
echo "############################################################"
if [ -d ${at91bootstrap} ]
then
	rm -rf ${at91bootstrap}
fi

git clone git://github.com/linux4sam/at91bootstrap.git
cd ${at91bootstrap}
make mrproper
make sama5d2_ptc_eknf_uboot_defconfig
make -j8
cp binaries/${at91bootstrap_resF} ./../${result_p}
cd ..

# step 3
# download u-boot
echo ""
echo "############################################################"
echo "########## Step 3 : download and make u-boot ###############"
echo "############################################################"
if [ -d ${u_boot} ]
then
	rm -rf ${u_boot}
fi

git clone git://github.com/linux4sam/u-boot-at91.git
cd ${u_boot}
make sama5d2_ptc_ek_nandflash_defconfig
make -j8
cp ${u_boot_resF} ./../${result_p}
cd ..

# step 4
# download kernel
echo ""
echo "############################################################"
echo "########## Step 4 : download and make kernel ###############"
echo "############################################################"
if [ -d ${kernel} ]
then
	rm -rf ${kernel}
fi

git clone git://github.com/linux4sam/linux-at91.git
cd ${kernel}
make sama5_defconfig
make ARCH=arm
cp arch/arm/boot/${kernel_resF} ./../${result_p}
cp arch/arm/boot/dts/${dtb_resF} ./../${result_p}
cd ..

# step 5
# download root file system
echo ""
echo "############################################################"
echo "########## Step 5 : download and make rootfs ###############"
echo "############################################################"
if [ -d ${rootfs} ]
then
	rm -rf ${rootfs}
fi
git clone https://github.com/linux4sam/buildroot-at91.git
cp atmel_sama5d2_ptc_nf_defconfig ${rootfs}/configs
cd ${rootfs}
make atmel_sama5d2_ptc_nf_defconfig
make -j8

