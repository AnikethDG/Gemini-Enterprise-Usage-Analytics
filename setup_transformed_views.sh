#!/bin/bash
# ==============================================================================
# Setup Transformed Views for Gemini Enterprise & NotebookLM Logs
# ==============================================================================

set -e # Exit immediately on error

# ------------------------------------------------------------------------------
# 1. Configuration variables
# ------------------------------------------------------------------------------
PROJECT_ID="bnoriega-test-ge"

# Destination datasets for the transformed flattened views
GE_TRANSFORMED_DATASET="ge_transformed"
NLM_TRANSFORMED_DATASET="nlm_transformed"

echo "======================================================================"
echo "Starting deployment of transformed views in project: ${PROJECT_ID}"
echo "GE Transformed Dataset: ${GE_TRANSFORMED_DATASET}"
echo "NLM Transformed Dataset: ${NLM_TRANSFORMED_DATASET}"
echo "======================================================================"

# ------------------------------------------------------------------------------
# 2. Create Destination Datasets if they don't exist
# ------------------------------------------------------------------------------
echo "-> Verifying Destination Datasets..."
bq mk -f -d --location=US "${PROJECT_ID}:${GE_TRANSFORMED_DATASET}" || true
bq mk -f -d --location=US "${PROJECT_ID}:${NLM_TRANSFORMED_DATASET}" || true

# ------------------------------------------------------------------------------
# 3. Deploy GE Transformed SQL
# ------------------------------------------------------------------------------
echo "-> Deploying Gemini Enterprise (GE) Logs View..."
SQL_GE="/usr/local/google/home/anikethd/gemini/Gemini-Enterprise-Usage-Analytics/ge_transformed.sql"

if [ ! -f "$SQL_GE" ]; then
  echo "[Error] file not found: $SQL_GE"
  exit 1
fi

# Run with Sed String replaces for configurability
cat "$SQL_GE" | \
sed "s/\${PROJECT_ID}/${PROJECT_ID}/g" | \
sed "s/\${GE_TRANSFORMED_DATASET}/${GE_TRANSFORMED_DATASET}/g" | \
bq query --use_legacy_sql=false

echo "[Success] GE View deployed."

# ------------------------------------------------------------------------------
# 4. Deploy NLM Transformed SQL
# ------------------------------------------------------------------------------
echo "-> Deploying NotebookLM (NLM) Logs View..."
SQL_NLM="/usr/local/google/home/anikethd/gemini/Gemini-Enterprise-Usage-Analytics/nlm_transformed.sql"

if [ ! -f "$SQL_NLM" ]; then
  echo "[Error] file not found: $SQL_NLM"
  exit 1
fi

# Run with Sed String replaces for configurability
cat "$SQL_NLM" | \
sed "s/\${PROJECT_ID}/${PROJECT_ID}/g" | \
sed "s/\${NLM_TRANSFORMED_DATASET}/${NLM_TRANSFORMED_DATASET}/g" | \
bq query --use_legacy_sql=false

echo "[Success] NLM View deployed."

echo "======================================================================"
echo "Deployment Complete!"
echo "======================================================================"
