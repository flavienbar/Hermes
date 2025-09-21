# Hermes
Data Lab : exploration 
---

## Schéma du pipeline
               ┌─────────────┐
               │   Binance    │
               │   (source)   │
               └──────┬───────┘
                      │
                 [fichiers .zip]
                      │
                      ▼
            ┌──────────────────┐
            │   MinIO bucket   │
            │     bronze       │
            └────────┬─────────┘
                     │
      [lecture + parsing avec Polars]
                     │
                     ▼
            ┌──────────────────┐
            │   MinIO bucket   │
            │     silver       │
            │ (Parquet part.)  │
            └────────┬─────────┘
                     │
 [métadonnées Iceberg (pyiceberg)]
                     │
                     ▼
            ┌──────────────────┐
            │   MinIO bucket   │
            │      gold        │
            │ (tables Iceberg) │
            └──────────────────┘

