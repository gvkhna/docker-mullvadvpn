FROM ubuntu:latest
LABEL org.opencontainers.image.description Mullvad CLI Docker Image

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y systemd systemd-sysv runit-systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && rm $(ls | grep -v systemd-tmpfiles-setup)

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

RUN apt-get update \
  && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  && apt-get install -qq -y --no-install-recommends \
  bash \
  ca-certificates \
  curl \
  dnsutils \
  iproute2 \
  iptables \
  iputils-ping \
  nano \
  nftables \
  wget \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR "/root"

RUN wget --content-disposition --no-verbose https://mullvad.net/download/app/deb/latest \
    && apt install -y ./Mullvad*.deb || true

RUN printf "#\041/bin/sh\n\
  if [ -f /etc/custom-init.d/00-startup.sh ]; then\n\
    echo '[custom-init] Running 00-startup.sh...'\n\
    /bin/bash /etc/custom-init.d/00-startup.sh\n\
  fi\n\
  exit 0\n\
  " > /etc/rc.local \
  && chmod u+x /etc/rc.local

RUN printf "\n\
  alias curlcheck='curl https://am.i.mullvad.net/connected'\n\
  alias curljson='curl https://am.i.mullvad.net/json'\n\
  " > /root/.bash_aliases

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]