from pyspark.sql import SparkSession
from pyspark.sql.functions import current_timestamp, lit

def ingest_ehr_cdc(source_path: str, target_table: str):
    spark = SparkSession.builder.getOrCreate()
    
    table_name = target_table.split('.')[-1]
    schema_location = f"/schemas/ehr_cdc_{table_name}"
    checkpoint_location = f"/checkpoints/ehr_cdc_bronze_{table_name}"

    df = (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "json")
        .option("cloudFiles.schemaLocation", schema_location)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(source_path)
        .withColumn("ingestion_timestamp", current_timestamp())
        .withColumn("source_system", lit("EHR_CDC"))
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
    ingest_ehr_cdc(
        source_path="/mnt/data/ehr/cdc_feed",
        target_table="health_claims_dev.bronze.ehr_cdc_raw"
    )
