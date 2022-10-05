#! /bin/sh
#kernel_version="#KERNEL VERSION: "$(uname -r | tr -s '-' | cut -d '-' -f 1)
#arquitectura="#ARQUITECTURA: "$(uname -r | rev | cut -d '.' -f 1 | rev)
architecture="#Architecture : "$(uname -rv)
cores="#CPU physical : "$(nproc)
#vcores="#vCPU physical : "$(cat /proc/cpuinfo | grep processor | wc -l)
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
lvm_state="#LVM user : "$(lvm)
active_connections="#Connections TCP : "$(netstat -tanp | grep ESTABLISHED | wc -l)" ESTABLISHED"
logged_users="#User log : "$(users | wc -w)
ip_mac_address="#Network : IP "$(ip address | grep "inet " | awk 'NR==2 {print $2}')" ("$(ip address | grep "link/ether" | awk '{print $2}')")"
sudo_cmd="#Sudo : "$(cat /var/log/secure | grep sudo | grep COMMAND | wc -l)" cmd"

wall "
echo $architecture
echo $cores
echo $vcores
echo $memory_usage
echo $disk_usage
echo $cpu_load
echo $last_boot
echo $lvm_state
echo $active_connections
echo $logged_users
echo $ip_mac_address
echo $sudo_cmd
"