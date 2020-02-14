Create a .pfx/.p12 certificate file using OpenSSL
==================================================


The PKCS#12 or PFX format is a binary format for storing the server
certificate, any intermediate certificates, and the private key into a single
encryptable file. PFX files are usually found with the extensions .pfx
and .p12. PFX files are typically used on Windows machines to import and
export certificates and private keys.

*Requirements:*

* The original private key used for the certificate
* A PEM (.pem, .crt, .cer) or PKCS#7/P7B (.p7b, .p7c) File
* OpenSSL

The commands below demonstrate examples of how to create a .pfx/.p12 file in
the command line using OpenSSL.

PEM (.pem, .crt, .cer) to PFX
------------------------------

..  code:: bash

    openssl pkcs12 -export -out certificate.pfx -inkey privateKey.key -in certificate.crt -certfile more.crt

Breaking down the command:

* openssl – the command for executing OpenSSL
* pkcs12 – the file utility for PKCS#12 files in OpenSSL
* -export -out certificate.pfx – export and save the PFX file as
  certificate.pfx
* -inkey privateKey.key – use the private key file privateKey.key
  as the private key to combine with the certificate.
* -in certificate.crt – use certificate.crt as the certificate the
  private key will be combined with.
* -certfile more.crt – This is optional, this is if you have any
  additional certificates you would like to include in the PFX file.

PKCS#7/P7B (.p7b, .p7c) to PFX
-------------------------------

P7B files cannot be used to directly create a PFX file. P7B files must be
converted to PEM. Once converted to PEM, follow the above steps to create a
PFX file from a PEM file.

..  code:: bash

    openssl pkcs7 -print_certs -in certificate.p7b -out certificate.crt

Breaking down the command:

* openssl – the command for executing OpenSSL
* pkcs7 – the file utility for PKCS#7 files in OpenSSL
* -print_certs -in certificate.p7b – prints out any certificates or CRLs
  contained in the file.
* -out certificate.crt – output the file as certificate.crt
