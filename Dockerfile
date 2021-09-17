ARG IMAGE
ARG MAJOR_VERSION
ARG MINOR_VERSION

FROM $IMAGE

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

# install additional required packages for running maya
RUN apt install -y libfam0
RUN apt install -y libcurl4
RUN apt install -y libpcre16-3
RUN apt install -y libjpeg62
RUN apt install -y libxm4
RUN apt install -y xfonts-100dpi
RUN apt install -y xfonts-75dpi

# download maya version
# TODO find how to determine download url dynamically
RUN wget http://trial2.autodesk.com/NetSWDLD/${MAJOR_VERSION}/MAYA/8A2BC89C-9B8B-33FC-949F-C7CAE28366A4/ESD/Autodesk_Maya_${MAJOR_VERSION}_${MINOR_VERSION}_ML_Linux_64bit.tgz -O maya.tgz
RUN mkdir /maya
RUN tar -xvf maya.tgz -C /maya
RUN rm maya.tgz

# convert rpm packages to debian
WORKDIR /maya/Packages
RUN alien -vc *.rpm

RUN apt install -y lsb-core

# install maya packages
RUN apt install -y ./adlmapps*_amd64.deb
RUN apt install -y ./adlmflexnetserveripv6*_amd64.deb
RUN apt install -y ./adlmflexnetclient*_amd64.deb
RUN apt install -y ./adsklicensing*_amd64.deb

# install maya
RUN apt install -y ./maya${MAJOR_VERSION}-64_${MAJOR_VERSION}*_amd64.deb

RUN mkdir /usr/tmpa
RUN chmod 777 /usr/tmp

ENV MAYA_DISABLE_CIP=1
ENV LC_ALL=1

# make mayapy the default python
RUN echo alias hpython="\"/usr/autodesk/maya/bin/mayapy\"" >> ~/.bashrc
RUN echo alias hpip="\"mayapy -m pip\"" >> ~/.bashrc

# setup environment
ENV MAYA_LOCATION=/usr/autodesk/maya/
ENV PATH=$MAYA_LOCATION/bin:$PATH
