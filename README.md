# PH4WSL1.cmd (Pi-hole for Windows)

This scripts performs an automated install of Pi-hole 5 on Windows 10 (version 1803 and newer) or Windows Server 2019, no Linux expertise required.

Copy [PH4WSL1.cmd](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/raw/master/PH4WSL1.cmd) to your computer and "Run as Administrator"

* Enables WSL1 and downloads Ubuntu 20.04 from Microsoft 

* Installs and Configures distro, downloads and executes Pi-hole installer 

* Creates a  **/etc/pihole/setupVars.conf** file for an automated install 

* Adds exceptions to Windows Firewall for DNS and Pi-hole admin page

* Includes a Scheduled Task **Pi-hole_Task.cmd** to allow auto-start at boot, before logon.  Edit the task, under *General* tab check **Run whether user is logged on or not** and **Hidden** and (if needed) in the *Conditions* tab uncheck **Start the task only if the computer is on AC power**

Additional Info:

* DHCP Server is disabled and only IPv4 is supported

* To reset or reconfigure Pi-Hole, run **Pi-hole_Reconfigure.cmd** in the Pi-hole install folder

* To uninstall Pi-Hole, run **Pi-hole_Uninstall.cmd** in the Pi-hole install folder

Below is a console dump and (trimmed) screenshot of the install procedure:

```Pi-hole for WSL
---------------

Location of 'Pi-hole' folder [Default = C:\Program Files]
Response:

Pi-hole listener IP and subnet in CIDR format, ie: 192.168.1.99/24
Response: 10.74.0.253/24

Port for Pi-hole. Port 80 is good if you don't have a webserver, or hit enter for default [8880]:
Response: 80

Install to: C:\Program Files\Pi-hole
   Network: 10.74.0.253/24
      Port: 80

Fetching LxRunOffline...

Installing distro...

Configuring distro, this can take a few minutes...

Extracting templates from packages: 100%



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
  [✓] Disk space check

  [✗] Checking apt-get for upgraded packages
      Kernel update detected. If the install fails, please reboot and try again
  [i] Installer Dependency checks...
  [✓] Checking for dhcpcd5
 
  [✓] Supported OS detected
  [i] SELinux not detected
  [✗] Check for existing repository in /etc/.pihole
  [i] Clone https://github.com/pi-hole/pi-hole.git into /etc/.pihole...HEAD is now at 6b536b7 Merge pull request #3564 from pi-hole/release/v5.1.2
  [✓] Clone https://github.com/pi-hole/pi-hole.git into /etc/.pihole

  [✗] Check for existing repository in /var/www/html/admin
  [i] Clone https://github.com/pi-hole/AdminLTE.git into /var/www/html/admin...HEAD is now at a03d1bd Merge pull request #1498 from pi-hole/release/v5.1.1
  [✓] Clone https://github.com/pi-hole/AdminLTE.git into /var/www/html/admin

  [✓] Enabling lighttpd service to start on reboot...
  [✓] Creating user 'pihole'

  [i] FTL Checks...

  [✓] Detected x86_64 architecture
  [i] Checking for existing FTL binary...
  [✓] Downloading and Installing FTL
  [✓] Installing scripts from /etc/.pihole

  [i] Installing configs from /etc/.pihole...
  [✓] No dnsmasq.conf found... restoring default dnsmasq.conf...
  [✓] Copying 01-pihole.conf to /etc/dnsmasq.d/01-pihole.conf

  [i] Installing blocking page...
  [✓] Creating directory for blocking page, and copying files
  [✓] Backing up index.lighttpd.html

  [✓] Installing sudoer file

  [✓] Installing latest Cron script

  [✓] Installing latest logrotate script
  [i] Backing up /etc/dnsmasq.conf to /etc/dnsmasq.conf.old
  [✓] man pages installed and database updated
  [i] Testing if systemd-resolved is enabled
  [i] Systemd-resolved is not enabled
  [i] Lighttpd is disabled, skipping service restart
  [i] Restarting services...
  [✓] Enabling pihole-FTL service to start on reboot...
  [✓] Restarting pihole-FTL service...
  [i] Creating new gravity database
  [i] Migrating content of /etc/pihole/adlists.list into new database
  [✓] Deleting existing list cache
  [i] Neutrino emissions detected...
  [✓] Pulling blocklist source list into range

  [✓] Preparing new gravity database
  [i] Target: https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
  [✓] Status: Retrieval successful
  [i] Received 56949 domains

  [i] Target: https://mirror1.malwaredomains.com/files/justdomains
  [✓] Status: Retrieval successful
  [i] Received 26854 domains

  [✓] Storing downloaded domains in new gravity database
  [✓] Building tree
  [✓] Swapping databases
  [i] Number of gravity domains: 83803 (83761 unique domains)
  [i] Number of exact blacklisted domains: 0
  [i] Number of regex blacklist filters: 0
  [i] Number of exact whitelisted domains: 0
  [i] Number of regex whitelist filters: 0
  [✓] Flushing DNS cache
  [✓] Cleaning up stray matter

  [✓] DNS service is running
  [✓] Pi-hole blocking is Enabled
  [i] Web Interface password: g7ZApLbw
  [i] This can be changed using 'pihole -a -p'

  [i] View the web interface at http://pi.hole/admin or http://10.74.0.253/admin

  [i] You may now configure your devices to use the Pi-hole as their DNS server
  [i] Pi-hole DNS (IPv4): 10.74.0.253
  [i] If you set a new IP address, please restart the server running the Pi-hole

  [i] The install log is located at: /etc/pihole/install.log
Installation Complete!
Web Interface Admin
Enter New Password (Blank for no password):
  [✓] Password Removed
SUCCESS: The scheduled task "Pi-hole for WSL" has successfully been created.

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\                                              Pi-hole for WSL                   Ready


SUCCESS: Attempted to run the scheduled task "Pi-hole for WSL".
Wait for launcher window to close then
Press any key to continue . . .
Pi-hole 5.x for WSL Install Complete!                  
```
Expected installer output, truncated screen shot:

![PH4WSL](https://user-images.githubusercontent.com/33142753/94637641-7b3b9700-02ae-11eb-9d5f-e84579cccbdc.png)

**Pi-hole-Reconfigure.cmd**
![image](https://user-images.githubusercontent.com/33142753/94819292-76bdce00-03d5-11eb-96ae-452fe4631c99.png)
