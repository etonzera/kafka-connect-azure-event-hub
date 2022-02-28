# kafka-connect-azure-event-hub
How to integrate data near real time with kafka-connect, mysql and azure event hub

# Pre Requirements
- [Docker](https://www.docker.com/ "Docker");
- [Miinikube](https://minikube.sigs.k8s.io/docs/start/ "Miinikube");
- [Helm](https://helm.sh/ "Helm").

## Clone the repository
```sh
git clone https://github.com/etonzera/kafka-connect-azure-event-hub.git
```

##  DATABASE
```sh
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=yourPasswdRoot -e MYSQL_DATABASE=test -e MYSQL_USER=yourUserMySQL -e MYSQL_PASSWORD=yourPasswordNewUser mysql:latest
```
## Connect to database test and execute the script below:
```sh
-- test.usuario definition

CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `stamp_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```
## Preparing kafka connect image in your local repository
```sh
cd kafka-connect-azure-event-hub/
docker build -t kafka-connect-sample/cp-kafka-connect:7.0.1-jdbc .
```
## Open the *values.yaml* file and change the properties below according to your azure event hub namespace:
| Key | Value |
| ------ | ------ |
| bootstrap.servers | change the value according to your event-hub namespaces information ex: yourserver.servicebus.windows.net:9093 |
| sasl.jaas.config | change the value according to your event-hub namespaces information ex: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=inputHereYourEndpointSecretAzure";'|
| producer.sasl.jaas.config | change the value according to your event-hub namespaces information ex: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=inputHereYourEndpointSecretAzure";'|
| consumer.sasl.jaas.config | change the value according to your event-hub namespaces information ex: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=inputHereYourEndpointSecretAzure";'|

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
curl -X POST -H "Content-Type: application/json" --data @./mysql-source.json http://localhost:8083/connectors
```
## Consuming offsets from your topic
- Open the* jaas.conf * file and change the property according to your event-hub information ex:
`password="Endpoint=sb://InputHereYourEndpointAzure";`

- Export the variable environments 
```sh
export EVENT_HUB_NAMESPACE=yourEventHubNamespace
export EVENT_HUB_TOPIC_NAME=yourTopicName
export KAFKA_OPTS="-Djava.security.auth.login.config=jaas.conf"
export KAFKA_INSTALL_HOME=/home/path/to/confluent-7.0.0 #path of your kafka connect binary
```
- Consuming topic offsets
```sh 
$KAFKA_INSTALL_HOME/bin/kafka-console-consumer --from-beginning --topic $EVENT_HUB_TOPIC_NAME --bootstrap-server $EVENT_HUB_NAMESPACE.servicebus.windows.net:9093 --consumer.config client_common.properties
```
## Finally, insert a record in the user table and watch the magic happen
```sh 
insert into user (id, name, description) values (1, 'everton.barros', 'Genesis company owner!')
```
