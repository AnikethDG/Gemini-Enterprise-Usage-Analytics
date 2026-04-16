#!/bin/bash
# ==============================================================================
# Interactive GCS Batch Analytics Runner
# ==============================================================================

echo "======================================================================"
echo "🌟 Gemini GCS Batch Analytics Wizard"
echo "======================================================================"

read -p "Enter Target Google Cloud PROJECT_ID: " PROMPT_PROJECT_ID
export PROJECT_ID="${PROMPT_PROJECT_ID:-your_project_id}"

read -p "Enter Gemini APP_ID(s) (optional, comma-separated for audit log setup): " PROMPT_APP_ID
export APP_ID="${PROMPT_APP_ID:-your_app_id}"

read -p "Enter BigQuery Dataset Name (default: ge_raw): " PROMPT_GCS_DATASET
read -p "Enter BigQuery Storage Location (default: US): " PROMPT_BQ_LOCATION
read -p "Enter Source GCS Logs URI (default: gs://${PROJECT_ID}-ge-raw-logs/discoveryengine.googleapis.com/gemini_enterprise_user_activity): " PROMPT_GCS_URI

# Apply Defaults
export GCS_DATASET="${PROMPT_GCS_DATASET:-ge_raw}"
export BQ_LOCATION="${PROMPT_BQ_LOCATION:-US}"
export GCS_URI="${PROMPT_GCS_URI:-gs://${PROJECT_ID}-ge-raw-logs/discoveryengine.googleapis.com/gemini_enterprise_user_activity}"

echo ""
echo "======================================================================"
echo "📋 GCS ARCHITECTURE PREVIEW"
echo "======================================================================"
echo "External Table: ${PROJECT_ID}:${GCS_DATASET}.raw_audit_logs"
echo "Unified View:   ${PROJECT_ID}:${GCS_DATASET}.gcs_ge_logs"
echo "Reading from:   ${GCS_URI}/*"
echo "======================================================================"

read -p "Are you ready to install these analytics structures? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "[Aborted] Safe exit."
    exit 0
fi

echo ""
# Extract bucket name and check existence
GCS_TEMP="${GCS_URI#gs://}"
GCS_BUCKET_NAME="${GCS_TEMP%%/*}"

echo "🔍 Checking GCS Bucket existence: gs://${GCS_BUCKET_NAME}..."
if ! gsutil ls -b "gs://${GCS_BUCKET_NAME}" >/dev/null 2>&1; then
    echo "[Warning] GCS Bucket 'gs://${GCS_BUCKET_NAME}' does not appear to exist."
    read -p "❓ Shall I create it for you in location '${BQ_LOCATION}'? (y/N): " CREATE_BUCKET
    if [[ "$CREATE_BUCKET" =~ ^[Yy]$ ]]; then
        echo "-> Provisioning bucket gs://${GCS_BUCKET_NAME}..."
        gsutil mb -l "${BQ_LOCATION}" "gs://${GCS_BUCKET_NAME}"
    else
        echo "[Warning] Skipping creation. External table build might fail!"
    fi
else
    echo "[OK] Bucket 'gs://${GCS_BUCKET_NAME}' verified."
fi

echo ""
echo "🚀 Compiling..."
chmod +x deploy_gcs_pipeline.sh ../enable_audit_logging.sh

echo "[Step 1] Enabling Global Usage Audit Logging..."
../enable_audit_logging.sh

echo ""
echo "[Step 2] Installing Abstracted GCS SQL Stack..."
./deploy_gcs_pipeline.sh

echo "✨ Deployment Complete!"
