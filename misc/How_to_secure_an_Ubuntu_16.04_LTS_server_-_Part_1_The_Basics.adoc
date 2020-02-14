= How to secure an Ubuntu 16.04 LTS server - Part 1 The Basics
Submitted by The Fan Club on Mon, 2016-03-28 13:50

This guide is based on various community forum posts and webpages. Special thanks to all. All comments and improvements are very welcome as this is purely a personal experimental project at this point and must be considered a work in progress. This guide is intended as a relatively easy step by step guide to:

Harden the security on an Ubuntu 16.04 LTS server by installing and configuring the following:

. Install and configure *Firewall* - ufw
. *Secure shared memory* - fstab 
. *SSH* - Key based login, disable root login and change port 
. Apache *SSL* - Disable SSL v3 support
. *Protect su* by limiting access only to admin group 
. Harden network with *sysctl* settings 
. Disable Open *DNS* Recursion and Remove *Version* Info  - Bind9 DNS 
. Prevent *IP Spoofing*
. Harden *PHP* for security 
. Restrict *Apache* Information Leakage
. Install and configure Apache application firewall - *ModSecurity*
. Protect from DDOS (Denial of Service) attacks with *ModEvasive*
. Scan logs and ban suspicious hosts - *DenyHosts* and *Fail2Ban*
. Intrusion Detection - *PSAD*
. Check for RootKits - *RKHunter* and *CHKRootKit*
. Scan open Ports - *Nmap*
. Analyse system LOG files - *LogWatch*
. *Apparmor* -  Application Armor
. Audit your system security - *Tiger* and *Tripwire*

Requirements:

* Ubuntu 16.04 LTS or later server with a standard LAMP stack installed.

== 1. Firewall - UFW

A good place to start is to install a Firewall. 

UFW - Uncomplicated Firewall is a basic firewall that works very well and easy to configure with its Firewall configuration tool - gufw, or use  Shorewall, fwbuilder, or Firestarter.

Use Firestarter GUI to configure your firewall or refer to the Ubuntu Server Guide,  UFW manual pages or the Ubuntu UFW community documentation.

Install UFW and enable, open a terminal window and enter :

`sudo apt-get install ufw`

Allow SSH and Http services.

[source,bash]
----
sudo ufw allow ssh
sudo ufw allow http
----

Enable the firewall.

`sudo ufw enable`

Check the status of the firewall.

`sudo ufw status verbose`

== 2. Secure shared memory.

Shared memory can be used in an attack against a running service. Modify /etc/fstab to make it more secure.

Open a Terminal Window and enter the following :

`sudo vi /etc/fstab`

Add the following line and save. You will need to reboot for this setting to take effect :

Note : This only is works in Ubuntu 12.10 or later - For earlier Ubuntu versions replace /run/shm with /dev/shm 

Save and Reboot when done

`tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0`

== 3. SSH Hardening - key based login, disable root login and change port.

The best way to secure SSH is to use public/private key based login. See SSH/OpenSSH/Keys

If you have to use password authentication, the easiest way to secure SSH is to disable root login and change the SSH port to something different than the standard port 22. 

Before disabling the root login create a new SSH user and make sure the user belongs to the admin group (see step 4. below regarding the admin group).

if you change the SSH port keep the port number below 1024 as these are priviledged ports that can only be opened by root or processes running as root. 

If you change the SSH port also open the new port you have chosen on the firewall and close port 22.

Open a Terminal Window and enter :

[source,bash]
----
sudo vi /etc/ssh/sshd_config
----

Change or add the following and save.

[source,bash]
----
Port <ENTER YOUR PORT>
Protocol 2
PermitRootLogin no
DebianBanner no
----

Restart SSH server, open a Terminal Window and enter :

[source,bash]
----
sudo service ssh restart
----

== 4. Apache SSL Hardening - disable SSL v2/v3 support.

The SSL v2/v3 protocol has been proven to be insecure. 

We will disable Apache support for the protocol and force the use of the newer protocols. 

Open a Terminal Window and enter :

[source,bash]
----
sudo vi /etc/apache2/mods-available/ssl.conf
----

Change this line from :

[source,bash]
----
SSLProtocol all -SSLv3
----

To the following and save.

[source,bash]
----
SSLProtocol all -SSLv2 -SSLv3
----

Restart the Apache server, open a Terminal Window and enter :

[source,bash]
----
sudo service apache2 restart
----

