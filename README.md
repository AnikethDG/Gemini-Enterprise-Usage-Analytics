# Gemini Enterprise & NotebookLM Usage Analytics Architecture

This repository hosts scalable patterns for extracting observability, user behaviors, and interaction metadata across Gemini Enterprise and NotebookLM Enterprise products without any custom local application instrumentation.

We maintain **two parallel architectural paradigms** for consuming these logs. 

## Security and Prerequisites

For details on setting up fundamental audit logs, requisite IAM roles, and internal security measures, follow the official setup guide:
- **[Gemini Enterprise: Set up usage audit logs](https://docs.cloud.google.com/gemini/enterprise/docs/set-up-usage-audit-logs)**

---

## 1. [Real-Time BigQuery Sink](./bigquery_realitime_sink/README.md)

**Best for:** Immediate dashboards, real-time monitoring, and instant usage alerting.

*   **How it works:** Direct Cloud Logging sinks stream structured records straight into distinct BigQuery schemas, unifying payloads on the fly.
*   **Latency:** **Near Real-Time** (Seconds). 
*   **Pros:** Immediate querying; zero external compute setup.
*   **Cons:** Minor incremental BigQuery streaming ingest costs; strict schema-typing requires managing isolated dataset abstractions to prevent record collisions.

---

## 2. [Google Cloud Storage Batching](./gcs_batch_sink/README.md)

**Best for:** Archival analysis, low-cost investigations, and consolidated reporting across complex unstructured attributes. 

*   **How it works:** Standard Cloud Logging chunks are shipped reliably to a persistent GCS Bucket. We then bind external JSON tables (`JSON_TYPE`) onto the data footprint directly.
*   **Latency:** **Batch delayed** (Aggregated hourly in storage buckets).
*   **Pros:** Minimal processing friction; completely handles dynamic, fluctuating log structures seamlessly via `jsonPayload`.
*   **Cons:** Users must wait up to 60 minutes for log intervals to close before seeing new analytics.

---

Select your approach by reviewing the linked folder architectures above! 
