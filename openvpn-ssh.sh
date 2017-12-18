#!/bin/sh

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

/usr/sbin/sshd -e -f /sshd_config
/usr/sbin/openvpn "/pia-ovpn/AU Melbourne.ovpn"
