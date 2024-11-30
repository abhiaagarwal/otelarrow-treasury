use std::collections::hash_map::Entry;
use std::pin::Pin;
use std::sync::Arc;

use arrow::buffer::Buffer;
use arrow::util::pretty::print_batches;
use arrow_ipc::reader::StreamDecoder;
use color_eyre::eyre::Result;
use rustc_hash::FxHashMap;
use tokio_stream::{Stream, StreamExt};
use tonic::codec::CompressionEncoding;
use tonic::{transport::Server, Request, Response, Status};
use tracing::{error, info, warn};
use tracing_subscriber::{fmt, prelude::*, EnvFilter};

use arrow_otel_proto::{
    arrow_logs_service_server::{ArrowLogsService, ArrowLogsServiceServer},
    arrow_metrics_service_server::{ArrowMetricsService, ArrowMetricsServiceServer},
    arrow_traces_service_server::{ArrowTracesService, ArrowTracesServiceServer},
    ArrowPayload, ArrowPayloadType, BatchArrowRecords, BatchStatus,
};

pub mod database;

pub mod arrow_otel_proto {
    tonic::include_proto!("opentelemetry.proto.experimental.arrow.v1");

    pub(crate) const FILE_DESCRIPTOR_SET: &[u8] =
        tonic::include_file_descriptor_set!("arrow_service");
}

#[derive(Debug, Clone)]
pub struct TreasuryServer {
}

type ArrowOtelStream = Pin<Box<dyn Stream<Item = Result<BatchStatus, Status>> + Send + 'static>>;

#[tonic::async_trait]
impl ArrowLogsService for TreasuryServer {
    type ArrowLogsStream = ArrowOtelStream;

    async fn arrow_logs(
        &self,
        request: Request<tonic::Streaming<BatchArrowRecords>>,
    ) -> Result<Response<Self::ArrowLogsStream>, Status> {
        info!("Received arrow_logs request: {:#?}", request);

        let mut stream = request.into_inner();
        let mut writers: FxHashMap<String, StreamDecoder> = FxHashMap::default();
        let output = async_stream::try_stream! {
            while let Some(batch) = stream.next().await {
                info!("Processing new batch");
                let batch = batch?;
                let payloads = batch.arrow_payloads;

                for payload in payloads {
                    let ArrowPayload {
                        schema_id,
                        r#type,
                        record,
                    } = payload;

                    let payload_type: ArrowPayloadType = r#type.try_into().unwrap();

                    info!(
                        schema_id = %schema_id,
                        payload_type = ?payload_type,
                        "Processing payload"
                    );

                    let decoder = match writers.entry(schema_id.clone()) {
                        Entry::Occupied(o) => {
                            info!(schema_id = %schema_id, "Using existing decoder");
                            o.into_mut()
                        },
                        Entry::Vacant(v) => {
                            info!(schema_id = %schema_id, "Creating new decoder");
                            v.insert(StreamDecoder::new())
                        },
                    };

                    match decoder.decode(&mut Buffer::from_vec(record)) {
                        Ok(Some(val)) => {
                            info!("Successfully decoded record");
                            if let Err(e) = print_batches(&[val.clone()]) {
                                error!(?e, "Failed to print batch");
                            }
                            info!("Schema: {}", &val.schema());

                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Ok as i32,
                                status_message: "ok".to_string(),
                            };
                            yield batch_status;
                        },
                        Ok(None) => {
                            warn!("No record decoded");
                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Internal as i32,
                                status_message: "Failed to decode record".to_string(),
                            };
                            yield batch_status;
                        },
                        Err(e) => {
                            error!(?e, "Error decoding record");
                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Internal as i32,
                                status_message: format!("Error decoding record: {:?}", e),
                            };
                            yield batch_status;
                        }
                    }
                }
            }
        };

        Ok(Response::new(Box::pin(output) as Self::ArrowLogsStream))
    }
}

#[tonic::async_trait]
impl ArrowMetricsService for TreasuryServer {
    type ArrowMetricsStream = ArrowOtelStream;

