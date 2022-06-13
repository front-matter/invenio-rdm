FROM phusion/passenger-full:2.3.0
LABEL maintainer="martin@front-matter.io"

# Set correct environment variables.
ENV HOME /home/app
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Allow app user to read /etc/container_environment
RUN usermod -a -G docker_env app

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Update installed APT packages
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get install ntp curl wget nano tmux tzdata software-properties-common imagemagick shared-mime-info -y
# Install Python 3.10 and Node 16
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install python3.10 -y && \
    curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install nodejs -y && \
    node -v

# clean up apt sources
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Passenger and Nginx and remove the default site
# Preserve env variables for nginx
# RUN rm -f /etc/service/nginx/down && \
 #   rm /etc/nginx/sites-enabled/default
# COPY vendor/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
# COPY vendor/docker/00_app_env.conf /etc/nginx/conf.d/00_app_env.conf

# Use Amazon NTP servers
# COPY vendor/docker/ntp.conf /etc/ntp.conf

# Add Runit script for shoryuken workers
# WORKDIR /home/app/webapp
# RUN mkdir /etc/service/shoryuken
# COPY vendor/docker/shoryuken.sh /etc/service/shoryuken/run

# Install Passenger monitor for Datadog
# RUN wget https://github.com/Sjeanpierre/passenger-datadog-monitor/releases/download/v1.00/passenger-datadog-monitor && \
#     mv passenger-datadog-monitor /usr/local/bin && \
#     chmod +x /usr/local/bin/passenger-datadog-monitor && \
#     mkdir /etc/service/passenger-datadog
# COPY vendor/docker/passenger-datadog.sh /etc/service/passenger-datadog/run
# RUN chmod +x /etc/service/passenger-datadog/run


WORKDIR /home/app/webapp

# Copy webapp folder
# COPY . /home/app/webapp/
# RUN mkdir -p tmp/pids && \
 #   mkdir -p tmp/storage && \
  #  chown -R app:app /home/app/webapp && \
  #  chmod -R 755 /home/app/webapp

# enable SSH
RUN rm -f /etc/service/sshd/down && \
    /etc/my_init.d/00_regen_ssh_host_keys.sh

# Run additional scripts during container startup (i.e. not at build time)
RUN mkdir -p /etc/my_init.d

# install custom ssh key during startup
# COPY vendor/docker/10_ssh.sh /etc/my_init.d/10_ssh.sh

# COPY vendor/docker/80_flush_cache.sh /etc/my_init.d/80_flush_cache.sh
# COPY vendor/docker/90_migrate.sh /etc/my_init.d/90_migrate.sh

# Expose web
# EXPOSE 80