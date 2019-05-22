import SAMBA 3.2
import SAMBA.Connection.Serial 3.2
import SAMBA.Device.SAMA5D2 3.2

SerialConnection {

	device: SAMA5D2PTCEK {
		config {
			nandflash {
				header: 0xc0902405
			}
		}
	}

	function initNand() {
		/* set drive strength to medium */
		var pioConf

		writeu32(0xFC038000, 0x3fc00000)
		pioConf = readu32(0xFC038004)
		pioConf &= ~(3 << 16)
		pioConf |= (2 << 16)
		writeu32(0xFC038004, pioConf)
	}

	function getEraseSize(size) {
		/* get smallest erase block size supported by applet */
		var eraseSize
		for (var i = 0; i <= 32; i++) {
			eraseSize = 1 << i
			if ((applet.eraseSupport & eraseSize) !== 0)
				break;
		}
		eraseSize *= applet.pageSize

		/* round up file size to erase block size */
		return (size + eraseSize - 1) & ~(eraseSize - 1)
	}

	function eraseWrite(offset, filename, bootfile) {
		/* get file size */
		var file = File.open(filename, false)
		var size = file.size()
		file.close()

		applet.erase(offset, getEraseSize(size))
		applet.write(offset, filename, bootfile)
	}

	onConnectionOpened: {
		var dtbFileName = "at91-sama5d2_ptc_ek.dtb"
		var ubootEnvFileName = "uboot-env.bin"

		// initialize Low-Level applet
		print("-I- === Initilize low level (system clocks) ===")
		initializeApplet("lowlevel")

		// intialize extram applet (needed for sam9)
		print("-I- === Initialize extram ===")
		initializeApplet("extram")

		print("-I- === Initialize nandflash access ===")
		initializeApplet("nandflash")

		initNand()

		// erase then write files
		print("-I- === Load AT91Bootstrap ===")
		eraseWrite(0x00000000, "boot.bin", true)

		print("-I- === Load u-boot environment ===")
		//erase redundant env to be in a clean and known state
		applet.erase(0x00100000, getEraseSize(0x20000))
		eraseWrite(0x00140000, ubootEnvFileName)

		print("-I- === Load u-boot ===")
		eraseWrite(0x00040000, "u-boot.bin")

		print("-I- === Load device tree database ===")
		eraseWrite(0x00180000, dtbFileName)

		print("-I- === Load Kernel image ===")
		eraseWrite(0x00200000, "zImage")

		print("-I- === Load root file-system image ===")
		applet.erase(0x00800000, applet.memorySize - 0x00800000)
		applet.write(0x00800000, "rootfs.ubi")

		print("-I- === Done. ===")
	}
}
