FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_DIR=/tmp/ohPlayer

RUN mkdir -p ${BUILD_DIR}

WORKDIR ${BUILD_DIR}

USER root

RUN	apt-get update && \
	apt-get install -y software-properties-common && \
	add-apt-repository ppa:longsleep/golang-backports && \
	apt-get update && \
	apt-get install -y gcc-4.8 g++-4.8 \
	gtk+-3-dev libnotify-dev notify-osd \
	libasound2-dev libappindicator3-dev \
	mono-mcs libavcodec-dev libavformat-dev \
	libavresample-dev \
	ruby-dev jruby ruby-ffi git golang-go

# Before building, clone ohdevtools
# into the same parent directory as ohPlayer.
RUN echo "Cloning ohdevtools"
RUN git clone --quiet https://github.com/openhome/ohdevtools.git

RUN echo "Cloning ohPlayer"
RUN git clone --quiet https://github.com/openhome/ohPlayer.git

RUN gem install fpm

WORKDIR ohPlayer

# Still need python2 O-o
RUN apt-get install -y python python-requests python-boto3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 20

# Clone
RUN ./go fetch --all

WORKDIR linux
# Build
RUN DISABLE_GTK=1 make ubuntu // raspbian release build without gtk