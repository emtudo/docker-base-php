FROM alpine:3.12

# Repository/Image Maintainer
LABEL maintainer="Leandro Henrique <emtudo@gmail.com>"

USER root

# Variables for enabling
ENV FRAMEWORK=laravel \
  OPCACHE_MODE="extreme" \
  PHP_MEMORY_LIMIT=512M \
  XDEBUG_ENABLED=false \
  TERM=xterm-256color \
  LARAVEL_CACHE=true \
  MIGRATE=true \
  COLORTERM=truecolor \
  COMPOSER_PROCESS_TIMEOUT=1200 \
  NGINX_ENABLED=true \
  SUPERVISOR=false \
  ENVIRONMENT=production

# Add the ENTRYPOINT script
RUN mkdir /scripts
ADD start.sh /scripts/start.sh
ADD bashrc /home/app/.bashrc
ADD bashrc /home/bashrc

# Install PHP From DotDeb, Common Extensions, Composer and then cleanup
RUN echo "---> Enabling PHP-Alpine" && \
  apk add --no-cache --update wget && \
  wget -O /etc/apk/keys/php-alpine.rsa.pub https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub && \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories && \
  echo "https://dl.bintray.com/php-alpine/v3.11/php-7.4" >> /etc/apk/repositories

RUN  echo "---> INSTALL PHP" && \
  apk add --no-cache --update \
  curl \
  poppler \
  bash \
  fontconfig \
  libxrender \
  libxext \
  imagemagick \
  nano \
  vim \
  git \
  unzip \
  wget \
  make \
  sudo && \
  echo "---> Preparing and Installing PHP" && \
  apk add --no-cache --update \
  php \
  php-apcu \
  php-bcmath \
  php-bz2 \
  php-calendar \
  php-ctype \
  php-cgi \
  php-curl \
  php-dom \
  php-exif \
  php-fpm \
  php-ftp \
  php-gd \
  php-gmp \
  php-iconv \
  php-imagick \
  php-imap \
  php-intl \
  php-json \
  php-mbstring \
  php-memcached \
  php-mongodb \
  php-mysqli \
  php-mysqlnd \
  php-opcache \
  php-openssl \
  php-pcntl \
  php-pdo_mysql \
  php-pdo_pgsql \
  php-pdo_sqlite \
  php-pgsql \
  php-phar \
  php-phpdbg \
  php-posix \
  php-redis \
  php-soap \
  php-sockets \
  php-swoole \
  php-sodium \
  php-sqlite3 \
  php-xdebug \
  php-xml \
  php-xmlreader \
  php-xsl \
  php-zip \
  php-zlib && \
  sudo ln -s /usr/bin/php7 /usr/bin/php && \
  sudo ln -s /usr/bin/php-cgi7 /usr/bin/php-cgi && \
  sudo ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm && \
  echo "---> Installing Composer" && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
  echo "---> Cleaning up" && \
  rm -rf /tmp/* && \
  echo "---> Adding the app user" && \
  adduser -D -u 1000 app && \
  mkdir -p /var/www/app && \
  chown -R app:app /var/www && \
  wget -O /tini https://github.com/krallin/tini/releases/download/v0.18.0/tini-static && \
  chmod +x /tini && \
  echo "---> Configuring PHP" && \
  echo "app  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers && \
  sed -i "/user = .*/c\user = app" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/^group = .*/c\group = app" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/listen.owner = .*/c\listen.owner = app" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/listen.group = .*/c\listen.group = app" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/listen = .*/c\listen = [::]:9000" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/;access.log = .*/c\access.log = /proc/self/fd/2" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/;clear_env = .*/c\clear_env = no" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/;catch_workers_output = .*/c\catch_workers_output = yes" /etc/php7/php-fpm.d/www.conf && \
  sed -i "/pid = .*/c\;pid = /run/php/php7.1-fpm.pid" /etc/php7/php-fpm.conf && \
  sed -i "/;daemonize = .*/c\daemonize = yes" /etc/php7/php-fpm.conf && \
  sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php7/php-fpm.conf && \
  sed -i "/post_max_size = .*/c\post_max_size = 1000M" /etc/php7/php.ini && \
  sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 1000M" /etc/php7/php.ini && \
  sed -i "/zend_extension=xdebug/c\;zend_extension=xdebug" /etc/php7/conf.d/00_xdebug.ini && \
  chown -R app:app /home/app && \
  chmod +x /scripts/start.sh && \
  rm -rf /tmp/*

# Supervisor
RUN echo -e "\n # ---> Installing Supervisor \n" && \
  apk add --no-cache --update supervisor

COPY supervisord.conf /etc/

# Application directory
WORKDIR "/var/www/app"

# Environment variables
ENV PATH=/home/app/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copy nginx and entry script
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl.conf /etc/nginx/ssl.conf
COPY sites /etc/nginx/sites

# Install nginx from dotdeb (already enabled on base image)
RUN echo "--> Installing Nginx" && \
  apk add --update nginx openssl openssh-client npm && \
  rm -rf /tmp/* /var/tmp/* /usr/share/doc/* && \
  echo "--> Fixing permissions" && \
  mkdir /var/tmp/nginx && \
  mkdir /var/run/nginx && \
  mkdir /home/ssl && \
  chown -R app:app /home/ssl && \
  chown -R app:app /var/tmp/nginx && \
  chown -R app:app /var/run/nginx && \
  chown -R app:app /var/log/nginx && \
  chown -R app:app /var/lib/nginx && \
  chown -R app:app /home/app

# Pre generate some SSL
# YOU SHOULD REPLACE WITH YOUR OWN CERT.
RUN openssl req -x509 -nodes -days 3650 \
  -newkey rsa:2048 -keyout /home/ssl/nginx.key \
  -out /home/ssl/nginx.crt -subj "/C=AM/ST=app/L=app/O=app/CN=*.test" && \
  openssl dhparam -out /home/ssl/dhparam.pem 2048

COPY start.sh  /home/start.sh

# Expose webserver port
EXPOSE 80
EXPOSE 443
EXPOSE 9000

# Define the entry point that tries to enable
ENTRYPOINT ["/tini", "--", "/scripts/start.sh"]

# As non daemon and single base image, it may be used as cli container
CMD ["/bin/bash"]


