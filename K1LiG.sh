#!/bin/bash

# 安装git
sudo apt-get update
sudo apt-get install git -y

# 安装php以及一些必要的php扩展
sudo apt-get install php php-cli php-zip php-mbstring php-xml -y

# 安装composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

# 安装nginx
sudo apt-get install nginx -y

# 克隆项目
git clone https://github.com/assimon/dujiaoka.git

# 安装composer依赖项
cd dujiaoka && composer install

# 提示用户输入域名和项目路径
echo "请输入你的域名："
read domain
echo "请输入你的项目路径："
read project_path

# 创建一个新的nginx配置文件
echo "server {
    listen 80;
    server_name $domain;
    root $project_path;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}" | sudo tee /etc/nginx/sites-available/your_project

# 启用新的nginx配置文件
sudo ln -s /etc/nginx/sites-available/your_project /etc/nginx/sites-enabled/

# 重启nginx服务
sudo service nginx restart
