#!/bin/bash

#
# Automate mysql secure installation for ubuntu
# Usage:
#  Setup mysql root password:  ./mysql_secure.sh 'your_new_root_password'
#  Change mysql root password: ./mysql_secure.sh 'your_old_root_password' 'your_new_root_password'"
#

# Delete package expect when script is done
# 0 - No;
# 1 - Yes.
PURGE_EXPECT_WHEN_DONE=1

#
# Check the bash shell script is being run by root
#
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Check input params
#
if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
    CURRENT_MYSQL_PASSWORD='_'
    NEW_MYSQL_PASSWORD="${1}"
elif [ -n "${1}" -a -n "${2}" ]; then
    # Change existens root password
    CURRENT_MYSQL_PASSWORD="${1}"
    NEW_MYSQL_PASSWORD="${2}"
else
    echo "Usage:"
    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
    echo "  Change mysql root password: ${0} 'your_old_root_password' 'your_new_root_password'"
    exit 1
fi

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    sudo apt-get -y install expect

fi
$NEW_CUSTOM_MYSQL_PASSWORD ='_'
SECURE_MYSQL=$(expect -c "

set timeout 3
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$NEW_CUSTOM_MYSQL_PASSWORD\r\"

expect \"root password?\"
send \"y\r\"

expect \"New password:\"
send \"$NEW_CUSTOM_MYSQL_PASSWORD\r\"

expect \"Re-enter new password:\"
send \"$NEW_CUSTOM_MYSQL_PASSWORD\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"n\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
    # Uninstalling expect package
    sudo apt-get -y purge expect
fi

exit 0
