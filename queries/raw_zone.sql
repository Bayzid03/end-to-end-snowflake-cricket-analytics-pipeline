use role sysadmin;
use warehouse compute_wh
use schema cricket.raw;

-- lets create a table inside the raw layer
create or replace transient table cricket.raw.match_raw_table (
    meta object not null,
    info variant not null,
    innings ARRAY not null,
    stg_file_name text not null,
    stg_file_row_number int not null,
    stg_file_hashkey text not null,
    stg_modified_ts timestamp not null
)
comment = 'This is raw table to store all the json data file with root elements extracted';

-- we have total 2411 JSON files.
copy into cricket.raw.match_raw_table from 
    (
    select 
        t.$1:meta::object as meta, 
        t.$1:info::variant as info, 
        t.$1:innings::array as innings, 
        --
        metadata$filename,
        metadata$file_row_number,
        metadata$file_content_key,
        metadata$file_last_modified
    from @cricket.land.int_stg/cricket_data/json (file_format => 'cricket.land.json_format') t
    )
    on_error = continue;

select count(*) from cricket.raw.match_raw_table; 

select * from cricket.raw.match_raw_table limit 10;
