#!/bin/sh

#chmod +x pingpong.sh
#sudo ./pingpong.sh

# permite 1 pacote a cada 10 segundos

IPT=/sbin/iptables

$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

$IPT -F
$IPT -X

###################################
# STATELESS
###################################

echo "ping com limites - cliente"
$IPT -A OUTPUT -p icmp --icmp-type echo-request -m limit --limit 6/minute --limit-burst 4 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