== 5. Protect su by limiting access only to admin group.

To limit the use of su by admin users only we need to create an admin group, then add users and limit the use of su to the admin group.

Add a admin group to the system and add your own admin username to the group by replacing <YOUR ADMIN USERNAME> below with your admin username.

Open a terminal window and enter:

[source,bash]
----
sudo groupadd admin
sudo usermod -a -G admin <YOUR ADMIN USERNAME>
sudo dpkg-statoverride --update --add root admin 4750 /bin/su
----

== 6. Harden network with sysctl settings.

The /etc/sysctl.conf file contain all the sysctl settings.

Prevent source routing of incoming packets and log malformed IP's enter the following in a terminal window:

[source,bash]
----
sudo vi /etc/sysctl.conf
----

Edit the /etc/sysctl.conf file and un-comment or add the following lines :

[source,bash]
----
= IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

= Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

= Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0 
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

= Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

= Block SYN attacks
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

= Log Martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

= Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0 
net.ipv6.conf.default.accept_redirects = 0

= Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1
----

To reload sysctl with the latest changes, enter:

[source,bash]
----
sudo sysctl -p
----

== 7. Disable Open DNS Recursion and Remove Version Info  - BIND DNS Server.

Open a Terminal and enter the following :

[source,bash]
----
sudo vi /etc/bind/named.conf.options
----

Add the following to the Options section :

[source,bash]
----
recursion no;
version "Not Disclosed";
----

Restart BIND DNS server. Open a Terminal and enter the following :

[source,bash]
----
sudo service bind9 restart
----

== 8. Prevent IP Spoofing.

Open a Terminal and enter the following :

[source,bash]
----
sudo vi /etc/host.conf
----

Add or edit the following lines :

[source,bash]
----
order bind,hosts
nospoof on
----

== 9. Harden PHP for security.

Edit the php.ini file :

[source,bash]
----
sudo vi /etc/php5/apache2/php.ini
----

Add or edit the following lines an save :

[source,bash]
----
disable_functions = exec,system,shell_exec,passthru
register_globals = Off
expose_php = Off
display_errors = Off
track_errors = Off
html_errors = Off
magic_quotes_gpc = Off
mail.add_x_header = Off
session.name = NEWSESSID
----

Restart Apache server. Open a Terminal and enter the following :

[source,bash]
----
sudo service apache2 restart
----

== 10. Restrict Apache Information Leakage.

Edit the Apache2 configuration security file :

[source,bash]
----
sudo vi /etc/apache2/conf-available/security.conf
----

Add or edit the following lines and save :

[source,bash]
----
ServerTokens Prod
ServerSignature Off
TraceEnable Off
Header unset ETag
Header always unset X-Powered-By
FileETag None
----

Restart Apache server. Open a Terminal and enter the following :

[source,bash]
----
sudo service apache2 restart
----

== 11. Web Application Firewall - ModSecurity.

See : How to install apache2 mod_security and mod_evasive on Ubuntu 12.04 LTS server

== 12. Protect from DDOS (Denial of Service) attacks - ModEvasive

See : How to install apache2 mod_security and mod_evasive on Ubuntu 12.04 LTS server

== 13. Scan logs and ban suspicious hosts - DenyHosts and Fail2Ban.

link:http://denyhosts.sourceforge.net/[DenyHosts] is a python program that automatically blocks SSH attacks by adding entries to /etc/hosts.deny. DenyHosts will also inform Linux administrators about offending hosts, attacked users and suspicious logins.

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install denyhosts
----

After installation edit the configuration file /etc/denyhosts.conf  and change the email, and other settings as required.

To edit the admin email settings open a terminal window and enter:

[source,bash]
----
sudo vi /etc/denyhosts.conf
----

Change the following values as required on your server :

[source,bash]
----
ADMIN_EMAIL = root@localhost
SMTP_HOST = localhost
SMTP_PORT = 25
#SMTP_USERNAME=foo
#SMTP_PASSWORD=bar
SMTP_FROM = DenyHosts nobody@localhost
#SYSLOG_REPORT=YES 
[source,bash]
----

Fail2ban is more advanced than DenyHosts as it extends the log monitoring to other services including SSH, Apache, Courier, FTP, and more.

Fail2ban scans log files and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc.

Generally Fail2Ban then used to update firewall rules to reject the IP addresses for a specified amount of time, although any arbitrary other action could also be configured.

