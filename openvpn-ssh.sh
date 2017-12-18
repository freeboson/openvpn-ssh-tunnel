#!/bin/sh

if [ ! -z "$1" ]; then
    cfg="$1"
else
    cfg="AU Melbourne.ovpn"
fi

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

/usr/sbin/sshd -e -f /sshd_config
/usr/sbin/openvpn "/pia-ovpn/${cfg}"

