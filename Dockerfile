ARG IMAGE

FROM $IMAGE

ARG MAJOR_VERSION
ARG MINOR_VERSION

USER root

# install pacakges
RUN  apt update
RUN  apt install -y apt-utils
RUN  apt install -y wget
RUN  apt install -y alien
RUN  apt install -y dpkg-dev
RUN  apt install -y debhelper
RUN  apt install -y build-essential
RUN  apt install -y zlib1g-dev
RUN  apt install -y software-properties-common

RUN add-apt-repository ppa:zeehio/libxp
RUN apt update
RUN apt -y install libxp6

# download maya version
# TODO find how to determine download url dynamically
RUN wget http://trial2.autodesk.com/NetSWDLD/${MAJOR_VERSION}/MAYA/8A2BC89C-9B8B-33FC-949F-C7CAE28366A4/ESD/Autodesk_Maya_${MAJOR_VERSION}_${MINOR_VERSION}_ML_Linux_64bit.tgz -O maya.tgz
RUN mkdir /maya
RUN tar -xvf maya.tgz -C /maya
RUN rm maya.tgz

# convert rpm packages to debian
WORKDIR /maya/Packages
RUN alien -vc *.rpm

# install packages for standalone licensing
RUN apt install -y lsb-core

# install maya packages
RUN apt install -y ./adlmapps*_amd64.deb
RUN apt install -y ./adlmflexnetserveripv6*_amd64.deb
RUN apt install -y ./adlmflexnetclient*_amd64.deb
RUN apt install -y ./adsklicensing*_amd64.deb

# install maya
RUN apt install -y ./maya${MAJOR_VERSION}-64_${MAJOR_VERSION}*_amd64.deb

# install additional required packages for running maya
RUN apt install -y libfam0
RUN apt install -y libcurl4
RUN apt install -y libpcre16-3
RUN apt install -y libjpeg62
RUN apt install -y libxm4
RUN apt install -y xfonts-100dpi
RUN apt install -y xfonts-75dpi

# install additional dependencies
RUN sudo ln -s /usr/lib/x86_64-linux-gnu/libpcre16.so.3 /usr/autodesk/maya${MAJOR_VERSION}/lib/libpcre16.so.0
RUN sudo ln -s /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/autodesk/maya${MAJOR_VERSION}/lib/libssl.so.10
RUN sudo ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/autodesk/maya${MAJOR_VERSION}/lib/libcrypto.so.10
RUN sudo ln -s /usr/lib/x86_64-linux-gnu/libXp.so.6 /usr/autodesk/maya${MAJOR_VERSION}/lib/libXp.so.6


RUN apt install -y libglu1-mesa
RUN apt install -y libxinerama1
RUN apt install -y libexpat1
RUN apt install -y libxpm4
RUN apt install -y libxi6

WORKDIR ~/tmp
RUN wget https://sourceforge.net/projects/libpng/files/libpng15/older-releases/1.5.15/libpng-1.5.15.tar.gz
RUN tar -zxvf ./libpng-1.5.15.tar.gz
WORKDIR libpng-1.5.15
RUN ./configure --prefix=/usr/local/libpng
RUN make check
RUN make install
RUN make check
RUN sudo ln -s /usr/local/libpng/lib/libpng15.so.15 /usr/autodesk/maya2022/lib/libpng15.so.15

RUN apt install -y libxcomposite-dev
RUN apt install -y libxrandr-dev
RUN apt install -y libxcursor1
RUN apt install -y libxtst6
RUN apt install -y libxkbcommon-x11-0
RUN apt install -y libasound2

RUN mkdir /usr/tmpa
RUN chmod 777 /usr/tmp

USER ue4

# Setup environment
ENV MAYA_LOCATION=/usr/autodesk/maya${MAJOR_VERSION}/
ENV PATH=$MAYA_LOCATION/bin:$PATH

# Avoid warning about this variable not set, the path is its default value
RUN mkdir /var/tmp/runtime-root && \
    chmod 0700 /var/tmp/runtime-root
ENV XDG_RUNTIME_DIR=/var/tmp/runtime-root

ENV MAYA_DISABLE_CIP=1
ENV LC_ALL=1

# make mayapy the default python
RUN echo alias hpython="\"/usr/autodesk/maya/bin/mayapy\"" >> ~/.bashrc
RUN echo alias hpip="\"mayapy -m pip\"" >> ~/.bashrc

# setup environment
ENV MAYA_LOCATION=/usr/autodesk/maya/
ENV PATH=$MAYA_LOCATION/bin:$PATH

# install python packages
RUN python3 -m pip install html-testRunner
RUN cd $(python3 -m site --user-site) &&\
    cd .. &&\
    cd .. &&\
    cp -r python3.6 python3.7

