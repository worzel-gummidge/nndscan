#! /bin/bash

# nndscan.sh

# this script runs nmap's os, port(tcp0-65535) and version scan with default scripts, no name resolution with no regard for stealth and writes the results to nmap.txt. the script then writes every port running an http service into a file named httpports. the script then invokes nikto which scans every entry in httpports and writes the results to nikto.txt. finally dirb also performs a scan on all entries of httpports using the /usr/share/dirb/big.txt wordlist and writes the results to dirb.txt. to run this script successfully, nmap, nikto and dirb but be installed

# basically, this script performs an nmap port scan then retrieves every port running http. these ports are scanned by nikto and dirb

# worzel_gummidge

clear
# collect data from user
ip=$1
name=$2
if [[ $# -ne 2 ]]; then
	echo "[!] Usage: ./nndscan.sh target_ip target_name"
	exit 1
fi

# check that the target is reachable
echo "[!] Establishing a connection.."
if [[ $(ping $ip -c 5 | grep rtt | cut -d " " -f 1) == ""  ]]; then
	echo "[!] Target host not reachable. Check connectivity"
	exit 1
fi

# create directory for results
mkdir $name
cd $name
mkdir html
mkdir nmap
mkdir dirb

# nmap scan
echo "[!] Starting nmap tcp scan.."
echo "nmap $ip -A -n -T5 -p1-65535"
nmap $ip -A -n -T5 -p1-65535 -oX nmap/nmapt.xml
echo "[!] Nmap tcp scan complete"

echo "[!] Starting nmap udp scan.."
echo "nmap $ip -sU -V -T5 -F --version-intensity 0"
nmap $ip -sU -sV -T5 -F --version-intensity 0 -oX nmap/nmapu.xml

# write http ports to file
cat nmap/nmapt.xml | grep portid | cut -d '"' -f 4 > tcpports
cat nmap/nmapu.xml | grep portid | cut -d '"' -f 4 > udpports
cat nmap/nmapt.xml | grep http | cut -d '"' -f 4 > httpports

# prepare html files

xsltproc nmap/nmapt.xml -o html/nmapt.html
xsltproc nmap/nmapu.xml -o html/nmapu.html

# nikto scan
echo "[!] Starting nikto scan.."
echo "nikto -h $ip:$port"
for port in $(cat httpports); do gnome-terminal -- nikto -nointeractive -h $ip:$port -o html/nikto.html -Format htm; done

# dirb scan
cat /usr/share/dirb/wordlists/common.txt /usr/share/dirb/wordlists/big.txt > directory.txt
echo "[!] Starting dirb.."
echo "dirb http://$ip:$port directory.txt"
for port in $(cat httpports); do dirb http://$ip:$port directory.txt -o dirb/dirb.txt; done
rm directory.txt

# get links to find directories and files
cat dirb/dirb.txt | grep DIRECTORY | cut -d ' ' -f 3 >> dirb/urls
cat dirb/dirb.txt | grep CODE:2 | cut  -d ' ' -f 2 >> dirb/urls
cat dirb/dirb.txt | grep CODE:3 | cut -f 2 -d ' ' >> dirb/urls

# create report
echo "<!DOCTYPE html>
<html>
	<head>
		<title>NNDSCAN RESULTS FOR $ip</title>
	</head>
	<body>
		<div>
			<h2>results for nmap tcp scan</h2>
			<a href="html/nmapt.html">nmap TCP scan results</a>
		</div>
		<div>
			<h2>results for nmap udp scan</h2>
			<a href="html/nmapu.html">nmap UDP scan results</a>
		</div>
		<br>
		<div>
			<h2>results for nikto scan</h2>
			<a href="html/nikto.html">nikto scan results</a>
		</div>
		<br>
		<div>
			<h2>results for dirb directory brute-force</h2>
			<ul>" >> html/report.html
while read url; do
	echo "			<li><a href="$url">$url</a></li>" >> html/report.html
done < dirb/urls
echo "			</ul>
		</div>
	</body>
</html>" >> html/report.html

# show report
firefox html/report.html&

echo "[!] nndscan completed.."
