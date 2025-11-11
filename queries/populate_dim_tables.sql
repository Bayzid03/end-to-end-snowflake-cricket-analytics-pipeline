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
