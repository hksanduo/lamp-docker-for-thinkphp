FROM ubuntu:20.04
MAINTAINER hksanduo<hksanduo@qq.com>
# ENV is not working
#ENV LANG C.UTF-8
RUN echo "export LC_ALL="C.UTF-8"" >> /etc/bash.bashrc

# config apt sources.list
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# Install basic packages
RUN apt-get update
RUN apt-get install -y software-properties-common vim unzip && \
add-apt-repository ppa:ondrej/php && apt-get update

# Install php7.0
RUN apt-get install -y php7.0 php7.0-mysql mysql-client libapache2-mod-php7.0 php7.0-gd php7.0-mbstring php7.0-xml
COPY php.ini /etc/php/7.0/apache2/

# Install apache 
RUN apt-get install -y apache2 && groupadd apache && useradd -M -s /sbin/nologin -g apache apache

# Config apache2
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOG_DIR

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN echo "ServerTokens ProductOnly" >> /etc/apache2/apache2.conf
RUN echo "ProtocolsHonorOrder On" >> /etc/apache2/apache2.conf
RUN echo "Protocols h2 http/1.1" >> /etc/apache2/apache2.conf

# enable rewrite mod
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load

# remove default website
RUN rm -rf /var/www/html

# set web port
EXPOSE 80

# install ssh
RUN apt-get install -y ssh lrzsz net-tools 

# config ssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config 
RUN sed -i 's/#Port 22/Port 222/g' /etc/ssh/sshd_config 
RUN mkdir /var/run/sshd

# change root password
RUN echo 'root:P@ssw0rd' | chpasswd

#run ssh server and apache background
EXPOSE 222
CMD /usr/sbin/sshd && /usr/sbin/apache2 -D FOREGROUND

# Clean apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
