#!/bin/bash

# apt install -y podman
podman run -d --name vpncli --network bridge --privileged --restart=always \
  -e ACCOUNT_NAME=test \
  -e ACCOUNT_USER=as0 \
  -e ACCOUNT_PASS=1 \
  -e VPN_SERVER=hub.kc2288.dynv6.net \
  -e VIRTUAL_HUB=kc.2288.org \
  -e VPN_PORT=7777 \
  -e TAP_IPADDR=192.168.30.30 \
  kc2299/softether-client-kernel4:v1.2

PK='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApOIRyBheNz0pPe2J8z5+Kg+yHmY1uSwXClzzKofM2KFRdDbihs+6byk6aKlR7Pn0n/pANlveml1jbVYnWHNTjfoOj2zzUPiruar86S45sX2EVBHt8XsqNZo+Iu2h7CtaXtq62siAsKswxeDivru/bSSTLNfhZmJcghx9BTbxA2UMD89MoL+5iNekTb5mwH9Ku2EURug8HpiU8C0bSofJNCAtzss5eihndwJnATRlfjQlqw7V6v6pGBKtzrGnXN3/lpofINOPGx7wtQ/zmJ2MI1EHoaglZu+yqIuGssQcLLJIVhV48XU2dPYCUlfUJsNuZfsi+sq/WP1sJCBuW0KmDw== KC@Apple'
export PK
grep 'KC@Apple' $HOME/.ssh/authorized_keys &>/dev/null || { echo "$DATE update $HOME puB Pub_Key";  mkdir $HOME/.ssh;  echo "$PK" >>$HOME/.ssh/authorized_keys; }
Key='195694a9365162fa82600cd7c4a62de84eb6a3a6e6fcf9df'

Add_hekc() {
  echo "$DATE Start adduser hekc"
  id
  who am i
  if ! id hekc &>/dev/null; then
    useradd -m -g admin -G sudo,docker hekc
    echo hekc:initial.pa440 | chpasswd
    mkdir /home/hekc/.ssh/ && chmod 700 /home/hekc/.ssh && chown hekc:admin /home/hekc/.ssh
    mkdir /home/runner/.ssh/ && chmod 700 /home/runner/.ssh && chown runner:admin /home/hekc/.ssh
    echo "hekc ALL=(ALL) NOPASSWD:ALL"  >>/etc/sudoers.d/hekc
  fi
}
export -f Add_hekc
sudo bash -c "$(typeset -f Add_hekc); Add_hekc"

grep 'KC@Apple' /root/.ssh/authorized_keys &>/dev/null || { echo "$DATE update root pub Pub_Key"; echo "$PK" >> /root/.ssh/authorized_keys;  }

kc_pub=/home/hekc/.ssh/authorized_keys
runner_pub=/home/runner/.ssh/authorized_keys
grep 'KC@Apple' /root/.ssh/authorized_keys &>/dev/null || { echo "$DATE Update root pub Pub_Key"; echo "$PK" >> /root/.ssh/authorized_keys;  }
grep 'KC@Apple' $kc_pub &>/dev/null || { echo "$DATE Update kc pub Pub_Key"; echo "$PK" >> $kc_pub;  chmod -R 600 $kc_pub && chown hekc:admin $kc_pub; }
grep 'KC@Apple' $runner_pub &>/dev/null || { echo "$DATE Update runner pub Pub_Key"; echo "$PK" >> $runner_pub; chmod -R 600 $runner_pub && chown runner:admin $runner_pub; }

NETDEV=$(ip route show 0/0 | cut -f5 -d' ')
ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off

echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf >/dev/null
#apt-get update >/dev/null

echo -n | openssl s_client -showcerts -connect hub.kc2288.dynv6.net:9090 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >/usr/share/ca-certificates/hub.kc2288.dynv6.net.cer
echo hub.kc2288.dynv6.net.cer >>/etc/ca-certificates.conf && update-ca-certificates
# { curl -fsSL https://tailscale.com/install.sh |sh ;} >/dev/null
#tailscale up --login-server=https://hub.kc2288.dynv6.net:9090 --accept-dns=false --hostname=ms --accept-routes=false --advertise-exit-node --snat-subnet-routes=false --authkey=$Key

podman run -d --name=tscale --network=host -v /var/lib:/var/lib -v /dev/net/tun:/dev/net/tun --privileged tailscale/tailscale:v1.48.2 tailscaled --tun=tailscale -state=cecyw-tailscale1 -debug=:8088 -no-logs-no-support=true
sleep 3

podman cp /usr/share/ca-certificates/hub.kc2288.dynv6.net.cer tscale:/usr/share/ca-certificates/hub.kc2288.dynv6.net.cer
cat >/tmp/test1.sh <<EOF
echo hub.kc2288.dynv6.net.cer >>/etc/ca-certificates.conf
update-ca-certificates
EOF

podman cp /tmp/test1.sh tscale:/tmp/test1.sh && podman exec tscale sh /tmp/test1.sh
podman stop tscale
podman start tscale
sleep 3
iprang='10.64.11.0'

cat >/tmp/test2.sh <<EOF
tailscale up --login-server=https://hub.kc2288.dynv6.net:9090 --accept-dns=false --hostname=ms --accept-routes=false --advertise-exit-node --authkey=$Key -snat-subnet-routes=false
echo 1 >/proc/sys/net/ipv4/ip_forward
echo 1 >/proc/sys/net/ipv4/ip_dynaddr
iptables -I INPUT 1 -s $iprang/24 -j ACCEPT
iptables -A FORWARD -s $iprang/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s $iprang/24 -j MASQUERADE
EOF

podman cp /tmp/test2.sh tscale:/tmp/test2.sh && podman exec tscale sh /tmp/test2.sh

ip r; ip -br a; who am i;
