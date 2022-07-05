FROM --platform=$BUILDPLATFORM phusion/baseimage:jammy-1.0.0
LABEL maintainer="martin@front-matter.io"

# Set correct environment variables.
ENV HOME /home/app
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# add app user
RUN useradd -ms /bin/bash app

# Allow app user to read /etc/container_environment
RUN usermod -a -G docker_env app

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Update installed APT packages
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get install ntp curl wget nano tmux tzdata software-properties-common python-is-python3 imagemagick shared-mime-info -y && \
    apt-get autoremove --purge

# Install Python 3.9 (default in Ubuntu 22.04 is 3.10)
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install python3.9 python3.9-distutils python3.9-dev pip -y && \
    python3.9 -m pip install pipenv

# Install Node 14
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install nodejs -y && \
    node -v

# clean up apt sources
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable uWSGI and Nginx and remove the default site
# Preserve env variables for nginx
RUN rm -f /etc/service/nginx/down
COPY docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
# COPY vendor/docker/00_app_env.conf /etc/nginx/conf.d/00_app_env.conf

# Use Amazon NTP servers
# COPY vendor/docker/ntp.conf /etc/ntp.conf

# Add Runit script for shoryuken workers
# WORKDIR /home/app/webapp
# RUN mkdir /etc/service/shoryuken
# COPY vendor/docker/shoryuken.sh /etc/service/shoryuken/run

# Copy webapp folder
WORKDIR /home/app
COPY . /home/app/

RUN pipenv install --deploy --pre

# WORKDIR /home/app/webapp

RUN chown app:app  /etc/container_environment && \
    chown -R app:app /home/app && \
    chmod -R 755 /home/app

# enable SSH
RUN rm -f /etc/service/sshd/down && \
    /etc/my_init.d/00_regen_ssh_host_keys.sh

# Run additional scripts during container startup (i.e. not at build time)
RUN mkdir -p /etc/my_init.d

# install custom ssh key during startup
# COPY docker/10_ssh.sh /etc/my_init.d/10_ssh.sh

# COPY vendor/docker/80_flush_cache.sh /etc/my_init.d/80_flush_cache.sh
# COPY vendor/docker/90_migrate.sh /etc/my_init.d/90_migrate.sh

# run as app user
USER app

# Expose web
EXPOSE 80