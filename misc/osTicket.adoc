https://github.com/osTicket/osTicket/releases/download/v1.10.4/osTicket-v1.10.4.zip


apt update; apt install vim-nox apt-transport-https unzip -y; apt full-upgrade -y

apt install nginx php-common php-cli php-fpm
apt install apache2 php php-cli
apt install php-mysql php-gd php-imap php-xml php-mbstring php-intl php-apcu php-ldap


mkdir -p /opt/osTicket
cd /opt/osTicket
wget -O /opt/osTicket.zip https://github.com/osTicket/osTicket/releases/download/v1.10.4/osTicket-v1.10.4.zip
unzip /opt/osTicket.zip
mv /opt/osTicket/upload/* /var/www/html/.
chown -R www-data:www-data /var/www/html
cd /var/www/html
cp include/ost-sampleconfig.php include/ost-config.php
chown -R www-data:www-data /var/www/html
chmod 0666 include/ost-config.php
<follow install procedures>
chmod 0644 include/ost-config.php
systemctl restart apache2


CREATE DATABASE ost;

CREATE USER 'ost'@'%' IDENTIFIED BY 'Wa0dRmDiPnRESS';

GRANT ALL PRIVILEGES ON ost.* TO 'ost'@'%';

FLUSH PRIVILEGES;


setup sendmail


apt install sendmail mailutils sendmail-bin


