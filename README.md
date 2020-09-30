# [PH4WSL1.cmd](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/raw/master/PH4WSL1.cmd)

This scripts performs an automated install of Pi-Hole on Windows 10, version 1803 or newer.

* Enables WSL1 and downloads Ubuntu 20.04 from Microsoft 

* Installs and Configures distro, downloads and executes Pi-hole installer 

* Creates a  **/etc/pihole/setupVars.conf** file for an automated install 

* Opens Windows Firewall ports for DNS and Pi-hole web admin

* Includes a Scheduled Task to accomodate auto-start at boot.  Edit the task, under General tab check **Run whether user is logged on or not** and **Hidden** and in the Conditions tab uncheck **Start the task only if the computer is on AC power**

Below is a console dump and (trimmed) screenshot of the install procedure:

```Pi-hole 5.x for WSL
------------------------------------------------------------------
Pi-hole listener IP and subnet in CIDR format, ie: 192.168.3.99/24
Respone: 10.74.0.253/24

Port for Pi-hole. Port 80 is good if you don't have a webserver, or hit enter for default [8880]:
Respone: 80

Fetching LxRunOffline...

Installing distro...

Configuring distro, this can take a few minutes...

Extracting templates from packages: 100%
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   145  100   145    0     0     44      0  0:00:03  0:00:03 --:--:--    74
100  118k  100  118k    0     0  25065      0  0:00:04  0:00:04 --:--:--  139k

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
  [✓] Checking for git
  [✓] Checking for iproute2
  [✓] Checking for whiptail
  [✓] Checking for dnsutils

  [✓] Supported OS detected
  [i] SELinux not detected
  [✗] Check for existing repository in /etc/.pihole
  [i] Clone https://github.com/pi-hole/pi-hole.git into /etc/.pihole...HEAD is now at 6b536b7 Merge pull request #3564 from pi-hole/release/v5.1.2
  [✓] Clone https://github.com/pi-hole/pi-hole.git into /etc/.pihole

  [✗] Check for existing repository in /var/www/html/admin
  [i] Clone https://github.com/pi-hole/AdminLTE.git into /var/www/html/admin...HEAD is now at a03d1bd Merge pull request #1498 from pi-hole/release/v5.1.1
  [✓] Clone https://github.com/pi-hole/AdminLTE.git into /var/www/html/admin

  [i] Main Dependency checks...
  [✓] Checking for cron
  [✓] Checking for curl
  [✓] Checking for iputils-ping
  [✓] Checking for lsof
  [✓] Checking for netcat
  [✓] Checking for psmisc
  [✓] Checking for sudo
  [✓] Checking for unzip
  [✓] Checking for wget
  [✓] Checking for idn2
  [✓] Checking for sqlite3
  [✓] Checking for libcap2-bin
  [✓] Checking for dns-root-data
  [✓] Checking for libcap2
  [✓] Checking for lighttpd
  [✓] Checking for php7.4-common
  [✓] Checking for php7.4-cgi
  [✓] Checking for php7.4-sqlite3
  [✓] Checking for php7.4-xml
  [✓] Checking for php7.4-intl

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


![PH4WSL](https://user-images.githubusercontent.com/33142753/94637641-7b3b9700-02ae-11eb-9d5f-e84579cccbdc.png)
