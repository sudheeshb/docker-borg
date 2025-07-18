FROM tgbyte/ubuntu:24.04

ARG BORG_VERSION=1.4

RUN set -x \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
        build-essential \
        libacl1 \
        libacl1-dev \
        liblz4-1 \
        liblz4-dev \
        libssl3t64 \
        libssl-dev \
        libxxhash0 \
        libxxhash-dev \
        libzstd1 \
        libzstd-dev \
        openssh-server \
        python3 \
        python3-pip \
        python3-pkgconfig \
        python3-setuptools \
        python3-setuptools-scm \
    && rm -f /etc/ssh/ssh_host_* \
    && python3 --version \
    && pip3 install --break-system-packages -v "borgbackup==${BORG_VERSION}" \
    && apt-get remove -y --purge \
        build-essential \
        libacl1-dev \
        liblz4-dev \
        libssl-dev \
        libxxhash-dev \
        libzstd-dev \
    && apt-get autoremove -y --purge \
    && adduser --uid 500 --disabled-password --gecos "Borg Backup" --quiet borg \
    && mkdir -p /var/run/sshd /var/backups/borg /var/lib/docker-borg/ssh mkdir /home/borg/.ssh \
    && chown borg.borg /var/backups/borg /home/borg/.ssh \
    && chmod 700 /home/borg/.ssh \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^X11Forwarding yes$/X11Forwarding no/g' \
        -e 's/^#LogLevel .*$/LogLevel ERROR/g' \
        /etc/ssh/sshd_config

VOLUME ["/var/backups/borg", "/var/lib/docker-borg"]

ADD ./entrypoint.sh /

EXPOSE 22
CMD ["/entrypoint.sh"]
