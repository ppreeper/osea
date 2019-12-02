= How to block SSH access for specific IP addresses
By Jack Wallen | February 1, 2018, 11:00 AM PST 

Take every precaution necessary to make sure secure shell is protected. Jack Wallen shows you how to easily block specific IP addresses from gaining access to your Linux server.

If you work with Linux, chances are secure shell (SSH) is a part of your daily routine. In fact, remotely administering a Linux server can be a challenge without this often vaunted tool. And although SSH, by design, is quite secure, it's not perfect. If you have an SSH daemon running on a server, especially one that is accessible to the outside world, chances are it's getting hit by regular attacks. Eventually one of those attacks will brute force its way into your server and have at your data. To that end, you need to take every precaution necessary to make sure SSH is protected.

Say, for instance, while checking your log files, you discover a particular, unwanted, IP address has attempted to log into your server, via SSH. Although they may have failed this time, that might not stop them from trying a second, third, or fourth time to brute force their way in. What do you do? Since you're using Linux, you already have all the tools necessary to take care of this.

I'm going to show you two different ways you can block a specific IP address or range of addresses using built-in tools. The two tools in question are Uncomplicated Firewall (UFW) and TCP Wrappers. I'll be demonstrating on Ubuntu Server 16.04, but the process is the same on most distributions.

NOTE: If your distribution doesn't make use of UFW, you'll need to adjust this process, based on the firewall used.

== Uncomplicated Firewall

Our first method is the most complicated—simply because it makes use of iptables, by way of UFW. Let's say the offending IP address you want to block is 192.168.1.162. We're going to block this using UFW, with a single command:

`sudo ufw deny from 192.168.1.162 port 22`

Check to see if UWF is running and enabled with the command `sudo uwf status`. If you see that UFW is active and the new rule listed (*Figure A*), you're good to go.

=== Figure A

image:https://tr3.cbsistatic.com/hub/i/2018/02/01/4d2ae634-179e-44db-8250-84e424b6d270/ea1c92ad498f10c76fdd98bcf6e34a1e/sshdenya.jpg[SSH is officially denied for IP address 192.168.1.162.]

If UFW is listed as inactive, issue the command sudo ufw enable and it will start and load your newly written rule to block the offending IP address.

To delete that rule, you would issue the command:

`sudo ufw delete 1`

Since our SSH blocking rule is the only rule, its associated number will be 1. If you have more than one rule, you'll have to make sure to delete the rule according to its correct number.

If you need to block a range of addresses, the command would be:

`sudo ufw deny from 192.168.1.162/24 port 22`

You can block whatever range you need using CIDR Notation.

== TCP Wrappers

Now let's work with the simpler method of blocking an IP address from gaining access to your server via ssh. That method is TCP Wrappers. Again, this is built into Linux, so there's nothing to install.

To block the same IP address as we did with UFW, open up the hosts.deny file with the command `sudo nano /etc/hosts.deny`. In that file, add the following line:

`sshd 192.168.1.162`

Save and close the file.

Restart the SSH daemon with the command:

`sudo systemctl restart sshd`

At this point, when the offending IP address attempts to login, they'll see the error, shown in *Figure B*.

=== Figure B

image:https://tr4.cbsistatic.com/hub/i/2018/02/01/11525d54-8b9e-4019-ab24-43d73a004d33/123d1ce4e382fbbe322ada27ad23d8e2/sshdenyb.jpg[TCP Wrappers doing its thing.]

If you want to block a range of addresses, the entry would look like:

`sshd 192.168.1.*`

If you want to block certain IP addresses, they could be listed as such:

`sshd 192.168.1.101, 192.168.1.102, 192.168.1.103`

== Two simple methods

There you have it. Two very simple ways of blocking specific IP addresses from gaining access to SSH on your Linux server. Don't be fooled, there are better yet more complicated methods of doing this, but when you want something fast and simple, you can't go wrong with a quick UFW rule or a TCP Wrapper addition.
