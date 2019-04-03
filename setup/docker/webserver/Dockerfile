FROM debian:jessie

MAINTAINER Da Cunha Alves <rui@virtua.ch>

# Install some useful packages
RUN apt-get update && \
    apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
        apt-transport-https bash-completion ca-certificates curl git gnupg imagemagick \
        less make mysql-client perceptualdiff procps ssh-client sudo unzip vim wget && \
    apt-get clean && apt-get --yes --quiet autoremove --purge && \
    rm -rf  /var/lib/apt/lists/* /tmp/* /var/tmp/* \
            /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
            /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

# Add Sury PHP repository
RUN wget -O sury.gpg https://packages.sury.org/php/apt.gpg && apt-key add sury.gpg && rm sury.gpg
COPY config/sury.list /etc/apt/sources.list.d/sury.list

# Install PHP with some extensions
RUN echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list && \
        apt-key adv --fetch-keys http://www.dotdeb.org/dotdeb.gpg && \
        apt-get update && apt-get --yes install \
            curl htop nano vim nodejs-legacy wget mysql-client git cron supervisor \
            nginx php7.2-fpm php7.2-cli php7.2-redis php7.2-soap php7.2-zip php7.2-mbstring \
            php7.2-xmlrpc php7.2-xsl php7.2-curl php7.2-enchant php7.2-gd php7.2-json php7.2-imap \
            php7.2-intl php7.2-mysqlnd php7.2-tidy \
            # For dev only \
            php7.2-xdebug strace npm sudo && \
        apt-get clean -y && apt-get autoclean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
        apt-get clean && apt-get --yes --quiet autoremove --purge && \
        rm -rf  /var/lib/apt/lists/* /tmp/* /var/tmp/* \
                /usr/share/doc/* /usr/share/groff/* /usr/share/info/* /usr/share/linda/* \
                /usr/share/lintian/* /usr/share/locale/* /usr/share/man/*

# PHP settings
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/memory_limit =.*/memory_limit = 1024M/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/memory_limit =.*/memory_limit = 1024M/" /etc/php/7.2/cli/php.ini && \
    sed -i "s/max_execution_time =.*/max_execution_time = 300/" /etc/php/7.2/fpm/php.ini && \
    sed -i "s/max_execution_time =.*/max_execution_time = 300/" /etc/php/7.2/cli/php.ini && \
    mkdir /run/php

# Add Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer global require "fxp/composer-asset-plugin:~1.2"

# Add Crontab
RUN (crontab -l 2>/dev/null; echo "*/1 * * * * /var/www/app/bin/console oro:cron --env=prod") | crontab -u www-data -

# Create a non privileged user
RUN useradd --create-home --groups sudo --shell /bin/bash docker \
    &&  echo "docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker

# Copy files
COPY ssl/* /etc/ssl/private/
COPY config/app.supervisor.conf /etc/supervisor/conf.d/app-orocrm.conf
COPY config/app.nginx.conf /etc/nginx/sites-available/app-orocrm
COPY config/app.www.fpm.conf /etc/php/7.2/fpm/pool.d/www.conf
COPY config/run.sh /usr/local/bin/run.sh
COPY config/optimization.php.ini /etc/php/7.2/cli/conf.d/
COPY config/optimization.php.ini /etc/php/7.2/fpm/conf.d/
COPY config/dev.php.ini /etc/php/7.2/cli/conf.d/
COPY config/dev.php.ini /etc/php/7.2/fpm/conf.d/

RUN chmod +x /usr/local/bin/run.sh && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    ngx-conf -e app-orocrm

EXPOSE 80 443 8443 8080
USER docker
WORKDIR /var/www/app/

CMD [ "sudo", "run.sh" ]
