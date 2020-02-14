Certification Authority SSL (Self-Signed)
==========================================

..  code:: bash

    mkdir /etc/ssl/CA
    mkdir /etc/ssl/newcerts
    echo '01'>/etc/ssl/CA/serial
    touch /etc/ssl/CA/index.txt
    vim /etc/ssl/openssl.cnf
    dir             = /etc/ssl/             # Where everything is kept
    database        = $dir/CA/index.txt     # database index file.
    certificate     = $dir/certs/cacert.pem # The CA certificate
    serial          = $dir/CA/serial        # The current serial number
    private_key     = $dir/private/cakey.pem# The private key

Create self-signed root certificate

..  code:: bash

    openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650

Install the root certificate

..  code:: bash

    sudo mv cakey.pem /etc/ssl/private/
    sudo mv cacert.pem /etc/ssl/certs/

Create Local Secure key (on other server)

..  code:: bash

    openssl genrsa -des3 -out star.example.com.key.secure 2048

Create the insecure key

..  code:: bash

    openssl rsa -in star.example.com.key.secure -out star.example.com.key

Create the Certificate Signing Request

..  code:: bash

    openssl req -new -key star.example.com.key -out star.example.com.csr
    scp star.example.com.csr sysadmin@ca:~/.

CA server

..  code:: bash

    openssl ca -in star.example.com.csr -config /etc/ssl/openssl.cnf -days 3650
    cp /etc/ssl/newcerts/01.pem /etc/ssl/newcerts/star.example.com.crt
    remove everything before "-----BEGIN CERTIFICATE-----"
    scp /etc/ssl/newcerts/star.example.com.crt sysadmin@apps:~/.
    scp /etc/ssl/certs/cacert.pem sysadmin@apps:~/.

Application Server Requesting

..  code:: bash

    cp cacert.pem /etc/ssl/certs/.
    cp star.example.com.crt /etc/ssl/certs/.
