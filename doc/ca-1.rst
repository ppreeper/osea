How To create an intermediate Certificate Authority (CA) using openssl
=======================================================================

What is an Intermediate Certificate Authority (CA) and why do I need one?
An Intermediate CA is an authority that you use to create your own SSL
certificates in a PKI environment. An Intermediate CA depends on a Root CA
that is the origin of the chain of trust. The idea is that if your
Intermediate CA gets compromised or you decide to revocate all the
certificates issued by it, you can still use your Root CA without further
inconvenience for your users (the users only need to have installed the
certificate of the Root CA in their browsers).

As for the second question, the sort answer is that chances are that you
really do not need one :) but for the shake of the experiment lets get our
hands dirty!

First of all, I need to clarify that my interest in this topic was also
risen by the fact that Verisign has switched to a two-tier hierarchy of
Certificate Authorities, and this has some implications specially in the
configuration of web server software:

“As of April 2006, all SSL certificates issued by VeriSign require the
installation of an Intermediate CA Certificate. The SSL certificates are
signed by an Intermediate CA using a two-tier hierarchy (also known as
trust chain) which enhances the security of your SSL Certificate. If the
proper Intermediate CA is not installed on the server, your customers
will see browser errors and may choose not to proceed further and close
their browser.”

This means that while the users do not need to modify anything (if their
browser already has Verisigns Root CA certificate) the server owners need
to ensure that the server is able to provide the so called trust chain
to the users’ browser when the SSL handshake is performed.

Never mind, lets get back to it. In order to get your Intermediate CA
working, first you need a Root CA (if you already have a CA, feel free
to skip the next section). Remember that in order to get this working
you need to have a copy of the openssl toolkit installed in your system.

Configure the Root CA

..  code:: bash

    [ca-root]
    mkdir /var/ca
    cd /var/ca/
    mkdir certs crl newcerts private
    echo "01" > serial
    cp /dev/null index.txt
    # beware that the location of the sample file is dependent on your environment
    cp /usr/lib/ssl/openssl.cnf .

You may want to modify some of the settings in the configuration file to
save you some time in the future when creating the certificates:
default_bits, countryName, stateOrProvinceName, 0.organizationName_default,
organizationalUnitName and emailAddress.

Now you are ready to create the CA:

..  code:: bash

    [ca-root]
    # generate a private key
    openssl genrsa -des3 -out private/cakey.key 4096
    # create a self-signed certificate valid for 5 years
    openssl req -new -x509 -nodes -sha1 -days 1825 -key private/cakey.pem -out cacert.pem
    # go for the default values if you adapted the settings in the openssl.cnf file or enter the values you desire

Now you have everything you need to run a successful CA.

Configure an Intermediate CA
-----------------------------

The idea is simple, we will create a new CA following the same template that
we used in the previous section, but this time instead of generating a
self-signed certificate we will generate a certificate sign request that we
will sign using the Root CA.

First we create the folder structure:

..  code:: bash

    [ca-int]
    cd /var/ca/
    mkdir ca2008
    cd ca2008
    cp ../openssl.cnf .
    mkdir certs crl newcerts private
    echo "01" > serial
    cp /dev/null index.txt

Then the Intermediate CA private key:

..  code:: bash

    [ca-int]
    #generate the key
    openssl genrsa -des3 -out private/cakey.pem 4096
    #generate a signing request (valid for 1year)
    openssl req -new -sha1 -key private/cakey.pem -out ca2008.csr
    # go for the default values if you adapted the settings in the openssl.cnf file or enter the values you desire

Move the sign request to the Root CA directory and sign it:

..  code:: bash

    [ca-root]
    mv ca2008.csr ..
    cd ..
    openssl ca -extensions v3_ca -days 365 -out ca2008.crt -in ca2008.csr -config openssl.cnf
    mv ca2008.* ca2008/
    cd ca2008/
    mv ca2008.crt cacert.pem

And that was it. The next thing to do is start using your Intermediate CA to
sign your new certificates. But just before that, remember that to verify a
certificate signed by an Intermediate CA the web browser has to verify both
the certificate against the Intermediate CA and the certificate of the
Intermediate CA against a Root CA.

In order to allow the browser to do this, a certificate chain file needs to
be installed in the server. A certificate chain is a plaintext file that
contains all the certificates from the Authority issuing a given certificate
up to the Root of the certificate tree. In this case our chain has only two
levels and the chain file is created like this:

..  code:: bash

    # first the intermediate CA certificate
    [ca-int]
    cat cacert.pem > chain.crt
    # then the Root CA cert
    [ca-root]
    cat ../cacert.pem >> chain.crt

