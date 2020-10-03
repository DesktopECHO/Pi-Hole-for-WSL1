@ECHO OFF
NET SESSION >NUL 2>&1
 if %errorLevel% == 0 (
      echo Administrative permissions confirmed...
  ) else (
      echo You need to run this command with administrative rights.  User Account Control enabled?
      pause
      goto ENDSCRIPT
  )
POWERSHELL.EXE -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
:INPUTS
CLS
ECHO.Pi-hole for Windows
ECHO.-------------------
ECHO.
ECHO Location of 'Pi-hole' folder [Default = %PROGRAMFILES%] 
SET PRGP=%PROGRAMFILES%& SET /p PRGP=Response: 
SET PRGF=%PRGP%\Pi-hole
IF EXIST "%PRGF%" GOTO INPUTS
ECHO.
ECHO.Pi-hole listener IP and subnet in CIDR format, ie: 192.168.1.99/24
SET /p IPSM=Response: 
ECHO.
ECHO.Port for Pi-hole. Port 80 is good if you don't have a webserver, or hit enter for default [8880]: 
SET PORT=8880& SET /p PORT=Response: 
ECHO.
ECHO.Install to: %PRGF% 
ECHO.   Network: %IPSM%
ECHO.      Port: %PORT%
IF NOT EXIST %TEMP%\Ubuntu.zip POWERSHELL.EXE -Command "Start-BitsTransfer -source https://aka.ms/wslubuntu2004 -destination '%TEMP%\Ubuntu.zip'"
POWERSHELL.EXE -Command "Expand-Archive -Path '%TEMP%\Ubuntu.zip' -DestinationPath '%TEMP%' -force"
ECHO.
ECHO.Fetching LxRunOffline...
%PRGF:~0,1%: & MKDIR "%PRGF%" & CD "%PRGF%"
POWERSHELL.EXE -Command "Start-BitsTransfer -source https://github.com/DesktopECHO/Pi-Hole-for-WSL1/raw/master/LxRunOffline.exe -destination '%PRGF%\LxRunOffline.exe'"
ECHO.
ECHO.Installing Ubuntu 20.04...
START /WAIT /MIN "Installing Ubuntu 20.04..." "LxRunOffline.exe" "i" "-n" "Pi-hole" "-f" "%TEMP%\install.tar.gz" "-d" "."
ECHO. 
ECHO.Slimming footprint... 
SET GO="%PRGF%\LxRunOffline.exe" r -n Pi-hole -c 
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh /etc/init.d/udev ; mv /usr/bin/sleep /usr/bin/sleep.wsl ; cp /usr/lib/klibc/bin/sleep /usr/bin/sleep"
%GO% "apt-get -qq --purge remove *vim* *sound* *alsa* *libgl* *pulse* mount dbus dbus-x11 console-setup console-setup-linux kbd xkb-data iso-codes libllvm9 mesa-vulkan-drivers powermgmt-base openssh-server openssh-sftp-server apport snapd open-iscsi plymouth open-vm-tools mdadm rsyslog ufw irqbalance lvm2 multipath-tools cloud-init cryptsetup cryptsetup-bin cryptsetup-run dbus-user-session dmsetup eject friendly-recovery init libcryptsetup12 libdevmapper1.02.1 libnss-systemd libpam-systemd libparted2 netplan.io packagekit packagekit-tools parted policykit-1 software-properties-common systemd systemd-sysv systemd-timesyncd ubuntu-standard xfsprogs udev apparmor byobu cloud-guest-utils landscape-common pollinate run-one sqlite3 usb.ids usbutils xxd --autoremove --allow-remove-essential ; apt-get update" >> "%PRGF%\Pi-hole_Install.log"
ECHO.
ECHO.Installing dependencies...
%GO% "apt-get -y install libklibc unattended-upgrades anacron cron logrotate inetutils-syslogd dns-root-data dnsutils gamin idn2 libgamin0 lighttpd netcat php-cgi php-common php-intl php-sqlite3 php-xml php7.4-cgi php7.4-cli php7.4-common php7.4-intl php7.4-json php7.4-opcache php7.4-readline php7.4-sqlite3 php7.4-xml sqlite3 unzip dhcpcd5 nano --no-install-recommends ; apt-get clean" >> "%PRGF%\Pi-hole_Install.log"
%GO% "mkdir /etc/pihole ; touch /etc/network/interfaces"
%GO% "echo BLOCKING_ENABLED=true      >  /etc/pihole/setupVars.conf"
%GO% "echo PIHOLE_INTERFACE=eth0      >> /etc/pihole/setupVars.conf"
%GO% "echo IPV4_ADDRESS=%IPSM%        >> /etc/pihole/setupVars.conf"
%GO% "echo PIHOLE_DNS_1=8.8.8.8       >> /etc/pihole/setupVars.conf"
%GO% "echo PIHOLE_DNS_2=8.8.4.4       >> /etc/pihole/setupVars.conf"
%GO% "echo QUERY_LOGGING=true         >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_SERVER=true    >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_INTERFACE=true >> /etc/pihole/setupVars.conf"
%GO% "echo LIGHTTPD_ENABLED=true      >> /etc/pihole/setupVars.conf"
ECHO.
ECHO.Launching Pi-hole installer...
%GO% "curl -L https://install.Pi-hole.net | bash /dev/stdin --unattended"
ECHO.
%GO% "echo Web Interface Admin ; pihole -a -p"
%GO% "sed -i 's/= 80/= %PORT%/g' /etc/lighttpd/lighttpd.conf"
%GO% "touch /var/run/syslog.pid ; chmod 600 /var/run/syslog.pid"

