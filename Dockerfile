# This image is supposed to run "once" in a container. Build it and run (once). 
#   docker-compose -f docker-compose.yml build tir
#   docker-compose -f docker-compose.yml run tir
# create a file called '.env' with targetUrl to upload images on a (remote) webserver

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
  openssh-clients
  
# configure CPAN and install required modules
RUN (echo y;echo o conf prerequisites_policy follow;echo o conf commit) | cpan \
  && cpan install Proc/Background.pm

# fix dependencies
RUN ln -s libnetcdff.so.6 /lib64/libnetcdff.so.5 \
  && ln -s libnetcdf.so.11 /lib64/libnetcdf.so.7

WORKDIR /root/

# Get necessary data into container

# Geographical data directory
COPY geog.tar.gz $BASEDIR
RUN cd $BASEDIR \
  && tar xf geog.tar.gz \
  && rm geog.tar.gz
RUN ls $BASEDIR

COPY geog.fine.tar.gz $BASEDIR
RUN cd $BASEDIR \
  && tar xf geog.fine.tar.gz \
  && rm geog.fine.tar.gz
RUN ls $BASEDIR

# raspGM base
COPY rasp-gm-stable.tar.gz $BASEDIR
RUN cd $BASEDIR \
  && tar xf rasp-gm-stable.tar.gz --strip-components=1 \
  && rm rasp-gm-stable.tar.gz
RUN ls $BASEDIR

# coastlines and lakes
COPY rangs.tgz $BASEDIR
RUN cd $BASEDIR \
  && tar xf rangs.tgz \
  && rm rangs.tgz
RUN ls $BASEDIR

# Set environment for interactive container shells
RUN echo export BASEDIR=$BASEDIR >> /etc/bashrc \
  && echo export PATH+=:\$BASEDIR/bin >> /etc/bashrc

# cleanup 
RUN yum clean all

# Prepare region directory
RUN mkdir $BASEDIR/TIR
COPY rasp.run.parameters.TIR $BASEDIR/TIR

# Change download links to new format
RUN sed -i 's/gfs.%04d%02d%02d%02d/gfs.%04d%02d%02d\/%02d/' $BASEDIR/bin/GM-master.pl

# Set up from template
RUN cp -a $BASEDIR/region.TEMPLATE/. $BASEDIR/TIR/
RUN ls $BASEDIR
RUN ls $BASEDIR/TIR

# Overwrite with region specific data
COPY TIR/. $BASEDIR/TIR/
COPY RUN.TABLES/. $BASEDIR/RUN.TABLES
RUN ls $BASEDIR
RUN ls $BASEDIR/TIR

COPY rasp-gm-TIR/ $BASEDIR/
RUN ls $BASEDIR
RUN ls $BASEDIR/GM

ENV PATH="${BASEDIR}/bin:${PATH}"

# initialize
RUN cd $BASEDIR/TIR/ \
  && geogrid.exe

RUN rm -rf $BASEDIR/geog

WORKDIR /root/rasp/

VOLUME ["/root/rasp/TIR/OUT/", "/root/rasp/TIR/LOG/"]

COPY runRasp.sh meteogram.ncl sitedata.ncl ${BASEDIR}/bin/
COPY logo.png ${BASEDIR}/

#Run RASP, move the images to the final directory and copy some extra log files
CMD ["runRasp.sh","TIR"]

