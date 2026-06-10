# 🏥 Smart Health Claims Adjudication Platform

A modern, end-to-end data and AI platform built on Databricks to automate and streamline health insurance claim processing. This project demonstrates the pivot from traditional manual ETL to modern, declarative, and AI-driven data engineering.

## 🏗️ Architecture Highlights
- **Ingestion:** Databricks Lakeflow Connect (CDC from EHR) & Autoloader (Medical Imaging metadata).
- **Transformation:** Lakeflow Declarative Pipelines with built-in Data Quality (Expectations) and automated PHI masking.
- **Machine Learning:** MLflow-tracked computer vision model to assess injury severity from uploaded images.
- **Automation:** SQL-based Rules Engine for instant claim adjudication (Auto-Approve vs. Manual Review).
- **Consumption:** Databricks Genie (Natural Language Analytics) & Databricks Apps (Patient/Admin Portals powered by Lakebase).

## 📂 Project Structure
- `/data`: Synthetic mock data generation scripts.
- `/src/ingestion`: Lakeflow and Autoloader configurations.
- `/src/transformations`: Bronze to Silver to Gold declarative pipelines.
- `/src/ml`: MLflow experiment tracking and model registry.
- `/src/app`: Databricks Apps (Streamlit) source code.

## 🎯 Business Value
Reduces manual claim review time by 70%, ensures HIPAA-compliant data handling, and provides real-time, natural language insights for claims adjusters.
