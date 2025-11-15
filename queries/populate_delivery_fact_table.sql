-- ============================================================
-- DELIVERY FACT TABLE POPULATION SCRIPT
-- ============================================================
-- This script builds the delivery_fact table by joining delivery-level
-- curated data with team and player dimensions. It captures granular
-- ball-by-ball measures (runs, extras, wickets).
-- ============================================================

use role sysadmin;
use warehouse compute_wh;
use schema cricket.enriched;

select * 
from cricket.curated.delivery_curated_table
where match_type_number = 4686;


-- ------------------------------------------------------------
-- v1: Get Team ID
-- ------------------------------------------------------------
-- Join delivery records with team_dim to fetch team_id for each delivery.
select 
    d.match_type_number as match_id,
    td.team_id, 
    td.team_name
from cricket.curated.delivery_curated_table d
join team_dim td on d.team_name = td.team_name
where d.match_type_number = 4686;
