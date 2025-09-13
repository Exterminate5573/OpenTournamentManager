create table alliances
(
    id INTEGER not null
        primary key autoincrement
);

create table alliances_have_teams
(
    alliances_id  INTEGER UNSIGNED           not null,
    teams_id      INTEGER UNSIGNED           not null,
    role          INTEGER UNSIGNED default 1 not null,
    role_instance INTEGER UNSIGNED default 1 not null,
    round         INTEGER UNSIGNED default 0 not null
);

create index alliances_have_teams_alliances_id_index
    on alliances_have_teams (alliances_id);

create table awards
(
    id             INTEGER                    not null
        primary key autoincrement,
    type           INTEGER                    not null,
    name           TEXT                       not null,
    user_defined   INTEGER UNSIGNED default 0 not null,
    sort_order     INTEGER UNSIGNED default 0 not null,
    robotevents_id INTEGER UNSIGNED default 0 not null,
    judged         INTEGER UNSIGNED default 0 not null
);

create table changed_teams
(
    teams_id     INTEGER UNSIGNED not null,
    time_changed DATETIME
);

create table config
(
    id           INTEGER UNSIGNED not null,
    divisions_id INTEGER UNSIGNED default 0,
    value        TEXT,
    unique (id, divisions_id)
);

create index config_id_index
    on config (id);

create table custom_elim_bracket
(
    division INTEGER UNSIGNED not null,
    seed     INTEGER UNSIGNED not null,
    round    INTEGER UNSIGNED not null,
    unique (division, seed)
);

create table display_slides
(
    id         INTEGER                    not null
        primary key autoincrement,
    sort_order INTEGER UNSIGNED default 0 not null,
    protobuf   BLOB
);

create table division_awards
(
    awards_id    INTEGER UNSIGNED default 0,
    divisions_id INTEGER UNSIGNED default 0,
    given        INTEGER UNSIGNED default 1  not null,
    teams_id     INTEGER UNSIGNED            not null,
    recipient    TEXT             default "" not null,
    description  TEXT             default "" not null
);

create table divisions
(
    id         INTEGER                    not null
        primary key autoincrement,
    name       VARCHAR(64)                not null,
    enabled    INTEGER UNSIGNED default 0 not null,
    is_elim    INTEGER UNSIGNED default 0 not null,
    match_type INTEGER UNSIGNED default 1 not null
);

create index divisions_id_index
    on divisions (id);

create table elim_alliances
(
    id       INTEGER UNSIGNED not null,
    teams_id INTEGER UNSIGNED not null,
    division INTEGER UNSIGNED not null,
    position INTEGER UNSIGNED not null,
    name     TEXT default ""  not null
);

create index elim_alliances_id_index
    on elim_alliances (id);

create index elim_alliances_teams_id_index
    on elim_alliances (teams_id);

create table elim_bracket_data
(
    id             INTEGER                    not null
        primary key autoincrement,
    division       INTEGER UNSIGNED           not null,
    round          INTEGER UNSIGNED           not null,
    instance       INTEGER UNSIGNED           not null,
    seed           INTEGER UNSIGNED           not null,
    wins           INTEGER UNSIGNED           not null,
    child_instance INTEGER UNSIGNED           not null,
    matches_played INTEGER UNSIGNED default 0 not null
);

create index elim_bracket_data_division_index
    on elim_bracket_data (division);

create index elim_bracket_data_id_index
    on elim_bracket_data (id);

create index elim_bracket_data_instance_index
    on elim_bracket_data (instance);

create index elim_bracket_data_round_index
    on elim_bracket_data (round);

create table elim_unavail_teams
(
    teams_id INTEGER UNSIGNED not null,
    division INTEGER UNSIGNED not null,
    reason   INTEGER UNSIGNED not null
);

create index elim_unavail_teams_reason_index
    on elim_unavail_teams (reason);

create index elim_unavail_teams_teams_id_index
    on elim_unavail_teams (teams_id);

create table elim_wins_to_advance
(
    division INTEGER UNSIGNED not null,
    round    INTEGER UNSIGNED not null,
    num_wins INTEGER UNSIGNED not null,
    unique (division, round)
);

create table field_sets
(
    id       INTEGER                    not null
        primary key autoincrement,
    division INTEGER UNSIGNED           not null,
    name     VARCHAR(64)                not null,
    type     INTEGER UNSIGNED default 1 not null
);

create index field_sets_division_index
    on field_sets (division);

create index field_sets_id_index
    on field_sets (id);

create table fields
(
    id            INTEGER          not null
        primary key autoincrement,
    field_sets_id INTEGER UNSIGNED not null,
    name          VARCHAR(64)      not null
);

