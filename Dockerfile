FROM centos:7

MAINTAINER Sebastien LANGOUREAUX <sebastien.langoureaux@sihm.fr>

ARG http_proxy
ARG https_proxy

ENV PUPPET_VERSION=5.3.5 \
    LANG=C.UTF-8


# Install ruby and require for beaker
RUN \
    yum install -y rubygems make ruby-dev libxml2 libxml2-dev libxslt1-dev g++ zlib1g-dev &&\
    yum clean packages

# Install puppet
RUN gem install puppet -v=${PUPPET_VERSION}

# Install ruby lib
RUN gem install rspec && gem install rspec-puppet && gem install rspec-puppet-facts
RUN gem install puppetlabs_spec_helper
RUN gem install puppet-lint

# Install puppet modules
RUN \
    puppet module install puppetlabs/stdlib &&\
    puppet module install puppetlabs-inifile --version 2.1.1

COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml

# Systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;


VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]


