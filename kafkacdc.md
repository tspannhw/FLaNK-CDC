# FLaNK-CDC with Kafka Connect

CDC with NiFi, Kafka Connect, Kafka, Cloudera Data in Motion

**Data Flow**

1.  Kafka Connect Source -> CLASS NAME: io.debezium.connector.postgresql.PostgresConnector
2.  Uses pgoutput to consume from Postgresql database via Debezium
3.  Data to produced to Kafka Topic: tspann.public.newjerseybus
4.  CDC is in Stream

**CDC/Debezium/Kafka Consumer**

1.  NiFi consumes from Kafka Topic: tspann.public.newjerseybus
2.  Debezium JSON events are parsed by NiFi
3.  NiFi sends **after** record to ForkEnrichment
4.  NiFi sends plain **after** record as inserts to Oracle 12 database/schema/table: FREEPDB1.TSPANN.NEWJERSEYBUS
5.  Debezium Meta Data attributes are joined with **after** records to build annotated JSON record.
6.  NiFi sends this enhanced JSON event to the Kafka Topic:   ${sourcetable}-cdc ie. newjerseybus-cdc.

For development, use the free dockerized Oracle:   [https://hub.docker.com/r/gvenzl/oracle-free](https://hub.docker.com/r/gvenzl/oracle-free)


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


#### Kafka table

````
CREATE TABLE  `kafka_ibmnewjerseybus` (
  `title` VARCHAR(2147483647),
  `description` VARCHAR(2147483647),
  `pubDate` VARCHAR(2147483647),
  `advisoryAlert` VARCHAR(2147483647),
  `companyname` VARCHAR(2147483647),
  `servicename` VARCHAR(2147483647),
  `guid` VARCHAR(2147483647),
  `link` VARCHAR(2147483647),
  `uuid` VARCHAR(2147483647),
  `ts` BIGINT NOT NULL
) WITH (
  'connector' = 'kafka', 
  'format' = 'json', 
  'properties.bootstrap.servers' = 'kafka:9092'
  'topic' = 'ibm.newjerseybus'
);

````

#### Flink SQL receiver table

````

CREATE TABLE kafka_newjerseybus (
    `title` STRING,
    `description` STRING,
    `link` STRING,
    `guid` STRING,
    `advisoryAlert` STRING,
    `pubDate` STRING,
    `ts` STRING,
    `companyname` STRING,
    `uuid` STRING,
    `servicename` STRING
) WITH (
 'connector' = 'kafka: Local Kafka',
'format' = 'json',
'scan.startup.mode' = 'group-offsets',
'topic' = 'kafka_newjerseybus',
'properties.group.id' = 'flink1-group-id',
'properties.auto.offset.reset' = 'latest'
);


CREATE TABLE kafka_newjerseybus_sink (
    `title` STRING,
    `description` STRING,
    `link` STRING,
    `guid` STRING,
    `advisoryAlert` STRING,
    `pubDate` STRING,
    `ts` STRING,
    `companyname` STRING,
    `uuid` STRING,
    `servicename` STRING
) WITH (
 'connector' = 'kafka',
'format' = 'json',
'scan.startup.mode' = 'group-offsets',
'topic' = 'kafka_newjerseybus',
'properties.group.id' = 'flink1-group-id',
'properties.auto.offset.reset' = 'earliest'
);

````

#### Flink SQL Table Build

````

CREATE TABLE `postgres_cdc_newjerseybus` (
    `title` STRING,
    `description` STRING,
    `link` STRING,
    `guid` STRING,
    `advisoryAlert` STRING,
    `pubDate` STRING,
    `ts` STRING,
    `companyname` STRING,
    `uuid` STRING,
    `servicename` STRING
) WITH (
  'connector' = 'postgres-cdc', 
  'database-name' = 'tspann', 
  'hostname' = '192.168.1.153',
  'password' = 'tspann', 
  'decoding.plugin.name' = 'pgoutput',
  'schema-name' = 'public',
  'table-name' = 'newjerseybus',
  'username' = 'tspann',
  'port' = '5432'
);

CREATE TABLE  `postgres_newjerseytransit` (
    `title` STRING,
    `description` STRING,
    `link` STRING,
    `guid` STRING,
    `advisoryAlert` STRING,
    `pubDate` STRING,
    `ts` STRING,
    `companyname` STRING,
    `uuid` STRING primary key,
    `servicename` STRING
) WITH (
  'connector' = 'jdbc', 
  'table-name' = 'newjerseytransit', 
  'url' = 'jdbc:postgresql://192.168.1.153:5432/tspann',
  'password' = 'tspann',
  'username' = 'tspann'
);


````


Kafka topic tspann.public.newjerseybus


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


### Oracle

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

SQL> CREATE USER TEST IDENTIFIED BY test QUOTA UNLIMITED ON USERS;

User created.

SQL> GRANT CONNECT, RESOURCE TO TEST;

Grant succeeded.

SQL> GRANT CONNECT, RESOURCE to NIFI;

Grant succeeded.

SQL> GRANT CONNECT, RESOURCE to TSPANN;

Grant succeeded.

SQL> GRANT ALL PRIVILEGES TO TEST;

Grant succeeded.

SQL> GRANT ALL PRIVILEGES TO TSPANN;

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
