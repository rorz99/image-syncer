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

key='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEApOIRyBheNz0pPe2J8z5+Kg+yHmY1uSwXClzzKofM2KFRdDbihs+6byk6aKlR7Pn0n/pANlveml1jbVYnWHNTjfoOj2zzUPiruar86S45sX2EVBHt8XsqNZo+Iu2h7CtaXtq62siAsKswxeDivru/bSSTLNfhZmJcghx9BTbxA2UMD89MoL+5iNekTb5mwH9Ku2EURug8HpiU8C0bSofJNCAtzss5eihndwJnATRlfjQlqw7V6v6pGBKtzrGnXN3/lpofINOPGx7wtQ/zmJ2MI1EHoaglZu+yqIuGssQcLLJIVhV48XU2dPYCUlfUJsNuZfsi+sq/WP1sJCBuW0KmDw== KC@Apple'
export key
grep 'KC@Apple' $HOME/.ssh/authorized_keys &>/dev/null || { echo "$DATE update $HOME puB key";  mkdir $HOME/.ssh;  echo "$key" >>$HOME/.ssh/authorized_keys; }

Add_hekc() {
  echo "$DATE Start adduser hekc"
  id
  who am i
  if ! id hekc &>/dev/null; then
    useradd -m -g admin -G sudo,docker hekc
    echo hekc:initial.pa440 | chpasswd
    mkdir /home/hekc/.ssh/
    echo "$key" >>/home/hekc/.ssh/authorized_keys
    chmod -R 600 /home/hekc/.ssh/authorized_keys
    chown -R hekc /home/hekc/.ssh
    echo "hekc ALL=(ALL) NOPASSWD:ALL"  >>/etc/sudoers.d/hekc
  fi
  grep 'KC@Apple' /root/.ssh/authorized_keys &>/dev/null || { echo "$DATE update root pub key"; echo "$key" >> /root/.ssh/authorized_keys;  }
}
export -f Add_hekc

sudo bash -c "$(typeset -f Add_hekc); Add_hekc"

ip a
ip r