create index fields_field_sets_id_index
    on fields (field_sets_id);

create index fields_id_index
    on fields (id);

create table inspection
(
    id            INTEGER                     not null
        primary key autoincrement,
    teams_id      INTEGER UNSIGNED            not null,
    session_id    INTEGER          default 1  not null,
    status        INTEGER UNSIGNED default 1  not null,
    comments      TEXT,
    num_robots    INTEGER UNSIGNED default 1  not null,
    robot1_status INTEGER UNSIGNED default 1  not null,
    robot2_status INTEGER UNSIGNED default 1  not null,
    details       BLOB             default "" not null,
    unique (teams_id, session_id)
);

CREATE TRIGGER inspection_status_log_trigger AFTER INSERT ON inspection
BEGIN
    INSERT INTO inspection_log (
        team_number,
        new_status,
        timestamp
    ) VALUES (
                 (SELECT number FROM teams WHERE id = NEW.teams_id),
                 NEW.status,
                 datetime('now')
             );
END;

create table inspection_log
(
    team_number TEXT not null,
    new_status  TEXT,
    timestamp   TEXT
);

create table league_session
(
    session INTEGER default 1 not null
);

create table match_scores
(
    id         INTEGER          not null
        primary key autoincrement,
    matches_id INTEGER UNSIGNED not null
        unique,
    data       BLOB
);

create table match_time_schedules
(
    id         INTEGER          not null
        primary key autoincrement,
    match_type INTEGER UNSIGNED not null,
    step_num   INTEGER UNSIGNED not null,
    block_type INTEGER UNSIGNED not null,
    duration   INTEGER UNSIGNED not null,
    name       TEXT default ""  not null
);

create index match_time_schedules_id_index
    on match_time_schedules (id);

create index match_time_schedules_match_type_index
    on match_time_schedules (match_type);

create table matches
(
    id                 INTEGER                    not null
        primary key autoincrement,
    division           INTEGER UNSIGNED           not null,
    round              INTEGER UNSIGNED           not null,
    instance           INTEGER UNSIGNED           not null,
    match              INTEGER UNSIGNED           not null,
    state              INTEGER UNSIGNED default 0 not null,
    projected_time     INTEGER UNSIGNED default 0 not null,
    actual_time        INTEGER UNSIGNED default 0 not null,
    session            INTEGER UNSIGNED default 1 not null,
    actual_resume_time INTEGER UNSIGNED default 0 not null,
    saved_time         INTEGER UNSIGNED default 0 not null
);

create index matches_division_index
    on matches (division);

create index matches_id_index
    on matches (id);

create index matches_instance_index
    on matches (instance);

create index matches_match_index
    on matches (match);

create index matches_round_index
    on matches (round);

create table matches_have_alliances
(
    matches_id   INTEGER UNSIGNED            not null,
    alliances_id INTEGER UNSIGNED            not null,
    color        INTEGER UNSIGNED default 0  not null,
    name         TEXT             default "" not null
);

create index matches_have_alliances_alliances_id_index
    on matches_have_alliances (alliances_id);

create index matches_have_alliances_matches_id_index
    on matches_have_alliances (matches_id);

create table matches_have_fields
(
    id            INTEGER          not null
        primary key autoincrement,
    matches_id    INTEGER UNSIGNED not null,
    fields_id     INTEGER UNSIGNED not null,
    field_sets_id INTEGER UNSIGNED not null
);

create index matches_have_fields_field_sets_id_index
    on matches_have_fields (field_sets_id);

create index matches_have_fields_fields_id_index
    on matches_have_fields (fields_id);

create index matches_have_fields_id_index
    on matches_have_fields (id);

create index matches_have_fields_matches_id_index
    on matches_have_fields (matches_id);

create unique index matches_have_fields_unique_matches_id_index
    on matches_have_fields (matches_id);

create table mobile_devices
(
    device_id       TEXT                        not null
        unique,
    name            TEXT                        not null,
    enabled         BOOLEAN                     not null,
    expiration_time INTEGER UNSIGNED default 0  not null,
    activated       BOOLEAN          default 1  not null,
    device_key      TEXT             default "" not null,
    roles           INTEGER          default 0  not null
);

create table overall_scores
(
    id         INTEGER            not null
        primary key autoincrement,
    teams_id   INTEGER UNSIGNED   not null,
    session_id INTEGER default 1  not null,
    details    BLOB    default "" not null,
    unique (teams_id, session_id)
);

create table pit_displays
(
    id             INTEGER           not null
        primary key autoincrement,
    division       INTEGER UNSIGNED  not null,
    name           VARCHAR(64)       not null,
    default_screen INTEGER default 5 not null
);

create index pit_displays_division_index
    on pit_displays (division);

