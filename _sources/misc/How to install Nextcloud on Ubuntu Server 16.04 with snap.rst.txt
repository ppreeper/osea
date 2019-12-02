= How to install Nextcloud on Ubuntu Server 16.04 with snap
By Jack Wallen | December 13, 2017, 8:00 AM PST 

If the installation process has been preventing you from giving Nextcloud a try, Jack Wallen shows you how to get it up and running with a single command.

You've heard me discuss Nextcloud plenty of times, and with good reason. Nextcloud is a fantastic in-house cloud server that is ready to serve small and large businesses alike. It's flexible, powerful, secure, and incredibly easy to manage.

Through the normal process, Nextcloud is fairly easy to install—if you have a solid understanding of the Linux command line. But what if you're new to Linux and aren't as up to speed as you need to be to pull off such an installation? Should that be the case, you turn to snap packages. Thanks to the universal package format, server software like Nextcloud is so easy to install, anyone can pull it off as long as they know how to type a single command.

But why install with snap? Outside of the incredible simplicity, with snap packages you are running the Nextcloud server in a sandbox, so it will enjoy a bit more security than it might otherwise. Also, upgrading Nextcloud, via snap, is incredibly simple as long as the latest version of the software has been converted to a snap package. Those two reasons alone should be enough to pique your interests.

It should be noted that installing Nextcloud via snap will install, along with its own web and MySQL server, on port 80. If your machine has another server on port 80, you'd be best served installing Nextcloud via the manual method, using virtual hosts, or installing Nextcloud as a virtual machine with its own IP address.

I'm going to walk you through the process of installing Nextcloud, via snap, on the Ubuntu Server 16.04 platform. To succeed with this installation, you'll need a user account with sudo access.

Let's install.

== Installation

Before we install, I always find it good to upgrade or update the platform. To accomplish this, open a terminal window, or log into your headless server via ssh and issue the following two commands:

[source,bash]
----
sudo apt update
sudo apt upgrade
----

When the above commands complete, you're ready to move on. Do note, if the kernel upgrades, you'll need to reboot the system. Because of this, you might want to plan this process at a time when a reboot won't cause problems.

With the upgrades taken care of install Nextcloud, via snap, with the following command:

[source,bash]
----
sudo snap install nextcloud
----

Because we're using Ubuntu 16.04, snap will be installed out of the box, so there's no need to install snapd.

When the installation of the snap package completes, you'll need to find out the server IP address. You can achieve that with the command ip a (*Figure A*).

=== Figure A

image:https://tr2.cbsistatic.com/hub/i/2017/12/13/a5ab4ebd-25c2-4241-8341-0790e6cbf432/581fa71ccbb3efff9d19f377b5f411b4/nextsnapa.jpg[Finding your server IP address.]

With the IP address "in hand," open a browser and point it to http://SERVER_IP. Where SERVER_IP is the actual IP address of the server. You will be greeted by the Nextcloud admin account creation screen (*Figure B*).

=== Figure B

image:https://tr4.cbsistatic.com/hub/i/2017/12/13/8707eb6b-aedb-4a6f-b19e-925100f9575b/0d2bedb825b11836f6499c8806edc1fd/nextsnapb.jpg[The admin creation screen.]

Type a new username and password for the admin user and click Finish setup. You will find yourself on the Nextcloud home page where you can start creating users, adding apps, and making your new in-house cloud server function exactly as you need.

Wasn't that simple?

== No reason not to try

With the help of Ubuntu and snap packages, you now have zero reason to not give Nextcloud a try. Set this up on a virtual machine and you have a perfect test environment. Trust me, your company will thank you for adding Nextcloud into the mix
