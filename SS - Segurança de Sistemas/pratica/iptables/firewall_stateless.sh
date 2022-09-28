#!/bin/sh

echo "politica por omissão: negar tudo"
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

echo  "eliminar regras e listas"
iptables -F
iptables -X

echo "Permitir localhost"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#exceçoes primeiro porque se fosse la embaixo iria ser permitido ja que na regra mesmo abaixo todo o icmp e permitido
echo "permitir dois e negar um pc"
iptables -A OUTPUT -p icmp -s 10.200.0.215 -p 
iptables -A INPUT -p icmp

echo "Permitir ping"
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

echo "Permitir ping -servidor"
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

DYN_PORT=1024:65535

echo "Permitir DNS - cliente"
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT 

echo "Permitir SSH - cliente"
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -j ACCEPT

echo "Permitir SSH - servidor"
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

echo "Permitir HTTPs -ambos"
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -j ACCEPT

#UDP port number 67 destination of server
#udp port 68 for the client
echo "permitir receber configuração por DHCP"
iptables -A OUTPUT -p udp --sport 68 --dport 67 -j ACCEPT
iptables -A INTPUT -p udp --sport 67 --dport 68 -j ACCEPT
