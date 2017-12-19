OpenVPN SSH Tunnel
==================

Setup an OpenVPN connection to [PIA](https://privateinternetaccess.com) within a
docker container, with an SSH daemon (OpenSSH) running. You can then create an
SSH tunnel into your container that will route your traffic via the VPN. This is
useful for having *some* but not *all* of your traffic to go through VPN.

In short, think of it as a way to convert a VPN service into an encrypted SOCKS5
proxy.

Most VPN services provide SOCKS proxies directly because it is convenient to
users, but they have major shortcomings:
1. Traffic between you and your SOCKS provider will be unencrypted, except for
   protocol/application specific stuff.
    - E.g., if you route BitTorrent traffic through SOCKS, the swarm will see
      your provider's IP and not yours, but anyone with access to your side of
      the network (like your ISP) can see that you are using BitTorrent. Even if
      you use encrypted BT (which is weak), you are leaking information to your
      ISP.
2. Quite a bit less important is that clients that do support SOCKS might still
   not support authenticated SOCKS, which is what most paid services will offer.

The setup here will be like this:
```
┏━━━━━━━━━━━┓  (chacha20)  ┏━━━━━━━━━━━━━┓  (AES-128 CBC)  ┏━━━━━━━━━━━┓
┃           ┃──────────────┃    Docker   ┃─────────────────┃           ┃
┃    You    ┃      SSH     ┠─────┐ ┌─────┨     OpenVPN     ┃    PIA    ┃
┃           ┃──────────────┃ SSH │ │ VPN ┃─────────────────┃           ┃
┗━━━━━━━━━━━┛              ┗━━━━━┷━┷━━━━━┛                 ┗━━━━━━━━━━━┛
```
The docker container might be running on your own computer so the SSH pipeline
might be via loopback, or you could expose the SSH server to a larger network.
The cipher settings for SSH and OpenVPN depend on the specific configs.

Instructions
------------

1. Clone into some directory
2. Create `authorized_keys` (for SSH) and `pia-cred` (2 lines: pia username, pia
   password) in that directory
3. `docker build`
4. `docker run --cap-add NET_ADMIN -p 22222:22 -it ...`
5. Tunnel in: `ssh -N -D 9000 tunnel@localhost -p 22222` (or use autossh)
6. Now you can set whatever client that supports SOCKS e.g. Firefox,
   qBittorrent, etc. to connect via SOCKS5 at `localhost:9000`
    - You can also try `tsocks` or similar for clients that do not support it

Notes
-----

Lots of room for improvement here:
1. Upgrade crypto on the OpenVPN configs (you'll want to edit `pia-config.sh`)
   if desired
2. If you setup your docker network devices and addresses correctly, you could
   degrade the SSH encryption relying on loopback only traffic
3. (Easy) get `openvpn-ssh.sh` to look at args for picking a PIA region, etc.
4. Are there signatures or sums for the PIA configs somewhere?
5. Make it easy to swap out OpenVPN configs without rebuilding the image, e.g.
   `scp` a config from a different provider and pick that from CLI args
    - Maybe volumes are useful here, idk
6. (Flip side of #2), if you don't want it local-only, use a restricted shell so
   that you can only tunnel, and not issue commands
    - I really am not familiar with how docker security works

