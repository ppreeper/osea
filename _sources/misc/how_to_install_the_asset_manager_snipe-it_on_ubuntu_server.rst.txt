#How to install the asset manager Snipe-IT on Ubuntu Server

If you're in need of a powerful IT asset manager, Jack Wallen shows you how to install the open source Snipe-IT system.

By Jack Wallen | May 10, 2018, 9:25 AM PST

Your company IT assets continue to pile up, so much so, that you can no longer keep track of what you own, how something has been deployed, who is working with what desktop, and the details of every server in your data center. To that end, you need the right tool to keep track of all this. But which tool is the right one? There are so many asset management options available. If you happen to be fan of open source software, and you have a Ubuntu Server machine (or VM) at the ready, you can give [[https://snipeitapp.com/|Snipe-IT]] Asset Manager a go.

Snipe-IT is a bit of a challenge to install, but the end results are definitely worth the work. You'll have an asset management tool that includes:

 * Ability to see which assets are assigned (as well as to whom and their physical location)
 * One-click check in for assets
 * Asset Models allow you to group common features
 * Require End-User EULAs/Terms of Service on Checkout
 * Email alerts for expiring warranties and licenses
 * Integrates with most handheld barcode scanners and QR code reader apps
 * Quick and easy asset auditing
 * Add custom fields for additional asset attributes
 * Import and export assets
 * Generate QR code labels for asset tagging
 * Assets can be marked as requestable by users
 * Full history retention (including checkouts, checkins and maintenance)
 * Optional digital signatures on asset acceptance

Let's install Snipe-IT on Ubuntu Server 16.04.

##Installation

###Apache

The first thing we must do is install the necessary dependencies. There are a few, so open up a terminal and let's type. The first is Apache. Install the web server with the command:

<code bash>
sudo apt install apache2
</code>

Once that completes, start and enable the server with the commands:

<code bash>
sudo systemctl start apache2
sudo systemctl enable apache2
</code>

###PHP and modules

Next we're going to install PHP and it's various modules:

<code bash>
sudo apt install php php-pdo php-mbstring php-tokenizer php-curl php-mysql php-ldap php-zip php-fileinfo php-gd php-dom php-mcrypt php-bcmath php-gd
</code>

###MariaDB

Now it's time to install our database. Do this with the commands:

<code bash>
sudo apt install mariadb-server
sudo systemctl start mysql
sudo systemctl enable mysql
</code>

Set up a root user password and secure MariaDB with the command:

<code bash>
sudo mysql_secure_installation
</code>

With our db server installed, let's create a database and a snipe-it user. First launch the MariaDB console by changing to the root user with the command sudo -s. Now issue the command:

<code bash>
mysql -r root -p
</code>

Create the database, the user, and give the user proper permissions with the commands:

<code sql>
CREATE DATABASE snipeit_data;
CREATE USER 'snipeit_user'@'localhost' IDENTIFIED BY 'PASSWORD';
GRANT ALL PRIVILEGES ON snipeit_data.* TO 'snipeit_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
</code>

Where PASSWORD is a strong password.

###Composer

Composer is required for the installation. Install this with the following commands:

<code bash>
cd ~curl -sS https://getcomposer.org/installer | phpsudo mv composer.phar /usr/local/bin/composer
</code>

###Snipe-IT

It's time to install Snipe-IT. First install git with the command:

<code bash>
sudo apt install git
</code>

Change into the Apache document root with the command cd /var/www. Clone Snipe-IT with the command:

<code bash>
sudo git clone https://github.com/snipe/snipe-it snipe-it
</code>

Create a new .env file (the configuration file) with the commands:

<code bash>
cd /var/www/snipe-it
sudo cp .env.example .env
</code>

Edit the .env file with the command:

<code bash>
sudo nano .env
</code>

Within the .env file, you need to edit the following lines:

<code bash>
APP_URL=SERVER_IP
APP_TIMEZONE='TIME_ZONE'


DB_DATABASE=snipeit_data
DB_USERNAME=snipeit_user
DB_PASSWORD=PASSWORD
</code>

Where:

 * SERVER_IP is the IP address of your server.
 * TIME_ZONE is the time zone for your location.
 * PASSWORD is the password you created for the db user.

Now we have to give the proper permissions for the Snipe-IT folders. This is done with the following commands:

<code bash>
sudo chown -R www-data:www-data storage public/uploads
sudo chmod -R 755 storage
sudo chmod -R 755 public/uploads
</code>

The final Apache configuration is the virtual host. Create the new .conf file with the command:

<code bash>
sudo nano /etc/apache2/sites-available/snipeit.conf
<code>

The contents of that file should be:

<code>
<VirtualHost *:80>
  ServerName snipeit.example.com
  DocumentRoot /var/www/snipe-it/public
  <Directory /var/www/snipe-it/public>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
  </Directory>
</VirtualHost>
</code>

Enable the newly configured site and activate mod_rewrite with the following commands:

<code bash>
sudo a2ensite snipeit.conf
sudo a2enmod rewrite
</code>

Restart Apache with the command:

<code bash>
sudo systemctl restart apache2
</code>

###Final PHP dependencies

We now have to finish up the remaining Snipe-IT PHP dependencies. This is done with the composer command, like so:

<code bash>
sudo composer install --no-dev --prefer-source
</code>

Finally, we generate the necessary APP_Key with the command:

<code bash>
sudo php artisan key:generate
</code>

##Finish the setup

Open up a browser and point it to http://SERVER_IP. You should be greeted by the pre-flight checklist, where you can click the Next button and continue with the installation (**Figure A**).

###Figure A

{{https://tr2.cbsistatic.com/hub/i/2018/05/10/2ea302e2-8c97-42f4-803a-379e039992a7/6dcbb50d4fff9d56e81b035e4bf38259/snipeita-800x600.jpg|The Snipe-IT pre-flight checklist.}}

At this point, everything is self-explanatory. There is, however, one caveat. If you do happen to see the Apache welcome page (instead of the Snipe-IT pre-flight page), move the index.html file with the command:

<code bash>
sudo mv /var/www/html/index.html /var/www/html/index_old.html
</code>

Make sure to restart Apache with the command:

<code bash>
sudo systemctl restart apache2
</code>

That should do it. You can now start working with your Snipe-IT Asset Management system.