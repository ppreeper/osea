lxc stop lxd01:wordp
lxc delete lxd01:wordp

lxc launch ubuntu: lxd01:wordp
lxc exec lxd01:wordp bash

apt install libapache2-mod-php mariadb-server php-mysql
mysql_secure_installation
wordpress--

mysql -u root -p
CREATE DATABASE wp_database;
GRANT ALL PRIVILEGES ON wp_database.* TO "wp_dbuser"@"localhost" IDENTIFIED BY "wp_dbpassword";
FLUSH PRIVILEGES;
EXIT

cd /opt
wget https://wordpress.org/latest.tar.gz
tar zxvf latest.tar.gz

rm /var/www/html/index.html 
cp -R /opt/wordpress/* /var/www/html/.

cd /var/www/html/
cat wp-config-sample.php | sed "s/database_name_here/wp_database/" | sed "s/username_here/wp_dbuser/" | sed "s/password_here/wp_dbpassword/" > wp-config.php

systemctl restart apache2.service

