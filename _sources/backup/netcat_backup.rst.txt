Netcat Backup
=============

From BAD Machine to GOOD Server

.. code::

    dd if=/dev/sda | gzip | nc 192.139.193.67 9999

Good Server Side

.. code::

    nc -l -p 9999 > sda.raw.gz
