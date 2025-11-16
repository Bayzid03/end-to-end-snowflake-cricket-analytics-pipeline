# 🏏 End-to-End Snowflake Cricket Analytics Pipeline

> **Enterprise data warehouse for cricket analytics with advanced dimensional modeling and multi-layer architecture**

[![Snowflake](https://img.shields.io/badge/Snowflake-Data%20Warehouse-29B5E8?style=flat-square&logo=snowflake)](https://www.snowflake.com/)
[![SQL](https://img.shields.io/badge/SQL-Advanced%20Queries-4479A1?style=flat-square&logo=postgresql)](https://www.snowflake.com/)
[![Star Schema](https://img.shields.io/badge/Star%20Schema-Dimensional%20Modeling-FF6B35?style=flat-square)]()
[![JSON](https://img.shields.io/badge/JSON-Semi--Structured-000000?style=flat-square&logo=json)](https://www.json.org/)

## 🎯 Overview

A **production-grade data warehouse** built on Snowflake, processing 2,400+ cricket match JSON files into a comprehensive analytics platform. Implements **4-layer medallion architecture** (Landing → Raw → Curated → Enriched) with star schema design for deep sports analytics and business intelligence.

### ✨ Key Features

- **📊 4-Layer Architecture** - Landing, Raw, Curated, Enriched for data quality progression
- **⭐ Star Schema Design** - 5 dimensions + 2 fact tables for flexible analytics
- **🔄 JSON Processing** - 2,411 nested JSON files flattened into structured tables
- **📈 Advanced SQL** - Window functions, CTEs, lateral flatten, aggregations
- **🏗️ Dimensional Modeling** - Type 1 SCD with surrogate keys and foreign keys
- **⚡ Optimized Performance** - Transient tables, compression, partitioning strategies
- **🔍 Data Quality** - Constraints, validation, referential integrity
- **📊 Deep Analytics** - Ball-by-ball delivery tracking, match outcomes, player performance

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                   DATA SOURCE                                │
├──────────────────────────────────────────────────────────────┤
│  📄 Cricket Match Data (JSON)                               │
│  • 2,411 match files in gzipped JSON format                  │
│  • Nested structure: meta, info, innings, deliveries         │
│  • Contains: Match details, players, ball-by-ball events     │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│                   LANDING LAYER (cricket.land)               │
├──────────────────────────────────────────────────────────────┤
│  📂 Snowflake Internal Stage                                │
│  • Path: @int_stg/cricket_data/json/                        │
│  • Format: JSON (strip_outer_array = true)                  │
│  • Compression: gzip                                         │
│  • Metadata tracking: filename, row_number, hash            │
└──────────────────────────────────────────────────────────────┘
                            ↓
                    COPY INTO command
                            ↓
┌──────────────────────────────────────────────────────────────┐
│                   RAW LAYER (cricket.raw)                    │
├──────────────────────────────────────────────────────────────┤
│  💾 match_raw_table (Transient)                             │
│  • Column Types: OBJECT, VARIANT, ARRAY                     │
│  • Root elements extracted: meta, info, innings             │
│  • 2,411 records loaded                                      │
│  • Preserves original JSON structure                         │
└──────────────────────────────────────────────────────────────┘
                            ↓
              Advanced SQL Transformations
          (FLATTEN, LATERAL JOIN, CTEs)
                            ↓
┌──────────────────────────────────────────────────────────────┐
│                   CURATED LAYER (cricket.curated)            │
├──────────────────────────────────────────────────────────────┤
│  📊 Structured Relational Tables                            │
│  • match_detail_curated                                      │
│    - Match metadata, teams, venue, toss, result             │
│  • player_curated_table                                      │
│    - Player roster by country/team                           │
│  • delivery_curated_table                                    │
│    - Ball-by-ball delivery data with wickets & extras       │
│  • Primary/Foreign key constraints enforced                  │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│              ENRICHED LAYER (cricket.enriched)               │
├─────────────────────────┬────────────────────────────────────┤
│  📊 DIMENSIONS          │  ⭐ FACTS                          │
├─────────────────────────┼────────────────────────────────────┤
│ • date_dim             │ • match_fact                       │
│ • referee_dim          │   - Aggregated match metrics       │
│ • team_dim             │   - Team A vs Team B stats         │
│ • player_dim           │   - Toss, result, run rates        │
│ • venue_dim            │ • delivery_fact                    │
│ • match_type_dim       │   - Ball-by-ball granularity       │
│                         │   - Bowler, batter, runs, wickets │
└─────────────────────────┴────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│                   ANALYTICS & BI                             │
├──────────────────────────────────────────────────────────────┤
│  📊 Advanced Analytics Queries                              │
│  • Team performance analysis                                 │
│  • Player statistics & rankings                              │
│  • Match outcome predictions                                 │
│  • Venue/pitch analysis                                      │
│  • Historical trend analysis                                 │
└──────────────────────────────────────────────────────────────┘
```

## 🛠️ Technical Stack

### **Data Warehouse Platform**
- **❄️ Snowflake** - Cloud data warehouse with compute separation
- **📊 Multi-Layer Architecture** - Landing, Raw, Curated, Enriched
- **💾 Transient Tables** - Optimized for ETL workloads
- **🔄 COPY INTO** - Bulk data loading from internal stage

### **Data Processing**
- **🔍 LATERAL FLATTEN** - Unnesting JSON arrays and objects
- **📊 Window Functions** - Analytical calculations (FIRST_VALUE, LAST_VALUE, ROW_NUMBER)
- **🔗 CTEs** - Complex multi-step transformations
- **⚡ VARIANT/ARRAY/OBJECT** - Semi-structured data types

### **Data Modeling**
- **⭐ Star Schema** - Fact-dimension architecture
- **🔑 Surrogate Keys** - AUTOINCREMENT for primary keys
- **🔗 Foreign Keys** - Referential integrity (NOT ENFORCED for performance)
- **📏 Constraints** - NOT NULL, PRIMARY KEY, FOREIGN KEY

### **Data Sources**
- **📄 JSON Format** - Nested match data (meta, info, innings)
- **📦 gzip Compression** - Efficient storage and transfer
- **🎯 2,411 Files** - Comprehensive cricket match dataset

## 📊 Data Model

### **Dimension Tables**
| Dimension | Records | Key Attributes |
|-----------|---------|----------------|
| `date_dim` | 365+ | day, month, year, quarter, dayofweek, isweekend |
| `team_dim` | 50+ | team_name |
| `player_dim` | 1,000+ | player_name, team_id |
| `venue_dim` | 200+ | venue_name, city, country, capacity, coordinates |
| `referee_dim` | 100+ | referee_name, referee_type |
| `match_type_dim` | 3 | match_type (Test, ODI, T20) |

### **Fact Tables**
| Fact | Grain | Measures | Records |
|------|-------|----------|---------|
| `match_fact` | One row per match | Team scores, overs, wickets, run rates, boundary %, extras % | 2,411 |
| `delivery_fact` | One row per ball | Runs, extras, wickets, bowler_id, batter_id | 500K+ |

### **Curated Tables**
| Table | Purpose | Records |
|-------|---------|---------|
| `match_detail_curated` | Match metadata & outcomes | 2,411 |
| `player_curated_table` | Player rosters by team | 10,000+ |
| `delivery_curated_table` | Ball-by-ball delivery data | 500K+ |

## 🚀 Quick Start

### Prerequisites
- Snowflake account (Standard or higher)
- SQL client (SnowSQL, Snowflake Web UI, DBeaver)
- Cricket match JSON files (2,411 files)

### Setup Instructions

**1. Create Database & Schemas**
```sql
-- Execute: queries/schema_creation.sql
CREATE DATABASE IF NOT EXISTS cricket;
CREATE SCHEMA cricket.land;
CREATE SCHEMA cricket.raw;
CREATE SCHEMA cricket.curated;
CREATE SCHEMA cricket.enriched;

-- Create JSON file format
CREATE FILE FORMAT json_format
  TYPE = JSON
  STRIP_OUTER_ARRAY = TRUE;

-- Create internal stage
CREATE STAGE int_stg;
```

**2. Upload JSON Files**
```bash
# Using SnowSQL
snowsql -a your_account -u your_user -q "PUT file://path/to/json/*.json.gz @cricket.land.int_stg/cricket_data/json/"
```

**3. Load Raw Data**
```sql
-- Execute: queries/raw_zone.sql
CREATE TRANSIENT TABLE cricket.raw.match_raw_table (
    meta OBJECT NOT NULL,
    info VARIANT NOT NULL,
    innings ARRAY NOT NULL,
    stg_file_name TEXT,
    stg_file_row_number INT,
    stg_file_hashkey TEXT,
    stg_modified_ts TIMESTAMP
);

COPY INTO cricket.raw.match_raw_table FROM (
    SELECT 
        t.$1:meta::OBJECT,
        t.$1:info::VARIANT,
        t.$1:innings::ARRAY,
        metadata$filename,
        metadata$file_row_number,
        metadata$file_content_key,
        metadata$file_last_modified
    FROM @cricket.land.int_stg/cricket_data/json/
    (file_format => 'cricket.land.json_format')
) ON_ERROR = CONTINUE;
```

**4. Transform to Curated Layer**
```sql
-- Execute: queries/curated_zone.sql, curated_zone2.sql, curated_zone3.sql
-- Creates match_detail_curated, player_curated_table, delivery_curated_table
```

**5. Build Dimensional Model**
```sql
-- Execute: queries/dim_nd_fact_table.sql
-- Creates all dimension and fact tables

-- Execute: queries/populate_dim_tables.sql
-- Populates dimensions from curated data

-- Execute: queries/populate_fact_dim_tables.sql, populate_delivery_fact_table.sql
-- Loads fact tables with aggregated metrics
```

**6. Run Analytics**
```sql
-- Execute: queries/data_quality_check.sql
-- Validate data integrity and run sample queries
```

## 📁 Project Structure

```
cricket-analytics-pipeline/
├── queries/
│   ├── schema_creation.sql              # Database & schema setup
│   ├── raw_zone.sql                     # Raw data loading
│   ├── curated_zone.sql                 # Match detail transformations
│   ├── curated_zone2.sql                # Player data flattening
│   ├── curated_zone3.sql                # Delivery-level extraction
│   ├── dim_nd_fact_table.sql            # Star schema DDL
│   ├── populate_dim_tables.sql          # Dimension population
│   ├── populate_fact_dim_tables.sql     # Match fact loading
│   ├── populate_delivery_fact_table.sql # Delivery fact loading
│   └── data_quality_check.sql           # Validation queries
└── README.md
```

## 🔧 Advanced SQL Techniques

### **1. JSON Flattening with LATERAL FLATTEN**
```sql
-- Unnest nested arrays (players, overs, deliveries)
SELECT 
    raw.info:match_type_number::INT as match_id,
    p.path::TEXT as country,
    team.value::TEXT as player_name
FROM cricket.raw.match_raw_table raw,
LATERAL FLATTEN(input => raw.info:players) p,
LATERAL FLATTEN(input => p.value) team;
```

### **2. Window Functions for Aggregation**
```sql
-- Calculate opening & closing prices using FIRST_VALUE/LAST_VALUE
SELECT 
    symbol, trade_date,
    FIRST_VALUE(price) OVER (
        PARTITION BY symbol, trade_date 
        ORDER BY timestamp
    ) as candle_open,
    LAST_VALUE(price) OVER (
        PARTITION BY symbol, trade_date 
        ORDER BY timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as candle_close
FROM delivery_curated_table;
```

### **3. Complex CTEs for Multi-Step Transforms**
```sql
-- Extract match metadata with conditional logic
WITH enriched AS (
    SELECT 
        match_id,
        CASE 
            WHEN info:event.match_number IS NOT NULL 
            THEN info:event.match_number
            WHEN info:event.stage IS NOT NULL 
            THEN info:event.stage
            ELSE 'NA'
        END as match_stage
    FROM match_raw_table
)
SELECT * FROM enriched;
```

### **4. Dimensional Model Population**
```sql
-- Populate fact table with aggregated delivery metrics
INSERT INTO match_fact
SELECT 
    m.match_type_number,
    dd.date_id,
    SUM(CASE WHEN d.team_name = m.first_team THEN d.runs END) as team_a_runs,
    SUM(CASE WHEN d.team_name = m.first_team THEN 1 END) as team_a_balls,
    COUNT(CASE WHEN d.player_out IS NOT NULL THEN 1 END) as team_a_wickets
FROM match_detail_curated m
JOIN delivery_curated_table d ON m.match_type_number = d.match_type_number
JOIN date_dim dd ON m.event_date = dd.full_dt
GROUP BY m.match_type_number, dd.date_id;
```

## 📈 Sample Analytics Queries

### **Top Run Scorers**
```sql
SELECT 
    p.player_name,
    t.team_name,
    SUM(df.runs) as total_runs,
    COUNT(DISTINCT df.match_id) as matches_played,
    ROUND(SUM(df.runs) * 1.0 / COUNT(DISTINCT df.match_id), 2) as avg_runs_per_match
FROM delivery_fact df
JOIN player_dim p ON df.batter_id = p.player_id
JOIN team_dim t ON p.team_id = t.team_id
GROUP BY p.player_name, t.team_name
ORDER BY total_runs DESC
LIMIT 20;
```

### **Venue Win Rates**
```sql
SELECT 
    v.venue_name,
    v.city,
    COUNT(*) as total_matches,
    SUM(CASE WHEN mf.toss_winner_team_id = mf.winner_team_id THEN 1 ELSE 0 END) as toss_wins,
    ROUND(toss_wins * 100.0 / total_matches, 2) as toss_win_percentage
FROM match_fact mf
JOIN venue_dim v ON mf.venue_id = v.venue_id
GROUP BY v.venue_name, v.city
HAVING COUNT(*) >= 10
ORDER BY toss_win_percentage DESC;
```

### **Bowler Economy Rates**
```sql
SELECT 
    p.player_name,
    COUNT(DISTINCT df.match_id) as matches,
    COUNT(*) as balls_bowled,
    SUM(df.runs + df.extra_runs) as runs_conceded,
    ROUND(runs_conceded * 6.0 / NULLIF(balls_bowled, 0), 2) as economy_rate
FROM delivery_fact df
JOIN player_dim p ON df.bowler_id = p.player_id
GROUP BY p.player_name
HAVING balls_bowled >= 300
ORDER BY economy_rate ASC
LIMIT 20;
```

## 🌟 Key Technical Highlights

### **Semi-Structured Data Mastery**
- ✅ **VARIANT, OBJECT, ARRAY** types for flexible JSON handling
- ✅ **Path notation** (info:teams[0]) for nested access
- ✅ **FLATTEN operations** for array unnesting
- ✅ **Type casting** (::TEXT, ::INT, ::DATE) for data quality

### **Performance Optimization**
- ✅ **Transient tables** for ETL (no Fail-safe storage)
- ✅ **COPY INTO** for bulk loading (2,411 files)
- ✅ **Surrogate keys** with AUTOINCREMENT
- ✅ **Foreign keys** (NOT ENFORCED) for documentation + query optimization

### **Data Quality & Governance**
- ✅ **NOT NULL constraints** on critical columns
- ✅ **Primary/Foreign keys** for referential integrity
- ✅ **Data validation queries** for QA checks
- ✅ **Metadata tracking** (file name, row number, hash, timestamp)

### **Advanced Analytics**
- ✅ **Star schema** for flexible BI queries
- ✅ **Date dimension** with calendar attributes
- ✅ **Fact tables** at multiple grains (match, delivery)
- ✅ **Calculated measures** (run rates, boundary %, extras %)

## 🎯 Real-world Use Cases

- **📊 Sports Analytics Platforms** - Fan engagement dashboards (ESPN, Cricbuzz)
- **🏆 Team Performance** - Coach decision support systems
- **🎮 Fantasy Cricket** - Player statistics and predictions
- **📺 Broadcasting** - Real-time match graphics and insights
- **💼 Sports Betting** - Odds calculation and risk modeling

## 🚀 Future Enhancements

- [ ] **🤖 ML Integration** - Win probability models, player performance prediction
- [ ] **📊 Power BI Dashboards** - Interactive visualizations for stakeholders
- [ ] **⚡ Incremental Loading** - CDC for new match data
- [ ] **🗓️ Time-Series Analysis** - Player form tracking, trend identification
- [ ] **🌐 API Layer** - REST endpoints for external consumption
- [ ] **🔔 Alerting** - Real-time match event notifications

## 🤝 Contributing

Contributions welcome! Focus areas:
- **📊 Additional Metrics** - New analytical views and KPIs
- **🔧 Query Optimization** - Performance tuning for large datasets
- **🧪 Testing** - Data quality checks and validation scripts
- **📈 Visualization** - Tableau/Power BI integration examples

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

**Enterprise cricket analytics powered by Snowflake** 🏏❄️
