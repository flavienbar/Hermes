# Hermes Data Lab

Ce document décrit l'architecture du Data Lab Hermes, une plateforme conçue pour l'ingestion, la transformation et l'analyse de données financières en vue de développer et backtester des stratégies de trading.

🏛️ Architecture Générale : Modèle Medallion

L'architecture repose sur le modèle Medallion en trois couches (Bronze, Argent, Or). Ce modèle garantit une séparation claire des responsabilités, une traçabilité des données et une montée en qualité progressive, de la donnée brute à la donnée prête à l'emploi.
Plaintext

          +-------------------------+
          |     Source : NFS        |
          |  Fichiers bruts (.zip)  |
          | (Données d'API, etc.)   |
          +-----------+-------------+
                      |
                      v
          +-------------------------+
          |      🥉 Couche Bronze     |
          | - Tables brutes, immuables|
          | - Partitionnées par date  |
          | - Format : Parquet        |
          | - Stockage : MinIO        |
          +-----------+-------------+
                      |
                      v
          +-------------------------+
          |      🥈 Couche Argent     |
          | - Données nettoyées, validées|
          | - Types, dates et schémas standardisés |
          | - Contrôles qualité       |
          | - Stockage : MinIO        |
          +-----------+-------------+
                      |
                      v
          +-------------------------+
          |       🥇 Couche Or        |
          | - Datamarts spécialisés   |
          | - Données enrichies, agrégées|
          | - Indicateurs de trading  |
          | - Stockage : MinIO        |
          +-------------------------+

🛠️ Écosystème Technologique

Notre architecture s'appuie sur des outils modernes et performants, choisis pour leur efficacité dans le traitement de données volumineuses.
Outil	Rôle dans l'architecture
MinIO (S3)	Data Lake central pour le stockage des couches Bronze, Argent et Or.
DuckDB	Moteur d'interrogation SQL rapide pour lire/écrire sur MinIO, effectuer des jointures et des agrégations.
Polars	Moteur de transformation ultra-rapide pour le nettoyage, le calcul d'indicateurs et les manipulations complexes de DataFrames.
Jupyter Notebook	Interface d'analyse et d'exploration pour le développement des stratégies, la visualisation et le backtesting.

🌊 Flux de Données (Data Flow)

Le parcours de la donnée suit un processus clair à travers les trois couches.

Étape 1 : Ingestion (Source → Bronze)

L'objectif de cette étape est de créer une copie brute, fiable et partitionnée des données sources.

    Les fichiers .zip contenant les données brutes sont récupérés depuis le montage NFS.

    Un script lit chaque archive, ajoute des colonnes de date (year, month, day) pour le partitionnement.

    Les données sont écrites sur MinIO au format Parquet, partitionnées par date. Polars et DuckDB sont utilisés pour leur efficacité dans ce processus.

Étape 2 : Structuration et Nettoyage (Bronze → Argent)

Ici, nous transformons les données brutes en une source de vérité propre et fiable.

    Les tables de la couche Bronze sont lues depuis MinIO.

    Des transformations structurelles sont appliquées avec Polars :

        Conversion des timestamps en dates lisibles et fuseaux horaires cohérents.

        Correction et unification des types de données (ex: string → float).

        Application de contrôles qualité pour détecter les anomalies (valeurs manquantes, outliers).

    Les tables nettoyées et structurées sont écrites dans la couche Argent sur MinIO.

Étape 3 : Enrichissement Métier (Argent → Or)

Cette couche crée des datamarts spécialisés, prêts à être consommés par les algorithmes de trading.

    Les données propres de la couche Argent sont lues.

    Des règles métier et des calculs complexes sont appliqués :

        Calcul d'indicateurs techniques (Moyennes Mobiles, RSI, etc.) via Polars.

        Jointures avec d'autres sources de données (ex: données macro-économiques) via DuckDB.

        Création de signaux de trading basés sur les stratégies définies.

    Les tables finales, enrichies et souvent agrégées, sont stockées dans la couche Or.

Étape 4 : Consommation et Analyse (Or → Jupyter)

La couche Or est le point d'entrée pour toute analyse.

    Les Jupyter Notebooks se connectent directement aux tables de la couche Or via DuckDB pour explorer les données, visualiser les résultats, et itérer rapidement sur le backtesting des stratégies.

✨ Bonnes Pratiques et Recommandations

Pour garantir la robustesse et la maintenabilité de la plateforme, les principes suivants sont appliqués :

    Format de Fichiers : Le format Parquet est utilisé systématiquement après l'ingestion initiale pour bénéficier de la compression, du stockage en colonnes et de l'optimisation des lectures (predicate pushdown).

    Qualité des Données : Des métriques de qualité sont calculées et suivies lors du passage à la couche Argent pour garantir la fiabilité des analyses en aval.

    Versioning : Chaque couche (données) et chaque transformation (code) doit être versionnée. Cela permet de garantir la reproductibilité des expériences et des backtests.

    Séparation des Environnements : Les données utilisées pour le backtesting (couche Or) doivent être distinctes de celles utilisées en production pour éviter tout biais ou contamination des modèles.

    Traçabilité : Chaque table de la couche Or doit pouvoir être tracée jusqu'à sa source brute dans les fichiers NFS, en documentant toutes les transformations intermédiaires.


















# Hermes
Data Lab : exploration 
---

          +-------------------------+
          |         NFS             |
          |  Fichiers bruts .zip    |
          | (API ou téléchargés)    |
          +-----------+-------------+
                      |
                      v
          +-------------------------+
          |        Bronze           |
          | - Tables brutes         |
          | - Partitionnées (date)  |
          | - Stockage : MinIO  (format Parquet)    |
          | - Lecture/écriture :   |
          |   Polars / DuckDB       |
          +-----------+-------------+
                      |
                      v
          +-------------------------+
          |        Argent  
          Tables Bronze         |
          | - Nettoyage / structuration |
          | - Dates lisibles, alignement |
          |   temporel, types cohérents,contrôles   qualité   |
          | - Stockage : MinIO           |
          | - Traitement : Polars / DuckDB|
          +-----------+-------------+
                      |
                      v
          +-------------------------+
          |         Or              |
          | - Tables Argent enrichies,     |
          |   prêtes pour trading   |
          | - Application stratégie |
          | - Stockage : MinIO      |
          | - Analyse : Polars / DuckDB / Jupyter |
          +-------------------------+


| Couche        | MinIO                   | DuckDB                           | Polars                               | Jupyter Notebook                            |
| ------------- | ----------------------- | -------------------------------- | ------------------------------------ | ------------------------------------------- |
| Bronze        | Stockage partitionné    | Lecture rapide, SQL sur fichiers | Chargement / transformations rapides | Exploration des données                     |
| Argent        | Stockage structuré      | SQL + Joins, agrégations         | Transformations complexes, nettoyage | Notebooks pour test / ETL                   |
| Or (datamart) | Stockage tables finales | Interrogation pour backtesting   | Calcul indicateurs, signaux          | Analyse / visualisation / stratégie trading |


Ingestion NFS → Bronze :

Tu prends les .zip de l’API, tu les décompresses et tu stockes les fichiers bruts sur MinIO.

DuckDB et Polars permettent de charger les fichiers Parquet/CSV directement depuis MinIO pour traitement.

Bronze → Argent :

Nettoyage minimal et transformation structurelle : date lisible, alignement temporel, types corrects.

Polars est très rapide pour les transformations colonne par colonne.

Argent → Or (Datamart) :

Application des règles de trading et calcul des indicateurs.

DuckDB permet des jointures SQL complexes si nécessaire.

Polars sert pour le calcul vectorisé très rapide (ex : indicateurs techniques).

Or → Consommation / Analyse :

Jupyter pour visualisation et exploration.

Tu peux itérer sur stratégies de trading directement sur les tables Or.


Chaque couche peut avoir un versioning pour tracer les changements.
Bronze = “raw”, Argent = “curated / structured”, Or = “consommable / ready-to-use”


NFS : fichiers bruts .zip en provenance de l’API

Positif :

Stocker les fichiers bruts tels quels est une bonne pratique pour reproduire l’ingestion initiale et conserver l’historique exact des données.

Permet de refaire des transformations si nécessaire.

À améliorer :

Vérifie que tu as un mécanisme de tracking de version/date pour ces fichiers, afin de pouvoir retracer exactement quelle version a été ingérée.

Penser à l’archivage et nettoyage automatique si le volume devient très important.

2️⃣ Bronze : tables brutes partitionnées sur MinIO

Positif :

Partitionner dès le départ (par date par exemple) est excellent pour le scaling et l’optimisation des lectures dans Spark ou PySpark.

Stocker sur MinIO (S3-like) est très adapté pour un datalake.

À améliorer :

Assure-toi que les formats sont optimisés pour le traitement : Parquet ou Delta Lake (plutôt que CSV/JSON), pour bénéficier de compression, schema evolution, predicate pushdown.

Bronze doit rester “raw” : évite de faire des transformations ici (même minimes), sauf nettoyage obligatoire pour ingestion.

3️⃣ Argent : tables de Bronze avec transformations structurelles

Positif :

Transformation pour rendre la date lisible et alignement temporel sont classiques pour la couche “silver”.

Ici, on commence à corriger/structurer les données sans perte d’information.

À améliorer :

Documente bien toutes les transformations, surtout si elles influencent les calculs de stratégie.

Penser à inclure des indicateurs de qualité / anomalies détectées, très important en trading.

4️⃣ Or : tables d’Argent avec application de stratégie trading

Positif :

Bonne pratique d’avoir une couche finale “ready-to-use” pour les algos de trading.

Idéalement, ces tables sont aggrégées, filtrées, enrichies, et prêtes pour l’analytics ou la production.

À améliorer :

Sépare éventuellement les données utilisées pour backtesting vs celles pour production pour éviter les contaminations.

Penser à des méta-données de version de stratégie et des logs de backtest pour audit et traçabilité.

✅ Conclusion générale

Ton architecture suit globalement les bonnes pratiques du datalake en 3 couches (bronze/silver/gold) :

NFS = raw files

Bronze = ingestion brute partitionnée

Argent = structuration / nettoyage

Or = application métier / trading

💡 Quelques conseils pour l’améliorer :

Utiliser Parquet/Delta Lake pour Bronze/Argent/Or pour performance et fiabilité.

Ajouter un système de versioning/metadata à chaque couche.

Tracker la qualité des données à la couche Argent.

Séparer backtesting et production pour Or.