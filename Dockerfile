FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update --fix-missing && apt-get -y upgrade

# Install gcc
RUN apt-get update && \
    apt-get -y install gcc mono-mcs && \
    rm -rf /var/lib/apt/lists/*

# Compile
ADD challenge/script.sh /home/ctf/script.sh
ADD challenge/bof.c /home/ctf/bof.c
RUN chmod +x /home/ctf/script.sh
RUN /home/ctf/script.sh

# System deps
RUN apt-get install -y lib32z1 libseccomp-dev xinetd locales

# Create ctf-user
RUN groupadd -r ctf && useradd -r -g ctf ctf
RUN mkdir /home/ctf

# Configuration files/scripts
ADD config/ctf.xinetd /etc/xinetd.d/ctf
ADD config/run_xinetd.sh /etc/run_xinetd.sh
ADD config/run_challenge.sh /home/ctf/run_challenge.sh

# Challenge files
ADD challenge/flag.txt /home/ctf/flag.txt
ADD challenge/bof /home/ctf/bof

# Set some proper permissions
RUN chown -R root:ctf /home/ctf
RUN chmod 750 /home/ctf/bof
RUN chmod 750 /home/ctf/run_challenge.sh
RUN chmod 440 /home/ctf/key.txt
RUN chmod 700 /etc/run_xinetd.sh

# Setup locales
# RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
# ENV LANG en_US.UTF-8
# ENV LC_ALL en_US.UTF-8

RUN service xinetd restart
