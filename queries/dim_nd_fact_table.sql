use role sysadmin;
use warehouse compute_wh;

-- Set the working schema to enriched layer of cricket database
use schema cricket.enriched;

-- Create Date Dimension:
-- Stores calendar attributes for time-based analysis (day, month, year, quarter, weekday, weekend flag)
create or replace table date_dim (
    date_id int primary key autoincrement,   -- surrogate key
    full_dt date,                            -- actual date
    day int,                                 -- day number
    month int,                               -- month number
    year int,                                -- year number
    quarter int,                             -- quarter of the year
    dayofweek int,                           -- numeric day of week (1–7)
    dayofmonth int,                          -- day of month
    dayofyear int,                           -- day of year
    dayofweekname varchar(3),                -- short day name (e.g., "Mon")
    isweekend boolean                        -- weekend flag (True if Sat/Sun)
);

-- Create Referee Dimension:
-- Stores referee details and type (e.g., field umpire, third umpire, match referee)
create or replace table referee_dim (
    referee_id int primary key autoincrement, -- surrogate key
    referee_name text not null,               -- referee full name
    referee_type text not null                -- type/category of referee
);

-- Create Team Dimension:
-- Stores team identifiers and names
create or replace table team_dim (
    team_id int primary key autoincrement,    -- surrogate key
    team_name text not null                   -- team name
);

-- Create Player Dimension:
-- Stores player details linked to their team
create or replace table player_dim (
    player_id int primary key autoincrement,  -- surrogate key
    team_id int not null,                     -- foreign key to team_dim
    player_name text not null                 -- player full name
);

-- Add foreign key constraint to link players with their teams
alter table cricket.enriched.player_dim
add constraint fk_team_player_id
foreign key (team_id)
references cricket.enriched.team_dim (team_id);

-- Create Venue Dimension:
-- Stores venue details including location, capacity, pitch type, and geo-coordinates
create or replace table venue_dim (
    venue_id int primary key autoincrement,   -- surrogate key
    venue_name text not null,                 -- venue name
    city text not null,                       -- city name
    state text,                               -- state/province
    country text,                             -- country
    continent text,                           -- continent
    end_Names text,                           -- end names (e.g., "Pavilion End")
    capacity number,                          -- seating capacity
    pitch text,                               -- pitch type/description
    flood_light boolean,                      -- floodlight availability
    established_dt date,                      -- establishment date
    playing_area text,                        -- playing area description
    other_sports text,                        -- other sports hosted
    curator text,                             -- pitch curator name
    lattitude number(10,6),                   -- latitude coordinate
    longitude number(10,6)                    -- longitude coordinate
);

-- Create Match Type Dimension:
-- Stores match format types (e.g., Test, ODI, T20)
create or replace table match_type_dim (
    match_type_id int primary key autoincrement, -- surrogate key
    match_type text not null                     -- match type name
);
