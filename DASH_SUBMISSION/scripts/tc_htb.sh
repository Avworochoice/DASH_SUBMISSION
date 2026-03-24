sudo tc qdisc del dev enp0s3 root 2>/dev/null
sudo tc qdisc add dev enp0s3 root handle 1: htb default 10
sudo tc class add dev enp0s3 parent 1: classid 1:10 htb rate 2.5mbit ceil 5mbit burst 20k
tc -s class show dev enp0s3
