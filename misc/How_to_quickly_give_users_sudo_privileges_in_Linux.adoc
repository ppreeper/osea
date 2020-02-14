= How to quickly give users sudo privileges in Linux

* **If you have users that need certain admin privileges on your Linux machines, here's a walk-through of the process for granting full or specific rights.**
* By Jack Wallen | June 15, 2017, 8:44 AM PST 

How many times have you created a new user on a Linux machine, only to find out that new user doesn't have sudo privileges. Without the ability to use sudo, that user is limited in what they can do. This, of course, is by design; you certainly don't want every user on your system having admin privileges. However, for those users you do want to enjoy admin rights, they must be able to use the sudo command.

There are a couple of ways to tackle this task; one of which is not recommended (unless you need granular control over user admin privileges). I will demonstrate both methods and will be working on the Ubuntu Server 16.04 platform, but these methods will work on any Linux distribution that makes use of sudo.

== Method 1

Say you want to give a user access to only one administration-level command. This method is what you want to use to give granular control over admin privileges Effectively, what you do is edit the `/etc/sudoers` file and add the user. However, you want to use a special tool for this: visudo. When using visudo, it will lock the sudoers file against multiple, simultaneous edits (this is important). To use this tool, you need to issue the command `sudo -s` and then enter your sudo password. Now enter the command visudo and the tool will open the `/etc/sudoers` file for editing).

To add a specific user for all administrative privileges, scroll down to the bottom of the file and add the following, where `USERNAME` is the actual username you want to add.:

[source,bash]
----
USERNAME ALL=(ALL) ALL
----

Save and close the file and have the user log out and log back in. They should now have a full range of sudo privileges.

But what if you only want to give that user rights to a single command? You can do that. How? Issue the command visudo (after issuing `sudo -s`) to open the sudoers file for editing. There are two bits of information you must add to this file:

* Command alias(es)
* User entry

Both of these entries are necessary. Let's give user willow access to the apt-get command. To this, issue the commands sudo -s followed by visudo. Locate the Cmnd alias specification section and add the following:

`Cmnd_Alias APT_GET = /usr/bin/apt-get`

Scroll down to the bottom of the file and add the following line:

`willow ALL=(ALL) NOPASSWD: APT_GET`

Save and close that file. Have the user willow log out and log back in, at which point they will be able to now use the `sudo apt-get` command successfully.

== Method 2

If you have a user you want to give all admin privileges to, the best method is to simply add that user to the admin group. You will notice this line, in the `/etc/sudoers` file:

`%admin ALL=(ALL) ALL`

This means all members of the admin group have full sudo privileges. To add your user to the admin group, you would issue the command (as a user who already has full sudo privileges):

`sudo usermod -a -G sudo USERNAME`

Where `USERNAME` is the name of the user to be added. Once the user logs out and logs back in, they will now enjoy full sudo privileges.

== Use with caution

Obviously, you do not want to add every user to the sudoers file or to the admin group. Use this with caution, otherwise you run the risk of jeopardizing system security. But with care, you can manage what your users can and cannot do with ease.
