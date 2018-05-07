#!/bin/bash
#
#  Copyright 2018 Emanuele Forestieri <forestieriemanuele@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#

#text colors
export BLUE='\033[1;94m'
export GREEN='\033[1;92m'
export RED='\e[0;31m'
export NORMAL='\033[1;00m'

export DIRECTORY='$PWD'

err_echo () #echo on stderr
{
        >&2 echo -e "$*"
}

err ()
{
        err_echo $RED"[!] "$*$NORMAL
}

inf ()
{
        err_echo $BLUE"[*] "$*$NORMAL
}

ok ()
{
        err_echo $GREEN"[+] "$*$NORMAL
}

if [ `id -u` -eq 0 ]; then #if it is run as root
        inf "Checking directory..."
        if [ -d "$DIRECTORY" ]; then
                ok "Directory checked"

                inf "Stopping service..."
                ./magnet/magnetd stop > /dev/null 2>&1

                # Waiting until the service has stopped
                sleep 3
                PROCESSID=$(pidof magnetd)
                if [ $PROCESSID -gt 0 ]; then
                        err "Failed to stop service"
                        exit 1
                else
                        ok "Service stopped successfully"

                        inf "Cleaning files..."
                        rm -rf magnet/*
                        ok "Files cleaned"

                        inf "Creating temp folder..."
                        mkdir temp
                        cd temp
                        ok "Temp folder created"

                        inf "Downloading magnet wallet..."
                        wget https://magnetwork.io/Wallets/magnet-qt-LINUX.tar.gz > /dev/null 2>&1
                        ok "Magnet wallet downloaded"

                        inf "Extracting files..."
                        tar -xvzf magnet-qt-LINUX.tar.gz > /dev/null 2>&1
                        ok "Files extracted"

                        inf "Copying files..."
                        
                        # Ubuntu 16.04
                        if [ `lsb_release -rs` == "16.04" ]; then 
                                cp ubuntu_16_04/magnetd ../magnet/magnetd
                        # Ubuntu 17.04
                        elif [ `lsb_release -rs` == "17.04" ]; then
                                cp ubuntu_17_04/magnetd ../magnet/magnetd
                        # Ubuntu 17.10
                        elif [ `lsb_release -rs` == "17.10" ]; then
                                cp ubuntu_17_10/magnetd ../magnet/magnetd
                        # Other OS
                        else 
                                cp magnetd ../magnet/magnetd
                        fi

                        cp magnet-qt ../magnet/magnet-qt
                        ok "Files copied"

                        inf "Removing temp folder..."
                        cd ../magnet
                        rm -rf ../temp
                        ok "Temp folder removed"

                        inf "Starting magnet service..."
                        chmod +x magnetd
                        ./magnetd & > /dev/null 2>&1
                        
                        # Waiting until the service has started
                        sleep 3
                        PROCESSID=$(pidof magnetd)
                        if [ $PROCESSID -gt 0 ]; then 
                                ok "Magnet service started"
                        else
                                err "Failed to start magnet service"
                                exit 1
                        fi
                fi
        else 
                err
else
        err "R U Drunk Man?! This script must be run as root!"
        exit 1
fi
exit 0
