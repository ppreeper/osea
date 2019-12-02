Certificate Authority
=====================

Create Local Secure key

..  code:: bash

    openssl genrsa -des3 -out /etc/ssl/private/server.key.secure 2048

Create Local InSecure key

..  code:: bash

    openssl rsa -in /etc/ssl/private/server.key.secure -out /etc/ssl/private/server.key

Use InSecure key for CSR without passphrase

..  code:: bash

    openssl req -new -key /etc/ssl/private/server.key -out ~/server.csr

Send server.csr to CA

CA is same-server (self-signed)
--------------------------------

..  code:: bash

    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

Install Certificate

..  code:: bash

    cp server.crt /etc/ssl/certs
    cp server.key /etc/ssl/private

Become a CA
------------

1. Create Dir for CA certs and etc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  code:: bash

    sudo mkdir /etc/ssl/CA
    sudo mkdir /etc/ssl/newcerts

2. Initialize serial and index files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  code:: bash

    sudo sh -c "echo '01' > /etc/ssl/CA/serial"
    sudo touch /etc/ssl/CA/index.txt

3. Create Self-Signed Root Certificate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  code:: bash

    openssl req -new -x509 -extensions v3_ca -keyout /etc/ssl/private/cakey.pem -out /etc/ssl/certs/cacert.pem -days 3650


4. You are ready to start signing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  code:: bash

    sudo openssl ca -in server.csr -config /etc/ssl/openssl.cnf

== HOWTO: Create a self-signed (wildcard) SSL certificate
Posted on March 11, 2006, 11:35 pm, by justin, under HOWTOs, Linux.

The following commands are all you need to create a self-signed (wildcard,
if you want) SSL certificate:

..  code:: bash

    mkdir /usr/share/ssl/certs/hostname.domain.com
    cd /usr/share/ssl/certs/hostname.domain.com

(umask 077 && touch host.key host.cert host.info host.pem)

..  code:: bash

    openssl genrsa 2048 > host.key
    openssl req -new -x509 -nodes -sha1 -days 3650 -key host.key > host.cert
    ...[enter *.domain.com for the Common Name]...
    openssl x509 -noout -fingerprint -text < host.cert > host.info
    cat host.cert host.key > host.pem
    chmod 400 host.key host.pem
