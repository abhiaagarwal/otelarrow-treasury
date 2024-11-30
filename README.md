# otelarrow-treasury

A rust-based server that ingests data in the [OpenTelemetry Arrow](https://github.com/open-telemetry/otel-arrow) format, stores it in a database, and exposes a HTTP API to read it inside of Grafana.

## Why does this exist?

* I want full stack observability in my apps, logs/traces/metrics. 
    * I want this to be usable in environments without scaling requirements.
    * Potentially a drop-in for dev environments.
* I don't want to deal with a webui.
* I want to use the gold standard for dashboarding, Grafana. 
* I want to take advantage of opentelemetry-collector, which handles ingestion and processing from a variety of sources, but not storage.
    * Since the opentelemetry ecosystem prioritizes the use of gRPC, all you need to do is grab one of their protos to start cooking.
* I want something that consumes minimal resources and stays out of your hair.
* I want the data model for logs/traces/metrics to be stored in an OLAP fashion for long-term analytics.
* I just want it to work.

Based on my research, this doesn't exist. So I figured I'd write it.

## Design

I expose a Opentelemetry-compatible endpoint, namely, one uses the same protocol defined by the [`opentel-arrow`](https://github.com/open-telemetry/otel-arrow/blob/main/proto/opentelemetry/proto/experimental/arrow/v1/arrow_service.proto) receiver. Since DuckDB is used as the underlying database and the server has an exclusive lease on it, we support simultaneous read/writes. Additionally, DuckDB supports efficient appends for Arrow RecordBatches. Rust is the chosen language, as the Arrow, DuckDB, and gRPC bindings are better compared to my next choice, go. 

The server exposes a REST API that Grafana can consume, which return Arrow RecordBatches. In the grafana datasource, we query for a data source, read the returned dataframes, do mimimal processing as aggregation is done server-side, then display it.

### Open questions

* DuckDB vs. Parquet/Delta files
    * I'm choosing DuckDB since the current schema by the receiver involves a bunch of tables, but there's an argument to denormalize it and maintain it as three separate tables (since said separate tables are what Grafana will be consuming). In which case, storing it as parquet files/delta tables makes more sense.
* How do we directly deserialize Arrow dataframes in the browser?
    * Grafana's docs say that their internal dataframes use Arrow, can we somehow directly bypass any sort of construction on their side and zero-copy the Recordbatches returned by the GET calls directly?
* Do we expose a "push" API as well, so this could be used in a chain of opentel-based pipelines?
    * We could basically serve as a long-term store of opentel data, and then based on some sort of orchestration, push it down the line in an ETL fashion.
    * Basically implement the otel-arrow-exporter (aka gRPC client)
* Do we try to support TraceQL/PromQL/LogQL?
    * I'm leaning towards yes, we can probably write a nom/cfg parser to handle that for us.
    * PromQL parser: https://github.com/GreptimeTeam/promql-parser
    * LogQL parser: [Does not exist]
    * TraceQL parser: [Does not exist]