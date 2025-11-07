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

-- Step 4: Extract detailed delivery-level metrics including bowler, batter, runs, and extras
select
    m.info:match_type_number::int as match_type_number,
    i.value:team::text as team_name,
    o.value:over::int+1 as over,
    d.value:bowler::text as bowler,
    d.value:batter::text as batter,
    d.value:non_striker::text as non_striker,
    d.value:runs.batter::text as runs,
    d.value:runs.extras::text as extras,
    d.value:runs.total::text as total,
    e.key::text as extra_type,
    e.value::number as extra_runs
from cricket.raw.match_raw_table m,
lateral flatten (input => m.innings) i,
lateral flatten (input => i.value:overs) o,
lateral flatten (input => i.value:deliveries) d,
lateral flatten (input => d.value:extras, outer => True) e
where match_type_number = 3951;

-- Step 5: Create a curated delivery-level table with enriched match metadata and dismissal info
create or replace transient table cricket.curated.delivery_curated_table as
select 
    m.info:match_type_number::int as match_type_number, 
    i.value:team::text as country,
    o.value:over::int as over,
    d.value:bowler::text as bowler,
    d.value:batter::text as batter,
    d.value:non_striker::text as non_striker,
    d.value:runs.batter::text as runs,
    d.value:runs.extras::text as extras,
    d.value:runs.total::text as total,
    e.key::text as extra_type,
    e.value::number as extra_runs,
    w.value:player_out::text as player_out,
    w.value:kind::text as player_out_kind,
    w.value:fielders::variant as player_out_fielders,
    m.stg_file_name ,
    m.stg_file_row_number,
    m.stg_file_hashkey,
    m.stg_modified_ts
from cricket.raw.match_raw_table m,
lateral flatten (input => m.innings) i,
lateral flatten (input => i.value:overs) o,
lateral flatten (input => o.value:deliveries) d,
lateral flatten (input => d.value:extras, outer => True) e;
lateral flatten (input => d.value:wickets, outer => True) w;

-- Step 6: Inspect the structure of the newly created curated delivery table
desc table cricket.curated.delivery_curated_table;

-- Step 7: Enforce NOT NULL constraints on key analytical columns
alter table cricket.curated.delivery_curated_table
modify column match_type_number set not null;

alter table cricket.curated.delivery_curated_table
modify column team_name set not null;

alter table cricket.curated.delivery_curated_table
modify column over set not null;

alter table cricket.curated.delivery_curated_table
modify column bowler set not null;

alter table cricket.curated.delivery_curated_table
modify column batter set not null;

alter table cricket.curated.delivery_curated_table
modify column non_striker set not null;

-- Step 8: Define foreign key relationship to match detail curated table for referential integrity
alter table cricket.curated.delivery_curated_table
add constraint fk_delivery_match_id
foreign key (match_type_number)
references cricket.curated.match_detail_curated (match_type_number);

-- Step 9: Retrieve the DDL statement for the curated delivery table for documentation or migration
select get_ddl('table', 'delivery_curated_table'