NetSH AdvFirewall Firewall add rule name="WSL Pi-hole Admin Page" dir=in action=allow protocol=TCP localport=%PORT%  >> "%PRGF%\Pi-hole_Install.log"
NetSH AdvFirewall Firewall add rule name="WSL Pi-hole DNS (TCP)"  dir=in action=allow protocol=TCP localport=53      >> "%PRGF%\Pi-hole_Install.log"
NetSH AdvFirewall Firewall add rule name="WSL Pi-hole DNS (UDP)"  dir=in action=allow protocol=UDP localport=53      >> "%PRGF%\Pi-hole_Install.log"

ECHO @"%PRGF%\LxRunOffline.exe" r -n Pi-hole -c "apt-get -qq remove dhcpcd5 > /dev/null"                      >  "%PRGF%\Pi-hole_Task.cmd" 
ECHO @"%PRGF%\LxRunOffline.exe" r -n Pi-hole -c "sed -i 's/= 80/= %PORT%/g'  /etc/lighttpd/lighttpd.conf"     >> "%PRGF%\Pi-hole_Task.cmd"
ECHO @%GO% "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service restart ; done ; sleep 3" >> "%PRGF%\Pi-hole_Task.cmd"
ECHO @EXIT                                                                                                    >> "%PRGF%\Pi-hole_Task.cmd"
ECHO @WSLCONFIG /T Pi-hole                                      >  "%PRGF%\Pi-hole_Reconfigure.cmd"
ECHO @"%PRGF%\LxRunOffline.exe" r -n Pi-hole -c "pihole -r"     >> "%PRGF%\Pi-hole_Reconfigure.cmd"
ECHO @START /WAIT /MIN "Pi-hole Init" "%PRGF%\Pi-hole_Task.cmd" >> "%PRGF%\Pi-hole_Reconfigure.cmd"
ECHO @START http://%COMPUTERNAME%:%PORT%/admin                  >> "%PRGF%\Pi-hole_Reconfigure.cmd"
ECHO @ECHO Uninstall Pi-hole?                               >  "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO @PAUSE                                                 >> "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO @COPY /Y "%PRGF%\LxRunOffline.exe" "%TEMP%"            >> "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO @CD "%USERPROFILE%"		                    >> "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO @WSLCONFIG /T Pi-hole                                  >> "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO @"%TEMP%\LxRunOffline.exe" ur -n Pi-hole               >> "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO @RD /S /Q "%PRGF%"                                     >> "%PRGF%\Pi-hole_Uninstall.cmd"
ECHO ---------------------------------------------------------------------------
SCHTASKS /CREATE /RU %USERNAME% /RL HIGHEST /SC ONSTART /TN "Pi-hole for WSL" /TR '"%PRGF%\Pi-hole_Task.cmd"' /F
START /WAIT /MIN "Pi-hole Init" "%PRGF%\Pi-hole_Task.cmd"  
ECHO Pi-hole for Windows Installed to %PRGF%
START /MIN "Installing Ubuntu 20.04 updates in background, do not run Pi-hole_Reconfigure.cmd until this completes..." "%PRGF%\LxRunOffline.exe" r -n Pi-hole -c "apt-get -y dist-upgrade ; apt-get purge ; apt-get clean"
START http://%COMPUTERNAME%:%PORT%/admin
ECHO.
:ENDSCRIPT
