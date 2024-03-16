#!/bin/bash

tailscaleKey=$1
# apt install -y podman
podman run -d --name vpncli --network host --privileged --restart=always \
  -e ACCOUNT_NAME=test \
  -e ACCOUNT_USER=as0 \
  -e ACCOUNT_PASS=1 \
  -e VPN_SERVER=hub.kc2288.dynv6.net \
  -e VIRTUAL_HUB=kc.2288.org \
  -e VPN_PORT=7777 \
  -e TAP_IPADDR=192.168.30.199 \
  kc2299/softether-client-kernel4:v1.2

PK='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApOIRyBheNz0pPe2J8z5+Kg+yHmY1uSwXClzzKofM2KFRdDbihs+6byk6aKlR7Pn0n/pANlveml1jbVYnWHNTjfoOj2zzUPiruar86S45sX2EVBHt8XsqNZo+Iu2h7CtaXtq62siAsKswxeDivru/bSSTLNfhZmJcghx9BTbxA2UMD89MoL+5iNekTb5mwH9Ku2EURug8HpiU8C0bSofJNCAtzss5eihndwJnATRlfjQlqw7V6v6pGBKtzrGnXN3/lpofINOPGx7wtQ/zmJ2MI1EHoaglZu+yqIuGssQcLLJIVhV48XU2dPYCUlfUJsNuZfsi+sq/WP1sJCBuW0KmDw== KC@Apple'
export PK
grep 'KC@Apple' $HOME/.ssh/authorized_keys &>/dev/null || { echo "$DATE update $HOME puB Pub_Key";  mkdir $HOME/.ssh;  echo "$PK" >>$HOME/.ssh/authorized_keys; }

Add_hekc() {
  echo "$DATE Start adduser hekc"
  id
  who am i
  if ! id hekc &>/dev/null; then
    useradd -m -g admin -G sudo,docker hekc
    echo hekc:initial.pa440 | chpasswd
    mkdir /home/hekc/.ssh/ && chmod 700 /home/hekc/.ssh && chown hekc:admin /home/hekc/.ssh
    mkdir /home/runner/.ssh/ && chmod 700 /home/runner/.ssh && chown runner:admin /home/runner/.ssh
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
echo "starting check hub certs"
echo -n | openssl s_client -showcerts -connect kc2288.softether.net:9090 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >/usr/share/ca-certificates/hub.kc2288.dynv6.net.cer
echo hub.kc2288.dynv6.net.cer >>/etc/ca-certificates.conf && update-ca-certificates
# { curl -fsSL https://tailscale.com/install.sh |sh ;} >/dev/null
#tailscale up --login-server=https://hub.kc2288.dynv6.net:9090 --accept-dns=false --hostname=ms --accept-routes=false --advertise-exit-node --snat-subnet-routes=false --authkey=$Key

iprang='10.64.11.0'
#RouteRange='3.33.221.0/24,13.107.213.0/24,13.107.246.0/24,13.107.42.0/24,140.82.112.0/24,140.82.113.0/24,140.82.114.0/24,15.197.206.0/24,15.197.210.0/24,16.182.33.0/24,16.182.35.0/24,16.182.39.0/24,16.182.68.0/24,185.199.108.0/24,185.199.109.0/24,185.199.110.0/24,185.199.111.0/24,192.0.66.0/24,199.232.45.0/24,20.205.243.0/24,52.216.146.0/24,52.217.135.0/24,52.217.199.0/24,52.217.204.0/24,52.217.207.0/24,52.217.228.0/24,52.217.229.0/24,52.217.48.0/24,52.217.86.0/24,54.231.135.0/24,54.231.198.0/24'

github_hosts="
alive.github.com
api.github.com
assets-cdn.github.com
avatars.githubusercontent.com
avatars0.githubusercontent.com
avatars1.githubusercontent.com
avatars2.githubusercontent.com
avatars3.githubusercontent.com
avatars4.githubusercontent.com
avatars5.githubusercontent.com
camo.githubusercontent.com
central.github.com
cloud.githubusercontent.com
codeload.github.com
collector.github.com
desktop.githubusercontent.com
favicons.githubusercontent.com
gist.github.com
github-cloud.s3.amazonaws.com
github-com.s3.amazonaws.com
github-production-release-asset-2e65be.s3.amazonaws.com
github-production-repository-file-5c1aeb.s3.amazonaws.com
github-production-user-asset-6210df.s3.amazonaws.com
github.blog
github.com
github.community
github.githubassets.com
github.global.ssl.fastly.net
github.io
github.map.fastly.net
githubstatus.com
live.github.com
media.githubusercontent.com
objects.githubusercontent.com
pipelines.actions.githubusercontent.com
raw.githubusercontent.com
user-images.githubusercontent.com
vscode.dev
education.github.com
web.whatsapp.com
c.whatsapp.net
e.whatsapp.net
WhatsApp.com
g.whatsapp.net
chat.cdn.whatsapp.net
"

check_iprang(){
  for n in {1..20};do dig +short c$n.whatsapp.net ;done
  for n in {1..20};do dig +short e$n.whatsapp.net ;done
  for h in $github_hosts;do dig +short $h ;done
}

RouteRange=$( check_iprang |awk -F. -v OFS=. '/^[0-9]/{print $1,$2,$3,"0/24"}'|sort |uniq |awk -v ORS=, '1' )
RouteRange=${RouteRange%?}

tscale(){
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
if podman ps -a |grep tscale; then
  sleep 3
  cat >/tmp/test2.sh <<EOF
tailscale up --login-server=https://hub.kc2288.dynv6.net:9090 --accept-dns=false --hostname=ms --accept-routes=false --advertise-exit-node --authkey=$tailscaleKey --advertise-routes="$RouteRange"
echo 1 >/proc/sys/net/ipv4/ip_forward
echo 1 >/proc/sys/net/ipv4/ip_dynaddr
iptables -I INPUT 1 -s $iprang/24 -j ACCEPT
iptables -A FORWARD -s $iprang/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s $iprang/24 -j MASQUERADE
EOF

  podman cp /tmp/test2.sh tscale:/tmp/test2.sh && podman exec tscale sh /tmp/test2.sh
fi
}

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list
apt-get -qq update
apt-get -qq install tailscale=1.48.2
tailscale up --login-server=https://hub.kc2288.dynv6.net:9090 --accept-dns=false --hostname=ms --accept-routes=false --authkey=$tailscaleKey --advertise-routes="$RouteRange"
kill -9 $(pgrep dnsmasq);
/usr/sbin/dnsmasq --strict-order --pid-file=/tmp/vpn_vpn.dnsmasq.pid --conf-file= --bind-interfaces --cache-size=1000 --neg-ttl=3600
podman run --name sock5 -d --network host --privileged --restart=always echochio/sock5
#docker run -it -p 80:80 -p 443:443 -p 5222:5222 -p 8080:8080 -p 8443:8443 -p 8222:8222 -p 8199:8199 -p 587:587 -p 7777:7777 whatsapp_proxy:1.0
podman run --name whatsapp -d --privileged -p 5222:5222 -p 8081:8080 -p 8443:8443 -p 8222:8222 -p 8199:8199 -p 7777:7777 kc2299/whatsapp_proxy:1.0
ip r; ip -br a; who am i;
