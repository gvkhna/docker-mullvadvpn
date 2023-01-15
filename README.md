# Mullvad Docker Container

A Docker container with the linux Mullvad cli client.

# Setup

Before running setup a folder to contain your mullvad setting files such as "myappdata/mullvadvpn"

1. Copy etc-mullvad.template files into "myappdata/mullvadvpn"

Your myappdata/mullvadvpn should contain `account-history.json`,`device.json`, and `settings.json`

2. Run with the following similar flags 

```sh
docker run --privileged --name mullvadvpn -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v myappdata/mullvadvpn:/etc/mullvad-vpn:rw mullvadvpn
```

# Details

The etc-mullvad.template files are example files generated from mullvad-cli with the following configurations set:

```sh
mullvad relay set tunnel-protocol wireguard
mullvad always-require-vpn set on
mullvad auto-connect set on
mullvad lan set allow
```

This at the bare minimum will ensure no leaking of packets upon startup even without authentication into your account.

To verify you can run the following commands upon starting the container:

```sh
mullvad status
nft list tables
```


Based on [jrei/systemd-ubuntu](https://hub.docker.com/r/jrei/systemd-ubuntu) for systemd support.