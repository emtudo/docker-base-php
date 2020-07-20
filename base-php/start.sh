#!/usr/bin/env bash

# fix home directory permissions.
sudo chown -R app:app /home/app
sudo chown -R app:app /var/www/app

# copy bash config into place.
cp /home/bashrc /home/app/.bashrc

# Set PHP memory limit value.
sudo sed -i "/memory_limit = .*/c\memory_limit = $PHP_MEMORY_LIMIT" /etc/php7/php.ini

# OPCache extreme mode.
if [[ $OPCACHE_MODE == "extreme" ]]; then
  # enable extreme caching for OPCache.
  echo "opcache.enable=1" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
  echo "opcache.memory_consumption=512" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
  echo "opcache.interned_strings_buffer=128" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
  echo "opcache.max_accelerated_files=32531" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
  echo "opcache.validate_timestamps=0" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
  echo "opcache.save_comments=1" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
  echo "opcache.fast_shutdown=0" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
fi

# OPCache disabled mode.
if [[ $OPCACHE_MODE == "disabled" ]]; then
  # disable extension.
  sudo sed -i "/zend_extension=opcache/c\;zend_extension=opcache" /etc/php7/conf.d/00_opcache.ini
  # set enabled as zero, case extension still gets loaded (by other extension).
  echo "opcache.enable=0" | sudo tee -a /etc/php7/conf.d/00_opcache.ini > /dev/null
fi

if [[ $XDEBUG_ENABLED == true ]]; then
   # enable xdebug extension
   sudo sed -i "/;zend_extension=xdebug/c\zend_extension=xdebug" /etc/php7/conf.d/00_xdebug.ini
   # enable xdebug remote config
   echo "[xdebug]" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo "xdebug.remote_enable=1" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo "xdebug.remote_host=`/sbin/ip route|awk '/default/ { print $3 }'`" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo "xdebug.remote_port=9000" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo "xdebug.scream=0" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo "xdebug.cli_color=1" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo "xdebug.show_local_vars=1" | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
   echo 'xdebug.idekey = "app"' | sudo tee -a /etc/php7/conf.d/00_xdebug.ini > /dev/null
fi

if [[ $LARAVEL_CACHE == true ]]; then
  echo -e "\n # ---> Optimize \n" && \
  php artisan config:cache && \
  php artisan route:cache
fi

if [[ $MIGRATE == true ]]; then
  echo -e "\n # ---> Migrate \n" && \
  php artisan migrate --force
fi

if [[ $SUPERVISOR == true ]]; then
  echo "Supervisor Settings"
  [ -d /var/log/supervisor ] || mkdir -p /var/log/supervisor
  sudo chown -R app:app /var/run
  sudo chown -R app:app /run
  echo -e "\n # ---> Crontab \n" && \
  (echo '* * * * * /usr/bin/php7 /var/www/app/artisan schedule:run') | crontab -
  /usr/sbin/crond
  if [[ $NGINX_ENABLED == false ]]; then
    /usr/bin/supervisord -n -c /etc/supervisord.conf
  fi
  /usr/bin/supervisord -c /etc/supervisord.conf
fi

if [[ $NGINX_ENABLED == true ]]; then
  echo "Aliasing $FRAMEWORK"
  sudo ln -s /etc/nginx/sites/$FRAMEWORK.conf /etc/nginx/sites/enabled.conf

  # Starts FPM
  nohup /usr/sbin/php-fpm7 -y /etc/php7/php-fpm.conf -F -O 2>&1 &

  # Starts NGINX!
  nginx
fi

# run the original command
exec "$@"
