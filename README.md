# Mullvad Docker Container

A Docker container with the linux Mullvad cli client.

# Setup

Before running setup a folder to contain your mullvad setting files such as `"myappdata/mullvadvpn"`

1. Copy `etc-mullvad.template` files into `"myappdata/mullvadvpn"`

Your `myappdata/mullvadvpn` should contain `account-history.json`,`device.json`, and `settings.json`

2. Run with the following similar flags 

```sh
docker run 
  --privileged 
  --name mullvadvpn 
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro 
  -v myappdata/mullvadvpn/etc:/etc/mullvad-vpn:rw 
  -v myappdata/mullvadvpn/var:/var/cache/mullvad-vpn:rw
  mullvadvpn
```

3. Login and setup your relay and account

```sh
docker exec -ti mullvadvpn bash
```

```sh
mullvad relay set location se mma
mullvad account login 1234123412341234
```

4. You can use the mullvad API with a bash_alias added for convenience to check you are connected

```sh
curlcheck # => You are connected to Mullvad...
```

```sh
mullvadkey # => Your Mullvad Device wireguard key
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
root@3138e96e42d9:~# nft list tables
table inet mullvad
table ip mullvadmangle4
table ip6 mullvadmangle6
```

# Custom Init/Startup Script

If you add a volume for `/etc/custom-init.d/` to `myappdata/custom-init.d/` with a file named `00-startup.sh` it will be run on boot

Similar to the following:

```sh
docker run 
  --privileged 
  --name mullvadvpn 
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro 
  -v myappdata/etc-mullvadvpn:/etc/mullvad-vpn:rw 
  -v myappdata/mullvadvpn/var:/var/cache/mullvad-vpn:rw
  -v myappdata/custom-init.d:/etc/custom-init.d:ro 
  mullvadvpn
```

To allow nat packet forwarding add the environment variable `VPN_ALLOW_FORWARDING='true'`

This will run the following commands on boot.

```sh
#!/bin/bash
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o wg+ -j MASQUERADE
```

This can be used for setting routes of another container instead of changing the container network to be this docker container.

For example run the following on startup in the secondary container. If your mullvad container has a static ip address set at `172.10.250.250`, then your default route will be set to the mullvad container, which means default packets will travel through your vpn. This also has a route set for local LAN that keeps LAN accessible by routing it through the secondary container directly.

```sh
echo 'Changing default routes to mullvadvpn'
ip route del default
ip route add default via 172.10.250.250
ip route add 192.168.1.0/24 via 172.10.0.1
```

## INPUT PORTS

If you connect a container's network to this container, you may need to open a port to that container.

Set the following Environment Variable to a list of ports `VPN_INPUT_PORTS=8080,9090`

# Development

`docker build -t mullvadvpn .`

`docker rm mullvadvpn`

`docker run --privileged --name mullvadvpn -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v appdata/etc-mullvadvpn:/etc/mullvad-vpn:rw -v appdata/custom-init.d:/etc/custom-init.d:ro -e VPN_INPUT_PORTS='8080' -e VPN_ALLOW_FORWARDING='true' mullvadvpn`

`docker exec -ti mullvadvpn bash`

Run the following commands: 

`ip route show`

`ip rule list`

`netstat -an`

iptables setup based on [binhex/arch-int-vpn](https://github.com/binhex/arch-int-vpn) for opening vpn input ports.
Based on [jrei/systemd-ubuntu](https://hub.docker.com/r/jrei/systemd-ubuntu) for systemd support.