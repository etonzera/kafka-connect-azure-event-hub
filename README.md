# kafka-connect-azure-event-hub
How to integrate data near real time with kafka-connect, mysql and azure event hub

# Prerequisites
- [Docker](https://www.docker.com/ "Docker");
- [Miinikube](https://minikube.sigs.k8s.io/docs/start/ "Miinikube");
- [Helm](https://helm.sh/ "Helm").

## Clone the repository
```sh
git clone https://github.com/etonzera/kafka-connect-azure-event-hub.git
```
## Preparing kafka connect image in your local repository
```sh
cd kafka-connect-azure-event-hub/
docker build -t kafka-connect-sample/cp-kafka-connect:7.7.0-csv .
```
## Sync your local docker repository with minikube
```sh
eval $(minikube docker-env)
```
## Open the *values.yaml* file and change the properties below according to your azure event hub namespace:
| Key | Value |
| ------ | ------ |
| bootstrap.servers | change the value according to your AWS namespaces information ex: broker.services.:9092 |
| sasl.jaas.config | change the value according to your event-hub namespaces information ex: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=inputHereYourEndpointSecretAWS";'|
| producer.sasl.jaas.config | change the value according to your event-hub namespaces information ex: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=inputHereYourEndpointSecretAWS";'|
| consumer.sasl.jaas.config | change the value according to your event-hub namespaces information ex: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=inputHereYourEndpointSecretAWS";'|

## Installing kafka connect on minikube with helm chart
```sh
helm install  my-kafka-connect -f values.yaml ./cp-kafka-connect
#uninstall
helm uninstall my-kafka-connect
```

## Since we are not using the example ingress, we need to forward the kube port
```sh
kubectl port-forward svc/my-kafka-connect-cp-kafka-connect 8083 #Don't close the command, open a new tab from the terminal to continue with the tutorial
```
## Open the *mysql-source.json* file and change the properties below according to your database infos:
| Key | Value |
| ------ | ------ |
| connection.url | ex: jdbc: mysql://inputHereYourIPDatabase:3306/inputHereYourNameDatabase |
| connection.user | ex: userDB |
| connection.password | ex: passwordDB |
| topic.prefix | ex: nameYourTopicEventHub |

## Creating a connector by rest API
```sh
curl -X POST -H "Content-Type: application/json" --data @./csv-connector.json http://localhost:8083/connectors
```
## Consuming offsets from your topic
- Open the* jaas.conf * file and change the property according to your event-hub information ex:
`password="Endpoint=sb://inputHereYourEndpointSecretAWS";`

- Export the variable environments 
```sh
export AWS_NAMESPACE=yourEventHubNamespace
export AWS_TOPIC_NAME=yourTopicName
export KAFKA_OPTS="-Djava.security.auth.login.config=jaas.conf"
export KAFKA_INSTALL_HOME=/home/path/to/confluent-7.0.0 #path of your kafka connect binary
```
- Consuming topic offsets
```sh 
$KAFKA_INSTALL_HOME/bin/kafka-console-consumer --from-beginning --topic $AWS_HUB_TOPIC_NAME --bootstrap-server $AWS_HUB_NAMESPACE.broker:9092 --consumer.config client_common.properties
```


