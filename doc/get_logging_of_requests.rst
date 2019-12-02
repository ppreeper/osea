How to get log listing of incoming DNS requests
===============================================

..  code::

    rndc querylog
    tail -f /var/log/syslog | grep -e named | grep -v -e "client 10.0.100.21" -e "client 10.0.100.22"
