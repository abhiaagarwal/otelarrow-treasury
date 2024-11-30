from opentelemetry import trace
from opentelemetry import metrics
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.instrumentation.logging import LoggingInstrumentor
import time
import random
import logging
import sys

# Configure logging
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize tracing
resource = Resource.create({"service.name": "test-service"})

# Configure trace exporter
trace_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
tracer_provider = TracerProvider(resource=resource)
span_processor = BatchSpanProcessor(trace_exporter)
tracer_provider.add_span_processor(span_processor)
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer(__name__)

# Configure metrics
metric_reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint="http://localhost:4317", insecure=True)
)
meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter(__name__)

# Create some metric instruments
counter = meter.create_counter(
    name="test.counter",
    description="Counts things",
    unit="1",
)

histogram = meter.create_histogram(
    name="test.histogram",
    description="Records values",
    unit="ms",
)

# Initialize logging instrumentation
LoggingInstrumentor().instrument(set_logging_format=True)

def generate_nested_spans():
    with tracer.start_as_current_span("parent_operation") as parent:
        logger.info("Starting parent operation")
        parent.set_attribute("custom.attribute", "parent_value")
        
        # Generate some child spans
        for i in range(3):
            with tracer.start_as_current_span(f"child_operation_{i}") as child:
                child.set_attribute("custom.attribute", f"child_value_{i}")
                logger.info(f"Processing child operation {i}")
                time.sleep(random.uniform(0.1, 0.3))
                
                # Record some metrics
                counter.add(1)
                histogram.record(random.uniform(0, 100))

def main():
    print("Starting to generate telemetry data...")
    print("Press Ctrl+C to stop")
    
    try:
        while True:
            # Generate a batch of telemetry
            with tracer.start_as_current_span("main_operation") as span:
                span.set_attribute("operation.type", "main")
                logger.info("Starting main operation")
                
                # Generate some nested spans with metrics
                generate_nested_spans()
                
                # Add some random errors
                if random.random() < 0.1:  # 10% chance of error
                    try:
                        raise Exception("Random test error")
                    except Exception as e:
                        logger.error("Error in operation", exc_info=True)
                        span.record_exception(e)
                
                time.sleep(1)  # Wait before generating next batch
                
    except KeyboardInterrupt:
        print("\nShutting down...")
        # Shutdown SDK components
        tracer_provider.shutdown()
        meter_provider.shutdown()

if __name__ == "__main__":
    main()