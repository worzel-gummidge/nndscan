#! /bin/bash

# nndscan.sh

# this script runs nmap's os, port(tcp0-65535) and version scan with default scripts, no name resolution with no regard for stealth and writes the results to nmap.txt. the script then writes every port running an http service into a file named httpports. the script then invokes nikto which scans every entry in httpports and writes the results to nikto.txt. finally dirb also performs a scan on all entries of httpports using the /usr/share/dirb/big.txt wordlist and writes the results to dirb.txt. to run this script successfully, nmap, nikto and dirb but be installed

# basically, this script performs an nmap port scan then retrieves every port running http. these ports are scaned by nikto and dirb

# worzel_gummidge

clear
# collect data from user
echo "Enter host IP:"
read ip

echo "Enter project name:"
read name

# create directory for results
mkdir $name
cd $name

# nmap scan
echo "[!] Starting nmap scan.."
echo "nmap $ip -A -n -T5 -p1-65535"
nmap $ip -A -n -T5 -p1-65535 -oN nmap.txt
echo "[!] Nmap scan complete"

# write http ports to file
cat nmap.txt | grep http | grep -h '[^d]/tcp*' | cut -d '/' -f 1 > httpports

# nikto scan
echo "[!] Starting nikto scan.."
echo "nikto -h $ip:$port"
for port in $(cat httpports); do gnome-terminal -- nikto -nointeractive -h $ip:$port >> nikto.txt; done

# dirb scan
echo "[!] Starting dirb.."
echo "dirb http://$ip:$port /usr/share/dirb/wordlists/big.txt"
for port in $(cat httpports); do gnome-terminal -- dirb http://$ip:$port /usr/share/dirb/wordlists/big.txt -o dirb.txt; done
echo "[!] This may take a while. nikto and dirb scans are running.."
