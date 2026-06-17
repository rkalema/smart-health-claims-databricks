from pyspark.sql import SparkSession
from pyspark.sql.functions import current_timestamp, input_file_name, lit

def ingest_images(source_path: str, target_table: str):
    spark = SparkSession.builder.getOrCreate()
    
    table_name = target_table.split('.')[-1]
    schema_location = f"/schemas/images_{table_name}"
    checkpoint_location = f"/checkpoints/images_bronze_{table_name}"

    df = (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "binaryFile")
        .option("cloudFiles.schemaLocation", schema_location)
        .option("pathGlobFilter", "*.jpg,*.png,*.dicom")
        .load(source_path)
        .withColumn("file_name", input_file_name())
        .withColumn("ingestion_timestamp", current_timestamp())
        .withColumn("source_system", lit("IMAGES_STORAGE"))
    )

    (
        df.writeStream
        .format("delta")
        .outputMode("append")
        .option("checkpointLocation", checkpoint_location)
        .trigger(availableNow=True)
        .start(target_table)
        .awaitTermination()
    )

if __name__ == "__main__":
    ingest_images(
        source_path="/mnt/data/medical/images",
        target_table="health_claims_dev.bronze.medical_images_raw"
    )
