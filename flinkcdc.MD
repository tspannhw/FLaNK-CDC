# FLaNK-CDC with Flink

CDC with NiFi, Flink CDC, Flink SQL, Cloudera Data in Motion

![cdcflinkflow](https://github.com/tspannhw/FLaNK-CDC/blob/main/flinkcdcdebeziumnifi.png?raw=true)

#### Data Flow

1. NiFi insert data into Postgresql via PutDatabaseRecord
2. Create FLink Postgresql-CDC virtual table
3. Flink uses Debezium connect to read data in Debezium JSON format
4. Query CDC Table.   select * from postgres_cdc_newjerseybus

![tim](https://github.com/tspannhw/FLaNK-CDC/blob/main/images/cyberpunkcitytimnano.jpg?raw=true)

### References

- https://docs.cloudera.com/csa/1.10.0/how-to-ssb/topics/csa-ssb-cdc-connectors.html
- https://nightlies.apache.org/flink/flink-docs-master/docs/connectors/table/formats/debezium/
- https://debezium.io/documentation/reference/1.7/
- Debezium Json


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


#### Flink SQL Virtual Table Build

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

````


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



#### Flink SQL Full CDC Postgres table info formatting

````

CREATE TABLE  `postgres_cdc_table_1686070440` (
  `col_str` STRING,
  `col_int` INT,
  `col_ts` TIMESTAMP(3),
   WATERMARK FOR `col_ts` AS col_ts - INTERVAL '5' SECOND
) WITH (
  'connector' = 'postgres-cdc', -- Must be set to 'postgres-cdc' to configure this connector.
  'database-name' = '...', -- Database name of the PostgreSQL server to monitor.
  'hostname' = '...', -- IP address or hostname of the PostgreSQL database server.
  'password' = '...', -- Password to use when connecting to the PostgreSQL database server.
  'schema-name' = '...', -- Table name of the PostgreSQL server to monitor.
  'table-name' = '...', -- Table name of the PostgreSQL server to monitor.
  'username' = '...' -- Name of the PostgreSQL database to use when connecting to the PostgreSQL database server.
  -- 'debezium.binary.handling.mode' = 'bytes' -- Specifies how binary (bytea) columns should be represented in change events,         (1) bytes represents binary data as byte array,         (2) base64 represents binary data as base64-encoded strings,         (3) hex represents binary data as hex-encoded (base16) strings,
  -- 'debezium.column.exclude.list' = '...' -- An optional, comma-separated list of regular expressions that match the fully-qualified names of columns         that should be excluded from change event record values.         Fully-qualified names for columns are of the form schemaName.tableName.columnName. Do not also set the column.include.list property.
  -- 'debezium.column.include.list' = '...' -- An optional, comma-separated list of regular expressions that match the fully-qualified names of columns that         should be included in change event record values.         Fully-qualified names for columns are of the form schemaName.tableName.columnName. Do not also set the column.exclude.list property.
  -- 'debezium.column.mask.with._length_.chars' = '...' -- An optional, comma-separated list of regular expressions that match the fully-qualified names of character-based columns. Fully-qualified names for columns are of the form schemaName.tableName.columnName. In the resulting change event record, the values for the specified columns are replaced with pseudonyms.         A pseudonym consists of the hashed value that results from applying the specified hashAlgorithm and salt. Based on the hash function that is used, referential integrity is maintained, while column values are replaced with pseudonyms. Supported hash functions are described in the MessageDigest section of the Java Cryptography Architecture Standard Algorithm Name Documentation.         In the following example, CzQMA0cB5K is a randomly selected salt.         column.mask.hash.SHA-256.with.salt.CzQMA0cB5K = inventory.orders.customerName, inventory.shipment.customerName         If necessary, the pseudonym is automatically shortened to the length of the column. The connector configuration can include multiple properties that specify different hash algorithms and salts.         Depending on the hashAlgorithm used, the salt selected, and the actual data set, the resulting data set might not be completely masked.
  -- 'debezium.column.propagate.source.type' = '...' -- An optional, comma-separated list of regular expressions that match the fully-qualified names of columns. Fully-qualified names for columns are of the form databaseName.tableName.columnName, or databaseName.schemaName.tableName.columnName.         For each specified column, the connector adds the column’s original type and original length as parameters to the corresponding field schemas in the emitted change records. The following added schema parameters propagate the original type name and also the original length for variable-width types         __debezium.source.column.type + __debezium.source.column.length + __debezium.source.column.scale         This property is useful for properly sizing corresponding columns in sink databases.
  -- 'debezium.column.truncate.to._length_.chars' = '...' -- An optional, comma-separated list of regular expressions that match the fully-qualified names of character-based columns. Fully-qualified names for columns are of the form schemaName.tableName.columnName. In change event records, values in these columns are truncated if they are longer than the number of characters specified by length in the property name. You can specify multiple properties with different lengths in a single configuration. Length must be a positive integer, for example, +column.truncate.to.20.chars.
  -- 'debezium.database.initial.statements' = '...' -- A semicolon separated list of SQL statements that the connector executes when it establishes a JDBC connection to the database. To use a semicolon as a character and not as a delimiter, specify two consecutive semicolons, ;;.         The connector may establish JDBC connections at its own discretion. Consequently, this property is useful for configuration of session parameters only, and not for executing DML statements.         The connector does not execute these statements when it creates a connection for reading the transaction log.
  -- 'debezium.database.sslcert' = '...' -- The path to the file that contains the SSL certificate for the client.
  -- 'debezium.database.sslkey' = '...' -- The path to the file that contains the SSL private key of the client.
  -- 'debezium.database.sslmode' = 'disable' -- Whether to use an encrypted connection to the PostgreSQL server. Options include,         (1) disable uses an unencrypted connection.         (2) require uses a secure (encrypted) connection, and fails if one cannot be established.         (3) verify-ca behaves like require but also verifies the server TLS certificate against the configured Certificate Authority (CA) certificates, or fails if no valid matching CA certificates are found.         (4) verify-full behaves like verify-ca but also verifies that the server certificate matches the host to which the connector is trying to connect.
  -- 'debezium.database.sslpassword' = '...' -- The password to access the client private key from the file specified by database.sslkey.
  -- 'debezium.database.sslrootcert' = '...' -- The path to the file that contains the root certificate(s) against which the server is validated.
  -- 'debezium.database.tcpKeepAlive' = 'true' -- Enable TCP keep-alive probe to verify that the database connection is still alive.
  -- 'debezium.decimal.handling.mode' = 'precise' -- Specifies how the connector should handle values for DECIMAL and NUMERIC columns,         (1) precise represents values by using java.math.BigDecimal to represent values in binary form in change events.         (2) double represents values by using double values, which might result in a loss of precision but which is easier to use.         (3) string encodes values as formatted strings, which are easy to consume but semantic information about the real type is lost.
  -- 'debezium.event.processing.failure.handling.mode' = 'fail' -- Specifies how the connector should react to exceptions during processing of events,         (1) fail propagates the exception, indicates the offset of the problematic event, and causes the connector to stop,         (2) warn logs the offset of the problematic event, skips that event, and continues processing,         (3) skip skips the problematic event and continues processing.
  -- 'debezium.heartbeat.action.query' = '...' -- Specifies a query that the connector executes on the source database when the connector sends a heartbeat message.         This is useful where capturing changes from a low-traffic database on the same host as a high-traffic database prevents Debezium from processing WAL records and thus acknowledging WAL positions with the database. To address this situation, create a heartbeat table in the low-traffic database, and set this property to a statement that inserts records into that table, for example,         INSERT INTO test_heartbeat_table (text) VALUES ('test_heartbeat')         This allows the connector to receive changes from the low-traffic database and acknowledge their LSNs, which prevents unbounded WAL growth on the database host.
  -- 'debezium.heartbeat.interval.ms' = '0' -- Controls how frequently the connector sends heartbeat messages to a Kafka topic. The default behavior is that the connector does not send heartbeat messages.         Heartbeat messages are useful for monitoring whether the connector is receiving change events from the database. Heartbeat messages might help decrease the number of change events that need to be re-sent when a connector restarts. To send heartbeat messages, set this property to a positive integer, which indicates the number of milliseconds between heartbeat messages.         Heartbeat messages are needed when there are many updates in a database that is being tracked but only a tiny number of updates are related to the table(s) and schema(s) for which the connector is capturing changes. In this situation, the connector reads from the database transaction log as usual but rarely emits change records to Kafka. This means that no offset updates are committed to Kafka and the connector does not have an opportunity to send the latest retrieved LSN to the database. The database retains WAL files that contain events that have already been processed by the connector.         Sending heartbeat messages enables the connector to send the latest retrieved LSN to the database, which allows the database to reclaim disk space being used by no longer needed WAL files.
  -- 'debezium.heartbeat.topics.prefix' = '__debezium-heartbeat' -- Controls the name of the topic to which the connector sends heartbeat messages. The topic name has this pattern,         <heartbeat.topics.prefix>.<server.name>         For example, if the database server name is fulfillment, the default topic name is __debezium-heartbeat.fulfillment.
  -- 'debezium.hstore.handling.mode' = 'map' -- Specifies how the connector should handle values for hstore columns,         (1) map represents values by using MAP.         (2) json represents values by using json string.
  -- 'debezium.include.unknown.datatypes' = 'false' -- Specifies connector behavior when the connector encounters a field whose data type is unknown. The default         behavior is that the connector omits the field from the change event and logs a warning.         Set this property to true if you want the change event to contain an opaque binary representation of the field.         This lets consumers decode the field. You can control the exact representation by setting the binary handling mode property.
  -- 'debezium.interval.handling.mode' = 'numeric' -- Specifies how the connector should handle values for interval columns,         (1) numeric represents intervals using approximate number of microseconds.         (2) string represents intervals exactly by using the string pattern representation P<years>Y<months>M<days>DT<hours>H<minutes>M<seconds>S. For example, P1Y2M3DT4H5M6.78S.
  -- 'debezium.max.batch.size' = '10240' -- Positive integer value that specifies the maximum size of each batch of events that the connector processes.
  -- 'debezium.max.queue.size' = '20240' -- Positive integer value for the maximum size of the blocking queue. The connector places change events received from streaming replication in the blocking queue before writing them to Kafka. This queue can provide backpressure when, for example, writing records to Kafka is slower that it should be or Kafka is not available.
  -- 'debezium.max.queue.size.in.bytes' = '0' -- Long value for the maximum size in bytes of the blocking queue.         The feature is disabled by default, it will be active if it’s set with a positive long value.
  -- 'debezium.message.key.columns' = '...' -- A semicolon separated list of tables with regular expressions that match table column names. The connector maps values in matching columns to key fields in change event records that it sends to Kafka topics. This is useful when a table does not have a primary key, or when you want to order change event records in a Kafka topic according to a field that is not a primary key.         Separate entries with semicolons. Insert a colon between the fully-qualified table name and its regular expression. The format is         schema-name.table-name:_regexp_;...         For example,         schemaA.table_a:regex_1;schemaB.table_b:regex_2;schemaC.table_c:regex_3         If table_a has a an id column, and regex_1 is ^i (matches any column that starts with i), the connector maps the value in table_a's id column to a key field in change events that the connector sends to Kafka.
  -- 'debezium.poll.interval.ms' = '1000' -- Positive integer value that specifies the number of milliseconds the connector should wait for new change events         to appear before it starts processing a batch of events. Defaults to 1000 milliseconds, or 1 second.
  -- 'debezium.provide.transaction.metadata' = 'false' -- Determines whether the connector generates events with transaction boundaries and enriches change event envelopes with transaction metadata. Specify true if you want the connector to do this.
  -- 'debezium.publication.autocreate.mode' = 'all_tables' -- Applies only when streaming changes by using the pgoutput plug-in. The setting determines how creation of a publication should work. Possible settings are,         (1) all_tables - If a publication exists, the connector uses it. If a publication does not exist, the connector creates a publication for all tables in the database for which the connector is capturing changes. This requires that the database user that has permission to perform replications also has permission to create a publication. This is granted with CREATE PUBLICATION <publication_name> FOR ALL TABLES;.         (2) disabled - The connector does not attempt to create a publication. A database administrator or the user configured to perform replications must have created the publication before running the connector. If the connector cannot find the publication, the connector throws an exception and stops.         (3) filtered - If a publication exists, the connector uses it. If no publication exists, the connector creates a new publication for tables that match the current filter configuration as specified by the database.exclude.list, schema.include.list, schema.exclude.list, and table.include.list connector configuration properties. For example, CREATE PUBLICATION <publication_name> FOR TABLE <tbl1, tbl2, tbl3>.
  -- 'debezium.publication.name' = 'dbz_publication' -- The name of the PostgreSQL publication created for streaming changes when using pgoutput.         This publication is created at start-up if it does not already exist and it includes all tables. Debezium then applies its own include/exclude list filtering, if configured, to limit the publication to change events for the specific tables of interest. The connector user must have superuser permissions to create this publication, so it is usually preferable to create the publication before starting the connector for the first time.         If the publication already exists, either for all tables or configured with a subset of tables, Debezium uses the publication as it is defined.
  -- 'debezium.retriable.restart.connector.wait.ms' = '10000 (10 seconds)' -- The number of milliseconds to wait before restarting a connector after a retriable error occurs.
  -- 'debezium.sanitize.field.names' = 'true if connector configuration sets the key.converter or value.converter property to the Avro converter.         false if not.' -- Indicates whether field names are sanitized to adhere to Avro naming requirements.
  -- 'debezium.schema.exclude.list' = '...' -- An optional, comma-separated list of regular expressions that match names of schemas for which you do not want         to capture changes. Any schema whose name is not included in schema.exclude.list has its changes captured, with         the exception of system schemas. Do not also set the schema.include.list property.
  -- 'debezium.schema.include.list' = '...' -- An optional, comma-separated list of regular expressions that match names of schemas for which you want to capture changes.         Any schema name not included in schema.include.list is excluded from having its changes captured.         By default, all non-system schemas have their changes captured. Do not also set the schema.exclude.list property.
  -- 'debezium.schema.refresh.mode' = 'columns_diff' -- Specify the conditions that trigger a refresh of the in-memory schema for a table.         (1) columns_diff is the safest mode. It ensures that the in-memory schema stays in sync with the database table’s schema at all times,         (2) columns_diff_exclude_unchanged_toast instructs the connector to refresh the in-memory schema cache if there is a discrepancy with the schema derived from the incoming message, unless unchanged TOASTable data fully accounts for the discrepancy.         This setting can significantly improve connector performance if there are frequently-updated tables that have TOASTed data that are rarely part of updates. However, it is possible for the in-memory schema to become outdated if TOASTable columns are dropped from the table.
  -- 'debezium.slot.drop.on.stop' = 'false' -- Whether or not to delete the logical replication slot when the connector stops in a graceful, expected way. The default behavior is that the replication slot remains configured for the connector when the connector stops. When the connector restarts, having the same replication slot enables the connector to start processing where it left off.         Set to true in only testing or development environments. Dropping the slot allows the database to discard WAL segments. When the connector restarts it performs a new snapshot or it can continue from a persistent offset in the Kafka Connect offsets topic.
  -- 'debezium.slot.max.retries' = '6' -- If connecting to a replication slot fails, this is the maximum number of consecutive attempts to connect.
  -- 'debezium.slot.retry.delay.ms' = '10000 (10 seconds)' -- The number of milliseconds to wait between retry attempts when the connector fails to connect to a replication slot.
  -- 'debezium.slot.stream.params' = '...' -- Semicolon separated list of parameters to pass to the configured logical decoding plug-in. For example, add-tables=public.table,public.table2;include-lsn=true.         If you are using the wal2json plug-in, this property is useful for enabling server-side table filtering. Allowed values depend on the configured plug-in.
  -- 'debezium.snapshot.custom.class' = '...' -- A full Java class name that is an implementation of the io.debezium.connector.postgresql.spi.Snapshotter interface. Required when the snapshot.mode property is set to custom.
  -- 'debezium.snapshot.delay.ms' = '...' -- An interval in milliseconds that the connector should wait before performing a snapshot when the connector starts. If you are starting multiple connectors in a cluster, this property is useful for avoiding snapshot interruptions, which might cause re-balancing of connectors.
  -- 'debezium.snapshot.fetch.size' = '10240' -- During a snapshot, the connector reads table content in batches of rows. This property specifies the maximum number of rows in a batch.
  -- 'debezium.snapshot.include.collection.list' = 'All tables specified in table.include.list' -- An optional, comma-separated list of regular expressions that match names of schemas specified in table.include.list for which you want to take the snapshot when the snapshot.mode is not never
  -- 'debezium.snapshot.lock.timeout.ms' = '10000' -- Positive integer value that specifies the maximum amount of time (in milliseconds) to wait to obtain table locks         when performing a snapshot. If the connector cannot acquire table locks in this time interval, the snapshot fails.
  -- 'debezium.snapshot.mode' = 'initial' -- Specifies the criteria for performing a snapshot when the connector starts,         (1) initial - The connector performs a snapshot only when no offsets have been recorded for the logical server name,         (2) always - The connector performs a snapshot each time the connector starts,         (3) never - The connector never performs snapshots. When a connector is configured this way, its behavior when it starts is as follows. If there is a previously stored LSN in the Kafka offsets topic, the connector continues streaming changes from that position. If no LSN has been stored, the connector starts streaming changes from the point in time when the PostgreSQL logical replication slot was created on the server. The never snapshot mode is useful only when you know all data of interest is still reflected in the WAL.         (4) initial_only - The connector performs an initial snapshot and then stops, without processing any subsequent changes,         (5) vexported - The connector performs a snapshot based on the point in time when the replication slot was created. This is an excellent way to perform the snapshot in a lock-free way,         (6) custom - The connector performs a snapshot according to the setting for the snapshot.custom.class property, which is a custom implementation of the io.debezium.connector.postgresql.spi.Snapshotter interface.
  -- 'debezium.snapshot.select.statement.overrides' = '...' -- Controls which table rows are included in snapshots. This property affects snapshots only. It does not affect events that are generated by the logical decoding plug-in. Specify a comma-separated list of fully-qualified table names in the form databaseName.tableName.         For each table that you specify, also specify another configuration property, snapshot.select.statement.overrides.DB_NAME.TABLE_NAME, for example, snapshot.select.statement.overrides.customers.orders. Set this property to a SELECT statement that obtains only the rows that you want in the snapshot. When the connector performs a snapshot, it executes this SELECT statement to retrieve data from that table.         A possible use case for setting these properties is large, append-only tables. You can specify a SELECT statement that sets a specific point for where to start a snapshot, or where to resume a snapshot if a previous snapshot was interrupted.
  -- 'debezium.table.exclude.list' = '...' -- An optional, comma-separated list of regular expressions that match fully-qualified table identifiers for         tables whose changes you do not want to capture. Any table not included in table.exclude.list has it changes captured.         Each identifier is of the form schemaName.tableName. Do not also set the table.include.list property.
  -- 'debezium.time.precision.mode' = 'adaptive' -- Time, date, and timestamps can be represented with different kinds of precision,         (1) adaptive captures the time and timestamp values exactly as in the database using either millisecond, microsecond, or nanosecond precision values based on the database column’s type.         (2) adaptive_time_microseconds captures the date, datetime and timestamp values exactly as in the database using either millisecond, microsecond, or nanosecond precision values based on the database column’s type. An exception is TIME type fields, which are always captured as microseconds.         (3) connect always represents time and timestamp values by using Kafka Connect’s built-in representations for Time, Date, and Timestamp, which use millisecond precision regardless of the database columns' precision.
  -- 'debezium.toasted.value.placeholder' = '__debezium_unavailable_value' -- Specifies the constant that the connector provides to indicate that the original value is a toasted value that is not provided by the database. If the setting of toasted.value.placeholder starts with the hex, prefix it is expected that the rest of the string represents hexadecimally encoded octets.
  -- 'debezium.tombstones.on.delete' = 'true' -- Controls whether a delete event is followed by a tombstone event.         (1) true - a delete operation is represented by a delete event and a subsequent tombstone event.         (2) false - only a delete event is emitted.         After a source record is deleted, emitting a tombstone event (the default behavior) allows Kafka to completely delete all events that pertain to the key of the deleted row in case log compaction is enabled for the topic.
  -- 'debezium.truncate.handling.mode' = 'bytes' -- Specifies how whether TRUNCATE events should be propagated or not (only available when using the pgoutput plug-in with Postgres 11 or later)         (1) skip causes those event to be omitted (the default),         (2) include causes those events to be included.
  -- 'decoding.plugin.name' = 'decoderbufs' -- The name of the Postgres logical decoding plug-in installed on the server. Supported values are decoderbufs, wal2json, wal2json_rds, wal2json_streaming, wal2json_rds_streaming and pgoutput.
  -- 'port' = '5432' -- Integer port number of the PostgreSQL database server.
  -- 'slot.name' = 'flink' -- The name of the PostgreSQL logical decoding slot that was created for streaming changes from a particular plug-in for a particular database/schema. The server uses this slot to stream events to the connector that you are configuring.
);


````

&copy; 2023
