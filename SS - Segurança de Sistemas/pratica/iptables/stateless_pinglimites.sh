#!/bin/sh

echo "Politica por omissao: Negar tudo"
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

echo "Remover regras e tarefas"
iptables -F
iptables -X

############
#stateless #
############

echo "Permitir acesso total interface loopback"
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

echo "Permitir ping"
#aceita 1 - rejeita 10
#iptables -A OUTPUT -p icmp --icmp-type echo-request -m limit --limit 6/m --limit-burst 4 -j REJECT
#iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT 

#aceita 10 -rejeita 1
iptables -A OUTPUT -p icmp --icmp-type echo-request -m limit --limit 6/m --limit-burst 2 -j REJECT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT 
