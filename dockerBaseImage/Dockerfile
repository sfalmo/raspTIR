FROM fedora:25

#Basic environment
ENV BASEDIR=/root/rasp
ENV TZ=Europe/Berlin
RUN mkdir $BASEDIR

# required packages
RUN dnf update -y && dnf install -y \
  netcdf-fortran \
  nco \
  libpng15 \
  iproute-tc \
  tcp_wrappers-libs \
  sendmail \
  procmail \
  psmisc \
  procps-ng \
  mailx \
  findutils \
  ImageMagick \
  perl-CPAN \
  perl-JSON \
  ncl \
  netcdf \
  libpng \
  libjpeg-turbo \
  which \
  patch \
  vim \
  less \
  bzip2 \
  pigz \
  openssh-clients \
  rsync \
  && dnf clean all
  
# configure CPAN and install required modules
RUN (echo y;echo o conf prerequisites_policy follow;echo o conf commit) | cpan \
  && cpan install Proc/Background.pm

RUN ln -s libnetcdff.so.6 /lib64/libnetcdff.so.5 \
  && ln -s libnetcdf.so.11 /lib64/libnetcdf.so.7

ENV PATH="${BASEDIR}/bin:${PATH}"
ENV LD_LIBRARY_PATH="${BASEDIR}/lib:${LD_LIBRARY_PATH}"

# Set environment for interactive container shells
RUN echo export BASEDIR=$BASEDIR >> /etc/bashrc \
  && echo export PATH+=:\$BASEDIR/bin >> /etc/bashrc
