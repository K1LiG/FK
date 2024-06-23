#!/bin/bash

# Update system packages
apt-get update

# Install Git
apt-get install git -y

# Clone the project
cd /var/www/
git clone https://github.com/assimon/dujiaoka.git

# Install PHP and required extensions
apt-get install php-cli php-zip php-mbstring php-xml -y

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install project dependencies
cd /var/www/dujiaoka
composer install

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
apt-get -y install mysql-server

# Setup database
mysql -uroot -proot -e "CREATE DATABASE dujiaoka; GRANT ALL PRIVILEGES ON dujiaoka.* TO 'dujiaoka'@'localhost' IDENTIFIED BY 'password'; FLUSH PRIVILEGES;"

# Install Redis
apt-get install redis-server -y
service redis-server start

# Install Nginx
apt-get install nginx -y

# Create Nginx configuration
echo "
server {
    listen 80;
    server_name \$1;

    root /var/www/dujiaoka/public;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
    }
}" > /etc/nginx/sites-available/dujiaoka

# Enable the Nginx configuration
ln -s /etc/nginx/sites-available/dujiaoka /etc/nginx/sites-enabled/

# Restart Nginx
service nginx restart

