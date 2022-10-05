#! /bin/bash

architecture="#Architecture : "$(uname -a)
cores="#CPU physical : "$(nproc)
vcores="#vCPU physical : "$(cat /proc/cpuinfo | grep "cpu cores" | rev | cut -d ' ' -f 1 | rev)
memory_usage="#Memory Usage : "$(free -m | grep Mem | awk '{ print $3"/"$2"MB" " ("$3/$2 * 100"%)"}')
disk_usage="#Disk Usage: "$(inxi -d | awk NR==2 | awk '{print $7"/"$4$8" "$9}')
cpu_idle=$(vmstat | awk NR==3 | awk '{print $(NF - 2)}')
cpu_load="#CPU load : "$(expr 100 - $cpu_idle)"%"
last_boot="#Last boot : "$(uptime -s)
if grep -Pq '/dev/(mapper/|disk/by-id/dm)' /etc/fstab  ||  mount | grep -q /dev/mapper
then
    lvm="yes"
fi
lvm_state="#LVM user : "$lvm
active_connections="#Connections TCP : "$(netstat -tanp | grep ESTABLISHED | wc -l)" ESTABLISHED"
logged_users="#User log : "$(users | wc -w)
ip_address=$(hostname -I |awk '{print $1}')
mac_address=$(ip link show |grep "ether " |awk '{print $2}')
ip_mac_address="#Network : IP "$ip_address" ("$mac_address")"
sudo_cmd="#Sudo : "$(cat /var/log/secure | grep sudo | grep COMMAND | wc -l)" cmd"

wall "
$architecture
$cores
$vcores
$memory_usage
$disk_usage
$cpu_load
$last_boot
$lvm_state
$active_connections
$logged_users
$ip_mac_address
$sudo_cmd
"
