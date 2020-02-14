#How to install Packetfence on CentOS 7

Jack Wallen walks you through the process of installing the Packetfence Network Access Control system on CentOS 7.

By Jack Wallen | May 3, 2018, 8:38 AM PST

Eleven years ago, I managed to get Packetfence installed on a Linux machine. I remember it well, because at the time Packetfence was an absolute nightmare to get up and running. Succeeding at that task made me feel like I'd seriously accomplished something. Back then, I was installing on (are you ready for this?) Ubuntu Server 6.04. Since then, Packetfence has halted their support for Ubuntu and now concentrates on only two distributions: CentOS and Debian. I'm going to show you how much easier this powerful Network Access Control system is to install. I'll be demonstrating on CentOS 7, which I'd highly recommend you using as well.

Before we get into the "How?" let's examine the "Why?"

What is [[https://packetfence.org/|Packetfence]]? Simply put, it's a Network Access Control (NAC) solution. In other words, if you want to control what devices are allowed on your network, you should consider a NAC. Packetfence is an open source take on the NAC that includes features like:

 * Captive-portal for registration and remediation
 * Centralized wired and wireless management
 * 802.1X support
 * Layer-2 isolation of problematic devices
 * Integration with the Snort IDS and the Nessus vulnerability scanner

PacketFence can be used to effectively secure networks—from small to very large heterogeneous networks. Best of all, what used to be a major challenge to get up and running has now become quite simple.

And now, let's get to the how.

##Adding the necessary repository

In order to get Packetfence installed, you first must add the necessary repository. To do this, issue the su command and enter the root user password. Once you've successfully authenticated against the root account, add the repository with the command:

<code bash>
rpm -Uvh https://packetfence.org/downloads/PacketFence/RHEL7/x86_64/RPMS/packetfence-release-1.2-5.1.noarch.rpm
</code>

Once that command completes, you're ready to install.

##Installation

Now it's time to install. Before you do this, make sure to upgrade your CentOS 7 platform with the command:

<code bash>
yum upgrade
</code>

Once the server upgrades making sure to reboot if the kernel is upgraded, install Packetfence with the command:

<code bash>
yum install --enablerepo=packetfence packetfence
</code>

The installation will take roughly five or so minutes (give or take, depending upon the speed of your processor). Once the install completes, you'll be greeted with the Complete! message and you're ready to move on.

##Configurator

It's time to fire up your browser and launch the Packetfence Configurator. To do this, point a browser that's on the same network to https://SERVER_IP:1443/configurator. This will land you on the first page of the Configurator (**Figure A**).

###Figure A

{{https://tr1.cbsistatic.com/hub/i/2018/05/03/e3f3e614-8668-4a46-b699-472b7e458bf0/d02838081213970eecfa530ac88e1b18/packetfencea-800x600.jpg|Page one of the Packetfence Configurator.}}

If you find you cannot connect to Packetfence, you might have to flush your iptables with the command sudo iptables -F. That should allow you to make the connection. If that doesn't work, you might also have to temporarily disable SELinux with the command setenforce 0. You can back that disable out with the command setenforce 1.

All you have to do now is walk through the Configurator, setting up Packetfence to perfectly meet the needs of your network. The Configurator does a great job of instructing you at every step. Make sure, at Step 3 (**Figure B**), you have the MySQL root user password, so you can create the pf database.

###Figure B

{{https://tr1.cbsistatic.com/hub/i/2018/05/03/f7c58065-e47e-47d5-8ded-e47eddefa5bf/769bd87ef9ddf20f12d0a62d68204f29/packetfenceb-800x600.jpg|Setting up the pf database.}}

If you find yourself stuck on Step 7 (with the Start Packetfence button not working), go back to the terminal window and issue the command:

<code bash>
cp /usr/local/pf/conf/pf-release /usr/local/pf/conf/currently-at
</code>

That should solve the problem and send you to the main Packetfence window.

Once you've completed this process, you can then begin configuring Packetfence such that you have complete control over who and what can access your network.

##Much simpler installation

Even though Packetfence no longer supports Ubuntu, which is a shame, if you have a CentOS 7 server at the ready or you can spin one up quickly, you can have this powerful NAC system up and running in no time. Thanks to the simpler installation, Packetfence can now be an option for any admin looking for a budget-friendly means of taking control device connection/usage on your network.