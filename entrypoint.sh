#!/bin/bash

mkdir -p /var/lib/docker-borg/ssh > /dev/null 2>&1

if [ ! -f /var/lib/docker-borg/ssh/ssh_host_rsa_key ]; then
    echo "Creating SSH keys. To persist keys across container updates, mount a volume to /var/lib/docker-borg..."
    ssh-keygen -A
    mv /etc/ssh/ssh*key* /var/lib/docker-borg/ssh/
fi

# Ensure correct permissions for ssh keys
chmod -R og-rwx /var/lib/docker-borg/ssh/

ln -sf /var/lib/docker-borg/ssh/* /etc/ssh > /dev/null 2>&1

if [ -n "${BORG_UID}" ]; then
    usermod -u "${BORG_UID}" borg
fi

if [ -n "${BORG_GID}" ]; then
    groupmod -o -g "${BORG_GID}" borg
    usermod -g "${BORG_GID}" borg
fi

if [ ! -z ${BORG_AUTHORIZED_KEYS+x} ]; then
    echo -e "${BORG_AUTHORIZED_KEYS}" > /home/borg/.ssh/authorized_keys
    echo -e "${BORG_AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
    chown borg:borg /home/borg/.ssh/authorized_keys
    chmod og-rwx /home/borg/.ssh/authorized_keys
fi

chown -R borg:borg /home/borg
chown -R borg:borg /home/borg/.ssh

exec /usr/sbin/sshd -D -e
