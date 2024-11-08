# 从官方基础版本构建
FROM php:8.2-fpm-alpine
MAINTAINER xieyangwanmu <fkha@163.com>

# 官方版本默认安装扩展: 
# Core, ctype, curl, date, dom, fileinfo, filter, ftp, hash, iconv, json, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_sqlite, Phar, posix, readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zlib

ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"}
    
    
# 更新为国内镜像
#RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories && \
#   apk update && apt del && rm -rf /var/cache/apt/*

RUN apk update && \
    # Libs
    apk add --no-cache make libc-dev gcc g++ linux-headers wget tzdata libxml2-dev openssl-dev sqlite-dev curl-dev oniguruma-dev autoconf libzip-dev freetype-dev libjpeg-turbo-dev libpng-dev imagemagick imagemagick-dev && \

    # PHP Library
    # zip bcmath, calendar, exif, gettext, sockets, dba, 
    # mysqli, pcntl, pdo, pdo_mysql, shmop, sysvmsg, sysvsem, sysvshm 扩展
    docker-php-ext-install -j$(nproc) zip bcmath calendar exif gettext sockets dba mysqli pcntl pdo pdo_mysql shmop sysvmsg sysvsem sysvshm iconv && \
    
    # Timezone
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    echo "[Date]\ndate.timezone=${TIMEZONE}" > /usr/local/etc/php/conf.d/timezone.ini && \
    apk del tzdata && \
    
    # Clean apt cache
    apt del && rm -rf /var/cache/apt/*
    
    # composer
RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \

    # Redis Mongo imagick swoole mcrypt memcached
    pecl install redis mongodb imagick swoole mcrypt memcached && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis mongodb imagick swoole mcrypt memcached && \
    
    # GD 扩展
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \

    # Opcache 扩展 
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install -j$(nproc) opcache && \
    
    # Clean
    apt del && rm -rf /var/cache/apt/*

# 配置PHP设置（如有需要）
#COPY php.ini /usr/local/etc/php/

ADD . /var/www/html

# 设置工作目录
WORKDIR /var/www/html

# 暴露端口
EXPOSE 9000

# 启动PHP-FPM
CMD ["/usr/local/sbin/php-fpm"]

# 镜像信息
LABEL Author="Hua"
LABEL Version="2024.10"
LABEL Description="PHP 8.2 开发环境镜像"
