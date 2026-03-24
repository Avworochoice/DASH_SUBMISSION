sudo tc qdisc del dev enp0s3 root 2>/dev/null
sudo tc qdisc add dev enp0s3 root tbf rate 2.5mbit burst 20kb latency 50ms
tc -s qdisc show dev enp0s3
