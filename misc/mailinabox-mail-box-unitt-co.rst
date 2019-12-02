root@mail2:~# curl -s https://mailinabox.email/setup.sh | sudo bash
sudo: unable to resolve host mail2
Installing git . . .
Selecting previously unselected package liberror-perl.
(Reading database ... 25096 files and directories currently installed.)
Preparing to unpack .../liberror-perl_0.17-1.1_all.deb ...
Unpacking liberror-perl (0.17-1.1) ...
Selecting previously unselected package git-man.
Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.7_all.deb ...
Unpacking git-man (1:1.9.1-1ubuntu0.7) ...
Selecting previously unselected package git.
Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.7_amd64.deb ...
Unpacking git (1:1.9.1-1ubuntu0.7) ...
Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
Setting up liberror-perl (0.17-1.1) ...
Setting up git-man (1:1.9.1-1ubuntu0.7) ...
Setting up git (1:1.9.1-1ubuntu0.7) ...

Downloading Mail-in-a-Box v0.26b. . .

Installing packages needed for setup...

┌───────────────────────────Mail-in-a-Box Installation──────────────────────────────┐
│ Hello and thanks for deploying a Mail-in-a-Box!                                   │  
│                                                                                   │  
│ I'm going to ask you a few questions.                                             │  
│                                                                                   │  
│ To change your answers later, just run 'sudo mailinabox' from the command line.   │  
│                                                                                   │  
│ NOTE: You should only install this on a brand new Ubuntu installation 100%        │  
│ dedicated to Mail-in-a-Box. Mail-in-a-Box will, for example, remove apache2.      │  
├───────────────────────────────────────────────────────────────────────────────────┤  
│                                     <  OK  >                                      │  
└───────────────────────────────────────────────────────────────────────────────────┘  

┌─────────────────────────────────Your Email Address───────────────────────────────────┐
│ What email address are you setting this box up to manage?                            │  
│                                                                                      │  
│ The part after the @-sign must be a domain name or subdomain that you control. You   │  
│ can add other email addresses to this box later (including email addresses on other  │  
│ domain names or subdomains you control).                                             │  
│                                                                                      │  
│ We've guessed an email address. Backspace it and type in what you really want.       │  
│                                                                                      │  
│ Email Address:                                                                       │  
│ ┌──────────────────────────────────────────────────────────────────────────────────┐ │  
│ │me@unitt.co                                                                       │ │  
│ └──────────────────────────────────────────────────────────────────────────────────┘ │  
├──────────────────────────────────────────────────────────────────────────────────────┤  
│                           <  OK  >              <Cancel>                             │  
└──────────────────────────────────────────────────────────────────────────────────────┘  

┌──────────────────────────────────────Hostname────────────────────────────────────────┐
│ This box needs a name, called a 'hostname'. The name will form a part of the box's   │  
│ web address.                                                                         │  
│                                                                                      │  
│ We recommend that the name be a subdomain of the domain in your email address, so    │  
│ we're suggesting box.unitt.co.                                                       │  
│                                                                                      │  
│ You can change it, but we recommend you don't.                                       │  
│                                                                                      │  
│ Hostname:                                                                            │  
│ ┌──────────────────────────────────────────────────────────────────────────────────┐ │  
│ │box.unitt.co                                                                      │ │  
│ └──────────────────────────────────────────────────────────────────────────────────┘ │  
├──────────────────────────────────────────────────────────────────────────────────────┤  
│                           <  OK  >              <Cancel>                             │  
└──────────────────────────────────────────────────────────────────────────────────────┘  
 
Primary Hostname: box.unitt.co
Public IP Address: 64.141.21.138
Private IP Address: 10.0.100.186
Private IPv6 Address: fe80::216:3eff:fe58:1426%eth0
Mail-in-a-Box Version:  v0.26b

Updating system packages...
Installing system packages...

Current default time zone: 'America/Edmonton'
Local time is now:      Mon Feb  5 11:23:00 MST 2018.
Universal Time is now:  Mon Feb  5 18:23:00 UTC 2018.

Initializing system random number generator...
Creating SSH key for backup…
Firewall is active and enabled on system startup
Creating initial SSL certificate and perfect forward secrecy Diffie-Hellman parameters...
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time
+..........*
Installing nsd (DNS server)...
Generating DNSSEC signing keys...
Installing Postfix (SMTP server)...
Installing Dovecot (IMAP server)...
Creating new user database: /home/user-data/mail/users.sqlite
Installing OpenDKIM/OpenDMARC...
Installing SpamAssassin...
Installing Nginx (web server)...
Installing Roundcube (webmail)...
Installing Nextcloud (contacts/calendar)...

Upgrading to Nextcloud version 12.0.3

creating sqlite db
Nextcloud is already latest version
Installing Z-Push (Exchange/ActiveSync server)...
Installing Mail-in-a-Box system management daemon...
Running virtualenv with interpreter /usr/bin/python3
Using base prefix '/usr'
New python executable in /usr/local/lib/mailinabox/env/bin/python3
Also creating executable in /usr/local/lib/mailinabox/env/bin/python
Installing setuptools, pip...done.
Installing Munin (system monitoring)...
updated DNS: box.unitt.co
web updated
No TLS certificates could be provisoned at this time:

box.unitt.co: Domain control validation cannot be performed for this domain because DNS points the domain to another machine (A 69.64.147.242).
www.box.unitt.co: Domain control validation cannot be performed for this domain because DNS points the domain to another machine (A 69.64.147.242).

Okay. I'm about to set up me@unitt.co for you. This account will also
have access to the box's control panel.
password: 
 (again): 
mail user added
updated DNS: unitt.co
web updated


-----------------------------------------------

Your Mail-in-a-Box is running.

Please log in to the control panel for further instructions at:

https://64.141.21.138/admin

You will be alerted that the website has an invalid certificate. Check that
the certificate fingerprint matches:

4F:1B:9F:2F:A5:68:E2:CC:51:23:38:03:26:46:4A:17:10:8D:5B:D3:D1:C8:66:D0:68:78:CD:03:EE:9A:3B:92

Then you can confirm the security exception and continue.

