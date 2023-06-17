# FLaNK-CDC with Kafka Connect

CDC with NiFi, Kafka Connect, Kafka, Cloudera Data in Motion



![cdcdiagram](https://github.com/tspannhw/FLaNK-CDC/blob/main/cdckafkaconnectdebeziumnifioracle.png?raw=true)
**Data Flow**

1.  Use SMM to easily configure.
2.  Kafka Connect Source -> CLASS NAME: io.debezium.connector.postgresql.PostgresConnector
3.  Uses pgoutput to consume from Postgresql database via Debezium
4.  Data to produced to Kafka Topic: **tspann.public.newjerseybus**
5.  CDC is in Stream

**CDC/Debezium/Kafka Consumer**

1.  NiFi consumes from Kafka Topic: **tspann.public.newjerseybus**
2.  Debezium JSON events are parsed by NiFi
3.  NiFi sends **after** record to ForkEnrichment
4.  NiFi sends plain **after** record as inserts to Oracle 23 database/schema/table: FREEPDB1.TSPANN.NEWJERSEYBUS
5.  Debezium Meta Data attributes are joined with **after** records to build annotated JSON record.
6.  NiFi sends this enhanced JSON event to the Kafka Topic:   ${sourcetable}-cdc ie. newjerseybus-cdc.


Consume from Kafka Topic
![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/consumeKafka1.jpg?raw=true)
![nifi2](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/consumekafka2.jpg?raw=true)


![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/addDebeziumFields0.jpg?raw=true)
![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/addDebeziumFields.jpg?raw=true)

EvaluateJsonPath (Parse JSON) - extract Debezium Event Fields

![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/buildJSON.jpg?raw=true)

Extract "after" json

![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/cdcattributesToJson.jpg?raw=true)

![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/forktokafkaandoracle.jpg?raw=true)


Build New JSON Record: After the Fork Enrichment, Add Debezium Fields

![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/cdcattributesToJson.jpg?raw=true)

After new JSON enhancement, let's join those two records together automagically

![nifi](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/joinenrichmentcdc.jpg?raw=true)

The Final Kafka Message Produced From our New Fields

![kafka](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/cdcenhancedkafkamessage.jpg?raw=true)



For development, use the free dockerized Oracle:   [https://hub.docker.com/r/gvenzl/oracle-free](https://hub.docker.com/r/gvenzl/oracle-free)

![cdc](https://github.com/tspannhw/FLaNK-CDC/blob/main/workingoncdc.jpg?raw=true)

#### Video Walkthru 

[https://www.youtube.com/watch?v=NPWglZW3rig&ab_channel=DatainMotion](https://www.youtube.com/watch?v=NPWglZW3rig&ab_channel=DatainMotion)

#### Kafka Connect Scripts

````
curl -X GET "http://localhost:8585/api/v1/admin/kafka-connect/connectors" -H "accept: application/json"

{"connectors":{"postgresqlsource":{"name":"postgresqlsource","workerId":"172.18.0.8:28083","type":"source","state":"RUNNING","trace":null,"config":{"connector.class":"io.debezium.connector.postgresql.PostgresConnector","database.dbname":"tspann","database.history.kafka.bootstrap.servers":"${cm-agent:ENV:KAFKA_BOOTSTRAP_SERVERS}","database.history.kafka.topic":"schema-changes.bus-postgres","database.hostname":"192.168.1.153","database.password":"tspann","database.port":"5432","database.server.id":"184055","database.server.name":"tspann","database.user":"tspann","name":"postgresqlsource","plugin.name":"pgoutput","secret.properties":"database.password","tasks.max":"1"},"tasks":{"0":{"workerId":"172.18.0.8:28083","state":"RUNNING","trace":null}},"topics":["tspann.public.newjerseybus"]}}}

curl -X GET "http://localhost:8585/api/v1/admin/metrics/connect/workers" -H "accept: application/json"

curl -X PUT "http://localhost:8585/api/v1/admin/kafka-connect/connectors/$schemaname" -H "accept: application/json" -H "Content-Type: application/json" -d @postgresqlsource.json

curl -X GET "http://localhost:8585/api/v1/admin/kafka-connect/connector-plugins" -H "accept: application/json"
[{"type":"sink","version":"0.0.1.7.2.16.0-287","class":"com.cloudera.dim.kafka.connect.hdfs.HdfsSinkConnector"},{"type":"sink","version":"0.0.1.7.2.16.0-287","class":"com.cloudera.dim.kafka.connect.s3.S3SinkConnector"},{"type":"source","version":"1.9.5.Final","class":"io.debezium.connector.db2.Db2Connector"},{"type":"source","version":"1.8.0.Final","class":"io.debezium.connector.mysql.MySqlConnector"},{"type":"source","version":"1.8.0.Final","class":"io.debezium.connector.oracle.OracleConnector"},{"type":"source","version":"1.8.0.Final","class":"io.debezium.connector.postgresql.PostgresConnector"},{"type":"source","version":"1.8.0.Final","class":"io.debezium.connector.sqlserver.SqlServerConnector"},{"type":"source","version":"1","class":"org.apache.kafka.connect.mirror.MirrorCheckpointConnector"},{"type":"source","version":"1","class":"org.apache.kafka.connect.mirror.MirrorHeartbeatConnector"},{"type":"source","version":"1","class":"org.apache.kafka.connect.mirror.MirrorSourceConnector"},{"type":"sink","version":"1.18.0.2.4.3.0-63","class":"org.apache.nifi.kafka.connect.StatelessNiFiSinkConnector"},{"type":"source","version":"1.18.0.2.4.3.0-63","class":"org.apache.nifi.kafka.connect.StatelessNiFiSourceConnector"}]

curl -X GET "http://localhost:8585/api/v1/admin/kafka-connect/is-configured" -H "accept: application/json"
true

curl -X GET "http://localhost:8585/api/v1/admin/metrics/producers?state=all&duration=LAST_THIRTY_DAYS" -H "accept: application/json"


````

#### Postgresql table

````
CREATE TABLE newjerseybus
(
    title VARCHAR(255), 
    description VARCHAR(255),
    link VARCHAR(255),
    guid   VARCHAR(255),
    advisoryAlert VARCHAR(255),
    pubDate VARCHAR(255), 
    ts VARCHAR(255),
    companyname VARCHAR(255),
    uuid VARCHAR(255),
    servicename VARCHAR(255)
)


````

### Kafka Connect Parms

````
	"connector.class": "io.debezium.connector.postgresql.PostgresConnector",
	"database.dbname": "tspann",
	"database.history.kafka.bootstrap.servers": "${cm-agent:ENV:KAFKA_BOOTSTRAP_SERVERS}",
	"database.history.kafka.topic": "schema-changes.bus-postgres",
	"database.hostname": "192.168.1.153",
	"database.password": "tspann",
	"database.port": "5432",
	"database.server.id": "184055",
	"database.server.name": "tspann",
	"database.user": "tspann",
	"name": "postgresqlsource",
	"plugin.name": "pgoutput",
	"secret.properties": "database.password",
	"tasks.max": "1"
````		


### Resources

* https://github.com/tspannhw/ApacheConAtHome2020
* https://github.com/tspannhw/CloudDemo2021


### Example Bus Data

|title|description|link|guid|advisoryalert|pubdate|ts|companyname|uuid|servicename|
|-----|-----------|----|----|-------------|-------|--|-----------|----|-----------|
|BUS 1 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086335|newjersey|d18a2b0e-f59c-4ac8-b479-0322c9fd45bb|bus|
|BUS 2 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086335|newjersey|ea24f013-ad60-4ac0-b8b3-ee81356faf09|bus|
|BUS 6 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086336|newjersey|ef3c7f59-2a40-4004-953b-2a4b4775d146|bus|
|BUS 10 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086336|newjersey|1cc9b0ce-f7e0-47ec-b09d-e2e442c01f02|bus|
|BUS 13 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086336|newjersey|e87ba787-3b2e-4914-b82d-aad71323343f|bus|
|BUS 22 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086337|newjersey|c8cde5d9-4a38-471f-ac16-06173a623ada|bus|
|BUS 25 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086337|newjersey|f5825247-fac5-4bb6-81ea-5108f40c2f94|bus|
|BUS 28 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||Jun 06, 2023 10:45:32 AM|1686083086338|newjersey|bddb840a-9d8b-4607-a19a-e38e16f019e1|bus|
|BUS 29 - Jun 06, 2023 10:45:32 AM|NJ TRANSIT Bus Customer Satisfaction Survey – Effective Immediately |https://www.njtransit.com/node/1613627|https://www.njtransit.com/node/1613627||


### Oracle Table Setup

````
bash-4.4$ sqlplus sys/Cloudera2023 as sysdba

SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Thu Jun 15 19:49:07 2023
Version 23.2.0.0.0

Copyright (c) 1982, 2023, Oracle.  All rights reserved.

Connected to:
Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0

SQL> ALTER SESSION SET CONTAINER=FREEPDB1;

Session altered.

SQL> CREATE USER NIFI IDENTIFIED BY test QUOTA UNLIMITED ON USERS;

User created.

SQL> GRANT CONNECT, RESOURCE to NIFI;

Grant succeeded.

SQL> GRANT ALL PRIVILEGES TO NIFI;

Grant succeeded.

SQL> commit;

Commit complete.

SQL> EXIT;
Disconnected from Oracle Database 23c Free, Release 23.0.0.0.0 - Developer-Release
Version 23.2.0.0.0

-- DROP TABLE TSPANN.NEWJERSEYBUS;

CREATE TABLE TSPANN.NEWJERSEYBUS (
	TITLE VARCHAR2(255) NULL,
	DESCRIPTION VARCHAR2(255) NULL,
	LINK VARCHAR2(255) NULL,
	GUID VARCHAR2(255) NULL,
	ADVISORYALERT VARCHAR2(255) NULL,
	PUBDATE VARCHAR2(255) NULL,
	TS VARCHAR2(255) NULL,
	COMPANYNAME VARCHAR2(255) NULL,
	UUID VARCHAR2(255) NOT NULL,
	SERVICENAME VARCHAR2(255) NULL,
	CONSTRAINT SYS_C008226 PRIMARY KEY (UUID)
);
CREATE UNIQUE INDEX SYS_C008226 ON TSPANN.NEWJERSEYBUS (UUID);

````
Tim Spann



#### Cat Data Capture


![cat](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/IMG_7651.jpeg?raw=true)

![cat2](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/IMG_7658.jpg?raw=true)


