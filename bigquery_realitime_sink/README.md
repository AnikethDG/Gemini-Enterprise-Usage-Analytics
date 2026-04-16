# Real-Time BigQuery Sink: Usage Analytics

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

### Option A: Interactive Wizard (Recommended)

We provide a convenient interactive runner that prompts you for all critical parameters (including multiple comma-separated APP_IDs) and sequentially handles the deployment:

```bash
./interactive_runner.sh
```
This will automatically execute both the raw pipeline creation and the transformed BigQuery view installations.

### Option B: Manual Configuration via Environment Variables

If you prefer executing the shell scripts directly or in a CI/CD context, you can pass configuration via environment variables.

1. **Set up API logging and raw sinks:**
   Edit or export variables directly. Note that `APP_ID` natively accepts a comma-separated list for provisioning multiple apps simultaneously.
   ```bash
   export PROJECT_ID="your_project_id"
   export APP_ID="your_app_id_1,your_app_id_2"
   export LOCATION="global"
   
   ./setup_user_logs_raw.sh
   ```

2. **Install refined unified views:**
   Run the SQL script consolidators to deploy views for simplified tabular reporting.
   ```bash
   ./setup_transformed_views.sh
   ```

This handling creates the target transformation datasets and automatically reads the templatized `.sql` views for both Gemini Enterprise and NotebookLM, substituting configured project identifiers successfully.

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