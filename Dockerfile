FROM aufwin.de/rasp-base:latest AS buildstage

# Geographical data
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
COPY raspGM_36.tar.gz $BASEDIR
RUN cd $BASEDIR \
  && tar xf raspGM_36.tar.gz --strip-components=1 \
  && rm raspGM_36.tar.gz
RUN ls $BASEDIR

# coastlines and lakes
COPY rangs.tgz $BASEDIR
RUN cd $BASEDIR \
  && tar xf rangs.tgz \
  && rm rangs.tgz
RUN ls $BASEDIR

# Prepare region directory
RUN mkdir $BASEDIR/TIR
COPY rasp.run.parameters.TIR $BASEDIR/TIR

# Set up from template
RUN cp -a $BASEDIR/region.TEMPLATE/. $BASEDIR/TIR/
RUN ls $BASEDIR
RUN ls $BASEDIR/TIR

# Overwrite with region specific data
COPY TIR/. $BASEDIR/TIR/
COPY RUN.TABLES/. $BASEDIR/RUN.TABLES
RUN ls $BASEDIR
RUN ls $BASEDIR/TIR

# Overwrite rasp scripts
COPY rasp-gm-TIR/ $BASEDIR/
RUN ls $BASEDIR
RUN ls $BASEDIR/GM

# Run geogrid
RUN cd $BASEDIR/TIR/ \
  && geogrid.exe
RUN rm -rf $BASEDIR/geog

COPY runRasp.sh meteogram.ncl sitedata.ncl title2json.pl rasp2geotiff.py ${BASEDIR}/bin/
COPY logo.svg ${BASEDIR}/

# End buildstage, begin prod container
FROM aufwin.de/rasp-base:latest
COPY --from=buildstage /root/rasp /root/rasp

WORKDIR /root/rasp
COPY aufwinde_key .
RUN chmod 600 aufwinde_key

VOLUME ["/root/rasp/TIR/OUT/", "/root/rasp/TIR/LOG/"]

#Run RASP, move the images to the final directory and copy some extra log files
CMD ["runRasp.sh","TIR"]

