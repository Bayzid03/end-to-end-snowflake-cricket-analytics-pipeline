use role sysadmin;
use warehouse compute_wh;
use schema cricket.curated;

-- Step 1: Retrieve the innings array for a specific match to inspect its structure
select
    m.info:match_type_number::int as match_type_number,
    m.innings
from cricket.raw.match_raw_table m
where match_type_number = 3951;

-- Step 2: Flatten the innings array to extract each team's innings details
select
    m.info:match_type_number::int as match_type_number,
    i.value:team::text as team_name,
    i.*
from cricket.raw.match_raw_table m,
lateral flatten (input => m.innings) i
where match_type_number = 3951;

-- Step 3: Further flatten overs and deliveries to access granular delivery-level data
select
    m.info:match_type_number::int as match_type_number,
    i.value:team::text as team_name,
    d.*
from cricket.raw.match_raw_table m,
lateral flatten (input => m.innings) i,
lateral flatten (input => i.value:overs) o,
lateral flatten (input => i.value:deliveries) d
where match_type_number = 3951;