Out of the box Fail2Ban comes with filters for various services (apache, courier, ftp, ssh, etc).

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install fail2ban
----

After installation edit the configuration file /etc/fail2ban/jail.local  and create the filter rules as required.

To edit the settings open a terminal window and enter:

[source,bash]
----
sudo vi /etc/fail2ban/jail.conf
----

Activate all the services you would like fail2ban to monitor by changing enabled = false to enabled = true

For example if you would like to enable the SSH monitoring and banning jail, find the line below and change enabled from false to true. Thats it.

[source,bash]
----
[sshd]

enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
----

If you have selected a non-standard SSH port in step 3 then you need to change the port setting in fail2ban from ssh which by default is port 22, to your new port number, for example if you have chosen 1234 then port = 1234

[source,bash]
----
[sshd]

enabled  = true
port     = <ENTER YOUR SSH PORT NUMBER HERE>
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
----

If you would like to receive emails from Fail2Ban if hosts are banned change the following line to your email address.

[source,bash]
----
destemail = root@localhost
----

and change the following line from :

[source,bash]
----
action = %(action_)s
----

to:

[source,bash]
----
action = %(action_mwl)s
----

You can also create rule filters for the various services that you would like fail2ban to monitor that is not supplied by default.

[source,bash]
----
sudo vi /etc/fail2ban/jail.local
----

Good instructions on how to configure fail2ban and create the various filters can be found on HowtoForge - click here for an example

When done with the configuration of Fail2Ban restart the service with :

[source,bash]
----
sudo service fail2ban restart
----

You can also check the status with.

[source,bash]
----
sudo fail2ban-client status
----

== 14. Intrusion Detection - PSAD.

Cipherdyne PSAD is a collection of three lightweight system daemons that run on Linux machines and analyze iptables log messages to detect port scans and other suspicious traffic.

To install the latest version from the source files follow these instruction : How to install PSAD Intrusion Detection on Ubuntu 12.04 LTS server

OR install the older version from the Ubuntu software repositories, open a Terminal and enter the following :

sudo apt-get install psad

Then for basic configuration see How to install PSAD Intrusion Detection on Ubuntu 12.04 LTS server and follow from step 2:

== 15. Check for rootkits - RKHunter and CHKRootKit.

Both RKHunter and CHKRootkit basically do the same thing - check your system for rootkits. No harm in using both.

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install rkhunter chkrootkit
----

To run chkrootkit open a terminal window and enter :

[source,bash]
----
sudo chkrootkit
----

To update and run RKHunter. Open a Terminal and enter the following :

[source,bash]
----
sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check
----

== 16. Scan open ports - Nmap.

Nmap ("Network Mapper") is a free and open source utility for network discovery and security auditing.

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install nmap
----

Scan your system for open ports with :

[source,bash]
----
nmap -v -sT localhost
----

SYN scanning with the following :

[source,bash]
----
sudo nmap -v -sS localhost
----

== 17. Analyse system LOG files - LogWatch.

Logwatch is a customizable log analysis system. Logwatch parses through your system's logs and creates a report analyzing areas that you specify. Logwatch is easy to use and will work right out of the package on most systems.

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install logwatch libdate-manip-perl
----

To view logwatch output use less :

[source,bash]
----
sudo logwatch | less
----

To email a logwatch report for the past 7 days to an email address, enter the following and replace mail@domain.com with the required email. :

[source,bash]
----
sudo logwatch --mailto mail@domain.com --output mail --format html --range 'between -7 days and today' 
----

== 18. Apparmor - Application Armor.

More information can be found here. Ubuntu Server Guide - Apparmor

It is installed by default since Ubuntu 7.04. 

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install apparmor apparmor-profiles
----

Check to see if things are running :

[source,bash]
----
sudo apparmor_status
----

== 19. Audit your system security - Tiger and Tripwire.

Tiger is a security tool that can be use both as a security audit and intrusion detection system.

Tripwire is a host-based intrusion detection system (HIDS) that checks file and folder integrity. 

Open a Terminal and enter the following :

[source,bash]
----
sudo apt-get install tiger tripwire
----

To setup Tripwire good installation guides can be found on Digital Ocean here and on Unixmen here

To run tiger enter :

sudo tiger

All Tiger output can be found in the /var/log/tiger

To view the tiger security reports, open a Terminal and enter the following :

[source,bash]
----
sudo less /var/log/tiger/security.report.*
----

