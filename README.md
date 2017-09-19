# LEDE for Talon AD7200

## Quick Image Build Instructions

This is a short build instruction to compile LEDE for the Talon AD7200. Parts of this instruction has been taken from the official [LEDE documentation](https://lede-project.org/docs/guide-developer/quickstart-build-images).

First we need to make sure the dependencies are installed, you can install
those on an Ubuntu/Debian machine (tested with ubuntu 16.4.2) with:
```bash
sudo apt-get install build-essential git git-core flex quilt xsltproc libxml-parser-perl 
sudo apt-get install mercurial bzr ecj cvs subversion g++ zlib1g-dev build-essential 
sudo apt-get install python libncurses5-dev gawk gettext unzip file libssl-dev wget
```

Obtain the source code from GitHub via:
```bash
git clone https://github.com/seemoo-lab/lede-ad7200.git lede-ad7200
cd lede-ad7200
```

Fetch the latest package definitions and install corresponding symlinks:
```bash
./scripts/feeds update -a
./scripts/feeds install -a
```

To build an image with the default configuration for the Talon AD7200, simply prepare the build process with:
```bash
cp default.conf .conf
make defconfig
```

Alternatively, if you need to refine your configuration, start with a clean configuration and select your preferred configuration for 
the toolchain and firmware::
```bash
cp legacy.conf .conf
make defconfig
make menuconfig
```

The last command will open the kernel configuration menu. Please ensure that you should select at least:
  * *Target System* => *Qualcomm Atheros IPQ806X*
  * *Target Profile* => *TP-Link Talon AD7200*

Simply running "make" will build your firmware:
```bash
make
```
It will download all sources, build the cross-compile toolchain, 
the kernel and all chosen applications. This may take some time on the first 
compilation, but definitely speeds up the next time when the toolchain has been build already.

To speed-up compilation using several CPU cores on multi-core computers, use:
```bash
make -j N
```
where N is your number of CPU cores + 1. However, this may lead to strange and hard-to-detect errors. 
Use the '-j' option only if you are familiar with the build system. 

To build your own firmware you need to have access to a Linux, BSD or MacOSX system
(case-sensitive filesystem required). Cygwin will not be supported because of
the lack of case sensitiveness in the file system.

Afterwards, the images can be found in ./bin/targets/ipq806x/generic/
The *lede-ipq806x-AD7200-squashfs-factory.bin* image should be used for installation.
Please do not use the *lede-ipq806x-AD7200-squashfs-sysupgrade.bin* image, as this is not supported yet.


## Device Flashing
To flash an image to the TALON device, you need to run a TFTP server on your machine. During boot, the TALON will start a TFTP client fetch the image file (webupdate is not working, yet).
This proceedure is default recovery mode in OpenWRT/LEDE. Check the documentation at https://lede-project.org/docs/user-guide/tftpserver and https://wiki.openwrt.org/doc/howto/generic.flashing.tftp
You can e.g. use tftpd-hpa,
```bash
sudo apt-get install tftpd-hpa
```
and place you image file in '/var/lib/tftpboot/'. The file must be named AD7200_1.0_tp_recovery.bin, and your machine must be setup with a fixed IP address of 192.168.0.66 in subnet 255.255.255.0. This is exactly the place, the bootloader looks for new firmware updates.
Next, you connect the router with any of the LAN ports to your machine, press and hold the reset pin, and power on the device.
Keep the reset button pressed for a couple of seconds until one of the LEDs starts blinking.
During the flash process, most LEDs stay on. If they went off after while, something went wrong. Please check your network settings again. Most likely, the router couldn't find the proper image file.
Otherwise if everthing went well, the LEDs stay on. Flashing takes some time, be patient.
Some routers reboot after flashing, some just don't. In the latter case, there is no way to check if flashing is done.
At some point you should take the risk, and reboot manually. If this happens too early, then you have to try (and wait) with little more patience again.
Happy flashing and good luck :)

## Accessing Device via SSH
The devices are configured with fixed IP address and SSH server running. Can can login remotely as root via:
```bash
ssh root@192.168.0.1
```
Please ensure that you have configured your client accordingly.
