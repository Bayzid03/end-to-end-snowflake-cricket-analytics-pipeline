
use role sysadmin;
use warehouse compute_wh;
use schema cricket.curated;

-- extract players
-- version-1
select
	raw.info:match_type_number::int as match_type_number
	raw.info:players,
	raw.info:teams
from cricket.raw.match_raw_table raw;

-- version-2
select
	raw.info:match_type_number::int as match_type_number
	raw.info:players,
	raw.info:teams
from cricket.raw.match_raw_table raw;
where match_type_number = 3951;

--version-3
select
	raw.info:match_type_number::int as match_type_number
	--p.*
	p.key::text as country
from cricket.raw.match_raw_table raw,
lateral flatten (input => raw.info:players) p 
where match_type_number = 3951;

--version-4
select
	raw.info:match_type_number::int as match_type_number
	--team.*
	p.key::text as country,
	team.value:: text as player_name
from cricket.raw.match_raw_table raw;
lateral flatten (input => raw.info.players) p,
lateral flatten (input => p.value) team
where match_type_number = 3951



create or replace table player_curated_table as 
select 
    raw.info:match_type_number::int as match_type_number, 
    p.path::text as country,
    team.value:: text as player_name,
    raw.stg_file_name ,
    raw.stg_file_row_number,
    raw.stg_file_hashkey,
    raw.stg_modified_ts
from cricket.raw.match_raw_table raw,
lateral flatten (input => rcm.info:players) p,
lateral flatten (input => p.value) team;

desc table cricket.curated.player_curated.table;

alter table cricket.curated.player_curated_table
modify column match_type_number set not null;

alter table cricket.curated.player_curated_table
modify column country set not null;

alter table cricket.curated.player_curated_table
modify column player_name set not null;

alter table cricket.curated.match_detail_curated
add constraint pk_match_type_number primary key (match_type_number);

-- Create a relationship 
alter table cricket.curated.player_curated_table
add constraint fk_match_id
foreign key (match_type_number)
references cricket.curated.match_detail_curated (match_type_number);

select get_ddl('table', 'cricket.curated.player_curated_table')
