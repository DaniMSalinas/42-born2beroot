#! /bin/bash

architecture="#Architecture : "$(uname -a)
cores="#CPU physical : "$(nproc)
vcores="#vCPU physical : "$(cat /proc/cpuinfo | grep "cpu cores" | rev | cut -d ' ' -f 1 | rev)
memory_usage="#Memory Usage : "$(free -m | grep Mem | awk '{ print $3"/"$2"MB" " ("$3/$2 * 100"%)"}')
disk_usage="#Disk Usage: "$(df -t xfs --total -h --output=used,size,pcent |tail -1 |awk '{printf "%s/%s (%s)", $1, $2, $3}')
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
ip_mac_address="#Network : IP "$ip_address" (08:00:27:46:32:09)"
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
