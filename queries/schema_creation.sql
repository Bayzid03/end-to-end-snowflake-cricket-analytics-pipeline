
create database if not exists cricket;
create or replace schema cricket.land;
create or replace schema cricket.raw;
create or replace schema cricket.curated;
create or replace schema cricket.enriched;

use schema cricket.land;

show schemas in database cricket;

-- json file format
create or replace file format json_format
 type = json
 null_if = ('\\n', 'null', '')
    strip_outer_array = true
    comment = 'Json File Format with outer stip array flag true'; 

-- creating an internal stage
create or replace stage int_stg; 

-- lets list the internal stage
list @int_stg;

-- check if data is being loaded or not
list @int_stg/cricket_data/json/;

-- check if data is coming correctly or not
select 
        t.$1:meta::variant as meta, 
        t.$1:info::variant as info, 
        t.$1:innings::array as innings, 
        metadata$filename as file_name,
        metadata$file_row_number int,
        metadata$file_content_key text,
        metadata$file_last_modified stg_modified_ts
     from  @int_stg/cricket_data/json/1000855.json.gz (file_format => 'json_format') t;
