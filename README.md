# Football-analytics
This project was completed as part of a university database systems assignment. It uses PostgreSQl to analyse a football tournament databse containing players, teams, matches, goals, and disciplinary events. The database is restored from a PostgreSQL dump file, and the main analysis is completed through SQL views and Pl/pgSQL functions.

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

## Database Design

The database models a simplified UNSW academic enrolment system. It contains information about academic terms, people, students, staff, organisational units, subjects, courses, programs, streams, enrolments, and academic requirements.

### Entity Summary

| Table | Description |
|---|---|
| `Terms` | Describes UNSW trimesters from the academic calendar |
| `Countries` | Stores brief information about countries |
| `People` | Stores information about people in the database, including staff and students |
| `Students` | Describes individual students |
| `Staff` | Identifies people who are also staff members |
| `Orgunits` | Describes UNSW organisational units such as faculties and schools |
| `Subjects` | Stores subject-level information, similar to a minimal handbook entry |
| `Courses` | Describes offerings of subjects in particular terms |
| `Streams` | Stores global information about academic streams |
| `Programs` | Stores global information about academic programs |
| `Program_enrolments` | Records student enrolment in programs by term |
| `Stream_enrolments` | Records student enrolment in streams within a program enrolment |
| `Course_enrolments` | Records student enrolment in courses |
| `Requirements` | Describes rules for completing programs and streams |

## Table Details

### `Terms`

Describes UNSW trimesters from the academic calendar.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `code` | Term code, such as `19T1` or `20T2` |
| `starting` | Date when the term starts |
| `ending` | Date when the term ends |
| `description` | Long-form description of the term name |

### `Countries`

Gives brief information about countries.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `code` | Unique three-letter country code |
| `name` | Unique full name of the country |

### `People`

Describes people in the database, including both staff and students.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `zid` | Student or staff ID, expected to be unique and not null |
| `family_name` | Family name |
| `given_names` | Given names, space-separated |
| `full_name` | Combination of given and family names |
| `origin` | Foreign key referencing the person’s country of origin |

### `Students`

Describes individual students.

| Column | Description |
|---|---|
| `id` | Unique integer primary key referencing the `People` table |
| `status` | Resident status, such as `AUS` or `INTL` |

### `Staff`

Notes that a particular person is also a staff member.

| Column | Description |
|---|---|
| `id` | Unique integer primary key referencing the `People` table |

### `Orgunits`

Describes organisational units within UNSW.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `code` | Unique symbolic code for identifying the unit, such as `COMPSC` |
| `name` | Name of the unit, such as `School of Physics` or `Faculty of Engineering` |
| `utype` | Type of organisational unit, such as `faculty` or `school` |
| `parent` | References the parent organisational unit, allowing organisational hierarchy |

### `Subjects`

Describes individual subjects as a minimal handbook entry.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `code` | Subject code, such as `COMP3311` |
| `title` | Name of the subject, such as `Database Systems` |
| `uoc` | Units of credit awarded for completing the subject |
| `career` | Academic career level, such as undergraduate, postgraduate, or research |
| `owner` | Organisational unit that owns or teaches the subject |

### `Courses`

Describes offerings of subjects in particular terms.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `subject` | Foreign key referencing the subject being offered |
| `term` | Foreign key referencing the term in which the subject is offered |
| `convenor` | Foreign key referencing the staff member teaching the course; may be `NULL` |
| `satisfact` | MyExperience satisfaction score; may be `NULL` |
| `nresponses` | Number of survey responses; may be `NULL` |

Note: the convenor may be `NULL` if the teaching staff member is unknown. The satisfaction score and number of responses may also be `NULL` if there are too few students enrolled in the course.

### `Streams`

Describes global information about academic streams.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `code` | Stream code, such as `COMPA1` or `SENGAH` |
| `name` | Stream name, such as `Software Engineering` |

### `Programs`

Describes global information about academic programs.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `code` | Program code, such as `3707`, `3778`, or `8543` |
| `name` | Program name, such as `Computer Science` |

### `Program_enrolments`

Describes student enrolment in a program in a given term.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `student` | Foreign key referencing the student enrolled in the program |
| `term` | Foreign key referencing the term of enrolment |
| `program` | Foreign key referencing the program |

### `Stream_enrolments`

Describes student enrolment in streams.

| Column | Description |
|---|---|
| `part_of` | Foreign key referencing the program enrolment that the stream is part of |
| `stream` | Foreign key referencing the stream |

Note: information about the student and term is stored in the referenced `Program_enrolments` table.

### `Course_enrolments`

Describes student enrolment in courses.

| Column | Description |
|---|---|
| `student` | Foreign key referencing the student enrolled in the course |
| `course` | Foreign key referencing the course enrolled in |
| `mark` | Course mark, in the range `0` to `100` |
| `grade` | UNSW grade, such as `FL` or `HD` |

Note: both `mark` and `grade` are `NULL` while the student is still enrolled in a course.

### `Requirements`

Describes rules for completing streams and programs.

| Column | Description |
|---|---|
| `id` | Unique integer primary key |
| `name` | Brief description of the requirement |
| `rtype` | Requirement type |
| `min_req` | Minimum requirement needed to satisfy the rule, such as UOC or count |
| `max_req` | Maximum requirement allowed for the rule, such as UOC or count |
| `acadobjs` | Academic objects associated with the requirement, such as courses or streams |
| `for_stream` | Stream that the requirement applies to |
| `for_program` | Program that the requirement applies to |
