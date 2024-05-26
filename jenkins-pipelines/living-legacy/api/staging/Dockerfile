FROM php:8.1-fpm

ARG GITHUB_ORG
ARG GITHUB_REPO
ARG GITHUB_BRANCH
ARG GITHUB_USER
ARG GITHUB_PAT

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm \
    librdkafka-dev \
    zlib1g-dev \
    libzip-dev \ 
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libgd-dev libpng-dev jpegoptim optipng pngquant gifsicle \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && apt-get install -y libmagickwand-dev \ 
    && pecl install imagick \ 
    && docker-php-ext-enable imagick


WORKDIR /var/www/html

RUN rm *

RUN git clone --branch ${GITHUB_BRANCH} https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git /var/www/html

RUN echo ${GITHUB_REPO}

RUN ls -la

RUN pwd

RUN cp docker/nginx/default.conf /etc/nginx/conf.d
RUN cp docker/nginx/fastcgi-php.conf /etc/nginx
RUN cp docker/php/php.ini-production /usr/local/etc/php/php.ini-production
RUN cp docker/php/php.ini-development /usr/local/etc/php/php.ini-development
RUN cp docker/php/php.ini-development /usr/local/etc/php/php.ini
RUN cp docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y libssl-dev
RUN apt-get install -y libcurl4-gnutls-dev
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libcurl4

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

#copy our laravel application to html
COPY --chown=docker:docker . /var/www/html

WORKDIR /var/www/html

#update dependencies
RUN composer update

#install dependencies with composer
RUN composer install --quiet --optimize-autoloader --no-dev --verbose

#set permission on storage folder
RUN chmod -R 777 storage

RUN chmod +x docker/entrypoint.sh

# Run the entrypoint file.
ENTRYPOINT [ "docker/entrypoint.sh" ]