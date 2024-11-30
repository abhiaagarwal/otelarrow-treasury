CREATE TABLE SCOPE_ATTRS (
    "parent_id" USMALLINT NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE NUMBER_DATA_POINTS (
    "id" UINTEGER NOT NULL,
    "parent_id" USMALLINT NOT NULL,
    "start_time_unix_nano" TIMESTAMP NOT NULL,
    "time_unix_nano" TIMESTAMP NOT NULL,
    "int_value" BIGINT NOT NULL,
    "double_value" DOUBLE NOT NULL,
    "flags" UINTEGER
);

CREATE TABLE NUMBER_DP_EXEMPLARS (
    "id" UINTEGER,
    "parent_id" UINTEGER NOT NULL,
    "time_unix_nano" TIMESTAMP,
    "int_value" BIGINT,
    "double_value" DOUBLE,
    "span_id" UBIGINT,
    "trace_id" UHUGEINT
);

CREATE TABLE NUMBER_DP_EXEMPLAR_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE HISTOGRAM_DATA_POINTS (
    "id" UINTEGER,
    "parent_id" USMALLINT NOT NULL,
    "start_time_unix_nano" TIMESTAMP,
    "time_unix_nano" TIMESTAMP,
    "count" UHUGEINT,
    "sum" DOUBLE,
    "bucket_counts" UHUGEINT,
    "explicit_bounds" DOUBLE,
    "flags" UINTEGER,
    "min" DOUBLE,
    "max" DOUBLE
);

CREATE TABLE EXP_HISTOGRAM_DP_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE EXP_HISTOGRAM_DP_EXEMPLAR_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE RESOURCE_ATTRS (
    "parent_id" USMALLINT NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE NUMBER_DP_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE SUMMARY_DATA_POINTS (
    "id" UINTEGER,
    "parent_id" USMALLINT NOT NULL,
    "start_time_unix_nano" TIMESTAMP,
    "time_unix_nano" TIMESTAMP,
    "count" UHUGEINT,
    "sum" DOUBLE,
    "flags" UINTEGER
);

CREATE TABLE quantile (
    "quantile" DOUBLE,
    "value" DOUBLE
);

CREATE TABLE SUMMARY_DP_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE METRICS (
    "id" USMALLINT NOT NULL,
    "resource" STRUCT(
        id USMALLINT NOT NULL,
        schema_url VARCHAR,
        dropped_attributes_count UINTEGER
    ),
    "scope" STRUCT(
        "id" USMALLINT NOT NULL,
        "name" VARCHAR,
        "version" VARCHAR,
        "dropped_attributes_count" UINTEGER
    )
    "schema_url" VARCHAR,
    "metric_type" UTINYINT NOT NULL,
    "name" VARCHAR NOT NULL,
    "description" VARCHAR,
    "unit" VARCHAR,
    "aggregation_temporality" INTEGER,
    "is_monotonic" BOOLEAN
);

CREATE TABLE HISTOGRAM_DP_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE HISTOGRAM_DP_EXEMPLARS (
    "id" UINTEGER,
    "parent_id" UINTEGER NOT NULL,
    "time_unix_nano" TIMESTAMP,
    "int_value" BIGINT,
    "double_value" DOUBLE,
    "span_id" UBIGINT,
    "trace_id" UHUGEINT
);

CREATE TABLE HISTOGRAM_DP_EXEMPLAR_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE EXP_HISTOGRAM_DATA_POINTS (
    "id" UINTEGER,
    "parent_id" USMALLINT NOT NULL,
    "start_time_unix_nano" TIMESTAMP,
    "time_unix_nano" TIMESTAMP,
    "count" UHUGEINT,
    "sum" DOUBLE,
    "scale" INTEGER,
    "zero_count" UHUGEINT,
    "positive_offset" INTEGER,
    "positive_bucket_counts" UHUGEINT,
    "negative_offset" INTEGER,
    "negative_bucket_counts" UHUGEINT,
    "flags" UINTEGER,
    "min" DOUBLE,
    "max" DOUBLE
);

CREATE TABLE EXP_HISTOGRAM_DP_EXEMPLARS (
    "id" UINTEGER,
    "parent_id" UINTEGER NOT NULL,
    "time_unix_nano" TIMESTAMP,
    "int_value" BIGINT,
    "double_value" DOUBLE,
    "span_id" UBIGINT,
    "trace_id" UHUGEINT
);

CREATE TABLE LOGS (
    "id" USMALLINT,
    "resource" STRUCT(
        "id" USMALLINT NOT NULL,
        "schema_url" VARCHAR,
        "dropped_attributes_count" UINTEGER
    ),
    "scope" STRUCT(
        "id" USMALLINT NOT NULL,
        "name" VARCHAR,
        "version" VARCHAR,
        "dropped_attributes_count" UINTEGER
    )
    "schema_url" VARCHAR,
    "time_unix_nano" TIMESTAMP NOT NULL,
    "observed_time_unix_nano" TIMESTAMP NOT NULL,
    "trace_id" UHUGEINT,
    "span_id" UBIGINT,
    "severity_number" INTEGER,
    "severity_text" VARCHAR,
    "body" STRUCT(
        "type" UTINYINT NOT NULL,
        "str" VARCHAR NOT NULL,
        "int" BIGINT,
        "double" DOUBLE,
        "bool" BOOLEAN,
        "bytes" BLOB,
        "ser" BLOB
    ),
    "dropped_attributes_count" UINTEGER,
    "flags" UINTEGER
);

CREATE TABLE LOG_ATTRS (
    "parent_id" USMALLINT NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE SPANS (
    "id" USMALLINT,
    "resource" STRUCT(
        "id" USMALLINT NOT NULL,
        "schema_url" VARCHAR,
        "dropped_attributes_count" UINTEGER
    ),
    "scope" STRUCT(
        "id" USMALLINT NOT NULL,
        "name" VARCHAR,
        "version" VARCHAR,
        "dropped_attributes_count" UINTEGER
    )
    "schema_url" VARCHAR,
    "start_time_unix_nano" TIMESTAMP NOT NULL,
    "duration_time_unix_nano" INTERVAL NOT NULL,
    "trace_id" UHUGEINT NOT NULL,
    "span_id" UBIGINT NOT NULL,
    "trace_state" VARCHAR,
    "parent_span_id" UBIGINT,
    "name" VARCHAR NOT NULL,
    "kind" INTEGER,
    "dropped_attributes_count" UINTEGER,
    "dropped_events_count" UINTEGER,
    "dropped_links_count" UINTEGER,
    "status_code" INTEGER
);

CREATE TABLE SPAN_ATTRS (
    "parent_id" USMALLINT NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE SPAN_EVENTS (
    "id" UINTEGER,
    "parent_id" USMALLINT NOT NULL,
    "time_unix_nano" TIMESTAMP,
    "name" VARCHAR NOT NULL,
    "dropped_attributes_count" UINTEGER
);

CREATE TABLE SPAN_LINKS (
    "id" UINTEGER,
    "parent_id" USMALLINT NOT NULL,
    "trace_id" UHUGEINT,
    "span_id" UBIGINT,
    "trace_state" VARCHAR,
    "dropped_attributes_count" UINTEGER
);

CREATE TABLE SPAN_EVENT_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);

CREATE TABLE SPAN_LINK_ATTRS (
    "parent_id" UINTEGER NOT NULL,
    "key" VARCHAR NOT NULL,
    "type" UTINYINT NOT NULL,
    "str" VARCHAR NOT NULL,
    "int" BIGINT,
    "double" DOUBLE,
    "bool" BOOLEAN,
    "bytes" BLOB,
    "ser" BLOB
);