create index pit_displays_id_index
    on pit_displays (id);

create table publish_options
(
    id      INTEGER                     not null
        primary key,
    enabled INTEGER UNSIGNED default 0  not null,
    value1  TEXT             default "" not null,
    value2  TEXT             default "" not null,
    value3  TEXT             default "" not null,
    value4  TEXT             default "" not null
);

create index publish_options_id_index
    on publish_options (id);

create table schedule_blocks
(
    id         INTEGER                    not null
        primary key autoincrement,
    type       INTEGER UNSIGNED default 0 not null,
    cycle_time INTEGER UNSIGNED default 0 not null,
    start      INTEGER UNSIGNED default 0 not null,
    stop       INTEGER UNSIGNED default 0 not null,
    session_id INTEGER          default 1 not null
);

create index schedule_blocks_id_index
    on schedule_blocks (id);

create table schedule_blocks_have_field_set_division
(
    id                 INTEGER          not null
        primary key autoincrement,
    schedule_blocks_id INTEGER UNSIGNED not null,
    field_sets_id      INTEGER UNSIGNED not null,
    divisions_id       INTEGER UNSIGNED not null
);

create index schedule_blocks_have_field_set_division_divisions_id_index
    on schedule_blocks_have_field_set_division (divisions_id);

create index schedule_blocks_have_field_set_division_field_sets_id_index
    on schedule_blocks_have_field_set_division (field_sets_id);

create index schedule_blocks_have_field_set_division_id_index
    on schedule_blocks_have_field_set_division (id);

create index schedule_blocks_have_field_set_division_schedule_blocks_id_index
    on schedule_blocks_have_field_set_division (schedule_blocks_id);

create table scoring_config
(
    id    INTEGER not null
        primary key autoincrement,
    name  TEXT
        unique,
    value BLOB
);

create index scoring_config_id_index
    on scoring_config (id);

create table scoring_log
(
    timestamp DATETIME default CURRENT_TIMESTAMP not null,
    division  INTEGER                            not null,
    round     INTEGER                            not null,
    instance  INTEGER                            not null,
    matchnum  INTEGER                            not null,
    session   INTEGER                            not null,
    matchdata BLOB,
    matchrepr TEXT
);

create table sessions
(
    id         INTEGER                     not null
        primary key autoincrement,
    uuid       TEXT             default "" not null,
    name       TEXT             default "" not null,
    start_date INTEGER UNSIGNED default 0  not null,
    end_date   INTEGER UNSIGNED default 0  not null
);

create table skills_scores
(
    id          INTEGER                    not null
        primary key autoincrement,
    uuid        TEXT                       not null
        unique,
    session_id                   default 1 not null,
    skills_id   INTEGER UNSIGNED           not null,
    teams_id    INTEGER UNSIGNED           not null,
    time_scored INTEGER UNSIGNED default 0 not null,
    score       INTEGER          default 0 not null,
    details     BLOB
);

create table sponsor_logos
(
    id     INTEGER                    not null
        primary key autoincrement,
    name   TEXT,
    data   BLOB,
    width  INTEGER,
    height INTEGER,
    type   INTEGER UNSIGNED default 1 not null
);

create table teams
(
    id           INTEGER                    not null
        primary key autoincrement,
    number       VARCHAR(16)                not null
        unique,
    name         VARCHAR(64)                not null,
    city         VARCHAR(32)                not null,
    state        VARCHAR(32)                not null,
    country      VARCHAR(32)                not null,
    shortName    VARCHAR(32)                not null,
    school       VARCHAR(32)                not null,
    sponsors     VARCHAR(64)                not null,
    tiebreaker   INTEGER                    not null,
    divisions_id INTEGER UNSIGNED default 0 not null,
    checked_in   INTEGER UNSIGNED default 0 not null,
    age_group    INTEGER UNSIGNED default 3 not null
);

create index teams_id_index
    on teams (id);

CREATE TRIGGER changed_teams_trigger AFTER UPDATE OF number ON teams WHEN NEW.number != OLD.number
BEGIN
    INSERT INTO changed_teams (teams_id, time_changed) VALUES (NEW.id, datetime('now'));
END;

create table teams_have_divisions
(
    teams_id     INTEGER UNSIGNED           not null,
    divisions_id INTEGER UNSIGNED           not null,
    is_primary   INTEGER UNSIGNED default 0 not null,
    unique (teams_id, divisions_id)
);

CREATE VIEW division_teams AS SELECT id, number, name, city, state, country, shortName, school, sponsors, tiebreaker, thd.divisions_id AS divisions_id, checked_in, age_group FROM teams, teams_have_divisions thd WHERE teams.id = thd.teams_id AND thd.is_primary = 1;

