#!/bin/sh

#chmod +x firewall.sh
#sudo ./firewall.sh

IPT=/sbin/iptables

#load kernel module
/sbin/modprobe ip_conntrack_ftp

echo "Apagar as regras que ja existem"
$IPT -F

echo "Eliminar todas as regras personalizadas"
$IPT -X

echo "Definir comportamento por omissao-negar"
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

####################################
#regras statefull
####################################
DYN=1024:65535
#regra geral
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "permitir FTP como cliente"
$IPT -A OUTPUT -p tcp --sport 1024:65535 --dport ftp -m state --state NEW -j ACCEPT

echo "permitir DNS - cliente"
$IPT -A OUTPUT -j ACCEPT -p udp --dport domain -m state --state NEW

echo "permitir HTTP -cliente"
$IPT -A OUTPUT -j ACCEPT -p tcp --dport http -m state --state NEW

#Obesrvaçao-tem de ser antes do https porque se tem de meter as exceçoes primeiro nas firewalls
echo "Bloquear Sapo.pt -cliente" # 'host www.sapo.pt' para saber o IP do site
$IPT -A OUTPUT -j DROP -p tcp -d 213.13.146.142 --dport 443 -m state --state NEW

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
