FROM ubuntu:16.04
LABEL maintainer="Soutionclub.in"


LABEL description="apache2,php-7.1 and Wordpress"

RUN apt-get update  && apt-get install -y software-properties-common && \
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
# Install apache, php7.1, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 php7.1 php7.1-mysql \
libapache2-mod-php7.1 curl php7.1-gd php7.1-intl php7.1-xml php7.1-curl php7.1-mbstring php7.1-zip mcrypt

RUN a2enmod rewrite

# Update the php7.1.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.1/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.1/apache2/php.ini


# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid



# Install wordpress
RUN mkdir -p /var/www/site/
RUN cd /var/www/site/
ADD http://wordpress.org/latest.tar.gz /var/www/site/wordpress.tar.gz
RUN tar xvzf /var/www/site/wordpress.tar.gz
RUN rm /var/www/site/wordpress.tar.gz
RUN mv wordpress /var/www/site/
RUN chown -R www-data:www-data /var/www/site/wordpress
RUN find /var/www/site/wordpress -type d -exec chmod 775 {} +
RUN find /var/www/site/wordpress -type f -exec chmod 664 {} +


# Expose apache.
EXPOSE 80
# Expose mysql.
EXPOSE 3306

# Clean up APT when done.
RUN apt-get autoclean all && apt-get autoremove -y &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update the default apache site with the config we created.
ADD apache-sample.conf /etc/apache2/sites-enabled/000-default.conf

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND
