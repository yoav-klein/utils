
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y sudo
RUN apt-get install -y systemd
RUN apt-get install -y tzdata

RUN useradd -m agent
RUN usermod -aG sudo agent
RUN /bin/bash -c "echo agent:agent | chpasswd"

USER agent