This file is the one you need to specify in the SSLCertificateChainFile of
your server.

Create a new server certificate

..  code:: bash

    [web]
    # create the private key
    openssl genrsa -des3 -out {server_name}.key 4096
    # generate a certificate sign request
    openssl req -new -key {server_name}.key -out {server_name}.csr
    # send {server_name}.csr to [ca-int]

..  code:: bash

    [ca-int]
    # make sure you are in the Intermediate CA folder and not in the Root CA one
    cd /var/ca/ca2008/
    cp {server_name}.csr /var/ca/ca2008/{server_name}.csr
    # sign the request with the Intermediate CA
    openssl ca -config openssl.cnf -policy policy_anything -out {server_name}.crt -infiles {server_name}.csr
    # and store the server files in the certs/ directory
    mkdir certs/{server_name}
    mv {server_name}.key {server_name}.csr {server_name}.crt certs/

Then you should securely copy the .key and .crt files to the server and
configure it to use them.

Apache server configuration [web]

Just in case you are using Apache server and for the sake of completeness,
these are the settings that you need to modify
(possibly in your extra/http-ssl.conf):-

..  code:: bash

    [web]
    SSLCertificateFile /var/ca/ca2008/certs/{server_name}.crt
    SSLCertificateKeyFile /var/ca/ca2008/certs/{server_name}.key
    SSLCertificateChainFile /var/ca/ca2008/chain.crt

Other Article
--------------

OK, this is a bit involved. Playing around with OpenSSL to create a three
level set of CA certificates which involve a Root, intermediary and issuing
certificates.

What I did was the following to establish the Root CA config:

..  code:: bash

    mkdir ~/CA
    mkdir ~/CA/root
    cd ~/CA/root
    cp /usr/lib/ssl/openssl.cnf .
    mkdir certs crl newcerts private
    touch index.txt
    echo "01" > serial

Edit the following values in openssl.cnf:

..  code:: bash

    HOME = $ENV::HOME
    dir = $HOME/CA/root
    default_days = 3650
    default_bits = 4096

The rest of these should be what your default info for certs are:

..  code:: bash

    countryName_default
    stateOrProvinceName_default
    localityName_default
    0.organizationName_default
    organizationalUnitName_default

Here is what I did to make the Intermediary and Issuing CA config:

..  code:: bash

    mkdir ~/CA/inter
    mkdir ~/CA/issue
    cp -R ~/CA/root/* ~/CA/inter/
    cp -R ~/CA/root/* ~/CA/issue/

Edit the ~/CA/inter/openssl.cnf file as follows:

..  code:: bash

    dir = $HOME/CA/inter
    default_days = 1825

Edit the ~/CA/issue/openssl.cnf file as follows:

..  code:: bash

    dir = $HOME/CA/issue
    default_days = 730
    default_bits = 2048

Now to establish the Root, intermediary and issuing certificates.

The Root CA cert:

..  code:: bash

    cd ~/CA/root
    openssl genrsa -des3 -out private/cakey.pem 4096
    openssl req -config openssl.cnf -new -x509 -nodes -sha1 -days 1825 -key private/cakey.pem -out cacert.pem

Intermediary cert:

..  code:: bash

    cd ~/CA/inter/
    openssl genrsa -des3 -out private/cakey.pem 4096
    openssl req -config openssl.cnf -new -sha1 -key private/cakey.pem -out inter.csr
    cp inter.csr ~/CA/root/
    cd ../root/
    openssl ca -config openssl.cnf -extensions v3_ca -days 3650 -out inter.cer -in inter.csr
    cp inter.* ~/CA/inter/cacert.pem

Issuing cert:

..  code:: bash

    cd ~/CA/issue/
    openssl genrsa -out private/cakey.pem 2048 -nodes
    openssl req -config openssl.cnf -new -sha1 -key private/cakey.pem -out issue.csr
    cp issue.csr ~/CA/inter/
    cd ~/CA/inter/
    openssl ca -config openssl.cnf -extensions v3_ca -days 3650 -out issue.cer -in issue.csr
    cp issue.cer ~/CA/issue/cacert.pem

Once you have done this you have everything you need to sign your own
certificates.

Just copy the CSR you want to sign into the ~/CA/issue directory and run
the command:

..  code:: bash

    openssl ca -config openssl.cnf -days 730 -out YourCert.cer -in YourCert.csr

Where YourCert.csr is the name of the CSR you just generated.

..  code:: bash

    openssl ca -revoke xyz.crt
