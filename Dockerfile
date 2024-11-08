# 从官方基础版本构建
FROM php:8.2-fpm
MAINTAINER xieyangwanmu <fkha@163.com>

# 官方版本默认安装扩展: 
# Core, ctype, curl, date, dom, fileinfo, filter, ftp, hash, iconv, json, libxml, mbstring, mysqlnd, openssl, pcre, PDO, pdo_sqlite, Phar, posix, readline, Reflection, session, SimpleXML, sodium, SPL, sqlite3, standard, tokenizer, xml, xmlreader, xmlwriter, zlib

ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} 
    
# 更新为国内镜像
#RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
#   && apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    # Libs
    apt-get install -y --no-install-recommends curl wget telnet vim git npm zlib1g-dev libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev imagemagick libmagickwand-dev && \

    # PHP Library
    # zip bcmath, calendar, exif, gettext, sockets, dba, 
    # mysqli, pcntl, pdo, pdo_mysql, shmop, sysvmsg, sysvsem, sysvshm 扩展
    docker-php-ext-install -j$(nproc) zip bcmath calendar exif gettext sockets dba mysqli pcntl pdo pdo_mysql shmop sysvmsg sysvsem sysvshm iconv && \
    
    # Clean apt cache
    apt-get clean && rm -rf /var/lib/apt/lists/*

    # composer
RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ && \

    # Redis Mongo imagick
    pecl install redis mongodb swoole imagick && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis mongodb swoole imagick && \
     
    # GD 扩展
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \

    # Opcache 扩展 
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install -j$(nproc) opcache && \
    
    # Timezone
    cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    echo "[Date]\ndate.timezone=${TIMEZONE}" > /usr/local/etc/php/conf.d/timezone.ini && \

    # Clean
    apt-get clean && rm -rf /var/cache/apt/*

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
