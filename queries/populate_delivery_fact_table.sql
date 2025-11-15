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

-- ------------------------------------------------------------
-- v2: Get Player IDs
-- ------------------------------------------------------------
-- Join delivery records with player_dim to fetch bowler, batter, and non-striker IDs.
select 
    d.match_type_number as match_id,
    td.team_id, 
    td.team_name,
    bpd.player_id as bowler_id, bpd.player_name as bowler,
    spd.player_id as batter_id, spd.player_name as batter,
    nspd.player_id as non_striker_id, nspd.player_name as non_striker
from cricket.curated.delivery_curated_table d
join team_dim td on d.team_name = td.team_name
join player_dim bpd on d.bowler = bpd.player_name
join player_dim spd on d.batter = spd.player_name
join player_dim nspd on d.non_striker = nspd.player_name
where d.match_type_number = 4686;

-- ------------------------------------------------------------
-- v3: Add Delivery Measurements
-- ------------------------------------------------------------
-- Include delivery-level metrics: over, runs, extras, and extra type.
select 
    d.match_type_number as match_id,
    td.team_id,
    bpd.player_id as bowler_id, bpd.player_name as bowler,
    spd.player_id as batter_id, spd.player_name as striker,
    nspd.player_id as non_striker_id, nspd.player_name as non_striker,
    d.over,
    d.runs,
    d.extra_runs,
    d.extra_type
from cricket.curated.delivery_curated_table d
join team_dim td on d.team_name = td.team_name
join player_dim bpd on d.bowler = bpd.player_name
join player_dim spd on d.batter = spd.player_name
join player_dim nspd on d.non_striker = nspd.player_name
where d.match_type_number = 4686;
