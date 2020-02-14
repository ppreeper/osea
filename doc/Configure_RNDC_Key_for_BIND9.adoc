Configure RNDC Key for Bind9 (DNS Server)
=========================================

*RNDC* controls the operation of a name server. rndc uses tcp connection to
communicate with bind server for sending commands authenticated with digital
signatures. Configure RNDC Key for Bind9 using below steps.

Step 1: Create RNDC Key and Configuration File
----------------------------------------------

First step is to create rndc key file and configuration file. rndc provides
command line tool rndc-confgen to generate it.

..  code::

    rndc-confgen

Sample Output:

..  code::

    # Start of rndc.conf
    key "rndc-key" {
            algorithm hmac-md5;
            secret "DTngw5O8I5Axx631GjQ9pA==";
    };

    options {
            default-key "rndc-key";
            default-server 127.0.0.1;
            default-port 953;
    };
    # End of rndc.conf

Step 2: Configure RNDC Key and Configuration File
-------------------------------------------------

2.1 Copy entire output of #1 to /etc/rndc.conf
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2.2 Copy the key section of #1 to /etc/rndc.key file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  code::

    # cat /etc/rndc.key
    key "rndc-key" {
        algorithm hmac-md5;
        secret "DTngw5O8I5Axx631GjQ9pA==";
    };

Step 3: Configure named.conf to Use rndc key
--------------------------------------------

Add below entry in named.conf. I have added it to above option’s section.

..  code::

    include "/etc/rndc.key";

    controls {
        inet 127.0.0.1 allow { localhost; } keys { "rndc-key"; };
    };

Step 4: Restart Bind Service
----------------------------

Before restarting bind service, I recommend to check configuration file first.

..  code::

    named-checkconf /etc/named.conf

and

..  code::

    named-checkconf -t /var/named/chroot /etc/named.conf

If above command shows nothing in output, means configuration is ok,
Now restart bind service.

..  code::

    /etc/init.d/named restart

Step 5: Test RNDC Setup
-----------------------

Test your setup using rndc command as below.

..  code::

    rndc status

Sample output:

..  code::

    WARNING: key file (/etc/rndc.key) exists, but using default configuration file (/etc/rndc.conf)
    version: 9.9.2-P2-RedHat-9.9.2-3.P2.el6
    CPUs found: 1
    worker threads: 1
    UDP listeners per interface: 1
    number of zones: 38
    debug level: 0
    xfers running: 0
    xfers deferred: 0
    soa queries in progress: 0
    query logging is OFF
    recursive clients: 0/0/1000
    tcp clients: 0/100
    server is up and running

Thanks You! for using this article.
