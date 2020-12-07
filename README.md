# PH4WSL1.cmd (Pi-hole for Windows)

**This script performs an automated install of Pi-hole 5.x on Windows 10 (version 1809 and newer) or Windows Server 2019 (Core and Standard) -- No Linux, Container, or Virtualization expertise required.**


Copy [PH4WSL1.cmd](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/raw/master/PH4WSL1.cmd) to your computer and "Run as Administrator."  

Ubuntu download and configuration completes in 5-20 minutes, depending on hardware.

* Enables WSL1 and downloads Ubuntu 20.04 from Microsoft 

* Installs and Configures distro, downloads and executes Pi-hole installer 

* Creates a  **/etc/pihole/setupVars.conf** file for an automated install

* Patches Pi-hole installer to use **netstat.exe** instead of **lsof** 

* Adds exceptions to Windows Firewall for DNS and Pi-hole admin page

* Includes a Scheduled Task **Pi-hole Launcher.cmd** to allow auto-start at boot, before logon.  Edit the task, under *General* tab check **Run whether user is logged on or not** and **Hidden** and (if needed) in the *Conditions* tab uncheck **Start the task only if the computer is on AC power**

**Requires the recent (August/Sept 2020) WSL update for Windows 10. If you don't have Windows up to date, Pi-hole installer will throw an "Unsupported OS" error midway through the installation.  Uninstall Pi-hole, update your machine and try again**

* 1809 - KB4571748
* 1909 - KB4566116
* 2004 - KB4571756

**Additional Info:**

* DHCP Server is disabled in the UI

* IPv6 works  

* To reset or reconfigure Pi-Hole, run **Pi-hole Configuration.cmd** in the Pi-hole install folder

* To uninstall Pi-Hole, run **Pi-hole Uninstall.cmd** in the Pi-hole install folder

**Trimmed console dump and screenshots:**

```
---------------------
 Pi-hole for Windows
--------------------- 
Set location for 'Pi-hole' install folder or hit enter for default [C:\Program Files] -> 

Pi-hole will be installed in "C:\Program Files\Pi-hole" and Web Admin will listen on port 80
Press any key to continue . . .

This will take a few minutes:  Installing Ubuntu 20.04 -> Compacting the install -> Install dependencies
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
![image](https://user-images.githubusercontent.com/33142753/101309475-e8295b00-3822-11eb-9a84-d22b74df849e.PNG)


**Install Complete:**
![image](https://user-images.githubusercontent.com/33142753/101309494-f4151d00-3822-11eb-8521-66a96279add0.PNG)
