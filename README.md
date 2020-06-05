[PH4WSL1.cmd](https://github.com/DesktopECHO/Pi-Hole-for-WSL1/blob/master/PH4WSL1.cmd)

Enables WSL if not already done

Downloads (from Ubuntu) the latest 20.04 WSL Image

Assembles dependancies and trims some packages

Opens firewall ports 53 (DNS) and 10080 (Pi-hole web admin)

Creates a  **/etc/pihole/setupVars.conf** file so the installer has a smoother run (the lack of an init system confuses the Pi-hole installer)  

In Windows, **C:\\ProgramData\\Pi-hole.cmd -r** is an alias for **/usr/local/bin/pihole -r** \- You don't have to do any linux-y stuff if you just want a working Pi-hole.

Includes a Scheduled Task to accomodate running at login or boot time.
