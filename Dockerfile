FROM ubuntu:16.04 as base

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/skel/.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD bash -c 'export > /etc/envvars && /usr/sbin/runsvdir-start'

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

#Kibana
RUN wget -O - https://artifacts.elastic.co/downloads/kibana/kibana-6.3.2-linux-x86_64.tar.gz | tar xz && \
    mv kibana-* kibana

#Logtrail
RUN /kibana/bin/kibana-plugin install https://github.com/sivasamyk/logtrail/releases/download/v0.1.29/logtrail-6.3.2-0.1.29.zip

#COPY kibana.yml /kibana/config/kibana.yml
COPY logtrail.json /kibana/plugins/logtrail/logtrail.json

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
