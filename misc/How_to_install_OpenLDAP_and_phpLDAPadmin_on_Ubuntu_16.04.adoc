= How to install OpenLDAP and phpLDAPadmin on Ubuntu 16.04
By Jack Wallen | December 21, 2017, 4:00 AM PST 

If you're looking to use OpenLDAP for your organization, Jack Wallen shows you how to easy install it and the web-based phpLDAPadmin tool.

OpenLDAP is an open source directory server that can be used for a number of cases like storing organization information and to serve as a centralized repository of user accounts. One of the best tools for administering OpenLDAP is the phpLDAPadmin web-based GUI. I am going to walk you through the process of installing both of these tools to make your LDAP administration considerably easier.

I'll be demonstrating these steps on Ubuntu Server 16.04. The installation of both tools will be done through the command line, so prepare to type.

With that said, let's install.

== Installing OpenLDAP

The first thing that must be installed is OpenLDAP. Before we do this, let's make sure the server up to date with the commands:

[source,bash]
----
sudo apt update
sudo apt upgrade
----

Do note: If the server's kernel upgrades you'll need to reboot. Because of this, you might want to consider running the upgrade command when a server reboot is possible.

When the upgrade completes, you can then install OpenLDAP with the command:

[source,bash]
----
sudo apt install slapd ldap-utils
----

The above command will pick up the necessary dependencies. During the installation, you will be prompted to create a password for the LDAP admin user (*Figure A*). Type and confirm that password.

=== Figure A

image:https://tr2.cbsistatic.com/hub/i/2017/11/30/84bf8d34-6961-4051-a758-3c0a8597c7b3/f7e1047c8926c7df2f950e122db476fe/ldapa.jpg[Creating an LDAP admin password.]

When the installation completes, you'll need to configure LDAP. To do this, issue the command:

[source,bash]
----
sudo dpkg-reconfigure slapd
----

The above command will open an ncurses window where you'll need to answer the following questions:

* Omit OpenLDAP server configuration—answer No
* DNS domain name—enter your correct A record for your domain name (or a subdomain)
* Organization Name—enter the name of your organization (such as company or division)
* Administrator password—enter the same password you used during the installation
* Database backend—select MDB
* Remove database—select No
* Move old database—select Yes 

Now we need to configure the ldap.conf file. Issue the command `sudo nano /etc/ldap/ldap.conf`. In this file you need to uncomment out the BASE line by removing the # character and modify it to reflect your LDAP configuration. The configuration will look like:

[source,bash]
----
BASE dc=DOMAIN, dc=COM
----

Where DOMAIN and COM are your domain. If you're using a subdomain, that line would look like:

[source,bash]
----
BASE dc=SUBDOMAIN, dc=DOMAIN, cd=COM
----

Where SUBDOMAIN is the subdomain and DOMAIN and COM are your domain name.

Save and close that file.

Restart slapd with the command `sudo systemctl restart slapd`.

Before we move on, the configuration should be tested. Issue the command ldapsearch -x and you should see your configuration information displayed. You are ready to install phpLDAPadmin.

== Installing phpLDAPadmin

This handy tool can be installed with a single command. If your server doesn't already have Apache installed, the command will pick it up as a dependency. The command to install phpLDAPadmin is:

[source,bash]
----
sudo apt install phpldapadmin
----

Once the installation is complete, there are a few configuration options that must be taken care of. To do this, open the phpldapadmin config file with the command `sudo nano /etc/phpldapadmin/config.php`. The following changes must be made.

First we need to disable template warnings. Locate the line:

[source,bash]
----
// $config->custom->appearance['hide_template_warning'] = false;
----

Uncomment it out (by removing the // characters) and change it to:

[source,bash]
----
$config->custom->appearance['hide_template_warning'] = true;
----

Next we need to allow phpLDAPadmin to automatically detect the base DN of your OpenLDAP server and disable anonymous login. Locate the line:

[source,bash]
----
$servers->setValue('server','base',array('dc=example,dc=com'));
----

Change the above to:

[source,bash]
----
$servers->setValue('server','base',array());
----

Locate the line:

[source,bash]
----
// $servers->setValue('login','anon_bind',true);
----

Uncomment out the above line (by removing the // characters) and then change it to:

[source,bash]
----
$servers->setValue('login','anon_bind',false);
----

Save and close that file. You are now ready to access your newly installed web admin tool by pointing a browser to http://SERVER_IP/phpldapadmin. You will then log in with the following:

[source,bash]
----
Login DN-cn=admin,dc=DOMAIN,dc=COM
----

Where DOMAIN and COM combine to make the domain name you configured for LDAP. Use the password you created during LDAP configuration. Click Authenticate and you'll find yourself in the LDAP administration window for phpLDAPadmin ready to work.

LDAP has never been so easy.

== Keep it going

You can now start to add new entries to your LDAP server. Click Create new entry here and keep the LDAP fun going!
