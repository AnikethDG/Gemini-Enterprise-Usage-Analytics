#!/bin/bash
# ==============================================================================
# Script: setup_user_logs_raw.sh
# Description: Automates the creation of 20 isolated BigQuery datasets and
#              Cloud Logging sinks to natively track Gemini Enterprise and
#              NotebookLM Enterprise usage metrics without schema collisions.
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration Variables
# ------------------------------------------------------------------------------
# Change these values to match your target environment.
PROJECT_ID="bnoriega-test-ge"
APP_ID="gemini-enterprise-17670338_1767033834650"
LOCATION="global"

# The string prefixed before the method name for datasets and sinks.
# E.g., if prefix is "ge_raw_logs_", dataset becomes "ge_raw_logs_search"
DATASET_PREFIX="ge_raw_logs_"
SINK_PREFIX="ge_raw_logs_"

# ------------------------------------------------------------------------------
# Pre-requisite: Enable Usage Audit Logging
# ------------------------------------------------------------------------------
echo "======================================================================"
echo "Enabling Usage Audit Logging for Gemini Enterprise (App: ${APP_ID})..."
echo "======================================================================"

curl -X PATCH -H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "X-Goog-User-Project: ${PROJECT_ID}" \
"https://${LOCATION}-discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/${LOCATION}/collections/default_collection/engines/${APP_ID}?updateMask=observabilityConfig" \
-d '{
  "observabilityConfig": {
    "observabilityEnabled": true,
    "sensitiveLoggingEnabled": true
  }
}'

echo ""
echo "======================================================================"
echo "Enabling Usage Audit Logging for NotebookLM Enterprise (Project: ${PROJECT_ID})..."
echo "======================================================================"

curl -X PATCH -H "Authorization: Bearer $(gcloud auth print-access-token)" \
-H "Content-Type: application/json" \
-H "X-Goog-User-Project: ${PROJECT_ID}" \
"https://${LOCATION}-discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}?updateMask=customerProvidedConfig.notebooklmConfig.observabilityConfig" \
-d '{
  "customerProvidedConfig": {
    "notebooklmConfig": {
      "observabilityConfig": {
        "observabilityEnabled": true,
        "sensitiveLoggingEnabled": true
      }
    }
  }
}'

echo ""

# ------------------------------------------------------------------------------
# Method Definitions
# ------------------------------------------------------------------------------
# Gemini Enterprise Methods
GE_METHODS=(
  "Search"
  "Assist"
  "StreamAssist"
  "AnswerQuery"
  "CreateEngine"
  "UpdateEngine"
  "SetIamPolicy"
  "CreateAgent"
  "UpdateAgent"
  "CreateAgentRequest"
  "GenerateGroundedContent"
  "UpdateDataConnector"
  "AddContextFile"
  "UploadSessionFile"
)

# NotebookLM Enterprise Methods
NLM_METHODS=(
  "CreateNotebook"
  "ShareNotebook"
  "DeleteNotebook"
  "GetNotebook"
  "InteractSources"
  "GenerateFreeFormStreamed"
)

# Combine all targeted tracked methods
ALL_METHODS=("${GE_METHODS[@]}" "${NLM_METHODS[@]}")

# ------------------------------------------------------------------------------
# Execution Logic
# ------------------------------------------------------------------------------
echo "======================================================================"
echo "Starting universal isolated logging deployment in project: ${PROJECT_ID}"
echo "Dataset Prefix: ${DATASET_PREFIX}"
echo "Sink Prefix: ${SINK_PREFIX}"
echo "Total Methods to Deploy: ${#ALL_METHODS[@]}"
echo "======================================================================"

# Universal Cloud Logging base logName targeting Discovery Engine Usage Activity
BASE_LOG_NAME="projects/${PROJECT_ID}/logs/discoveryengine.googleapis.com%2Fgemini_enterprise_user_activity"

for METHOD in "${ALL_METHODS[@]}"; do
    echo "--------------------------------------------------------"
    echo "Deploying infrastructure for method: ${METHOD}..."
    echo "--------------------------------------------------------"

    # Lowercase the method name for BigQuery dataset and Sink naming
    LOWER_METHOD=$(echo "$METHOD" | tr '[:upper:]' '[:lower:]')
    
    DATASET_NAME="${DATASET_PREFIX}${LOWER_METHOD}"
    SINK_NAME="${SINK_PREFIX}${LOWER_METHOD}"
    
    # 1. Create the BigQuery Dataset
    echo "-> Creating BigQuery dataset: ${DATASET_NAME}"
    bq mk -f -d --location=US "$DATASET_NAME" || true
    
    # 2. Create the Cloud Logging Sink targeting the exact jsonPayload methodName
    FILTER="logName=\"${BASE_LOG_NAME}\" AND jsonPayload.logMetadata.methodName=\"${METHOD}\""
    
    echo "-> Creating Cloud Logging sink: ${SINK_NAME}"
    SINK_PARAMS=$(gcloud logging sinks create "$SINK_NAME" "bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/${DATASET_NAME}" \
        --log-filter="${FILTER}" \
        --use-partitioned-tables \
        --format=json || gcloud logging sinks describe "$SINK_NAME" --format=json)
        
    # 3. Extract the Sink's native Service Account Identity
    WRITER_IDENTITY=$(echo "$SINK_PARAMS" | python3 -c "import sys, json; print(json.load(sys.stdin)['writerIdentity'])")
    
    # 4. Bind the BigQuery Data Editor IAM Role to permit raw log insertion
    echo "-> Binding IAM Role (roles/bigquery.dataEditor) to Service Account: ${WRITER_IDENTITY}"
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="$WRITER_IDENTITY" \
        --role="roles/bigquery.dataEditor" > /dev/null
        
    echo "[Success] Deployed ${METHOD}."
done

echo "======================================================================"
echo "Deployment Complete! All 20 isolation pipelines are active."
echo "======================================================================"
