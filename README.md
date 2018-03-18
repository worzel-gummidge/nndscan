# nndscan
nndscan is usually the first script i run when attempting a boot2root or ctf challenge. it basically runs an nmap scan followed by nikto and dirb scans. 

this script runs **nmap**'s os, port(tcp0-65535) and version scan with default scripts, no name resolution with no regard for stealth and writes the results to nmap.txt. the script then writes every port running an http service into a file named httpports. the script then invokes **nikto** which scans every entry in httpports and writes the results to nikto.txt. finally **dirb** also performs a scan on all entries of httpports using the /usr/share/dirb/big.txt wordlist and writes the results to dirb.txt. to run this script successfully, **nmap**, **nikto** and **dirb** must be installed.



#### dependencies####

1. nmap
2. nikto
3. dirb