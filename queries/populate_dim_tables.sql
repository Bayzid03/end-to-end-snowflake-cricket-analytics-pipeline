-- ============================================================
-- POPULATING DIMENSION TABLES FROM CURATED MATCH DATA
-- ============================================================
-- Since we don’t have separate master datasets, we derive dimension values directly from curated match detail tables. In real-world projects,
-- master data often comes from official registries (teams, venues, referees).
-- ============================================================

-- ------------------------------------------------------------
-- TEAM DIMENSION
-- ------------------------------------------------------------

-- Step 1: Extract distinct team names from curated match details
-- (both first team and second team fields)
select distinct team_name
from (
    select first_team as team_name from cricket.curated.match_detail_curated
    union all
    select second_team as team_name from cricket.curated.match_detail_curated
);

-- Step 2: Insert unique team names into enriched team_dim
insert into cricket.enriched.team_dim (team_name)
select distinct team_name
from (
    select first_team as team_name from cricket.curated.match_detail_curated
    union all
    select second_team as team_name from cricket.curated.match_detail_curated
)
order by team_name;

-- Step 3: Verify the populated team_dim
select * from cricket.enriched.team_dim order by team_name;


-- ------------------------------------------------------------
-- PLAYER DIMENSION
-- ------------------------------------------------------------

-- Step 1: Preview player data from curated player table
select * from cricket.curated.player_curated_table limit 10;

-- Step 2: Group players by country and name to remove duplicates
select country, player_name
from cricket.curated.player_curated_table
group by country, player_name;

-- Step 3: Join players with team_dim to get team_id
select a.country, b.team_id, a.player_name
from cricket.curated.player_curated_table a
join cricket.enriched.team_dim b
    on a.country = b.team_name
group by a.country, b.team_id, a.player_name;

-- Step 4: Insert into player_dim (team_id + player_name)
insert into cricket.enriched.player_dim (team_id, player_name)
select b.team_id, a.player_name
from cricket.curated.player_curated_table a
join cricket.enriched.team_dim b
    on a.country = b.team_name;

-- Step 5: Verify player_dim
select * from cricket.enriched.player_dim;

-- ------------------------------------------------------------
-- REFEREE DIMENSION
-- ------------------------------------------------------------

-- Step 1: Preview curated match details
select * from cricket.curated.match_detail_curated limit 10;

-- Step 2: Inspect raw JSON structure for officials
select info from cricket.raw.match_raw_table limit 1;

-- Step 3: Extract referee and umpire details from JSON fields
select
     info:officials.match_referees[0]::text as match_referee,
     info:officials.reserve_umpires[0]::text as reserve_umpire,
     info:officials.tv_umpires[0]::text as tv_umpire,
     info:officials.umpires[0]::text as first_umpire,
     info:officials.umpires[1]::text as second_umpire
from cricket.raw.match_raw_table
limit 1;

-- (Referee_dim can be populated later using extracted values)

-- ------------------------------------------------------------
-- VENUE DIMENSION
-- ------------------------------------------------------------

-- Step 1: Preview venue and city from curated match details
select * from cricket.curated.match_detail_curated limit 10;

-- Step 2: Select venue and city fields
select venue, city
from cricket.curated.match_detail_curated limit 10;

-- Step 3: Group by venue and city to remove duplicates
select venue, city
from cricket.curated.match_detail_curated
group by venue, city;

-- Step 4: Insert into venue_dim, replacing null city with 'NA'
insert into cricket.enriched.venue_dim (venue_name, city)
select venue, 
       case when city is null then 'NA' else city end as city
from cricket.curated.match_detail_curated
group by venue, city;

-- Step 5: Verify venue_dim
select * from cricket.enriched.venue_dim where city = 'Bengaluru';

-- Step 6: Check for duplicate cities
select city
from cricket.enriched.venue_dim
group by city
having count(1) > 1;

-- ------------------------------------------------------------
-- MATCH TYPE DIMENSION
-- ------------------------------------------------------------

-- Step 1: Preview match types from curated match details
select * from cricket.curated.match_detail_curated limit 10;

-- Step 2: Extract distinct match types (Test, ODI, T20, etc.)
select match_type
from cricket.curated.match_detail_curated
group by match_type;

-- Step 3: Insert unique match types into match_type_dim
insert into cricket.enriched.match_type_dim (match_type)
select match_type
from cricket.curated.match_detail_curated
group by match_type;

-- Step 4: Verify match_type_dim
select * from cricket.enriched.match_type_dim;
