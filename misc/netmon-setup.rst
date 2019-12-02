lxc stop lxred01:netmon ; lxc delete lxred01:netmon ; lxc launch lxred01:ubuntu lxred01:netmon ; lxc file push /usr/local/bin/update lxred01:netmon/usr/local/bin/update ; lxc exec lxred01:netmon chmod +x /usr/local/bin/update ; lxc exec lxred01:netmon /usr/local/bin/update ; lxc restart lxred01:netmon
lxc exec lxred01:netmon mkdir /root/go ;
lxc exec lxred01:netmon mkdir /home/ubuntu/go ;
lxc file push ~/.ssh/id_ecdsa.pub lxred01:netmon/root/.ssh/authorized_keys ;
lxc file push ~/.ssh/id_ecdsa.pub lxred01:netmon/home/ubuntu/.ssh/authorized_keys
lxc file push ~/workspace/check_toner/check_toner.go lxred01:netmon/opt/check_toner.go

lxc exec lxred01:netmon bash 
echo "export GOPATH=\$HOME/go" >> /etc/bash.bashrc

wget -O - http://packages.icinga.org/icinga.key | apt-key add -
add-apt-repository 'deb http://packages.icinga.org/ubuntu icinga-xenial main'
update

apt install icinga2 icinga2-ido-pgsql vim-icinga2 vim-nox vim-addon-manager monitoring-plugins monitoring-plugins-standard golang
vim-addon-manager -w install icinga2

sed -e "s/user\ =\ .*/user\ =\ \"icinga\",/" -i /etc/icinga2/features-available/ido-pgsql.conf
sed -e "s/password\ =\ .*/password\ =\ \"icinga\",/" -i /etc/icinga2/features-available/ido-pgsql.conf
sed -e "s/host\ =\ .*/host\ =\ \"pgdb.arthomson.com\",/" -i /etc/icinga2/features-available/ido-pgsql.conf
sed -e "s/database\ =\ .*/database\ =\ \"icinga\"/" -i /etc/icinga2/features-available/ido-pgsql.conf

icinga2 feature enable ido-pgsql
icinga2 feature enable command
systemctl restart icinga2

apt install icingaweb2 php-pgsql
sed -e "s/;date.timezone.*/date.timezone\ =\ \'America\/Edmonton\'/" -i /etc/php/7.0/apache2/php.ini
systemctl restart apache2

#to create token
icingacli setup token create

#to show created token
icingacli setup token show

http://<server>/icingaweb2/setup


database


cd /opt
go get github.com/soniah/gosnmp
go build check_toner.go
cp check_toner /usr/lib/nagios/plugins/.

