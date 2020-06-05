@ECHO OFF
POWERSHELL.EXE -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
CLS
ECHO.WSL1 Install Helper for Pi-Hole 5.0  //  Daniel Milisic
ECHO.-------------------------------------------------------------------
ECHO.Enter the IPv4 and subnet mask in CIDR format that Pi-Hole will use
ECHO.Example: 192.168.3.99/24
SET /p IPSM=Respone: 

IF NOT EXIST %TEMP%\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz POWERSHELL.EXE -Command "wget https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -OutFile %TEMP%\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz"
POWERSHELL.EXE -Command "wget https://github.com/DesktopECHO/xWSL/raw/master/LxRunOffline.exe -UseBasicParsing -OutFile %PROGRAMDATA%\LxRunOffline.exe"

%PROGRAMDATA%\LxRunOffline.exe i -d %PROGRAMDATA%\Pi-Hole -f %TEMP%\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -n Pi-Hole

%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "add-apt-repository -y ppa:rafaeldtinoco/lp1871129"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "apt-get -y install libc6=2.31-0ubuntu8+lp1871129~1 libc-dev-bin=2.31-0ubuntu8+lp1871129~1 --allow-downgrades ; apt-mark hold libc6"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh ; rm -rf  /var/lib/dpkg/info/udev.postinst"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "apt-get -y --purge remove openssh-server openssh-sftp-server apport snapd open-iscsi plymouth open-vm-tools mdadm rsyslog ufw irqbalance lvm2 multipath-tools cloud-init cryptsetup cryptsetup-bin cryptsetup-run dbus-user-session dmsetup eject friendly-recovery init libcryptsetup12 libdevmapper1.02.1 libnss-systemd libpam-systemd libparted2 netplan.io packagekit packagekit-tools parted policykit-1 software-properties-common systemd systemd-sysv systemd-timesyncd ubuntu-standard xfsprogs udev --autoremove --allow-remove-essential"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "apt-get -y install dns-root-data dnsutils gamin idn2 libgamin0 lighttpd netcat php-cgi php-common php-intl php-sqlite3 php-xml php7.4-cgi php7.4-cli php7.4-common php7.4-intl php7.4-json php7.4-opcache php7.4-readline php7.4-sqlite3 php7.4-xml sqlite3 unzip dhcpcd5 nano cron"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "mkdir /etc/pihole ; touch /etc/network/interfaces"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo BLOCKING_ENABLED=true > /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo PIHOLE_INTERFACE=eth0 >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo IPV4_ADDRESS=%IPSM% >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo PIHOLE_DNS_1=8.8.8.8 >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo PIHOLE_DNS_2=8.8.4.4 >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo QUERY_LOGGING=true >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo INSTALL_WEB_SERVER=true >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo INSTALL_WEB_INTERFACE=true >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo LIGHTTPD_ENABLED=true >> /etc/pihole/setupVars.conf"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "curl -L https://install.pi-hole.net | bash /dev/stdin --unattended"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "echo Web Interface Admin ; pihole -a -p"
%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "sed -i 's/= 80/= 10080/g'  /etc/lighttpd/lighttpd.conf"

NetSH AdvFirewall Firewall add rule name="Pi-Hole for WSL Admin" dir=in action=allow protocol=TCP localport=10080
NetSH AdvFirewall Firewall add rule name="Pi-Hole for DNS (TCP)" dir=in action=allow protocol=TCP localport=53
NetSH AdvFirewall Firewall add rule name="Pi-Hole for DNS (UDP)" dir=in action=allow protocol=UDP localport=53

SCHTASKS /CREATE /RU %USERNAME% /RL HIGHEST /SC ONSTART /TN "Pi-Hole for WSL Launcher" /TR %PROGRAMDATA%\Pi-Hole.cmd /F 
ECHO $task = Get-ScheduledTask "Pi-Hole for WSL Launcher" ; $task.Settings.ExecutionTimeLimit = "PT0S" ; Set-ScheduledTask $task > %TEMP%\ExecTimeLimit.ps1
POWERSHELL -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -COMMAND %TEMP%\ExecTimeLimit.ps1

ECHO @IF [%1]==[-r] C:\ProgramData\LxRunOffline.exe r -n Pi-Hole -c "pihole -r"                                                                > %PROGRAMDATA%\Pi-Hole.cmd
ECHO @%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "sed -i 's/= 80/= 10080/g'  /etc/lighttpd/lighttpd.conf"                                 >> %PROGRAMDATA%\Pi-Hole.cmd
ECHO @%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service restart ; done" >> %PROGRAMDATA%\Pi-Hole.cmd
     @%PROGRAMDATA%\LxRunOffline.exe r -n Pi-Hole -c "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service start   ; done"
     @START "First Run" http://%COMPUTERNAME%:10080/admin

