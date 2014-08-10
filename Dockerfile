# Chef cookbook testing, Debian/Ubuntu systems
#
# VERSION               0.0.2

FROM      debian:wheezy
#FROM      ubuntu:precise
MAINTAINER Emanuele Rocca <ema@linux.it>

RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh

# Replace this with your public SSH key. Mine is hosted on keychain.io.
ADD http://ssh.keychain.io/ema@linux.it /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Do not restart sshd causing the container to exit
RUN printf '#!/bin/sh\n\nexit 101\n' > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

# Install ssh, curl and locales
RUN apt-get update
RUN apt-get install -y openssh-server curl locales
RUN apt-get clean

# Generate and set default locale
RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen
RUN locale-gen
RUN echo LANG=en_US.UTF-8 > /etc/default/locale

RUN mkdir /var/run/sshd
