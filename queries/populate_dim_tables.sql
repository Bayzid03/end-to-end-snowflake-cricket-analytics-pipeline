-- ============================================================
-- POPULATING DIMENSION TABLES FROM CURATED MATCH DATA
-- ============================================================
-- Since we don’t have separate master datasets, we derive dimension values
-- directly from curated match detail tables. In real-world projects,
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
