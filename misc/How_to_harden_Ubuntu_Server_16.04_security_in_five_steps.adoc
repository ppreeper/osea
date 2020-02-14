= How to harden Ubuntu Server 16.04 security in five steps
By Jack Wallen | February 6, 2017, 1:47 PM PST 

If you're ready to take your Ubuntu Server security to the next level, read these five quick tips.

You have that shiny new Ubuntu 16.04 LTS Server up and running. The installation was far easier than you anticipated, and you're ready to enjoy all the incredible security that comes with Linux.

There's actually more you can do to achieve an adequate level of security for your data. The good news is it's pretty easy to harden your Ubuntu 16.04 Server. See how five quick steps will result in considerable security gains.

== 1: Secure shared memory

Shared memory can be used in an attack against a running service, so it is always best to secure that portion of memory. You can do this by modifying the /etc/fstab file.

First, you must open the file for editing by issuing the command:

[source,bash]
----
sudo nano /etc/fstab
----

Next, add the following line to the bottom of that file:

[source,bash]
----
tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0
----

Save and close the file. In order for the changes to take effect, you must reboot the server.

== 2: Enable ssh login for specific users

You'll probably spend a good amount of time secure shelling into that Ubuntu Server. Because you'll need to enter that server via ssh, you do not want to leave it wide open.

One thing you should do is enable ssh login for specific users. Let's say you want to only allow secure shell entry for the user olivia, from IP address 192.168.1.152. Here's how you would do this.

. Open a terminal window.
. Open the ssh config file for editing with the command sudo nano /etc/ssh/sshd_config.
. At the bottom of the file, add the line AllowUsers olivia@192.168.1.152.
. Save and close the file.
. Restart sshd with the command sudo service ssh restart.

At this point, secure shell will only allow entry by user olivia, from IP address 192.168.1.152. If someone other than olivia attempts to ssh into the server, they will be prompted for a password, but the password will not be accepted (even if it's correct), and entrance will be denied.

You can modify this to fit your needs. Say you want to allow all users on your network to be able to access the server via ssh. You would add the following line:

[source,bash]
----
AllowUsers *@192.168.1.*
----

Restart the ssh server, and you're good to go.

== 3: Add a security login banner

Adding a security login banner might seem like it would have zero effect on your server, but if an unwanted user gains access to your server, and if they see you've taken the time to set up a login banner warning them of consequences, they might think twice about continuing. Yes, it's purely psychological, but it's such an easy step, it shouldn't be overlooked. Here's how to manage this.

Create your new banner by following these steps.

. Open a terminal window.
. Issue the command sudo nano /etc/issue.net.
. Edit the file to add a suitable warning.
. Save and close the file.

Next, we need to disable the banner message from motd. To do this you must open a terminal and issue the command sudo nano /etc/pam.d/sshd. With this file open for editing, comment out the following two lines (adding a # to the beginning of each line):

[source,bash]
----
session optional pam_motd.so motd=/run/motd.dynamic 
​session optional pam_motd.so noupdate
----

Now open the /etc/ssh/sshd_config in your favorite text editor and comment out the line:

[source,bash]
----
Banner /etc/issue.net
----

Save and close that file.

Finally, restart the ssh server with the command:

[source,bash]
----
sudo service ssh restart
----

At this point, anytime someone logs into your server, via ssh, they will see your newly added banner displayed to warn them you are watching.

== 4: Harden the networking layer

There is a very simple way to prevent source routing of incoming packets (and log all malformed IPs) on your Ubuntu Server. Open a terminal window, issue the command sudo nano /etc/sysctl.conf, and uncomment or add the following lines:

[source,bash]
----
= IP Spoofing protection
​net.ipv4.conf.all.rp_filter = 1
​net.ipv4.conf.default.rp_filter = 1
​
​# Ignore ICMP broadcast requests
​net.ipv4.icmp_echo_ignore_broadcasts = 1
​
​# Disable source packet routing
​net.ipv4.conf.all.accept_source_route = 0
​net.ipv6.conf.all.accept_source_route = 0 
​net.ipv4.conf.default.accept_source_route = 0
​net.ipv6.conf.default.accept_source_route = 0
​
​# Ignore send redirects
​net.ipv4.conf.all.send_redirects = 0
​net.ipv4.conf.default.send_redirects = 0
​
​# Block SYN attacks
​net.ipv4.tcp_syncookies = 1
​net.ipv4.tcp_max_syn_backlog = 2048
​net.ipv4.tcp_synack_retries = 2
​net.ipv4.tcp_syn_retries = 5
​
​# Log Martians
​net.ipv4.conf.all.log_martians = 1
​net.ipv4.icmp_ignore_bogus_error_responses = 1
​
​# Ignore ICMP redirects
​net.ipv4.conf.all.accept_redirects = 0
​net.ipv6.conf.all.accept_redirects = 0
​net.ipv4.conf.default.accept_redirects = 0 
​net.ipv6.conf.default.accept_redirects = 0
​
​# Ignore Directed pings
​net.ipv4.icmp_echo_ignore_all = 1
----

Save and close the file, and then restart the service with the command sudo sysctl -p.

== 5: Prevent IP spoofing

This one is quite simple and will go a long way to prevent your server's IP from being spoofed. Open a terminal window and issue the command sudo nano /etc/host.conf. With this file open for editing, it will look like:

[source,bash]
----
= The "order" line is only used by old versions of the C library.
​order hosts,bind
​multi on
----

Change the content of this file to:

[source,bash]
----
= The "order" line is only used by old versions of the C library.
​order bind,hosts
​nospoof on
----

Save and close that file. Viola! No more IP spoofing.

== More ways to secure your server

We have only scratched the surface of hardening your Ubuntu 16.04 Server, but these five tips will provide you with a significant upgrade to your server's security. We'll explore this topic soon and continue the practice of locking down your Ubuntu Server platform.
