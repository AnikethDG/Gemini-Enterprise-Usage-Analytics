#!/bin/bash
# ==============================================================================
# Script: deploy_gcs_pipeline.sh
# Description: Installs the batch BQ external table and abstraction view
#              over exported Cloud Logging files in Google Cloud Storage.
# ==============================================================================

set -e

PROJECT_ID="${PROJECT_ID:-your_project_id}"
BQ_LOCATION="${BQ_LOCATION:-US}"
GCS_DATASET="${GCS_DATASET:-ge_gcs_batch_logs}"
GCS_URI="${GCS_URI:-gs://${PROJECT_ID}-ge-raw-logs/discoveryengine.googleapis.com/gemini_enterprise_user_activity}"

SQL_FILE="$(dirname "$0")/gcs_transformed.sql"

echo "======================================================================"
echo "Deploying GCS Batched Logs Analytical Stack..."
echo "Project: ${PROJECT_ID}"
echo "Dataset: ${GCS_DATASET}"
echo "Source GCS Bucket: ${GCS_URI}"
echo "======================================================================"

# 1. Create BigQuery Dataset
bq mk -f -d --location="${BQ_LOCATION}" "${PROJECT_ID}:${GCS_DATASET}" || true

# 2. Deploy SQL External Table and Views
cat "$SQL_FILE" | \
sed "s/\${PROJECT_ID}/${PROJECT_ID}/g" | \
sed "s/\${GCS_DATASET}/${GCS_DATASET}/g" | \
sed "s|\${GCS_URI}|${GCS_URI}|g" | \
bq query --use_legacy_sql=false --project_id="${PROJECT_ID}" > /dev/null

echo ""
echo "[Success] Successfully created abstracted GCS Analytical views!"
