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


-- Match Fact Table
CREATE or replace TABLE match_fact (
    match_id INT PRIMARY KEY,                  -- unique identifier for each match
    date_id INT NOT NULL,                      -- FK to date_dim
    referee_id INT NOT NULL,                   -- FK to referee_dim
    team_a_id INT NOT NULL,                    -- FK to team_dim (Team A)
    team_b_id INT NOT NULL,                    -- FK to team_dim (Team B)
    match_type_id INT NOT NULL,                -- FK to match_type_dim
    venue_id INT NOT NULL,                     -- FK to venue_dim
    total_overs number(3),                     -- scheduled overs
    balls_per_over number(1),                  -- balls per over (usually 6)

    -- Team A performance metrics
    overs_played_by_team_a number(2),
    bowls_played_by_team_a number(3),
    extra_bowls_played_by_team_a number(3),
    extra_runs_scored_by_team_a number(3),
    fours_by_team_a number(3),
    sixes_by_team_a number(3),
    total_score_by_team_a number(3),
    wicket_lost_by_team_a number(2),

    -- Team B performance metrics
    overs_played_by_team_b number(2),
    bowls_played_by_team_b number(3),
    extra_bowls_played_by_team_b number(3),
    extra_runs_scored_by_team_b number(3),
    fours_by_team_b number(3),
    sixes_by_team_b number(3),
    total_score_by_team_b number(3),
    wicket_lost_by_team_b number(2),

    -- Match outcome details
    toss_winner_team_id int not null, 
    toss_decision text not null, 
    match_result text not null, 
    winner_team_id int not null,

    -- Deeper analysis
    win_margin_runs number(3),                 -- margin of victory in runs (if applicable)
    win_margin_wickets number(2),              -- margin of victory in wickets (if applicable)
    man_of_the_match_player_id int,            -- FK to player_dim (best performer)
    series_name text,                          -- tournament/series name
    match_stage text,                          -- stage of tournament (Group, Semi-final, Final)
    audience_attendance number,                -- crowd attendance (linked to venue capacity)
    match_duration_days number(2),             -- duration in days (useful for Tests)
    is_day_night boolean,                      -- flag for day-night matches
    run_rate_team_a number(4,2),               -- calculated: total_score_by_team_a / overs_played_by_team_a
    run_rate_team_b number(4,2),               -- calculated: total_score_by_team_b / overs_played_by_team_b
    boundary_percentage_team_a number(5,2),    -- % of runs from boundaries for Team A
    boundary_percentage_team_b number(5,2),    -- % of runs from boundaries for Team B
    extras_percentage_team_a number(5,2),      -- % of runs from extras for Team A
    extras_percentage_team_b number(5,2),      -- % of runs from extras for Team B

    -- Foreign key constraints
    CONSTRAINT fk_date FOREIGN KEY (date_id) REFERENCES date_dim (date_id),
    CONSTRAINT fk_referee FOREIGN KEY (referee_id) REFERENCES referee_dim (referee_id),
    CONSTRAINT fk_team1 FOREIGN KEY (team_a_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_team2 FOREIGN KEY (team_b_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_match_type FOREIGN KEY (match_type_id) REFERENCES match_type_dim (match_type_id),
    CONSTRAINT fk_venue FOREIGN KEY (venue_id) REFERENCES venue_dim (venue_id),
    CONSTRAINT fk_toss_winner_team FOREIGN KEY (toss_winner_team_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_winner_team FOREIGN KEY (winner_team_id) REFERENCES team_dim (team_id),
    CONSTRAINT fk_man_of_the_match FOREIGN KEY (man_of_the_match_player_id) REFERENCES player_dim (player_id)
);

