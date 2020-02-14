#How to install RackTables on CentOS 7

This tutorial walks you through installing the open source, data center inventory tool RackTables. Though the installation process is tedious, tracking your inventory will become much easier.

By Jack Wallen | April 24, 2018, 7:53 AM PST 

{{https://tr3.cbsistatic.com/hub/i/r/2016/06/07/d22c04ec-84a5-4141-8662-a4e51465fe1f/resize/770x/32149ce61450a00fc4fe3461726978a2/datacenterhero.jpg?300}}

If you own a data center and a company with a large number of hardware devices, chances are you'll want to use a centralized tool to serve as an asset manager. There are a lot of options available, one of which is open source and free. That's [[https://racktables.org/|RackTables]]. RackTables lets you keep your inventory up to date easily from a web-based interface that is user-friendly, robust, and allows you to document hardware assets, network addresses, space in racks, networks configuration and much more.

I'm going to walk you through the process of installing RackTables on CentOS 7. It's not a terribly easy installation, but once you have it up and running, it'll serve you very well.

##What you'll need

I will assume you already have CentOS 7 up and running. You'll need access to either the root account or an account with sudo rights. For the sake of efficiency, I'm going to assume you can su to the root account to run all of the necessary installation commands. That's it.

Let's install.

##Apache

The first thing you must do is install the Apache web server. Open a terminal window, su to root, and issue the command:

<code>
yum install httpd
</code>

Once that command completes, start and enable Apache with the commands:

<code>
systemctl start httpd.service
systemctl enable httpd.service
</code>

##MariaDB

Next we must install the database. This is taken care of with the following command:

<code>
yum install mariadb-server mariadb
</code>

Start and enable the database with the commands:

<code>
systemctl start mariadb.service
systemctl enable mariadb.service
</code>

Next, create a database password, and secure the database, with the command:

<code>
mysql_secure_installation
</code>

Now we need to create a database and a user. First log into MySQL with the command mysql -u root -p. Once you've entered the password (created during the run of mysql_secure_installation), it is time to create the database with the command:

<code>
create database racktables;
</code>

Grant the necessary privileges with the command:

<code sql>
grant all privileges on racktables.* TO 'root'@'localhost' identified by 'PASSWORD';
</code>

Where PASSWORD is your root user password.

Flush the database privileges with the command:

<code sql>
flush privileges;
</code>

And, finally, exit the database with the command exit.

We need to do the smallest bit of configuration for the database. Issue the command nano etc/my.cnf.d/server.cnf and add the following under the [server] directive:

<code>
character-set-server = utf8
collation-server = utf8_general_ci
skip-character-set-client-handshake
</code>

Finally, restart the database with the command:

<code>
systemctl restart mariadb.service
</code>

##PHP and extensions

This is where it gets a bit tricky. The latest version of RackTables depends on PHP >= to 5.5, but CentOS 7 currently only updates to PHP 5.4. In order to pull this off, we have to first add the epel repository with the command:

<code>
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
</code>

Next we must install the SCL repository with the command:

<code>
yum install centos-release-scl
</code>

Update yum with the command:

<code>
yum update
</code>

Now install PHP and extensions with the command:

<code>
yum install php55 php55-php php55-mysqlnd php55-pdo php55-gd php55-snmp php55-mbstring php55-bcmath php55-ldap
</code>

Restart Apache with the command:

<code>
systemctl restart httpd
</code>

##Create the RackTable user

We now must create an unprivileged user to own all of the PHP files within the Apache documentroot. This is done with the following command:

<code>
useradd -s /sbin/nologin -c "RackTables User" -m -d /home/racktables racktables
</code>

##Download the RackTables installer file

Change into the /tmp directory with the command cd /tmp and download the necessary RackTables installer. As of this writing, the most recent version of RackTables is 21.1. Download that file with the command:

<code>
wget https://nchc.dl.sourceforge.net/project/racktables/RackTables-0.21.1.tar.gz --no-check-certificate
</code>

Extract the contents of that file with the command:

<code>
tar xvzf RackTables-0.21.tar.gz
</code>

Copy the newly created folder into the Apache documentroot with the command:

<code>
cp -rf RackTables-0.21 /var/www/html/racktables
</code>

Now we must change the ownership of the RackTables configuration file with the command:

<code>
chown -R racktables:racktables /var/www/html/racktables
</code>

##Configure Apache

We need to configure Apache so that it is aware of our RackTables installation. Issue the command nano /etc/httpd/conf.d/racktables.conf. Within that new file, add the following:

<code>
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .phps

<Directory /var/www/html/racktables/wwwroot/>
  DirectoryIndex index.php
  Require all granted
</Directory>

Alias /racktables /var/www/html/racktables/wwwroot/
</code>

Save and close that file.

Restart Apache with the command:

<code>
systemctl restart httpd
</code>

##Install RackTables

Before we attempt to install, there are a few more things to take care of. First, a secret.php file must be created and secured. This is done with the following commands:

<code>
touch /var/www/html/racktables/wwwroot/inc/secret.php
chmod a=rw /var/www/html/racktables/wwwroot/inc/secret.php
</code>

Finally, point your browser to http://SERVER_IP/racktables/?module=installer (Where SERVER_IP is the IP address of the server). Click the proceed button and you should see everything listed as either PASSED or NOT PRESENT (**Figure A**). If there are any listings in red, you'll have to go back and resolve whatever lingering issues you have. Once everything is either green or yellow, click proceed.

###Figure A

{{https://tr1.cbsistatic.com/hub/i/2018/04/24/c0384afd-904e-4112-9a4d-11537750e589/3761933c846769ba0c4d674d14bae723/racktablesa.jpg|All set to proceed with the installation.}}

In the next few screens, you'll be given various instructions on what to do to handle any lingering issues. For example, you might also be asked to temporarily disable SELinux (for the installation). That is handled with the command setenforce 0.Remember, once you've completed the installation, go back and enable SELinux with the command setenforce 1.

Eventually you'll land on the database configuration screen (**Figure B**). All you need to do is enter the database name, username, and password.

###Figure B

{{https://tr4.cbsistatic.com/hub/i/2018/04/24/b4e5e503-4c30-4ef7-81ba-f44b4b183a1d/b70a219648c20bd8651d2eaf340a06bc/racktablesb.jpg|Configuring the RackTables database.}}

Click Retry once you've set the configuration and you will then be presented with a warning that your secret.php file isn't owned by the necessary group. The command to resolve the issue is:

<code>
chown apache:nogroup secret.php; chmod 440 secret.php
</code>

Finally, you'll be asked to set a password for the admin user. This will be the login account for your RackTables installation. Once you've created a password, you'll land on the RackTables main page, where you can start adding objects to the database.

That's it. You're ready to rock.

##Now the fun begins

With the hard part over, you are now ready to start keeping track of your ever-growing inventory of servers, routers, switches, desktops, printers, etc. Don't fall behind on that inventory!