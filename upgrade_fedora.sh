#!/bin/bash

# Script to upgrade the fedora installation
# file below has version and URL information about
# the current release. Any variables not defined here
# come from there.
. /etc/os-release
echo "Running: $PRETTY_NAME"

# need to check if there is a next version availale?
# based on: https://discussion.fedoraproject.org/t/is-it-possible-to-verify-that-a-major-release-is-already-released/78713
LATEST_VER="$(curl -s "$HOME_URL/releases.json" | jq -r '[.[].version | select(test("^\\d*$"))] | max')"
AVAIL="$(curl -s "$HOME_URL/releases.json" | jq -r [.[].version] | uniq)"

echo "Available Versions: $AVAIL"
echo "Current is: $VERSION_ID, latest is $LATEST_VER."
if [ "$LATEST_VER" -eq "$VERSION_ID" ]; then
    echo "Already at latest version, no need to upgrade."
    echo "Exiting..."
    exit 0
else
    echo "Version $LATEST_VER of Fedora is available!"
    read -rsn1 -p "Upgrade y/n?" key
    if [ "$key" == "y" ]; then
        echo "running 'dnf upgrade --refresh' for Fedora $VERSION_ID"
        dnf upgrade --refresh

        #dnf install dnf-plugin-system-upgrade
        echo "Upgrading $VERSION_ID to $LATEST_VER"
        echo "downloading all the packages..."
        # dnf system-upgrade clean
        dnf system-upgrade download --releasever=$LATEST_VER --allowerasing

        # Rebuild the boot config
        echo  "Rebuilding the grub configuration..."
        /etc/cron.daily/rebuild_grub_config.pl

        echo "To remove cached metadata and transaction use 'dnf system-upgrade clean'"
        echo "The downloaded packages were saved in cache until the next successful transaction."
        echo "You can remove cached packages by executing 'dnf clean packages'."
        echo "Now do: # dnf system-upgrade reboot"
        #dnf system-upgrade reboot
    fi
fi
