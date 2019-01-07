# LEDE for Talon AD7200
<img src="logos/talon.png" align="right" width=20% height=20%/>
This project contains the source code to compile a LEDE image for the TP-Link Talon AD7200. With the wil6210 driver and firmware already integrated, it supports to configure the 60 GHz interface in AP, managed, and monitor mode. Therewith it allows to easily establish mm-wave links between multiple devices. Through the Linux based operating system, this allows to use the Talon AD7200 routers for arbitrary application scenarios.

## Usage Report and Statistics
Our Talon Tools framework is a research project that we share with the community so that others can reproduce our results and benefit from it. We aim to record basic statistics on where and for what purpose our tools are used. Please consider filling our short [usage report](https://goo.gl/forms/QKU0ME98f2gYhs5B2) that will only take a few minutes. You can also use this to report your publications. Doing so, you support us to keep track on the usage and allow us to continuously refine our work. 

## WARNING
This software might damage your hardware and may void your hardware’s warranty. Use our tools at your risk and responsibility.

## Download Pre-Build Image
To save time compiling the complete buildsystem, you can download our [pre-build images](https://github.com/seemoo-lab/lede-ad7200/releases) and directly flash it to the device (see "Device Flashing" below). If you want to integrate own functionality continue with the following build instructions.

## Quick Image Build Instructions

This is a quick build instruction guide to compile a LEDE image for the Talon AD7200. Parts of this instruction has been taken from the official [LEDE documentation](https://lede-project.org/docs/guide-developer/quickstart-build-images) and has been adapted for the given architecture.

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
cp default.config .config
make defconfig
```

Alternatively, if you need to refine your configuration, start with a clean configuration and select your preferred configuration for 
the toolchain and firmware:
```bash
cp legacy.config .config
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
To flash an image to the device, you need to run a TFTP server on your machine. During recovery boot, the device will start a TFTP client and fetch the image file.
This proceedure is default recovery mode in OpenWRT/LEDE. Check the documentation at https://lede-project.org/docs/user-guide/tftpserver and https://wiki.openwrt.org/doc/howto/generic.flashing.tftp
You can e.g. use tftpd-hpa,
```bash
sudo apt-get install tftpd-hpa
```
and place your image file in '/var/lib/tftpboot/'. The file must be named *AD7200_1.0_tp_recovery.bin*, and your machine must be setup with fixed IP address according to the following table. 

 * **image name**: *AD7200_1.0_tp_recovery.bin*
 * **ip address**: *192.168.0.66*
 * **net mask**: *255.255.255.0*

Only at this address and with exactly this filename the bootloader checks firmware updates.

Next, you connect the Talon device with any of the LAN ports to your machine, press and hold the reset pin, and power-on the device. 
All LEDs should turn on. Keep the reset button pressed for a couple of seconds until one of the LEDs starts blinking.
During the flash process, most LEDs stay on. If they went off again after a few seconds, something went wrong and the device restarts. 
In this case, you should check your network settings again. Most likely, the router cannot find find the image file.

If everything went well, the LEDs stay on and flashing takes some minutes. Some devices reboot after flashing, some stuck and need to be rebooted manually. Unfortunately, there is no easy way to check if flashing is completed. After around 10 - 15 minutes, you could take the risk and manually power off and on the device. If it does not boot up with your new firmware, try flashing again and be little more patient. Good luck. 

## Accessing Device via SSH
The devices are configured by default with fixed IP address and SSH server running. You can login remotely as root via:
```bash
ssh root@192.168.0.1
```
Please ensure that you have configured your client accordingly.

## Customizing the Image
You can add additional files to the image by placing them in the */files* folder.  

## Establish a 60 GHz Link
To establish a link, you need to configure one device as AP. The default image comes with a predefined configuration, you just need to start the hostapd daemon for the *wlan2* interface:
```bash
hostapd -B /etc/hostapd_wlan2.conf
```
This will start the AP with SSID *TALON_AD7200* on channel 2 without any encryption. Other devices in manged mode and range can connect using the wpa_supplicant:
```bash
wpa_supplicant -Dnl80211 -iwlan2 -c/etc/wpa_supplicant.conf -B
```
Up 8 managed stations are supported to connect to one AP simultaneously. Finally you need to configure the IP Addresses (replace XXX by any number less than 255):
```bash
$ ifconfig wlan2 192.168.100.XXX
```

## Set-up Monitor Mode
To configure a device in monitor mode on channel 2 use:
```bash
ifconfig wlan2 up
iw dev wlan2 set type monitor
iw dev wlan2 set freq 60480
ifconfig wlan2 down
ifconfig wlan2 up
```
Take note, that under heavy load the monitor mode might not catch all network packets correctly.

## Talon Tools
This software has been released as part of [Talon Tools: The Framework for Practical IEEE 802.11ad Research](https://seemoo.de/talon-tools/). Any use of it, which results in an academic publication or other publication which includes a bibliography is encouraged to appreciate this work and include a citation the Talon Tools project and any of our papers. You can find all references on Talon Tools in our [bibtex file](https://seemoo-lab.github.io/talon-tools/talon-tools.bib). Please also check the [project page](https://seemoo.de/talon-tools/) for supplemental tools.

## Give us Feedback
We want to learn how people use this software and what aspects we might improve. Please report any issues or comments using the bug-tracker and do not hesitate to approach us via e-mail.

## Contact
* [Daniel Steinmetzer](https://seemoo.tu-darmstadt.de/dsteinmetzer) <<dsteinmetzer@seemoo.tu-darmstadt.de>>
* Daniel Wegemer <<dwegemer@seemoo.tu-darmstadt.de>>

## Powered By
<a href="https://www.seemoo.tu-darmstadt.de">![SEEMOO logo](https://seemoo-lab.github.io/talon-tools/logos/seemoo.png)</a> &nbsp;
<a href="https://www.nicer.tu-darmstadt.de">![NICER logo](https://seemoo-lab.github.io/talon-tools/logos/nicer.png)</a> &nbsp;
<a href="https://www.crossing.tu-darmstadt.de">![CROSSING logo](https://seemoo-lab.github.io/talon-tools/logos/crossing.jpg)</a>&nbsp;
<a href="https://www.crisp-da.de">![CRSIP logo](https://seemoo-lab.github.io/talon-tools/logos/crisp.jpg)</a>&nbsp;
<a href="http://www.maki.tu-darmstadt.de/">![MAKI logo](https://seemoo-lab.github.io/talon-tools/logos/maki.png)</a> &nbsp;
<a href="https://www.cysec.tu-darmstadt.de">![CYSEC logo](https://seemoo-lab.github.io/talon-tools/logos/cysec.jpg)</a>&nbsp;
<a href="https://www.tu-darmstadt.de/index.en.jsp">![TU Darmstadt logo](https://seemoo-lab.github.io/talon-tools/logos/tudarmstadt.png)</a>&nbsp;
