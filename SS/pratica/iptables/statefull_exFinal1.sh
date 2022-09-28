#!/bin/sh

echo "Politica por omissao: Negar tudo\n"
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

echo "Remover regras e listas antigas\n"
iptables -F
iptables -X

##############
#stateless
##############

echo "Permitir acesso total loopback\n"
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

echo "Permitir entradas e saidas 6\n"
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCEPT

###############
#statefull
###############

echo "Criar lista RegistaLog\n"
iptables -N RegistaLog
iptables -A RegistaLog -p tcp -m limit --limit 6/h -j LOG --log-prefix "RegistaLog "
iptables -A RegistaLog -p udp -m limit --limit 12/h -j LOG --log-prefix "RegistaLog "

echo "Regras genericas statefull\n"
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Rejeitar pedidos TCP/UDP - DNS"
#iptables -A INPUT -p tcp --dport domain -m state --state NEW -j REJECT --reject-with tcp-reset
#iptables -A INPUT -p udp --dport domain -m state --state NEW -j REJECT --reject-with icmp-port-unreachable 

echo "Permitir DNS"
iptables -A OUTPUT -p udp --sport 1024:65535 --dport 53 -m state --state NEW -j ACCEPT

echo "Permitir obter configuracoes IP por DHCP\n"
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT

echo "Permitir acesso HTTP e HTTPS\n"
iptables -A OUTPUT -p tcp --dport http -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p tcp --dport https -m state --state NEW -j ACCEPT

echo "Permitir acesso SSH - cliente\n"
iptables -A OUTPUT -p tcp --dport ssh -m state --state NEW -j ACCEPT

echo "Permitir acesso SSH - servidor (excepto rede 192.168.226.0/24)\n"
IP=192.168.226.0/24
iptables -A INPUT -p tcp -s $IP --dport ssh -m state --state NEW -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --dport ssh -m state --state NEW -j ACCEPT

echo "Permitir SYN de 10 em 10 segundos\n"
iptables -A INPUT -p tcp --syn -m limit --limit 10/s -j ACCEPT

iptables-save -c > ~/SS/iptables/teste.txt









