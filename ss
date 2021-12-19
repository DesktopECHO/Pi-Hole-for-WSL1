#!/bin/bash																
#
# Pi-hole 'ss' Shim for WSL1
#
case "$1" in
--ipv4) netstat.exe -an | grep $7\ | grep 0.0.0.0 | tr '[:upper:]' '[:lower:]' ;;
--ipv6) netstat.exe -an | grep $7\ | grep ]: | tr '[:upper:]' '[:lower:]' ;;
*) echo "$1 INVALID" ;;
esac
