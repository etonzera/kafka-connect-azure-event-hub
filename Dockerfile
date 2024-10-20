FROM confluentinc/cp-kafka-connect:7.7.0

USER root

RUN echo "===> Installing kafka-connector" \
&& wget https://github.com/etonzera/kafka-connect-azure-event-hub/raw/main/jcustenborder-kafka-connect-spooldir-2.0.65.tar.gz \
&& tar -xvf jcustenborder-kafka-connect-spooldir-2.0.65.tar.gz -C /usr/share/java/confluent-hub-client \
&& wget https://github.com/aws/aws-msk-iam-auth/releases/download/v2.2.0/aws-msk-iam-auth-2.2.0-all.jar \
&& cp -R aws-msk-iam-auth-2.2.0-all.jar /usr/share/java/confluent-hub-client
&& mkdir -p /tmp/data/{error,processed,unprocessed}
