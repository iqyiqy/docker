# 从官方基础版本构建
FROM php:8.2-fpm
# 官方版本默认安装扩展: 
# Core, ctype, curl
# date, dom
# fileinfo, filter, ftp
# hash
# iconv
# json
# libxml
# mbstring, mysqlnd
# openssl
# pcre, PDO, pdo_sqlite, Phar, posix
# readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard
# tokenizer
# xml, xmlreader, xmlwriter
# zlib

# 更新为国内镜像
#RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
#    && apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/*

# bcmath, calendar, exif, gettext, sockets, dba, 
# mysqli, pcntl, pdo_mysql, shmop, sysvmsg, sysvsem, sysvshm 扩展
RUN docker-php-ext-install -j$(nproc) bcmath calendar exif gettext sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm iconv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# GD 扩展
RUN apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# imagick 扩展
RUN apt-get install -y --no-install-recommends libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# mcrypt 扩展 
RUN apt-get install -y --no-install-recommends libmcrypt-dev \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-enable mcrypt \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Memcached 扩展 
RUN apt-get install -y --no-install-recommends libmemcached-dev zlib1g-dev \
    && pecl install memcached-3.1.3 \
    && docker-php-ext-enable memcached \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# redis 扩展
RUN pecl install redis-5.0.0 && docker-php-ext-enable redis

# opcache 扩展 
RUN docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache 

# xdebug 扩展
#RUN pecl install xdebug-2.7.2 && docker-php-ext-enable xdebug

# swoole 扩展
#RUN pecl install swoole-4.4.0 && docker-php-ext-enable swoole

# 配置PHP设置（如有需要）
#COPY php.ini /usr/local/etc/php/

# 设置工作目录
WORKDIR /var/www/html

# 暴露端口
EXPOSE 9000

# 启动PHP-FPM
CMD ["php-fpm"]

# 镜像信息
LABEL Author="Hua"
LABEL Version="2024.10"
LABEL Description="PHP 8.2 开发环境镜像"
