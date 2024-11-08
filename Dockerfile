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
#RUN echo "deb http://mirrors.aliyun.com/debian/ buster main non-free contrib" > /etc/apt/sources.list \
#  && apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装所需依赖和扩展
RUN apt update && apt-get install -y --no-install-recommends \
    libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libmagickwand-dev libmcrypt-dev libmemcached-dev zlib1g-dev \
    && docker-php-ext-install -j$(nproc) bcmath calendar exif gettext sockets dba mysqli pcntl pdo_mysql shmop sysvmsg sysvsem sysvshm iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache \
    && pecl install imagick mcrypt-1.0.2 memcached-3.1.3 redis-5.0.0 \
    && docker-php-ext-enable imagick mcrypt memcached redis \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 配置PHP设置（如有需要）
#COPY php.ini /usr/local/etc/php/

# 设置工作目录
WORKDIR /var/www/html

# 暴露端口
EXPOSE 9000

# 启动PHP-FPM
CMD ["php-fpm"]

# 镜像信息
LABEL Author="Hua" \
      Version="2024.10" \
      Description="PHP 8.2 开发环境镜像"
