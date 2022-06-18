# PH4WSL1.cmd &nbsp;· &nbsp;Pi-hole for Windows
![image](https://user-images.githubusercontent.com/33142753/160953270-8f874a4d-ef32-4d66-adb8-24a628cd6aad.png)

Install script to help [Pi-hole](https://github.com/pi-hole) run semi-natively under Windows 10/11 and Server 2019/2022 by leveraging the Windows Subsystem for Linux, renamed later to WSL1.  Because WSL1 does not require a hypervisor and full Linux kernel it's the most lightweight way to run Pi-hole on Windows.  Pi-hole and associated Linux binaries are visible in Task Manager right alongside your Windows apps (See Windows 11 screenshot above.)  

 - Brief [installation walk-through](https://youtu.be/keDtJwK65Dw) on YouTube
 - Jump to [Install Instructions](#INSTALL-INSTRUCTIONS)

## Latest Updates for 2022-06-24

 - [**Gravity Sync**](https://github.com/vmstan/gravity-sync) lets you easily synchronize multiple Pi-hole instances.  Run ``Gravity Sync.cmd`` and copy/paste the command into the console of another Debian or Ubuntu-based Pi-hole.
 ![gs](https://user-images.githubusercontent.com/33142753/175460831-32f62c83-34c1-4860-b44b-7204f544a10f.png)
 - Less Pi-hole code is patched since upstream moved from ``lsof`` to ``ss`` for port and service checking.  Now a wrapper for ``ss`` on WSL1 reformats the output of ``netstat.exe`` into something Pi-hole can work with.
 - Integrated [**Unbound DNS Resolver**](https://www.nlnetlabs.nl/projects/unbound/about) and set the default Pi-hole configuration to use encrypted DNS.
 - Updated to Debian 11
 - Fixes for Windows 11 compatibility 
 - Added links in the install folder for ``Pi-hole System Update.cmd``, ``Pi-hole Gravity Update.cmd``, and ``Pi-hole Web Admin.cmd`` 
 - Debian is configured to stay up-to-date with '[unattended-upgrades](https://wiki.debian.org/UnattendedUpgrades)' 

## Note
There is no endorsement or partnership between this page and [**Pi-hole© LLC**](https://pi-hole.net).  They deserve [your support](https://pi-hole.net/donate/) if you find this useful.

Pi-hole for Windows can be used to block ads and encrypt DNS queries for your local Windows PC or entire network.  If you use it to serve DNS for your entire network, it's **highly** recommended you install a second Pi-hole for Windows instance on another PC on your network, and enable Gravity Sync to ensure DNS is constantly available should one of the Windows PCs need to reboot for a security update or other reason. 

Pi-hole for Windows is a great way to [upcycle](https://en.wikipedia.org/wiki/Upcycling) old hardware. If you have a Windows PC, tablet, or HDMI stick with 1GB RAM and it boots Windows 10 x64 you are good to go.  If you don't have a Windows license, Hyper-V Server 2019 works and is a [free download](https://www.microsoft.com/en-us/evalcenter/evaluate-hyper-v-server-2019) from Microsoft. 

# INSTALL INSTRUCTIONS
1. Save [**PH4WSL1.cmd**](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/raw/master/PH4WSL1.cmd) to your computer, right click the file and select **"Run as Administrator."**  

Download and configuration steps complete in 2-15 minutes, depending on your hardware and antivirus solution.  If Windows Defender is active the installation will take longer.  Some users have reported issues with [other antivirus products](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/issues/14) during installation.

## This script performs the following steps:

1. Enable WSL1 and install a Debian-built image from [**salsa.debian.org**](https://salsa.debian.org/debian/WSL/-/raw/master/x64/install.tar.gz) 
2. Download the [**LxRunOffline**](https://github.com/DDoSolitary/LxRunOffline) distro manager and install Debian 11 (Bullseye)
3. Perform interface/gateway detection and create a **/etc/pihole/setupVars.conf** file for automated install
4. Run the [official installer](https://github.com/pi-hole/pi-hole/#one-step-automated-install) from Pi-hole©
5. Create shim so Pi-hole gets the expected output from ``/bin/ss`` along with other fix-ups for WSL1 compatibility.
6. Add exceptions to Windows Firewall for DNS and the Pi-hole admin page

### NOTE 
  After the install completes, the Scheduled Task **needs to be configured** for auto-start at boot (before logon).  
   1. Open Windows Task Scheduler (taskschd.msc) and right-click the **Pi-hole for Windows** task, click edit.  
   2. On the *General* tab, place a checkmark next to both **Run whether user is logged on or not** and **Hidden**  
   3. On the *Conditions* tab, un-check the option **Start the task only if the computer is on AC power**

# Additional Info

* DHCP Server is not supported and is disabled in the Pi-hole Web UI.

* IPv6 DNS now works in addition to IPv4.

* To reset or reconfigure Pi-Hole, run **Pi-hole Configuration.cmd** in the Pi-hole install folder.

* To completely uninstall Pi-Hole, open the Pi-hole install folder in Windows Explorer.  Right-click ``Pi-hole Uninstall.cmd`` and click **Run As Administrator.**  If you are uninstalling or reinstalling and need to retain your Pi-hole's configuration, export it first via the web interface. 

# Screenshots

## Installer run
![PH4WSL](https://user-images.githubusercontent.com/33142753/101309416-c16b2480-3822-11eb-95ab-e1e2e1953adc.png)


## Install Folder

![Install Folder](https://user-images.githubusercontent.com/33142753/153233161-c7b5d9af-6120-448e-b4e7-d51f23c43dd9.PNG)


## Install Complete

![Install Complete](https://user-images.githubusercontent.com/33142753/101309494-f4151d00-3822-11eb-8521-66a96279add0.PNG)
