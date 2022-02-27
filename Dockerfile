FROM confluentinc/cp-kafka-connect:7.0.0

USER root

RUN echo "===> Installing kafka-jdbc-connector" \
&& wget https://github.com/etonzera/kafka-connect-azure-event-hub/raw/main/kafka-connect-libs.tar.gz \
&& tar -xvf kafka-connect-libs.tar.gz -C /usr/share/java/confluent-hub-client
