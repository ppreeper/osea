Elliptic Curve CA Guide
========================

Pick a curve to use. The NIST curves, recommended for US government security,
are labelled.
Note that you are not required to use the same curve across the whole CA.

..  code:: bash

    openssl ecparam -list-curves

In this example we will use sec283k1, a NIST/SECG standard curve over a 283 bit
binary field.
Create a private key and self signed curve certificate. This will act as CA.

..  code:: bash

    openssl ecparam -out sinful.key -name sect283k1 -genkey
    openssl req -x509 -new -key sinful.key -out sinful-ca.pem -outform PEM -days 3650

Create another private key and generate an associated certificate request.

..  code:: bash

    openssl ecparam -out sinful-host.key -name sect283k1 -genkey
    openssl req -new -nodes -key sinful-host.key -outform pem -out sinful-host.req

Generate the signed certificate from the request.

..  code:: bash

    openssl ca -keyfile sinful.key -cert sinful-ca.pem -in sinful-host.req -out sinful-host-cert.pem -outdir .

