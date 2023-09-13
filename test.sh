#!/bin/bash

# apt install -y podman
podman run -d --name vpncli --network host --privileged --restart=always -e ACCOUNT_NAME=test -e ACCOUNT_USER=as0 -e ACCOUNT_PASS=1  -e VPN_SERVER=hub.kc2288.dynv6.net  -e VIRTUAL_HUB=kc.2288.org -e VPN_PORT=7777 -e TAP_IPADDR=192.168.30.30 kc2299/softether-client-kernel4:v1.2