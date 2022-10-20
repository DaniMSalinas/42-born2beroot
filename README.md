# 42-born2beroot

#### SET HOSTNAME
hostnamectl set-hostname dmaldona42
reboot

# enable internt connection (working in bridge mode)
nmcli c up enps03

# installing and updating packet manager repo DNF
yum install -y dnf
dnf update -y
# instaling some tools needed
dnf install -y sudo net-tools openssh-server openssh-clients inxi

## CREATE USER AND SET PASSWORD
adduser dmaldona
passwd dmaldona

## CREATE GROUP AND BECOME SUDO
groupadd user42
usermod -aG wheel,user42 dmaldona
groups dmaldona

## INSTALLING AND CONFIGURING UFW
yum update
yum install epel-release -y
yum install --enablerepo="epel" ufw -y
ufw enable
systemctl start ufw
systemctl enable ufw
ufw allow 4242/tcp
ufw allow 80

## INSTALLING AND CONFIGURING SEMANAGE
yum install -y policycoreutils-python
semanage port -a -t ssh_port_t -p tcp 4242

## CONFIGURING AND STARTING SSHD SERVICE
systemctl enable sshd
vi /etc/ssh/sshd
    # PermitRootLogin no
    # Port 4242
systemctl restart sshd

## CONFIGURING PASSWORD POLICY || PENDING
vim /etc/login.defs
vim /etc/pam.d/system-auth
vim /etc/security/pwquality.conf

## CONFIGURING VISUDO (etc/sudoers)
visudo
    #Defaults   passwd_tries=3
    #Defaults   badpass_message="te has equivocado vro"
    #Defaults   logfile="/var/log/sudo/sudo.log"
    #Defaults   requiretty
    #Defaults   secure_path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
vim /etc/rsyslog.conf

## MONITORING script
touch /usr/local/sbin/monitoring.sh
crontab -e */10 * * * * /usr/local/sbin/monitoring.sh | cat -e

## BONUS ##
# https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-on-centos-7
su - dmaldona
sudo dnf update -y

## MARIADB installation and configuration
sudo dnf install mariadb-server wget -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
mysql_secure_installation #password messi10Barsa // yes to all
    Enter current password for root (enter for none): 
    Set root password? [Y/n] n
    Remove anonymous users? [Y/n] Y
    Disallow root login remotely? [Y/n] Y
    Remove test database and access to it? [Y/n] Y
    Reload privilege tables now? [Y/n] Y
mysqladmin -u root -p version
mysql -u root -p
    MariaDB [(none)]> CREATE DATABASE wordpress;
    MariaDB [(none)]> CREATE USER adminuser@localhost IDENTIFIED BY 'password';
    MariaDB [(none)]> SELECT User,Password FROM mysql.user;
    MariaDB [(none)]> GRANT ALL ON wordpress.* TO adminuser@localhost;
    MariaDB [(none)]> FLUSH PRIVILEGES;
    MariaDB [(none)]> exit;
mysql -u adminuser -p
    MariaDB [(none)]> SHOW DATABASES;
    MariaDB [(none)]> SHOW GRANTS FOR adminuser@localhost;

## LIGHTTPD installation and configuration
sudo yum install lighttpd -y
sudo systemctl start lighttpd
sudo systemctl enable lighttpd
vi /etc/lighttpd/lighttpd.conf
    server.use-ipv6 from enable to disable
    server.max-fds = 2048
sudo setsebool -P httpd_setrlimit on
sudo systemctl restart lighttpd

## INSTALL PHP AND FASTCGI (needed php version higher than 5.6.20)
sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum install -y yum-utils
sudo yum-config-manager --enable remi-php56
sudo yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
php -v
## https://www.tecmint.com/install-lighttpd-with-php-fpm-mariadb-on-centos/

# PHP 5.6.40 (cli) (built: Sep 28 2022 10:48:43)
systemctl restart lighttpd

## WORDPRESS installation and configuration
cd ~
wget http://wordpress.org/latest.tar.gz
tar xvzf latest.tar.gz
sudo yum -y install rsync
sudo rsync -avP ~/wordpress/ /var/www/html/
mkdir /var/www/html/wp-content/uploads
sudo chown -R lighttpd:lighttpd /var/www/html/*
cd /var/www/html
cp wp-config-sample.php wp-config.php #modify the file with the database info

# RabbitMQ installation and configuration
# https://www.vultr.com/docs/how-to-install-rabbitmq-on-centos-7/
sudo yum -y install epel-release
cd ~ && wget https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_23.3.1-1~centos~7_amd64.rpm
sudo yum -y install esl-erlang*.rpm
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.19/rabbitmq-server-3.8.19-1.el7.noarch.rpm
sudo yum -y install rabbitmq-server*.rpm
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmq-plugins enable rabbitmq_mqtt
