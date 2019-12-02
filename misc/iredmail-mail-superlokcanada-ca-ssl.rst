sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot 

sudo certbot certonly --webroot -w /var/www/html -d mail.superlokcanada.ca

root@mail:/var/www/html# sudo certbot certonly --webroot -w /var/www/html -d mail.superlokcanada.ca
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator webroot, Installer None
Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel): preeper.peter@arthomson.com

-------------------------------------------------------------------------------
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server at
https://acme-v01.api.letsencrypt.org/directory
-------------------------------------------------------------------------------
(A)gree/(C)ancel: A

-------------------------------------------------------------------------------
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about EFF and
our work to encrypt the web, protect its users and defend digital rights.
-------------------------------------------------------------------------------
(Y)es/(N)o: Y
Obtaining a new certificate
Performing the following challenges:
http-01 challenge for mail.superlokcanada.ca
Using the webroot path /var/www/html for all unmatched domains.
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/mail.superlokcanada.ca/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/mail.superlokcanada.ca/privkey.pem
   Your cert will expire on 2018-04-30. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


postconf -e smtpd_tls_cert_file='/etc/letsencrypt/live/mail.superlokcanada.ca/cert.pem'
postconf -e smtpd_tls_key_file='/etc/letsencrypt/live/mail.superlokcanada.ca/privkey.pem'
postconf -e smtpd_tls_CAfile='/etc/letsencrypt/live/mail.superlokcanada.ca/fullchain.pem'

ssl_cert = </etc/letsencrypt/live/mail.superlokcanada.ca/cert.pem
ssl_key = </etc/letsencrypt/live/mail.superlokcanada.ca/privkey.pem
ssl_ca = </etc/letsencrypt/live/mail.superlokcanada.ca/fullchain.pem



