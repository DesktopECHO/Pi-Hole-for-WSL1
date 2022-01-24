@CHCP 65001 > NUL
@ECHO OFF & NET SESSION >NUL 2>&1 
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run the Pi-hole installer with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)
POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"
SET PORT=80
START /MIN /WAIT "Check for Open Port" "POWERSHELL" "-COMMAND" "Get-NetTCPConnection -LocalPort 80 > '%TEMP%\PortCheck.tmp'"
FOR /f %%i in ("%TEMP%\PortCheck.tmp") do set SIZE=%%~zi 
IF %SIZE% gtr 0 SET PORT=60080
:INPUTS
CLS
ECHO.-------------------------------- & ECHO. Pi-hole for Windows v.20220124 & ECHO.-------------------------------- & ECHO.
SET PRGP=%PROGRAMFILES%&SET /P "PRGP=Set location for 'Pi-hole' install folder or hit enter for default [%PROGRAMFILES%] -> "
IF %PRGP:~-1%==\ SET PRGP=%PRGP:~0,-1%
SET PRGF=%PRGP%\Pi-hole
IF EXIST "%PRGF%" (ECHO. & ECHO Pi-hole folder already exists, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
WSL.EXE -d Pi-hole -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (ECHO. & ECHO Existing Pi-hole installation detected, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
ECHO.
ECHO.Pi-hole will be installed in "%PRGF%" and Web Admin will listen on port %PORT%
PAUSE 
IF NOT EXIST %TEMP%\Debian.tar.gz    POWERSHELL.EXE -Command "Start-BitsTransfer -source https://github.com/DesktopECHO/Pi-Hole-for-WSL1/blob/master/debian11.1b9e7597.tar.gz?raw=true -destination '%TEMP%\Debian.tar.gz'"
IF NOT EXIST %TEMP%\LxRunOffline.zip POWERSHELL.EXE -Command "Start-BitsTransfer -source https://github.com/DesktopECHO/Pi-Hole-for-WSL1/blob/master/LxRunOffline-v3.5.0-33-gbdc6d7d-msvc.zip?raw=true?raw=true -destination '%TEMP%\LxRunOffline.zip'"
%PRGF:~0,2% & MKDIR "%PRGF%" & CD "%PRGF%" & MKDIR "logs" 
FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v"
ICACLS "%PRGF%" /grant "%WAI%:(CI)(OI)F" > NUL
ECHO @ECHO OFF ^& CLS ^& NET SESSION ^>NUL 2^>^&1                                  > "%PRGF%\Pi-hole Uninstall.cmd"
ECHO IF ^%%ERRORLEVEL^%% == 0 ^(ECHO Pi-hole Uninstaller: Close window to abort or>> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO )ELSE ^(ECHO Please run uninstaller with admin rights! ^&^& pause ^&^& EXIT) >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO PAUSE ^& ECHO. ^& ECHO Uninstalling Pi-hole . . .                            >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO COPY /Y "%PRGF%\LxRunOffline.exe" "%TEMP%" ^> NUL 2^>^&1                     >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO SCHTASKS /Delete /TN:"Pi-hole for Windows" /F ^> NUL 2^>^&1                  >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole FTL"                       >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole Web Admin"                 >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole Gravity Sync"              >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole DNS (TCP)"                 >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole DNS (UDP)"                 >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO %PRGF:~0,2% ^& CD "%PRGF%" ^& WSLCONFIG /T Pi-hole ^> NUL 2^>^&1             >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO "%TEMP%\LxRunOffline.exe" ur -n Pi-hole ^> NUL 2^>^&1 ^& CD ..               >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO ECHO. ^& ECHO Uninstall Complete!                                            >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO START /MIN "Uninstall" "CMD.EXE" /C RD /S /Q "%PRGF%"                        >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO.
ECHO This will take a few minutes to complete . . .
ECHO|SET /p="Installing Debian "
POWERSHELL.EXE -Command "Expand-Archive -Force -Path '%TEMP%\LxRunOffline.zip' -DestinationPath '%TEMP%' ; Copy-Item '%TEMP%\LxRunOffline-v3.5.0-33-gbdc6d7d-msvc\LxRunOffline.exe' '%PRGF%'"
START /WAIT /MIN "Install Debian instance..." "LxRunOffline.exe" "i" "-n" "Pi-hole" "-f" "%TEMP%\Debian.tar.gz" "-d" "."
ECHO|SET /p="-> Compacting install " 
SET GO="%PRGF%\LxRunOffline.exe" r -n Pi-hole -c 
%GO% "apt-get -y purge dmsetup libapparmor1 libargon2-1 libdevmapper1.02.1 libestr0 libfastjson4 liblognorm5 rsyslog systemd systemd-sysv vim-common vim-tiny xxd --autoremove --allow-remove-essential" > "%PRGF%\logs\Pi-hole Compact Stage.log"
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh /etc/init.d/udev"
ECHO.-^> Install dependencies . . .
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; apt-get update ; apt-get -y install sshpass expect rsync xinetd update-inetd ssh openssh-server openssh-sftp-server openssh-client unbound gpg wget curl ca-certificates libpsl5 openssl perl-modules-5.32 libgdbm6 libgdbm-compat4 libperl5.32 perl libcurl3-gnutls liberror-perl git unattended-upgrades anacron inetutils-syslogd dns-root-data dnsutils gamin idn2 libgamin0 lighttpd netcat php-cgi php-common php-intl php-sqlite3 php-xml php7.4-cgi php7.4-cli php7.4-common php7.4-intl php7.4-json php7.4-opcache php7.4-readline php7.4-sqlite3 php7.4-xml sqlite3 unzip --no-install-recommends" > "%PRGF%\logs\Pi-hole Dependency Stage.log"
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; wget -q https://raw.githubusercontent.com/DesktopECHO/Pi-Hole-for-WSL1/master/pi-hole.conf -O /etc/unbound/unbound.conf.d/pi-hole.conf" > NUL
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; wget -q https://raw.githubusercontent.com/DesktopECHO/Pi-Hole-for-WSL1/master/ss -O /.ss ; chmod +x /.ss ; cp /.ss /bin/ss" > NUL
%GO% "sed -i 's#^ssh             22/tcp#ssh           5322/tcp#g' /etc/services ;  sed -i 's/#UseDNS no/UseDNS no/g' /etc/ssh/sshd_config"
%GO% "mkdir /etc/pihole ; touch /etc/network/interfaces ; update-rc.d ssh disable"
%GO% "IPC=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') ; IPC=$(ip -o addr show | grep $IPC) ; echo $IPC | sed 's/.*inet //g' | sed 's/\s.*$//'" > logs\IPC.tmp && set /p IPC=<logs\IPC.tmp
%GO% "IPF=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') ; IPF=$(ip -o addr show | grep $IPF) ; echo $IPF | sed 's/.*: //g'    | sed 's/\s.*$//'" > logs\IPF.tmp && set /p IPF=<logs\IPF.tmp
%GO% "echo PIHOLE_DNS_1=127.0.0.1#5335 >  /etc/pihole/setupVars.conf"
%GO% "echo IPV4_ADDRESS=%IPC%          >> /etc/pihole/setupVars.conf"
%GO% "echo PIHOLE_INTERFACE=%IPF%      >> /etc/pihole/setupVars.conf"
%GO% "echo BLOCKING_ENABLED=true       >> /etc/pihole/setupVars.conf"
%GO% "echo QUERY_LOGGING=true          >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_SERVER=true     >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_INTERFACE=true  >> /etc/pihole/setupVars.conf"
%GO% "echo LIGHTTPD_ENABLED=true       >> /etc/pihole/setupVars.conf"
%GO% "echo DNSMASQ_LISTENING=all       >> /etc/pihole/setupVars.conf"
%GO% "echo WEBPASSWORD=                >> /etc/pihole/setupVars.conf"
NetSH AdvFirewall Firewall add rule name="Pi-hole FTL"          dir=in action=allow program="%PRGF%\rootfs\usr\bin\pihole-ftl" enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole Web Admin"    dir=in action=allow program="%PRGF%\rootfs\usr\sbin\lighttpd"  enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole Gravity Sync" dir=in action=allow program="%PRGF%\rootfs\usr\sbin\sshd" enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS (TCP)"    dir=in action=allow protocol=TCP localport=53 enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS (UDP)"    dir=in action=allow protocol=UDP localport=53 enable=yes > NUL
ECHO. & ECHO.Launching Pi-hole installer... & ECHO.
REM -- Install Pi-hole
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; curl -L https://install.Pi-hole.net | PIHOLE_SKIP_OS_CHECK=true bash /dev/stdin --unattended"
REM -- FixUp: Remove DHCP server tab 
%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g'                                     /var/www/html/admin/settings.php"
%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g'                                                                    /var/www/html/admin/settings.php"
REM -- FixUp: Set Web Admin port to installer specification
%GO% "sed -i 's/= 80/= %PORT%/g'                                                                          /etc/lighttpd/lighttpd.conf"
REM -- FixUp: Debug log parsing on WSL1 
%GO% "sed -i 's* -f 3* -f 4*g'                                                                            /opt/pihole/piholeDebug.sh"
%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g'                                                           /opt/pihole/piholeDebug.sh"
%GO% "sed -i 's*#Port 22*Port 5322*g' /etc/ssh/sshd_config ; sed -i 's*#PasswordAuthentication no*PasswordAuthentication no*g' /etc/ssh/sshd_config ; update-rc.d ssh disable ; touch /var/run/syslog.pid ; chmod 600 /var/run/syslog.pid ; touch /etc/pihole/custom.list ; chown pihole:pihole /etc/pihole/custom.list ; chmod 644 /etc/pihole/custom.list ; touch /etc/pihole/local.list ; chown pihole:pihole /etc/pihole/local.list ; chmod 644 /etc/pihole/local.list"
ECHO @WSLCONFIG /T Pi-hole ^& @ECHO [Pi-Hole Launcher]                                                                                   > "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "cp /.ss /bin/ss ; apt clean all"                                                                                            >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service start ; done ; sleep 3"                             >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @EXIT                                                                                                                              >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @WSLCONFIG /T Pi-hole                                                                                                               > "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; PIHOLE_SKIP_OS_CHECK=true pihole reconfigure"                                >> "%PRGF%\Pi-hole Configuration.cmd"   
ECHO @%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g' /var/www/html/admin/settings.php"                           >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g' /var/www/html/admin/settings.php"                                                          >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's/= 80/= %PORT%/g'  /etc/lighttpd/lighttpd.conf"                                                                    >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's* -f 3* -f 4*g' /opt/pihole/piholeDebug.sh"                                                                        >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g' /opt/pihole/piholeDebug.sh"                                                       >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START /WAIT /MIN "Pi-hole Init" "%PRGF%\Pi-hole Launcher.cmd"                                                                     >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START http://%COMPUTERNAME%:%PORT%/admin                                                                                          >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START http://%COMPUTERNAME%:%PORT%/admin                                                                                           > "%PRGF%\Pi-hole Web Admin.cmd"
POWERSHELL.EXE -Command "(Get-Content -path '%PRGF%\Pi-hole Configuration.cmd' -Raw ) -replace 'reconfigure','updatePihole 2>/dev/null'" > "%PRGF%\Pi-hole System Update.cmd"
ECHO @%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; pihole updateGravity ; echo ; read -p 'Press any key to close this window...'"> "%PRGF%\Pi-hole Gravity Update.cmd"   
ECHO @ECHO OFF ^& %PRGF:~0,2% ^& CD "%PRGF%"                                                                                                                              > "%PRGF%\Gravity Sync - Setup.cmd"
ECHO ECHO Gravity Sync Setup: Continuing will remove any existing sync configuration.  Close this window to abort or ^& PAUSE ^& ECHO.                                   >> "%PRGF%\Gravity Sync - Setup.cmd"
ECHO IF EXIST ".\Gravity Sync - Smart Sync.cmd" DEL ".\Gravity Sync - Smart Sync.cmd"  ^&^& DEL ".\Logs\Gravity*.log"                                                    >> "%PRGF%\Gravity Sync - Setup.cmd"
ECHO %GO% "wget -q https://raw.githubusercontent.com/DesktopECHO/Pi-Hole-for-WSL1/master/gs4wsl1 -O /usr/local/bin/gs4wsl1 ; chmod +x /usr/local/bin/gs4wsl1 ; gs4wsl1"  >> "%PRGF%\Gravity Sync - Setup.cmd"
ECHO IF NOT EXIST ".\Logs\Gravity Sync.log"          MKLINK /H ".\Logs\Gravity Sync.log"          .\rootfs\home\gs4wsl1\gravity-sync\logs\gravity-sync.log ^>nul 2^>^&1  >> "%PRGF%\Gravity Sync - Setup.cmd"
ECHO IF NOT EXIST ".\Logs\Gravity Sync Cron Job.log" MKLINK /H ".\Logs\Gravity Sync Cron Job.log" .\rootfs\home\gs4wsl1\gravity-sync\logs\gravity-sync.cron^>nul 2^>^&1  >> "%PRGF%\Gravity Sync - Setup.cmd"
ECHO IF EXIST "%PRGF%\rootfs\home\gs4wsl1\SECONDARY" @ECHO @%GO% "su - gs4wsl1 -c ./gravity-sync/gravity-sync.sh smart ; sleep 5" ^> "Gravity Sync - Smart Sync.cmd"     >> "%PRGF%\Gravity Sync - Setup.cmd"
ECHO ECHO.^&ECHO To close this window, ^& PAUSE                                                                                                                          >> "%PRGF%\Gravity Sync - Setup.cmd"
%GO% "echo ; echo -n 'Pi-hole Web Admin, ' ; pihole -a -p"
START /WAIT /MIN "Pi-hole Launcher" "%PRGF%\Pi-hole Launcher.cmd"  
(ECHO.Input Specifications: & ECHO. && ECHO. Location: %PRGF% && ECHO.Interface: %IPF% && ECHO.  Address: %IPC% && ECHO.     Port: %PORT% && ECHO.     Temp: %TEMP% && ECHO.) >  "%PRGF%\logs\Pi-hole Inputs.log"
DIR "%PRGF%" >> "%PRGF%\logs\Pi-hole Inputs.log"
SET STTR="%PRGF%\Pi-hole Launcher.cmd"
ECHO.&SCHTASKS /CREATE /RU "%USERNAME%" /RL HIGHEST /SC ONSTART /TN "Pi-hole for Windows" /TR '%STTR%' /F
ECHO.&ECHO.   NOTE! The Scheduled Task needs additional configuration steps
ECHO.         for Pi-hole to start automatically at boot time.
ECHO.     
ECHO.       - Open Windows Task Scheduler (taskschd.msc)
ECHO.         Right-click the task "Pi-hole for Windows" and click "Edit"
ECHO.         
ECHO.       - On the General tab, place a checkmark next to both
ECHO.         "Run whether user is logged on or not" and "Hidden"
ECHO.         
ECHO.       - On the Conditions tab, un-check the option
ECHO.         "Start the task only if the computer is on AC power"
ECHO. & CD .. & PAUSE
START http://%COMPUTERNAME%:%PORT%/admin
ECHO.Pi-hole for Windows - Installation complete! & ECHO.
:ENDSCRIPT
