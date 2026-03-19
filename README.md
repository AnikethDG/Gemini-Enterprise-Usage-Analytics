# Gemini Enterprise & NotebookLM Enterprise Usage Analytics

This repository contains scripts and configurations to enable and analyze usage metrics for Google Cloud's Gemini Enterprise and NotebookLM Enterprise products.

## Overview

This project provides a solution to capture and analyze user interactions with Gemini Enterprise and NotebookLM Enterprise. It uses Google Cloud's native logging and BigQuery features to track usage without requiring custom instrumentation.

For more information, see the official documentation:
- [Gemini Enterprise: Set up usage audit logs](https://docs.cloud.google.com/gemini/enterprise/docs/set-up-usage-audit-logs)

## Features

- **Automated Logging Setup**: The script natively enables usage audit logging for both Gemini Enterprise and NotebookLM Enterprise via the Discovery Engine APIs.
- **Isolated BigQuery Datasets**: Creates separate BigQuery datasets for each tracked method to prevent schema collisions.
- **Cloud Logging Sinks**: Configures sinks to route usage logs directly to BigQuery.
- **Comprehensive Tracking**: Tracks 20 different methods across both Gemini Enterprise and NotebookLM Enterprise.

## Prerequisites

- Google Cloud SDK (`gcloud`) installed and authenticated.
- `bq` command-line tool available.
- `python3` available for parsing JSON output.
- Necessary IAM permissions to modify logging and BigQuery resources in the target project.

## Setup

### 1. Configuration

The single entrypoint script `setup_user_logs_raw.sh` handles both the API-level observability enablement and the infrastructure provisioning automatically.

Edit the `setup_user_logs_raw.sh` script to set your specific `PROJECT_ID`, `APP_ID`, and `LOCATION` variables before running it.

### 2. Run the Setup Script

This single execution handles making the REST API patches to enable Usage Audit Logging, creates all necessary BigQuery datasets, spins up matching Cloud Logging sinks, and applies the required IAM permissions automatically.

```bash
./setup_user_logs_raw.sh
```

## Usage

After running the setup script, usage data will be automatically streamed to BigQuery. You can then query the data using standard SQL.

### Example Queries

**Count of Gemini Enterprise Search queries:**

```sql
SELECT
  methodName,
  COUNT(*) as query_count
FROM
  `your-project.ge_raw_logs_search.cloudaudit_googleapis_com_activity`
WHERE
  methodName = 'Search'
GROUP BY
  methodName;
```

**Count of NotebookLM Enterprise interactions:**

```sql
SELECT
  methodName,
  COUNT(*) as interaction_count
FROM
  `your-project.ge_raw_logs_interactsources.cloudaudit_googleapis_com_activity`
WHERE
  methodName = 'InteractSources'
GROUP BY
  methodName;
```

## Monitored Methods

The following methods are tracked:

**Gemini Enterprise:**
- Search
- Assist
- StreamAssist
- AnswerQuery
- CreateEngine
- UpdateEngine
- SetIamPolicy
- CreateAgent
- UpdateAgent
- CreateAgentRequest
- GenerateGroundedContent
- UpdateDataConnector
- AddContextFile
- UploadSessionFile

**NotebookLM Enterprise:**
- CreateNotebook
- ShareNotebook
- DeleteNotebook
- GetNotebook
- InteractSources
- GenerateFreeFormStreamed

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.