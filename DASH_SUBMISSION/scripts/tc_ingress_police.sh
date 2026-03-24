sudo tc qdisc del dev enp0s3 ingress 2>/dev/null
sudo tc qdisc add dev enp0s3 handle ffff: ingress
sudo tc filter add dev enp0s3 parent ffff: protocol ip prio 1 u32 \
	match u32 0 0 police rate 3.5mbit burst 20kb drop flowid :1
tc -s filter show dev enp0s3
