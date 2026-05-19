# Football-analytics
This project was completed as part of a university database systems assignment. It uses PostgreSQl to analyse a football tournament databse and the main analysis is completed through SQL views and Pl/pgSQL functions.

## Project Structure

```text
.
├── data/
│   └── ass1.dump
├── sql/
│   └── ass1.sql
├── results/
│   ├── q1_oldest_player.md
│   ├── q2_team_total_matches.md
│   ├── q3_top_goal_scorers.md
│   ├── q4_discipline_scores.md
│   ├── q5_high_scoring_matches.md
│   ├── q6_close_matches_with_cards.md
│   ├── q7_comeback_wins.md
│   ├── q8_player_search.md
│   └── q9_match_report.md
├── save_results.sh
└── README.md
```

## Database Design: Football Match Database

This database models a simplified international football tournament system. It stores information about matches, national teams, players, goals, and disciplinary cards.

### Entity Summary

| Table | Description |
|---|---|
| `Matches` | Stores where and when each international match was played |
| `Teams` | Stores the national teams that take part in matches |
| `Involves` | Links each match to its two competing teams and records which team was the home side |
| `Players` | Stores player details, including name, birthday, team membership, and playing position |
| `Goals` | Records who scored, when they scored, and an optional goal quality rating |
| `Cards` | Records disciplinary cards issued to players during matches |

## Schema Details

### Domains

The schema uses two custom domains to make constraints clearer.

#### `GameTime`

Represents time in minutes since the game started.

| Constraint | Description |
|---|---|
| Type | `integer` |
| Valid range | `0` to `90` |


#### `CardColour`

Represents the type of disciplinary card issued to a player.

| Constraint | Description |
|---|---|
| Type | `varchar(6)` |
| Valid values | `red`, `yellow` |


## Table Details

### `Matches`

Stores where and when each international match was played.

| Column | Type | Description |
|---|---|---|
| `id` | `integer` | Unique match identifier and primary key |
| `city` | `varchar(50)` | City where the match was played |
| `played_on` | `date` | Date when the match was played |


### `Teams`

Stores the national sides that take part in matches.

| Column | Type | Description |
|---|---|---|
| `id` | `integer` | Unique team identifier and primary key |
| `country` | `varchar(50)` | Country represented by the team; must be unique |


### `Involves`

Represents the relationship between matches and teams. Each match should involve two teams, and this table records whether each team is the home side.

| Column | Type | Description |
|---|---|---|
| `match` | `integer` | Foreign key referencing `Matches(id)` |
| `team` | `integer` | Foreign key referencing `Teams(id)` |
| `is_home` | `boolean` | Indicates whether the team is the home team in the match |

| Key / Constraint | Description |
|---|---|
| Primary key | Composite key on `(match, team)` |
| Foreign key | `match` references `Matches(id)` |
| Foreign key | `team` references `Teams(id)` |


### `Players`

Stores personal and football-related details about players.

| Column | Type | Description |
|---|---|---|
| `id` | `integer` | Unique player identifier and primary key |
| `name` | `varchar(50)` | Player name |
| `birthday` | `date` | Player date of birth |
| `member_of` | `integer` | Foreign key referencing the player’s national team |
| `position` | `varchar(20)` | Player’s usual playing position |

| Key / Constraint | Description |
|---|---|
| Primary key | `id` |
| Foreign key | `member_of` references `Teams(id)` |


### `Goals`

Records goals scored during matches.

| Column | Type | Description |
|---|---|---|
| `id` | `integer` | Unique goal identifier and primary key |
| `scored_in` | `integer` | Foreign key referencing the match where the goal was scored |
| `scored_by` | `integer` | Foreign key referencing the player who scored |
| `time_scored` | `GameTime` | Minute when the goal was scored |
| `rating` | `varchar(20)` | Optional quality rating for the goal |

| Key / Constraint | Description |
|---|---|
| Primary key | `id` |
| Foreign key | `scored_in` references `Matches(id)` |
| Foreign key | `scored_by` references `Players(id)` |


### `Cards`

Records disciplinary cards issued to players during matches.

| Column | Type | Description |
|---|---|---|
| `id` | `integer` | Unique card identifier and primary key |
| `given_in` | `integer` | Foreign key referencing the match where the card was issued |
| `given_to` | `integer` | Foreign key referencing the player who received the card |
| `time_given` | `GameTime` | Minute when the card was issued |
| `card_type` | `CardColour` | Type of card issued, either `yellow` or `red` |

| Key / Constraint | Description |
|---|---|
| Primary key | `id` |
| Foreign key | `given_in` references `Matches(id)` |
| Foreign key | `given_to` references `Players(id)` |


## Relationship Overview

| Relationship | Description |
|---|---|
| `Matches` to `Teams` | Many-to-many relationship through `Involves` |
| `Teams` to `Players` | One team can have many players |
| `Matches` to `Goals` | One match can contain many goals |
| `Players` to `Goals` | One player can score many goals |
| `Matches` to `Cards` | One match can contain many cards |
| `Players` to `Cards` | One player can receive many cards |

## Schema Summary

The database is centred around football matches. Each match is connected to two teams through the `Involves` table. Players belong to teams, while goals and cards link individual players to specific match events. This design allows SQL queries to analyse player performance, team results, goal scoring patterns, and disciplinary records.
