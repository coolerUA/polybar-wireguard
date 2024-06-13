#!/usr/bin/env bash

configs_path="/etc/wireguard/"


get_ifaces() {
    interfaces=$(for i in `sudo ls $configs_path| grep conf | awk -F. '{print $1}'`; do echo $i;done)
}


active_ifaces() {
    get_ifaces

    aifaces=""
    iaifaces=""
    for interface in $interfaces; do
        state=$(nmcli c show $interface 2>/dev/null| grep "GENERAL.STATE:" | awk '{print $2}');
        if [[ "activated" == $state ]]; then
            aifaces+="$interface "
        else
            iaifaces+="$interface "
        fi
    done
}


iftoggle() {
    active_ifaces

    if [[ $aifaces == *"$1"* ]]; then
        sudo wg-quick down "$configs_path"/"$1".conf >/dev/null 2>&1
    elif [[ $iaifaces == *"$1"* ]]; then
        sudo wg-quick up "$configs_path"/"$1".conf >/dev/null 2>&1
    fi
}


toggle() {
    get_ifaces
    select=$(echo $interfaces |sed -e 's/ /\n/g'| rofi -dmenu -p 'select interface')
    iftoggle $select
}


print() {
    active_ifaces

    for interface in $interfaces; do
        if [[ $aifaces == *"$interface"* ]]; then
            echo -n %{F#0f0}%{F-} 
        elif [[ $iaifaces == *"$interface"* ]]; then
            echo -n %{F#f00}%{F-} 
        fi
        echo -n " $interface " 
        
    done
}


case "$1" in
    --connect)
        connect
        ;;
    --disconnect)
        disconnect
        ;;
    --toggle)
        toggle
        ;;
    *)
        print
        ;;
esac
