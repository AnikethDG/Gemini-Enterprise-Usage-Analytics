#!/bin/bash
# ==============================================================================
# Interactive GCS Batch Analytics Runner
# ==============================================================================

echo "======================================================================"
echo "🌟 Gemini GCS Batch Analytics Wizard"
echo "======================================================================"

read -p "Enter Target Google Cloud PROJECT_ID: " PROMPT_PROJECT_ID
read -p "Enter BigQuery Dataset Name (default: ge_raw): " PROMPT_GCS_DATASET
read -p "Enter BigQuery Storage Location (default: US): " PROMPT_BQ_LOCATION
read -p "Enter Source GCS Logs URI (default: gs://ge-raw-logs/discoveryengine.googleapis.com/gemini_enterprise_user_activity): " PROMPT_GCS_URI

# Apply Defaults
export PROJECT_ID="${PROMPT_PROJECT_ID:-your_project_id}"
export GCS_DATASET="${PROMPT_GCS_DATASET:-ge_raw}"
export BQ_LOCATION="${PROMPT_BQ_LOCATION:-US}"
export GCS_URI="${PROMPT_GCS_URI:-gs://ge-raw-logs/discoveryengine.googleapis.com/gemini_enterprise_user_activity}"

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
echo "🚀 Compiling..."
chmod +x deploy_gcs_pipeline.sh
./deploy_gcs_pipeline.sh

echo "✨ Deployment Complete!"
