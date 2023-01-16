FROM ubuntu:latest
MAINTAINER gvkhna
LABEL org.opencontainers.image.authors="gvkhna@gvkhna.com"
LABEL org.opencontainers.image.description Mullvad CLI Docker Image

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV CI true

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
  kmod \
  lsof \
  nano \
  net-tools \
  nftables \
  wget \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR "/root"

RUN wget --content-disposition --no-verbose https://mullvad.net/download/app/deb/latest \
    && apt install -y ./Mullvad*.deb || true

COPY rc-local.sh /etc/rc.local
COPY container-input-ports.sh /etc/container-input-ports.sh
RUN chmod u+x /etc/rc.local \
  && chmod +x /etc/container-input-ports.sh

RUN printf "\n\
  alias curlcheck='curl https://am.i.mullvad.net/connected'\n\
  alias curljson='curl https://am.i.mullvad.net/json'\n\
  " > /root/.bash_aliases

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]