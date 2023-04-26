#!/usr/bin/env bash

set -e -x

# enable ssl mode
a2enmod ssl
service apache2 restart

# create ssl certificate
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=DE/ST=Berlin/L=Berlin/O=Canonical/CN=localhost"

# Create site folder
mkdir -p /var/www/localhost/
chmod -R +r /var/www/localhost/

# Update the apache config to pick up the cert and key
mkdir -p /etc/apache2/sites-available/
cat <<EOF > /etc/apache2/sites-available/localhost.conf
<VirtualHost *:443>
   ServerName localhost
   DocumentRoot /var/www/localhost

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
EOF

echo "printing site localhost"
cat /etc/apache2/sites-available/localhost.conf

# enable the configuration file
a2ensite localhost.conf
apache2ctl configtest
service apache2 reload
service apache2 stop
