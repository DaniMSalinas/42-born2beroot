# 42-born2beroot CENTOS 7
    su - root
### 1. GENERIC SETTINGS
##### SET HOSTNAME
    hostnamectl set-hostname dmaldona42
    reboot
##### ENABLE INTERNET CONNECTION (working in bridge mode)
    nmcli c up enps03
##### INSTALLING AND UPDATING PACKET MANAGER REPO DNF
    yum update -y
    yum install -y dnf
    dnf update -y
##### INSTALLING SOME NEEDED TOOLS
    dnf install -y sudo vim net-tools openssh-server openssh-clients
    yum install epel-release -y
#
### 2. CREATE USER AND PASSWOORD CONFIGURATION
##### CREATE USER, GROUP AND BECOME SUDO
    adduser test_user 
    passwd test_user
    groupadd user42 
    usermod -aG wheel,user42 test_user
    groups test_user
##### CONFIGURING PASSWORD POLICY
    # modify /etc/login.defs using as it is on the configuration directory of this repo
    # modify /etc/pam.d/system-auth as it is on the configuration directory of this repo
    # modify /etc/security/pwquality.conf as it is on the configuration directory of this repo
    # modify /etc/sudoers as it is on the configuration directory of this repo
    # modify /etc/rsyslog.conf as it is on the configuration directory of this repo
#
### 3. INSTALLING AND CONFIGURING UFW
    yum install --enablerepo="epel" ufw -y
    ufw enable 
    systemctl start ufw
    systemctl enable ufw
    ufw allow 4242
#
### 4. CONFIGURING SSHD SERVICE
    yum install -y policycoreutils-python
    semanage port -a -t ssh_port_t -p tcp 4242
    # modify /etc/ssh/sshd as it is on the configuration directory of this repo
    systemctl enable sshd
#
### 5. MONITORING SCRIPT
    touch /usr/local/sbin/monitoring.sh and mofify as it is on the scripts directory of this repo
    chmod ug+x /usr/local/sbin/monitoring.sh
    crontab -e
        */10 * * * * /usr/local/sbin/monitoring.sh
#
### BONUS
    su - test_user
### 0. FIREWALL BONUS CONFIGURATION
    ufw allow 80
    ufw allow 1883
    ufw allow 5672
    ufw allow 15672
### 1. MARIADB installation and configuration
    sudo dnf install -y mariadb-server wget
    sudo systemctl start mariadb 
    sudo systemctl enable mariadb
    sudo mysql_secure_installation
    Enter current password for root (enter for none): 
        Set root password? [Y/n] n
        Remove anonymous users? [Y/n] Y
        Disallow root login remotely? [Y/n] Y
        Remove test database and access to it? [Y/n] Y
        Reload privilege tables now? [Y/n] Y
    sudo mysql -u root -p
        MariaDB [(none)]> CREATE DATABASE wordpress;
        MariaDB [(none)]> CREATE USER adminuser@localhost IDENTIFIED BY 'password';
        MariaDB [(none)]> SELECT User,Password FROM mysql.user;
        MariaDB [(none)]> GRANT ALL ON wordpress.* TO adminuser@localhost;
        MariaDB [(none)]> FLUSH PRIVILEGES;
        MariaDB [(none)]> exit;
    sudo mysql -u adminuser -p
        MariaDB [(none)]> SHOW DATABASES;
        MariaDB [(none)]> SHOW GRANTS FOR adminuser@localhost;
#
### 2. LIGHTTPD INSTALLATION AND CONFIGURATION
    sudo yum install lighttpd -y
    sudo systemctl start lighttpd
    sudo systemctl enable lighttpd
    vi /etc/lighttpd/lighttpd.conf
        server.use-ipv6 = disable
        server.max-fds = 2048
    sudo setsebool -P httpd_setrlimit on
    sudo systemctl restart lighttpd
#
### 3. WORDPRESS INSTALLATION AND CONFIGURATION
##### https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-on-centos-7
    cd ~
    wget http://wordpress.org/latest.tar.gz
    tar xvzf latest.tar.gz
    sudo yum -y install rsync
    sudo rsync -avP ~/wordpress/ /var/www/html/
    mkdir /var/www/html/wp-content/uploads
    sudo chown -R lighttpd:lighttpd /var/www/html/*
    cd /var/www/html
    cp wp-config-sample.php wp-config.php # modify the file as it is on the configuration directory of this repo
#
### 4. PHP INSTALLATION AND CONFIGURATION (needed php version higher than 5.6.20)
    sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
    sudo yum install -y yum-utils
    sudo yum-config-manager --enable remi-php56
    sudo yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo
    php -v
    > PHP 5.6.40 (cli) (built: Sep 28 2022 10:48:43)
#
### 5. FASTCGI INSTALLATION AND CONFIGURATION
##### https://www.tecmint.com/install-lighttpd-with-php-fpm-mariadb-on-centos/
    sudo yum -y install php-fpm lighttpd-fastcgi
    sudo vi /etc/php-fpm.d/www.conf # set the user and group
    sudo vi /etc/lighttpd.conf
         server_root + "/html"
    sudo vi /etc/php.ini
        cgi.fix_pathinfo=1
    sudo vi /etc/lighttpd/modules.conf
        include "conf.d/fastcgi.conf"
    sudo vi /etc/lighttpd/conf.d/fastcgi.conf
        fastcgi.server += ( ".php" =>
            ((
                "host" => "127.0.0.1",
                "port" => "9000",
                "broken-scriptfilename" => "enable"
            ))
        )
    sudo systemctl start php-fpm.service
    sudo systemctl enable php-fpm.service
    sudo systemctl restart lighttpd
    http://server_ip:80
#
### 6. RABBITMQ INSTALLATION AND CONFIGURATION
##### https://www.vultr.com/docs/how-to-install-rabbitmq-on-centos-7/
    sudo yum -y install epel-release
    cd ~ && wget https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_23.3.1-1~centos~7_amd64.rpm
    sudo yum -y install esl-erlang*.rpm
    wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.19/rabbitmq-server-3.8.19-1.el7.noarch.rpm
    sudo yum -y install rabbitmq-server*.rpm
    sudo systemctl start rabbitmq-server
    sudo systemctl enable rabbitmq-server
    sudo rabbitmq-plugins enable rabbitmq_management
    sudo rabbitmq-plugins enable rabbitmq_mqtt
    sudo rabbitmqctl delete_user guest
    sudo rabbitmqctl add_user admin
    sudo systemcctl restart rabbitmq
    sudo rabbitmqctl set_user_tags admin administrator
    sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
    http://server_ip:15672
#
