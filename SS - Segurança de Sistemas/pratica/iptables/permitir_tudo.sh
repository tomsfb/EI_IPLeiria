#!/bin/sh

#Permitir tudo
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

#Eliminar listas e regras
iptables -F
iptables -X
