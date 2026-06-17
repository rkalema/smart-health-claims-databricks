from pyspark.sql import SparkSession
from pyspark.sql.functions import current_timestamp, lit, to_timestamp

def ingest_rpm_stream(source_path: str, target_table: str):
    spark = SparkSession.builder.getOrCreate()
    
    table_name = target_table.split('.')[-1]
    schema_location = f"/schemas/rpm_stream_{table_name}"
    checkpoint_location = f"/checkpoints/rpm_bronze_{table_name}"

    df = (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", schema_location)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(source_path)
        .withColumn("event_timestamp", to_timestamp("timestamp"))
        .withColumn("ingestion_timestamp", current_timestamp())
        .withColumn("source_system", lit("RPM_DEVICES"))
    )

    (
        df.writeStream
        .format("delta")
        .outputMode("append")
        .option("checkpointLocation", checkpoint_location)
        .option("mergeSchema", "true")
        .trigger(availableNow=True)
        .start(target_table)
        .awaitTermination()
    )

if __name__ == "__main__":
    ingest_rpm_stream(
        source_path="/mnt/data/rpm/stream",
        target_table="health_claims_dev.bronze.rpm_stream_raw"
    )
