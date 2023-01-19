FROM ubuntu:latest
MAINTAINER gvkhna
LABEL org.opencontainers.image.authors="gvkhna@gvkhna.com"
LABEL org.opencontainers.image.description Mullvad CLI Docker Image

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV CI true

RUN apt-get update \
  && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  && apt-get install -qq -y --no-install-recommends \
  bash \
  ca-certificates \
  curl \
  dbus \
  dnsutils \
  ipcalc \
  iproute2 \
  iptables \
  iputils-ping \
  kmod \
  lsof \
  nano \
  net-tools \
  nftables \
  runit-systemd \
  socat \
  systemd \
  systemd-sysv \
  wget \
  && apt-get autoremove -y \
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

WORKDIR "/root"

RUN wget --content-disposition --no-verbose https://mullvad.net/download/app/deb/latest \
    && apt install -y ./Mullvad*.deb || true \
    && rm -rf ./Mullvad*.deb \
    && rm -rf /opt/Mullvad\ VPN

COPY rc-local.sh /etc/rc.local
COPY container-input-ports.sh container-env.sh /etc/
RUN chmod u+x /etc/rc.local \
  && chmod +x /etc/container-input-ports.sh \
  && chmod +x /etc/container-env.sh

RUN printf "\n\
  alias curlcheck='curl https://am.i.mullvad.net/connected'\n\
  alias curljson='curl https://am.i.mullvad.net/json'\n\
  alias mullvadkey='mullvad tunnel wireguard key check'\n\
  " > /root/.bash_aliases

VOLUME [ "/sys/fs/cgroup" ]

# systemd exits on SIGRTMIN+3, not SIGTERM (which re-executes it)
# https://bugzilla.redhat.com/show_bug.cgi?id=1201657
STOPSIGNAL SIGRTMIN+3

# use systemd stdio workaround here: https://github.com/systemd/systemd/pull/4262
RUN rm -rf /usr/sbin/init
ADD entrypoint.sh /usr/sbin/init
RUN chmod a+x /usr/sbin/init
CMD ["/usr/sbin/init"]