-- Set the active role to SYSADMIN for required privileges
use role sysadmin;

-- Select the compute warehouse for query execution
use warehouse compute_wh;

-- Set the working schema to curated layer of cricket database
use schema cricket.curated;

-- Step 1: Retrieve match details for the specific match (4686) from curated match detail table
select * 
from cricket.curated.match_detail_curated
where match_type_number = 4686;

-- Step 2: Aggregate batter-level runs for each team in match 4686
-- Summarizes total runs scored by each batter grouped by team
select 
    team_name,
    batter,
    sum(runs)
from delivery_curated_table
where match_type_number = 4686
group by team_name, batter
order by 1, 2, 3 desc;

-- Step 3: Aggregate team-level runs including extras for match 4686
-- Provides total team score by summing batter runs and extra runs
select
    team_name,
    sum(runs) + sum(extra_runs) as team_total_runs
from delivery_curated_table
where match_type_number = 4686
group by team_name
order by 1, 2 desc;
