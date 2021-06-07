@CHCP 65001 > NUL
@ECHO OFF & NET SESSION >NUL 2>&1 
if %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run this command with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)
POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"
SET PORT=80
START /MIN /WAIT "Check for Open Port" "POWERSHELL" "-COMMAND" "Get-NetTCPConnection -LocalPort 80 > '%TEMP%\PortCheck.tmp'"
FOR /f %%i in ("%TEMP%\PortCheck.tmp") do set SIZE=%%~zi 
IF %SIZE% gtr 0 SET PORT=60080
:INPUTS
CLS
ECHO.-------------------------------- & ECHO. Pi-hole for Windows v.20210607 & ECHO.-------------------------------- & ECHO.
SET PRGP=%PROGRAMFILES%&SET /P "PRGP=Set location for 'Pi-hole' install folder or hit enter for default [%PROGRAMFILES%] -> "
SET PRGF=%PRGP%\Pi-hole
IF EXIST "%PRGF%" (ECHO. & ECHO Pi-hole folder already exists, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
WSL.EXE -d Pi-hole -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (ECHO. & ECHO Existing Pi-hole installation detected, uninstall Pi-hole first. & PAUSE & GOTO INPUTS)
ECHO.
ECHO.Pi-hole will be installed in "%PRGF%" and Web Admin will listen on port %PORT%
PAUSE 
IF NOT EXIST %TEMP%\debian.tar.gz POWERSHELL.EXE -Command "Start-BitsTransfer -source https://salsa.debian.org/debian/WSL/-/raw/master/x64/install.tar.gz?inline=false -destination '%TEMP%\debian.tar.gz'"
%PRGF:~0,1%: & MKDIR "%PRGF%" & CD "%PRGF%" & MKDIR "logs" 
FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v"
ICACLS "%PRGF%" /grant "%WAI%:(CI)(OI)F" > NUL
ECHO @ECHO Ensure you run this as administrator, uninstall Pi-hole?>  "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @PAUSE                                                        >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @COPY /Y "%PRGF%\LxRunOffline.exe" "%TEMP%"                   >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @SCHTASKS /Delete /TN:"Pi-hole for Windows" /F                >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @CLS                                                          >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @ECHO Uninstalling Pi-hole...                                 >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @NetSH AdvFirewall Firewall del rule name="Pi-hole FTL"       >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @NetSH AdvFirewall Firewall del rule name="Pi-hole Web Admin" >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @NetSH AdvFirewall Firewall del rule name="Pi-hole DNS (TCP)" >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @NetSH AdvFirewall Firewall del rule name="Pi-hole DNS (UDP)" >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @%PRGF:~0,1%:                                                 >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @CD "%PRGF%\.."                                               >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @WSLCONFIG /T Pi-hole                                         >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @"%TEMP%\LxRunOffline.exe" ur -n Pi-hole                      >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO @RD /S /Q "%PRGF%"                                            >> "%PRGF%\Pi-hole Uninstall.cmd"
ECHO.
ECHO This will take a few minutes to complete...
ECHO|SET /p="Installing LXrunOffline.exe and Debian "
POWERSHELL.EXE -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; wget https://github.com/DDoSolitary/LxRunOffline/releases/download/v3.5.0/LxRunOffline-v3.5.0-msvc.zip -UseBasicParsing -OutFile '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' ; Expand-Archive -Path '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' -DestinationPath '%PRGF%'"
START /WAIT /MIN "Installing Debian..." "LxRunOffline.exe" "i" "-n" "Pi-hole" "-f" "%TEMP%\debian.tar.gz" "-d" "."
ECHO|SET /p="-> Compacting install " 
SET GO="%PRGF%\LxRunOffline.exe" r -n Pi-hole -c 
%GO% "apt-get -y purge dmsetup libapparmor1 libargon2-1 libdevmapper1.02.1 libestr0 libfastjson4 libidn11 libjson-c3 liblognorm5 rsyslog systemd systemd-sysv vim-common vim-tiny xxd --autoremove --allow-remove-essential" > "%PRGF%\logs\Pi-hole Compact Stage.log"
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh /etc/init.d/udev"
ECHO.-^> Install dependencies
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; apt-get update ; apt-get -y install gpg wget curl ca-certificates libpcre2-8-0 libpsl5 openssl perl-modules-5.28 libgdbm6 libgdbm-compat4 libperl5.28 perl libcurl3-gnutls liberror-perl git lsof unattended-upgrades anacron cron logrotate inetutils-syslogd dns-root-data dnsutils gamin idn2 libgamin0 lighttpd netcat php-cgi php-common php-intl php-sqlite3 php-xml php7.3-cgi php7.3-cli php7.3-common php7.3-intl php7.3-json php7.3-opcache php7.3-readline php7.3-sqlite3 php7.3-xml sqlite3 unzip dhcpcd5 --no-install-recommends" > "%PRGF%\logs\Pi-hole Dependency Stage.log"
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; wget -q https://raw.githubusercontent.com/DesktopECHO/Pi-Hole-for-WSL1/master/cloudflared ; wget -q https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb ; dpkg -i ./cloudflared-stable-linux-amd64.deb ; chmod +x cloudflared ; mv cloudflared /etc/init.d ; update-rc.d cloudflared defaults; apt-get clean" > "%PRGF%\logs\CloudflareD.log"
%GO% "pw=$(gpg --quiet --gen-random --armor 1 512) ; useradd -m -p $pw -s /bin/bash cloudflared" > NUL
%GO% "mkdir /etc/pihole ; touch /etc/network/interfaces"
%GO% "IPC=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') ; IPC=$(ip -o addr show | grep $IPC) ; echo $IPC | sed 's/.*inet //g' | sed 's/\s.*$//'" > logs\IPC.tmp && set /p IPC=<logs\IPC.tmp
%GO% "IPF=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+') ; IPF=$(ip -o addr show | grep $IPF) ; echo $IPF | sed 's/.*: //g'    | sed 's/\s.*$//'" > logs\IPF.tmp && set /p IPF=<logs\IPF.tmp
%GO% "echo PIHOLE_DNS_1=127.0.0.1#5053 >  /etc/pihole/setupVars.conf"
%GO% "echo IPV4_ADDRESS=%IPC%          >> /etc/pihole/setupVars.conf"
%GO% "echo PIHOLE_INTERFACE=%IPF%      >> /etc/pihole/setupVars.conf"
%GO% "echo BLOCKING_ENABLED=true       >> /etc/pihole/setupVars.conf"
%GO% "echo QUERY_LOGGING=true          >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_SERVER=true     >> /etc/pihole/setupVars.conf"
%GO% "echo INSTALL_WEB_INTERFACE=true  >> /etc/pihole/setupVars.conf"
%GO% "echo LIGHTTPD_ENABLED=true       >> /etc/pihole/setupVars.conf"
%GO% "echo DNSMASQ_LISTENING=all       >> /etc/pihole/setupVars.conf"
%GO% "echo WEBPASSWORD=                >> /etc/pihole/setupVars.conf"
%GO% "echo interface %IPF%             >  /etc/dhcpcd.conf"
%GO% "echo static ip_address=%IPC%     >> /etc/dhcpcd.conf"
NetSH AdvFirewall Firewall add rule name="Pi-hole FTL"        dir=in action=allow program="%PRGF%\rootfs\usr\bin\pihole-ftl" enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole Web Admin"  dir=in action=allow program="%PRGF%\rootfs\usr\sbin\lighttpd"  enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS (TCP)"  dir=in action=allow protocol=TCP localport=53 enable=yes > NUL
NetSH AdvFirewall Firewall add rule name="Pi-hole DNS (UDP)"  dir=in action=allow protocol=UDP localport=53 enable=yes > NUL
ECHO. & ECHO.Launching Pi-hole installer... & ECHO.
REM -- Install Pi-hole
%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; curl -L https://install.Pi-hole.net | bash /dev/stdin --unattended"
REM FixUp: DNS service indicator on web page and remove DHCP server tab 
%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g'         /var/www/html/admin/settings.php"
%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g'                                        /var/www/html/admin/settings.php"
%GO% "sed -i 's#if ($pistatus === \"1\")#if ($pistatus === \"-1\")#g'         /var/www/html/admin/scripts/pi-hole/php/header.php"
%GO% "sed -i 's#elseif ($pistatus === \"-1\")#elseif ($pistatus === \"1\")#g' /var/www/html/admin/scripts/pi-hole/php/header.php"
REM FixUp: Set Web Admin port to installer specification
%GO% "sed -i 's/= 80/= %PORT%/g'                                              /etc/lighttpd/lighttpd.conf"
REM FixUp: Debug log parsing on WSL1 
%GO% "sed -i 's* -f 3* -f 4*g'                                                /opt/pihole/piholeDebug.sh"
%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g'                               /opt/pihole/piholeDebug.sh"
REM FixUp: Configure lsof alternative for WSL1
%GO% "sed -i 's#lsof -Pni:53#netstat.exe -ano | grep \":53 \"#g'              /usr/local/bin/pihole"
%GO% "sed -i 's#if grep -q \"pihole\"#if grep -q \"LISTENING\"#g'             /usr/local/bin/pihole"  
%GO% "sed -i 's#IPv4.*UDP#UDP    0.0.0.0:53#g'                                /usr/local/bin/pihole"
%GO% "sed -i 's#IPv4.*TCP#TCP    0.0.0.0:53#g'                                /usr/local/bin/pihole" 
%GO% "sed -i 's#IPv6.*UDP#UDP    \\[::\\]:53#g'                               /usr/local/bin/pihole" 
%GO% "sed -i 's#IPv6.*TCP#TCP    \\[::\\]:53#g'                               /usr/local/bin/pihole"
REM FixUp: Remove unneeded service check (ugly hack, pull requests welcome :-)  
%GO% "sed -i 's#${CROSS} DNS service is NOT listening#Process Complete#g'     /usr/local/bin/pihole"
REM FixUp: Get pihole status 
%GO% "pihole status"          
%GO% "touch /var/run/syslog.pid ; chmod 600 /var/run/syslog.pid ; touch /etc/pihole/custom.list ; chown pihole:pihole /etc/pihole/custom.list ; chmod 644 /etc/pihole/custom.list ; touch /etc/pihole/local.list ; chown pihole:pihole /etc/pihole/local.list ; chmod 644 /etc/pihole/local.list ; pihole restartdns"
%GO% "echo ; echo -------------------------------------------------------------------------------- ; echo -n 'Pi-hole Web Admin, ' ; pihole -a -p"
ECHO @WSLCONFIG /T Pi-hole                                                                                                               > "%PRGF%\Pi-hole Launcher.cmd"
ECHO @ECHO [Pi-Hole Launcher]                                                                                                           >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "apt-get -qq remove dhcpcd5 > /dev/null 2>&1 ; apt-get clean"                                                                >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @%GO% "for rc_service in /etc/rc2.d/S*; do [[ -e $rc_service ]] && $rc_service start ; done ; sleep 3"                             >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @EXIT                                                                                                                              >> "%PRGF%\Pi-hole Launcher.cmd"
ECHO @WSLCONFIG /T Pi-hole                                                                                                               > "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; pihole -r"                                                                   >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#lsof -Pni:53#netstat.exe -ano | grep \":53 \"#g'          /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#if grep -q \"pihole\"#if grep -q \"LISTENING\"#g'         /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#IPv4.*UDP#UDP    0.0.0.0:53#g'                            /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#IPv4.*TCP#TCP    0.0.0.0:53#g'                            /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#IPv6.*UDP#UDP    \\[::\\]:53#g'                           /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#IPv6.*TCP#TCP    \\[::\\]:53#g'                           /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#${CROSS} DNS service is NOT listening#Process Complete#g' /usr/local/bin/pihole"                                  >> "%PRGF%\Pi-hole Configuration.cmd" 
ECHO @%GO% "sed -i 's*<a href=\"#piholedhcp\"*<!--a href=\"#piholedhcp\"*g' /var/www/html/admin/settings.php"                           >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's*DHCP</a>*DHCP</a-->*g' /var/www/html/admin/settings.php"                                                          >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's/= 80/= %PORT%/g'  /etc/lighttpd/lighttpd.conf"                                                                    >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's* -f 3* -f 4*g' /opt/pihole/piholeDebug.sh"                                                                        >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's*-I \"${PIHOLE_INTERFACE}\"* *g' /opt/pihole/piholeDebug.sh"                                                       >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#if ($pistatus === \"1\")#if ($pistatus === \"-1\")#g'         /var/www/html/admin/scripts/pi-hole/php/header.php" >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "sed -i 's#elseif ($pistatus === \"-1\")#elseif ($pistatus === \"1\")#g' /var/www/html/admin/scripts/pi-hole/php/header.php" >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @%GO% "pihole status"                                                                                                              >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START /WAIT /MIN "Pi-hole Init" "%PRGF%\Pi-hole Launcher.cmd"                                                                     >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO @START http://%COMPUTERNAME%:%PORT%/admin                                                                                          >> "%PRGF%\Pi-hole Configuration.cmd"
ECHO --------------------------------------------------------------------------------
SET STTR="%PRGF%\Pi-hole Launcher.cmd"
SCHTASKS /CREATE /RU "%USERNAME%" /RL HIGHEST /SC ONSTART /TN "Pi-hole for Windows" /TR '%STTR%' /F
START /WAIT /MIN "Pi-hole Launcher" "%PRGF%\Pi-hole Launcher.cmd"  
ECHO. & ECHO Pi-hole for Windows installed in %PRGF%
(ECHO.Input Specifications: & ECHO. && ECHO. Location: %PRGF% && ECHO.Interface: %IPF% && ECHO.  Address: %IPC% && ECHO.     Port: %PORT% && ECHO.     Temp: %TEMP% && ECHO.) >  "%PRGF%\logs\Pi-hole Inputs.log"
DIR "%PRGF%" >> "%PRGF%\logs\Pi-hole Inputs.log"
CD .. & PAUSE
START http://%COMPUTERNAME%:%PORT%/admin
ECHO.
:ENDSCRIPT
