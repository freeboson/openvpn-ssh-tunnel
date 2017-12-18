FROM alpine:latest

LABEL maintainer="Sujeet Akula <sujeet@freeboson.org>"

COPY pia-config.sh /pia-config.sh
RUN apk add --update openvpn openssh openssh-keygen && \
    adduser tunnel -D && \
    passwd -u tunnel && \
    mkdir -p /etc/authorized_keys && \
    ssh-keygen -t ed25519 -f /ssh_host_ed25519_key -N "" < /dev/null && \
    chmod 400 /ssh_host_ed25519_key && \
    wget https://www.privateinternetaccess.com/openvpn/openvpn.zip && \
    mkdir /pia-ovpn && \
    unzip /openvpn.zip -d /pia-ovpn && \
    /pia-config.sh && \
    rm -f /pia-config.sh /openvpn.zip && \
    rm -rf /var/cache/apk/*

COPY sshd_config /sshd_config
COPY authorized_keys /etc/authorized_keys/tunnel
COPY pia-cred /pia-ovpn/cred

COPY openvpn-ssh.sh /openvpn-ssh.sh

EXPOSE 22

ENTRYPOINT ["/openvpn-ssh.sh"]

