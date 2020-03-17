FROM solr:8.4.1 AS config

# install jq json processor
USER root
RUN wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
RUN chmod 777 jq
USER $SOLR_USER

#RUN git clone https://github.com/stedolan/jq.git; \
#  cd jq; \
#  autoreconf -i; \
#  ./configure --disable-maintainer-mode; \
#  make; \
#  sudo make install

# copy drivers
COPY sql_drivers /opt/solr/server/lib

# copy core config scripts
COPY core_config ./core_config

# copy init script
COPY init.sh .
COPY create_core.sh .

# initialize core
RUN ./init.sh example

# start a new image without the temporary files generated during configuration
FROM solr:8.4.1 AS runtime

# bring over only the new core configuration
COPY --from=config /tmp/data /tmp/data

# copy the core configuration to where it should be and start the server
CMD ["sh","-c","cp -r /tmp/data /var/solr/data ; solr-foreground"]