    async fn arrow_metrics(
        &self,
        request: Request<tonic::Streaming<BatchArrowRecords>>,
    ) -> Result<Response<Self::ArrowMetricsStream>, Status> {
        info!("Received arrow_metrics request: {:#?}", request);

        let mut stream = request.into_inner();
        let mut writers: FxHashMap<String, StreamDecoder> = FxHashMap::default();

        let output = async_stream::try_stream! {
            while let Some(batch) = stream.next().await {
                info!("Processing new batch");
                let batch = batch?;
                let payloads = batch.arrow_payloads;

                for payload in payloads {
                    let ArrowPayload {
                        schema_id,
                        r#type,
                        record,
                    } = payload;

                    let payload_type: ArrowPayloadType = r#type.try_into().unwrap();

                    info!(
                        schema_id = %schema_id,
                        payload_type = ?payload_type,
                        "Processing payload"
                    );

                    let decoder = match writers.entry(schema_id.clone()) {
                        Entry::Occupied(o) => {
                            info!(schema_id = %schema_id, "Using existing decoder");
                            o.into_mut()
                        },
                        Entry::Vacant(v) => {
                            info!(schema_id = %schema_id, "Creating new decoder");
                            v.insert(StreamDecoder::new())
                        },
                    };

                    match decoder.decode(&mut Buffer::from_vec(record)) {
                        Ok(Some(val)) => {
                            info!("Successfully decoded record");
                            if let Err(e) = print_batches(&[val.clone()]) {
                                error!(?e, "Failed to print batch");
                            }
                            info!("Schema: {}", &val.schema());

                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Ok as i32,
                                status_message: "ok".to_string(),
                            };
                            yield batch_status;
                        },
                        Ok(None) => {
                            warn!("No record decoded");
                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Internal as i32,
                                status_message: "Failed to decode record".to_string(),
                            };
                            yield batch_status;
                        },
                        Err(e) => {
                            error!(?e, "Error decoding record");
                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Internal as i32,
                                status_message: format!("Error decoding record: {:?}", e),
                            };
                            yield batch_status;
                        }
                    }
                }
            }
        };

        Ok(Response::new(Box::pin(output) as Self::ArrowMetricsStream))
    }
}

#[tonic::async_trait]
impl ArrowTracesService for TreasuryServer {
    type ArrowTracesStream = ArrowOtelStream;

    async fn arrow_traces(
        &self,
        request: Request<tonic::Streaming<BatchArrowRecords>>,
    ) -> Result<Response<Self::ArrowTracesStream>, Status> {
        info!("Received arrow_traces request: {:#?}", request);

        let mut stream = request.into_inner();
        let mut writers: FxHashMap<String, StreamDecoder> = FxHashMap::default();

        let output = async_stream::try_stream! {
            while let Some(batch) = stream.next().await {
                info!("Processing new batch");
                let batch = batch?;
                let payloads = batch.arrow_payloads;

                for payload in payloads {
                    let ArrowPayload {
                        schema_id,
                        r#type,
                        record,
                    } = payload;

                    let payload_type: ArrowPayloadType = r#type.try_into().unwrap();

                    info!(
                        schema_id = %schema_id,
                        payload_type = ?payload_type,
                        "Processing payload"
                    );

                    let decoder = match writers.entry(schema_id.clone()) {
                        Entry::Occupied(o) => {
                            info!(schema_id = %schema_id, "Using existing decoder");
                            o.into_mut()
                        },
                        Entry::Vacant(v) => {
                            info!(schema_id = %schema_id, "Creating new decoder");
                            v.insert(StreamDecoder::new())
                        },
                    };

                    match decoder.decode(&mut Buffer::from_vec(record)) {
                        Ok(Some(val)) => {
                            info!("Successfully decoded record");
                            if let Err(e) = print_batches(&[val.clone()]) {
                                error!(?e, "Failed to print batch");
                            }
                            info!("Schema: {}", &val.schema());

                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Ok as i32,
                                status_message: "ok".to_string(),
                            };
                            yield batch_status;
                        },
                        Ok(None) => {
                            warn!("No record decoded");
                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Internal as i32,
                                status_message: "Failed to decode record".to_string(),
                            };
                            yield batch_status;
                        },
                        Err(e) => {
                            error!(?e, "Error decoding record");
                            let batch_status = BatchStatus {
                                batch_id: batch.batch_id,
                                status_code: arrow_otel_proto::StatusCode::Internal as i32,
                                status_message: format!("Error decoding record: {:?}", e),
                            };
                            yield batch_status;
                        }
                    }
                }
            }
        };

        Ok(Response::new(Box::pin(output) as Self::ArrowTracesStream))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    color_eyre::install()?;

    tracing_subscriber::registry()
        .with(
            EnvFilter::try_from_default_env()
                .or_else(|_| EnvFilter::try_new("info"))
                .unwrap(),
        )
        .with(fmt::layer().pretty())
        .init();

    let reflection_service = tonic_reflection::server::Builder::configure()
        .register_encoded_file_descriptor_set(arrow_otel_proto::FILE_DESCRIPTOR_SET)
        .build_v1()
        .unwrap();

    let addr = "0.0.0.0:10000".parse().unwrap();

    let route_guide = TreasuryServer {};

    Server::builder()
        .add_service(
            reflection_service
                .accept_compressed(CompressionEncoding::Zstd)
                .send_compressed(CompressionEncoding::Zstd),
        )
        .add_service(
            ArrowLogsServiceServer::new(route_guide.clone())
                .accept_compressed(CompressionEncoding::Zstd)
                .send_compressed(CompressionEncoding::Zstd),
        )
        .add_service(
            ArrowMetricsServiceServer::new(route_guide.clone())
                .accept_compressed(CompressionEncoding::Zstd)
                .send_compressed(CompressionEncoding::Zstd),
        )
        .add_service(
            ArrowTracesServiceServer::new(route_guide)
                .accept_compressed(CompressionEncoding::Zstd)
                .send_compressed(CompressionEncoding::Zstd),
        )
        .serve(addr)
        .await?;

    Ok(())
}
