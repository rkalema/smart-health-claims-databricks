from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sha2, to_date, current_timestamp
from pyspark.sql.types import DoubleType, DateType

def bronze_to_silver(source_table: str, target_table: str):
    spark = SparkSession.builder.getOrCreate()
    
    df = spark.read.table(source_table)
    
    df_clean = (
        df.filter(col("claim_id").isNotNull())
        .filter(col("provider_requested_amount").isNotNull())
        .filter(col("provider_requested_amount") > 0)
        .withColumn("patient_id_hash", sha2(col("patient_id"), 256))
        .drop("patient_id")
        .withColumn("claim_amount", col("provider_requested_amount").cast(DoubleType()))
        .withColumn("claim_date", to_date(col("clean_claim_date")))
        .withColumn("last_updated", current_timestamp())
    )
    
    df_clean.write.mode("overwrite").saveAsTable(target_table)
    
    count = df_clean.count()
    print(f"Silver table {target_table} created with {count} records")

if __name__ == "__main__":
    bronze_to_silver(
        source_table="health_claims_dev.bronze.claims_raw",
        target_table="health_claims_dev.silver.claims_clean"
    )
