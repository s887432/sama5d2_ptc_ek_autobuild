#!/bin/bash

cd output

#file1=${kernel_resF}
#size1=$(stat -c%s "$file1")
#file2=${dtb_resF}
#size2=$(stat -c%s "$file2")

u_boot_env_resF=uboot-env.bin

rm -rf ${u_boot_env_resF}
rm -rf u-boot-env.txt
touch u-boot-env.txt

echo "arch=arm" >>u-boot-env.txt
echo "baudrate=115200" >>u-boot-env.txt
echo "board=sama5d2_ptc_ek" >>u-boot-env.txt
echo "board_name=sama5d2_ptc_ek" >>u-boot-env.txt
echo "bootargs=console=ttyS0,115200 earlyprintk mtdparts=atmel_nand:256k(bootstrap)ro,768k(uboot)ro,256K(env_redundant),256k(env),512k(dtb),6M(kernel)ro,-(rootfs) rootfstype=ubifs ubi.mtd=6 root=ubi0:rootfs" >>u-boot-env.txt
echo "bootcmd=fatload mmc 1 0x21000000 ${dtb_resF}; fatload mmc 1:1 0x22000000 ${kernel_resF}; bootz 0x22000000 - 0x21000000" >>u-boot-env.txt
echo "bootcmd=nand read 0x21000000 0x180000 0x80000;nand read 0x22000000 0x200000 0x600000;bootz 0x22000000 - 0x21000000" >>u-boot-env.txt
echo "bootdelay=1" >>u-boot-env.txt
echo "cpu=armv7" >>u-boot-env.txt
echo "ethaddr=54:10:ec:33:d1:a7" >>u-boot-env.txt
echo "fdtcontroladdr=27b56488" >>u-boot-env.txt
echo "soc=at91" >>u-boot-env.txt
echo "vendor=atmel" >>u-boot-env.txt


## create bin-version of u-boot-env.txt
if [ -f ${u_boot_env_resF} ] 
then
	rm -rf ${u_boot_env_resF}
fi

mkenvimage -s 0x2000 -o ${u_boot_env_resF} u-boot-env.txt

cd ..

echo "u-boot env file created"
# -------------------------------------------------------------------------------------------------
