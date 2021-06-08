# PH4WSL1.cmd (Pi-hole on Windows)
Note: There is no endorsement or partnership between this page and [**Pi-hole© LLC**](https://pi-hole.net).  They deserve [your support](https://pi-hole.net/donate/) if you find this useful.

This a simple script that convinces the Pi-hole installer to run on Windows.  

**Update 2021-05-22**:  
 - Rebased on Debian Buster for a smaller footprint.  
 - Integrated [**cloudflared**](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation) DNS over HTTPS and enabled DoH in the default configuration. 

By utilizing the Windows Subsystem for Linux it is possible to run Pi-hole on a Windows 10 PC just like any other Windows app.  The install script performs an automated install of Pi-hole 5.2+ on Windows 10 (version 1809 and newer) or Windows Server 2019 (including Hyper-V Core if you don't have a Windows license) - No Virtualization, Docker, or Linux expertise required.  Pi-hole can be used to block ads and encrypt DNS queries on your local Windows PC or the entire network. 

This approach uses fewer resources than a hypervisor/container, and runs on older CPU's without VT support, or on a VPS without pass-through virtualization.  If you have an old Windows tablet or HDMI stick with 1GB+ RAM and it can boot Windows x64, this is a great way to [upcycle](https://en.wikipedia.org/wiki/Upcycling) old hardware. 

**INSTRUCTIONS:** Copy [**PH4WSL1.cmd**](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/raw/master/PH4WSL1.cmd) to your computer, right click the file and select **"Run as Administrator."**  

Download and configuration steps complete in 5-20 minutes, depending on your hardware and antivirus solution.  If Windows Defender is active the installation will take longer.  Some users have reported isssues with [other antivurus products](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/issues/14) during installaion.

The script will:

* Enable WSL1 and download the official Debian 10 image from [**salsa.debian.org**](https://salsa.debian.org/debian/WSL/-/raw/master/x64/install.tar.gz) 

* Download the  [**LxRunOffline**](https://github.com/DDoSolitary/LxRunOffline) distro manager and install Debian

* Perform gateway detection and create a **/etc/pihole/setupVars.conf** file for automated install

* Run the [official installer](https://github.com/pi-hole/pi-hole/#one-step-automated-install) from Pi-hole©

* Patch Pi-hole installer to use **netstat.exe** instead of **lsof**, along with other fix-ups for WSL1 compatibility.

* Add exceptions to Windows Firewall for DNS and the Pi-hole admin page

* **NOTE:** After the install completes, the Scheduled Task **needs to be configured** for auto-start at boot (before logon).  
   - Open Windows Task Scheduler (taskschd.msc) and right-click the **Pi-hole for Windows** task, click edit.  
   - On the *General* tab, place a checkmark next to both **Run whether user is logged on or not** and **Hidden**  
   - On the *Conditions* tab, un-check the option **Start the task only if the computer is on AC power**

**IMPORTANT! Requires August/Sept 2020 WSL update for Windows 10.** This update is already included in Windows 20H2 and newer. If you don't have Windows up to date, Pi-hole installer will throw an "Unsupported OS" error midway through the installation.  If this occurrs, run the Pi-hole uninstaller, update your operating system and try again.  Minimum required updates are as follows:**

* 1809 - KB4571748
* 1909 - KB4566116
* 2004 - KB4571756

**Additional Info:**

* DHCP Server is not supported and has been removed from the UI.

* IPv6 DNS now works in addition to IPv4.

* To reset or reconfigure Pi-Hole, run **Pi-hole Configuration.cmd** in the Pi-hole install folder.

* To uninstall Pi-Hole go to the Pi-hole install folder, right-click **Pi-hole Uninstall.cmd** and click **Run As Administrator.**  If you plan on reinstalling, remember to first export your configuration via the Pi-hole web interface. 

**Trimmed console dump and screenshots:**

```
---------------------
 Pi-hole for Windows
--------------------- 
Set location for 'Pi-hole' install folder or hit enter for default [C:\Program Files] -> 

Pi-hole will be installed in "C:\Program Files\Pi-hole" and Web Admin will listen on port 80
Press any key to continue . . .

This will take a few minutes:  Installing Debian -> Compacting the install -> Install dependencies
Extracting templates from packages: 100%

Launching Pi-hole installer...

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   145  100   145    0     0    362      0 --:--:-- --:--:-- --:--:--   364
100  121k  100  121k    0     0   100k      0  0:00:01  0:00:01 --:--:--  222k

  [✓] Root user check

        .;;,.
        .ccccc:,.
         :cccclll:.      ..,,
          :ccccclll.   ;ooodc
           'ccll:;ll .oooodc
             .;cll.;;looo:.
                 .. ','.
                .',,,,,,'.
              .',,,,,,,,,,.
            .',,,,,,,,,,,,....
          ....''',,,,,,,'.......
        .........  ....  .........
        ..........      ..........
        ..........      ..........
        .........  ....  .........
          ........,,,,,,,'......
            ....',,,,,,,,,,,,.
               .',,,,,,,,,'.
                .',,,,,,'.
                  ..'''.

  [✓] Update local cache of available packages
  [i] Existing PHP installation detected : PHP version 7.4.3
  [i] Performing unattended setup, no whiptail dialogs will be displayed

  [✗] Checking apt-get for upgraded packages
      Kernel update detected. If the install fails, please reboot and try again
  [i] Installer Dependency checks...
  [✓] Checking for dhcpcd5
  [✓] Checking for git
  [✓] Checking for iproute2
  [✓] Checking for whiptail
  [✓] Checking for dnsutils

  [✓] Supported OS detected
  [i] SELinux not detected
  [✗] Check for existing repository in /etc/.pihole
  [i] Clone https://github.com/pi-hole/pi-hole.git into /etc/.pihole...HEAD is now at 0d8ece1 Merge pull request #3889 from pi-hole/release/v5.2.1
  [✓] Clone https://github.com/pi-hole/pi-hole.git into /etc/.pihole

  [✗] Check for existing repository in /var/www/html/admin
  [i] Clone https://github.com/pi-hole/AdminLTE.git into /var/www/html/admin...HEAD is now at 8ac95be Merge pull request #1647 from pi-hole/release/v5.2.1
  [✓] Clone https://github.com/pi-hole/AdminLTE.git into /var/www/html/admin

 
  [✓] Storing downloaded domains in new gravity database
  [✓] Building tree
  [✓] Swapping databases
  [i] Number of gravity domains: 85084 (85053 unique domains)
  [i] Number of exact blacklisted domains: 0
  [i] Number of regex blacklist filters: 0
  [i] Number of exact whitelisted domains: 0
  [i] Number of regex whitelist filters: 0
  [✓] Flushing DNS cache
  [✓] Cleaning up stray matter

  [✗] DNS service is NOT listening

  [i] The install log is located at: /etc/pihole/install.log
Update Complete!

  Current Pi-hole version is v5.2.1.
  Current AdminLTE version is v5.2.1.
  Current FTL version is v5.3.2.
  [✓] DNS service is listening
     [✓] UDP (IPv4)
     [✓] TCP (IPv4)
     [✓] UDP (IPv6)
     [✓] TCP (IPv6)

  [✓] Pi-hole blocking is enabled
  [✓] Restarting DNS server

--------------------------------------------------------------------------------
Pi-hole Web Admin, Enter New Password (Blank for no password):
  [✓] Password Removed
--------------------------------------------------------------------------------
SUCCESS: The scheduled task "Pi-hole for Windows" has successfully been created.

Pi-hole for Windows installed in C:\Program Files\Pi-hole
Press any key to continue . . .

C:\>       
```

**Installer run:**
![PH4WSL](https://user-images.githubusercontent.com/33142753/101309416-c16b2480-3822-11eb-95ab-e1e2e1953adc.png)


**Install Folder:**

![Install Folder](https://user-images.githubusercontent.com/33142753/101309475-e8295b00-3822-11eb-9a84-d22b74df849e.PNG)


**Install Complete:**

![Install Complete](https://user-images.githubusercontent.com/33142753/101309494-f4151d00-3822-11eb-8521-66a96279add0.PNG)


**Virtual Machine running Pi-hole on Hyper-V Server 2019 with 768MB RAM:**

![Install Complete](https://user-images.githubusercontent.com/33142753/119683187-d3b13d00-be19-11eb-8ed1-344fba3b6fdf.png)
