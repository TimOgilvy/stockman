FROM centos:centos6

MAINTAINER Abed Halawi <abed.halawi@vinelab.com>

# update packages
RUN yum -y update

# install basic software
RUN yum install -y rsyslog vixie-cron vim wget tar

# make the terminal prettier
RUN echo 'export PS1="[\u@docker] \W # "' >> /root/.bash_profile

# install & configure supervisord
RUN yum -y install http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum -y install python-setuptools
RUN easy_install supervisor
RUN /usr/bin/echo_supervisord_conf > /etc/supervisord.conf
RUN mkdir -p /var/log/supervisord

# make supervisor run in foreground
RUN sed -i -e "s/^nodaemon=false/nodaemon=true/" /etc/supervisord.conf

# make supervisor run the http server on 9001
RUN sed -i -e "s/^;\[inet_http_server\]/\[inet_http_server\]/" /etc/supervisord.conf
RUN sed -i -e "s/^;port=127.0.0.1:9001/port=0.0.0.0:9001/" /etc/supervisord.conf
RUN sed -i -e "s/^;username=user/username=vinelab/" /etc/supervisord.conf
RUN sed -i -e "s/^;password=123/password=vinelab/" /etc/supervisord.conf

# tell supervisor to include relative .ini files
RUN mkdir /etc/supervisord.d
RUN echo [include] >> /etc/supervisord.conf
RUN echo 'files = /etc/supervisord.d/*.ini' >> /etc/supervisord.conf

# add programs to supervisord config
ADD dockerlib/ini/rsyslog.ini /etc/supervisord.d/rsyslog.ini
ADD dockerlib/ini/cron.ini /etc/supervisord.d/cron.ini

RUN yum clean all

# setup locale
RUN echo 'LANG=C' > /etc/sysconfig/i18n

# ADD run /
# RUN chmod +x /run
RUN /usr/bin/supervisord -c /etc/supervisord.conf

EXPOSE 9001

# update packages
RUN yum -y update

# install package repo dependencies
RUN yum -y install http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
RUN wget -O /etc/yum.repos.d/hop5.repo http://www.hop5.in/yum/el6/hop5.repo

# install nginx
RUN yum install -y nginx

# install hhvm
RUN yum install -y hhvm

# make the php-cli available as a link to the hhvm compiler
# so that when someone runs php file.php it just works.
RUN ln -s /usr/bin/hhvm /usr/bin/php

# add hhvm files
ADD hhvm.conf /etc/nginx/
ADD hhvm.ini /etc/supervisord.d/

# install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

# setup nginx
RUN mkdir /var/www
RUN chown -R nginx:nginx /var/www
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default
ADD app.conf /etc/nginx/conf.d/app.conf
ADD nginx.conf /etc/nginx/
ADD nginx.ini /etc/supervisord.d/

