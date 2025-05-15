#!/bin/bash

echo "[+] Limpando regras antigas..."
iptables -F
iptables -X

echo "[+] Habilitando políticas padrão seguras..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "[+] Permitindo conexões locais..."
iptables -A INPUT -i lo -j ACCEPT

echo "[+] Permitindo conexões já estabelecidas..."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "[+] Protegendo contra SYN Flood (TCP)..."
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

echo "[+] Protegendo contra UDP Flood..."
iptables -A INPUT -p udp -m limit --limit 10/s --limit-burst 20 -j ACCEPT
iptables -A INPUT -p udp -j DROP

echo "[+] Bloqueando pacotes malformados e scans..."
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP

echo "[+] Regras de proteção aplicadas com sucesso!"
