@CHCP 65001 > NUL
@ECHO OFF & NET SESSION >NUL 2>&1 
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run the Pi-hole installer with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)
POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"
SET PORT=60080
:INPUTS
CLS
ECHO.-------------------------------- & ECHO. Pi-hole for Windows v.20240228 & ECHO.-------------------------------- & ECHO.
SET PRGP=%PROGRAMFILES%&SET /P "PRGP=Set Pi-hole install location, or hit enter for default [%PROGRAMFILES%] -> "
IF %PRGP:~-1%==\ SET PRGP=%PRGP:~0,-1%
SET PRGF=%PRGP%\Pi-hole
IF EXIST "%PRGF%" (ECHO. & ECHO Pi-hole folder already exists, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
WSL.EXE -d Pi-hole -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (ECHO. & ECHO Existing Pi-hole installation detected, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
ECHO.
SET IMG=Debian.tar.gz
IF EXIST "%TEMP%\%IMG%" DEL "%TEMP%\%IMG%"
ECHO Downloading minimal Debian image . . .
:DLIMG
POWERSHELL.EXE -Command "Start-BitsTransfer -Source https://salsa.debian.org/debian/WSL/-/raw/7723a557b040b85ab1c38d6dd84b2fcb2474d715/x64/install.tar.gz?inline=false -Destination '%TEMP%\%IMG%'" >NUL 2>&1
IF NOT EXIST "%TEMP%\%IMG%" GOTO DLIMG
%PRGF:~0,2% & MKDIR "%PRGF%" & CD "%PRGF%" & MKDIR "logs" 
IF EXIST PH4WSL1.zip DEL PH4WSL1.zip
ECHO Downloading prerequisite packages . . .
:DLPRQ
POWERSHELL.EXE -Command "$ProgressPreference = 'SilentlyContinue' ; Invoke-WebRequest -Uri 'https://github.com/DesktopECHO/Pi-Hole-for-WSL1/archive/refs/heads/v6.zip' -OutFile 'PH4WSL1.zip'" > NUL 2>&1
IF NOT EXIST PH4WSL1.zip GOTO DLPRQ
POWERSHELL.EXE -Command "Expand-Archive -Force 'PH4WSL1.zip' ; Remove-Item 'PH4WSL1.zip'
POWERSHELL.EXE -Command "Expand-Archive -Force -Path '.\PH4WSL1\Pi-Hole-for-WSL1-6\LxRunOffline-v3.5.0-33-gbdc6d7d-msvc.zip' -DestinationPath '%TEMP%' ; Copy-Item '%TEMP%\LxRunOffline-v3.5.0-33-gbdc6d7d-msvc\LxRunOffline.exe' '%PRGF%'"
FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v"
ICACLS "%PRGF%" /grant "%WAI%:(CI)(OI)F" > NUL
ECHO @ECHO OFF ^& CLS ^& NET SESSION ^>NUL 2^>^&1                                  > "%PRGF%\Pi-hole Uninstall.cmd"
ECHO IF ^%%ERRORLEVEL^%% == 0 ^(ECHO Pi-hole Uninstaller: Close window to abort or>> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO )ELSE ^(ECHO Please run uninstaller with admin rights! ^&^& pause ^&^& EXIT) >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO PAUSE ^& ECHO. ^& ECHO Uninstalling Pi-hole . . .                            >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO COPY /Y "%PRGF%\LxRunOffline.exe" "%TEMP%" ^> NUL 2^>^&1                     >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO SCHTASKS /Delete /TN:"Pi-hole for Windows" /F ^> NUL 2^>^&1                  >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole DNS Server"                >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole Web Admin"                 >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO NetSH AdvFirewall Firewall del rule name="Pi-hole SSH"                       >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO %PRGF:~0,2% ^& CD "%PRGF%" ^& WSLCONFIG /T Pi-hole ^> NUL 2^>^&1             >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO "%TEMP%\LxRunOffline.exe" ur -n Pi-hole ^> NUL 2^>^&1 ^& CD ..               >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO ECHO. ^& ECHO Uninstall Complete!                                            >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO START /MIN "Uninstall" "CMD.EXE" /C RD /S /Q "%PRGF%"                        >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO|SET /p="Installing Debian "
START /WAIT /MIN "Installing Debian, one moment please..." "LxRunOffline.exe" "i" "-n" "Pi-hole" "-f" "%TEMP%\%IMG%" "-d" "."
ECHO|SET /p="-> Compacting install . . ." 
SET GO="%PRGF%\LxRunOffline.exe" r -n Pi-hole -c 
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS Server" dir=in action=allow program="%PRGF%\rootfs\usr\bin\pihole-ftl" enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole Web Admin"  dir=in action=allow program="%PRGF%\rootfs\usr\sbin\lighttpd"  enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole SSH"        dir=in action=allow program="%PRGF%\rootfs\usr\sbin\sshd"      enable=yes > NUL
%GO% "apt-get -y purge dmsetup libapparmor1 libargon2-1 libdevmapper1.02.1 libestr0 libfastjson4 liblognorm5 rsyslog systemd systemd-sysv vim-common vim-tiny xxd --autoremove --allow-remove-essential" > NUL
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh /etc/init.d/udev ; echo 'echo N 2' > /usr/sbin/runlevel ; chmod +x /usr/sbin/runlevel ; dpkg-divert --local --rename --add /sbin/initctl ; ln -fs /bin/true /sbin/initctl ; echo 'exit 0' > /usr/sbin/policy-rc.d ; chmod +x /usr/sbin/policy-rc.d" > NUL
ECHO.&ECHO Please wait a few minutes for package installer . . .
%GO% "dpkg -i --force-all ./PH4WSL1/Pi-Hole-for-WSL1-6/deb/*.deb 2> /dev/null" > "%PRGF%\logs\Pi-hole package install.log" & ECHO.
%GO% "cp ./PH4WSL1/Pi-Hole-for-WSL1-6/ss /.ss ; chmod +x /.ss ; cp /.ss /bin/ss ; cp ./PH4WSL1/Pi-Hole-for-WSL1-6/pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf"
%GO% "mkdir /etc/pihole ; touch /etc/network/interfaces ; echo '13.107.4.52 www.msftconnecttest.com' > /etc/pihole/custom.list ; echo '131.107.255.255 dns.msftncsi.com' >> /etc/pihole/custom.list"
%GO% "IPC=$(ip route get 9.9.9.9 | grep -oP 'src \K\S+') ; IPC=$(ip -o addr show | grep $IPC) ; echo $IPC | sed 's/.*inet //g' | sed 's/\s.*$//'" > logs\IP.txt && set /p IPC=<logs\IP.txt
%GO% "IPF=$(ip route get 9.9.9.9 | grep -oP 'src \K\S+') ; IPF=$(ip -o addr show | grep $IPF) ; echo $IPF | sed 's/.*: //g'    | sed 's/\s.*$//'" > logs\Interface.txt && set /p IPF=<logs\Interface.txt
ECHO Update setupVars.conf to use IP address %IPC% on interface %IPF% . . .
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
ECHO. & ECHO.Launching Pi-hole v5 install... 
REM -- Install Pi-hole -- Prevent the Pi-hole installer from running APT on this one occasion.  Unattended-upgrades package will keep Debian updated moving forward 
START /MIN /WAIT "Pi-hole v5 install..." %GO% "mv /usr/bin/apt /usr/bin/apt.ph ; echo 'nameserver 9.9.9.9' > /etc/resolv.conf ; curl -L https://install.Pi-hole.net | bash /dev/stdin --unattended ; mv /usr/bin/apt.ph /usr/bin/apt; update-rc.d pihole-FTL remove ; update-rc.d pihole-FTL defaults"
REM -- FixUp: Remove DHCP server tab 
%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g'                                     /var/www/html/admin/settings.php"
%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g'                                                                    /var/www/html/admin/settings.php"
REM -- FixUp: Set Web Admin port to installer specification
%GO% "echo server.port := %PORT% > /etc/lighttpd/conf-enabled/07-port.conf"
REM -- FixUp: Debug log parsing on WSL1 
%GO% "sed -i 's* -f 3* -f 4*g'                                                                            /opt/pihole/piholeDebug.sh"
%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g'                                                           /opt/pihole/piholeDebug.sh"
%GO% "hn=`hostname` ; echo cname=$hn.gravitysync,$hn > /etc/dnsmasq.d/05-pihole-custom-cname.conf"
%GO% "sed -i 's/#UseDNS no/UseDNS no/g' /etc/ssh/sshd_config ; sed -i 's*#Port 22*Port 5322*g' /etc/ssh/sshd_config ; sed -i 's*#PasswordAuthentication yes*PasswordAuthentication no*g' /etc/ssh/sshd_config ; touch /var/run/syslog.pid ; chmod 600 /var/run/syslog.pid ; touch /etc/pihole/custom.list ; touch /etc/pihole/local.list ; chown pihole:pihole /etc/pihole/*.list ; chmod 644 /etc/pihole/*.list"
ECHO @WSLCONFIG /T Pi-hole ^& @ECHO [Pi-Hole Launcher]                                                                                   > "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "cp /.ss /bin/ss ; apt clean all"                                                                                            >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "sed -i 's|gravityTEMPfile=\"${GRAVITYDB}_temp\"|gravityTEMPfile=\"/dev/shm/gravity.db_temp\"|' /opt/pihole/gravity.sh"      >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service start ; done ; sleep 3"                             >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @EXIT                                                                                                                              >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @WSLCONFIG /T Pi-hole                                                                                                               > "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "echo 'nameserver 9.9.9.9' > /etc/resolv.conf ; pihole reconfigure"                                                          >> "%PRGF%\Pi-hole Configuration.cmd"   
ECHO @%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g' /var/www/html/admin/settings.php"                           >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g' /var/www/html/admin/settings.php"                                                          >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's* -f 3* -f 4*g' /opt/pihole/piholeDebug.sh"                                                                        >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g' /opt/pihole/piholeDebug.sh"                                                       >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START /WAIT /MIN "Pi-hole Init" "%PRGF%\Pi-hole Launcher.cmd"                                                                     >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START http://%COMPUTERNAME%:%PORT%/admin                                                                                          >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START http://%COMPUTERNAME%:%PORT%/admin                                                                                           > "%PRGF%\Pi-hole Web Admin.cmd"
POWERSHELL.EXE -Command "(Get-Content -path '%PRGF%\Pi-hole Configuration.cmd' -Raw ) -replace 'reconfigure','updatePihole 2>/dev/null'" > "%PRGF%\Pi-hole System Update.cmd"
ECHO @%GO% "sed -i 's|gravityTEMPfile=\"${GRAVITYDB}_temp\"|gravityTEMPfile=\"/dev/shm/gravity.db_temp\"|' /opt/pihole/gravity.sh"       > "%PRGF%\Pi-hole Gravity Update.cmd"  
ECHO @%GO% "echo 'nameserver 9.9.9.9' > /etc/resolv.conf ; pihole updateGravity ; echo ; read -p 'Hit [Enter] to close this window...'" >> "%PRGF%\Pi-hole Gravity Update.cmd" 
START /WAIT /MIN "Pi-hole Launcher" "%PRGF%\Pi-hole Launcher.cmd"  
(ECHO.Input Specifications: & ECHO. && ECHO. Location: %PRGF% && ECHO.Interface: %IPF% && ECHO.  Address: %IPC% && ECHO.     Port: %PORT% && ECHO.     Temp: %TEMP% && ECHO.) >  "%PRGF%\logs\Pi-hole install settings.log"
DIR "%PRGF%" >> "%PRGF%\logs\Pi-hole install settings.log"
ECHO.&ECHO Preparing Pi-hole v6 upgrade...
START /MIN /WAIT "Preparing Pi-hole v6 upgrade..." %GO% "apt-get -yqq purge lighttpd *php* --autoremove"
START /MIN "Gravity Tempfile Monitor" %GO% "while [ ! -f /tmp/done ] ; do sed -i '/gravityTEMPfile=/c\gravityTEMPfile=\/dev\/shm/gravity.db_temp' /opt/pihole/gravity.sh ; sleep .2 ; done"
%GO% "echo "development-v6" | sudo tee /etc/pihole/ftlbranch ; echo ; yes | pihole checkout core development-v6"
%GO% "sed -i 's/  useWAL = true/  useWAL = false/g' /etc/pihole/pihole.toml ; sed -i 's/  port = \"8.*/  port = \"60080,[::]:60080,60443s,[::]:60443s\"/g'  /etc/pihole/pihole.toml"
%GO% "sed -i '/\[ntp.ipv4\]/,/^\[/ s/active = true/active = false/' /etc/pihole/pihole.toml ; sed -i '/\[ntp.ipv6\]/,/^\[/ s/active = true/active = false/' /etc/pihole/pihole.toml ; sed -i '/\[ntp.rtc\]/,/^\[/ s/set = true/set = false/' /etc/pihole/pihole.toml ; sed -i '/\[ntp.rtc\]/,/^\[/ s/utc = true/utc = false/' /etc/pihole/pihole.toml ; sed -i '/\[ntp.sync.rtc\]/,/^\[/ s/set = true/set = false/' /etc/pihole/pihole.toml"
%GO% "yes | pihole checkout web development-v6 ; touch /tmp/done ; echo ; pihole version ; echo ; pihole status"
RD /S /Q "%PRGF%\PH4WSL1" & %GO% "echo ; echo -n 'Pi-hole Web Admin, ' ; pihole setpassword"
SET STTR="%PRGF%\Pi-hole Launcher.cmd"
ECHO.&SCHTASKS /CREATE /RU "%WAI%" /RL HIGHEST /SC ONSTART /TN "Pi-hole for Windows" /TR '%STTR%' /F
ECHO.&ECHO.  *NOTE* Additional configuration steps are required if you want
ECHO.         Pi-hole to run automatically at Windows start-up.
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
%GO% "echo Install complete!  Devices on your network reach this Pi-hole via IP $(ip route get 9.9.9.9 | grep -oP 'src \K\S+') ; echo ' '"
:ENDSCRIPT
