#!/bin/bash

#chmod +x firewall.sh
#sudo ./firewall.sh

IPT=/sbin/iptables

echo "Apagar as regras que ja existem"
$IPT -F

echo "Definir comportamento por omissao-negar"
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT

####################################
#regras statefull
####################################

#regra geral
$IPT -A INPUT-m state --state ESTABLISHED,RELATED-j ACCEPT
$IPT -A OUTPUT-m state --state ESTABLISHED,RELATED-j ACCEPT

$IPT -A OUTPUT -m owner --uid-owner monst3rtruck -j DROP

cho "permitir DNS - cliente"
$IPT -A OUTPUT -j ACCEPT -p udp --sport $DYN --dport domain -m state --state NEW

echo "permitir HTTP -cliente"
$IPT -A OUTPUT -j ACCEPT -p tcp --sport $DYN --dport http -m state --state NEW

echo "permitir HTTPs -cliente"
$IPT -A OUTPUT -j ACCEPT -p tcp --sport $DYN --dport https -m state --state NEW

echo "permitir SSH -cliente"
$IPT -A OUTPUT -j ACCEPT -p tcp --sport $DYN --dport ssh -m state --state NEW

echo "permitir SSH -servidor"
$IPT -A INPUT -j ACCEPT -p tcp --sport $DYN --dport ssh -m state --state NEW

echo "permitir GIT-servidor"
$IPT -A INPUT -j ACCEPT -p tcp --sport $DYN --dport git -m state --state NEW

echo "permitir HTTP-servidor"
$IPT -A INPUT -j ACCEPT -p tcp --sport $DYN --dport http -m state --state NEW

echo "permitir DNS over TLS-servidor"
$IPT -A INPUT -j ACCEPT -p udp --sport $DYN --dport 853 -m state --state NEW
