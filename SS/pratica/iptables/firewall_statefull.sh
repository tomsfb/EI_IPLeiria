#!/bin/sh

echo "Politica por omissao: negar tudo"

iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

echo "Eliminar listas e tabelas"

iptables -F
iptables -X

####################
#Regras Stateless  #
####################

echo "Permitir tudo no localhost"

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

echo "Ping"

iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

###################
#Regras Statefull #
###################

echo "Negar pacotes invalidos"

iptables -A INPUT -m state --state INVALID -j DROP

#####################################################################
#estas regras vao assegurar que depois de ser establecida uma ligacao, 
#essa ligacao continua a ser aceite

iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Criar lista 'NovaLista'"

iptables -N NovaLista

iptables -A NovaLista -p tcp --dport 443 -j ACCEPT

iptables -A OUTPUT -m state --state NEW -p ip -j NovaLista

echo "Permitir SSH - client"
#retorno do pacote assegurado pelas regras acima
iptables -A OUTPUT -p tcp --sport 1024:65535 --dport ssh -m state --state NEW -j ACCEPT

echo "Permitir SSH - server"
iptables -A INPUT -p tcp --sport 1024:65535 --dport ssh -m state --state NEW -j ACCEPT

#Example to prevent a flood of new TCP connections
# create the syn_flood chain
$IPT -N syn_flood
# add rules to the syn_flood chain
$IPT -A syn_flood -m limit --limit 10/second --limit-burst 5 -j RETURN
$IPT -A syn_flood -j DROP

# create the syn_flood chain with logs
$IPT -A INPUT -j LOG --log-prefix "DROPPED " --log-level 4 --log-ip-options --log-tcp-options --log-tcp-sequence

# redirect packets to the syn_flood change
$IPT -A INPUT -p tcp --syn -j syn_flood

