#!/bin/bash

# Script to upgrade the fedora installation
declare -i THISVER=`cat /etc/redhat-release | cut -d" " -f3`
declare -i NEXTVER=0
NEXTVER=$THISVER+1

echo "running 'dnf upgrade --refresh' for Fedora $THISVER"
dnf upgrade --refresh

# need to check if there is a next version availale?
#
#
#dnf install dnf-plugin-system-upgrade
echo "Upgrading $THISVER to $NEXTVER"
echo "downloading all the packages..."
#dnf system-upgrade clean
dnf system-upgrade download --releasever=$NEXTVER --allowerasing

# Rebuild the boot config
echo  "Rebuilding the grub configuration..."
/etc/cron.daily/rebuild_grub_config.pl

echo "Now do: # dnf system-upgrade reboot"
# To remove cached metadata and transaction use 'dnf system-upgrade clean'
# The downloaded packages were saved in cache until the next successful transaction.
# You can remove cached packages by executing 'dnf clean packages'.
#dnf system-upgrade reboot
