#!/bin/sh

for f in /pia-ovpn/*.ovpn
do
    sed -i -r 's/(auth-user-pass)/\1 \/pia-ovpn\/cred/' "$f"
    sed -i -r 's/(crl.rsa.2048.pem)/\/pia-ovpn\/\1/' "$f"
    sed -i -r 's/(ca.rsa.2048.crt)/\/pia-ovpn\/\1/' "$f"
done

