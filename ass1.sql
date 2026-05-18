-- COMP3311 T2 2025 ass1.sql
--
-- Name: Henry Chen
-- Student ID: z5477742

----------------------------------------------------------------
CREATE OR REPLACE VIEW Q1(player, born) AS
SELECT
    name, birthday
FROM
    Players
WHERE
    birthday = (SELECT MIN(birthday) FROM Players)
;

-- ----------------------------------------------------------------
CREATE VIEW TeamTotalMatches(team, country, total_matches) AS
SELECT
    t.id, t.country, COUNT(i.match)
FROM
    Teams t INNER JOIN Involves i
ON
    t.id = i.team
GROUP BY
    t.id
;

CREATE OR REPLACE VIEW Q2(team, country, total_matches) AS
SELECT
    team, country, total_matches
FROM
    TeamTotalMatches
WHERE
    total_matches >= 5
ORDER BY
    total_matches DESC,
    team ASC
;

-- ----------------------------------------------------------------
CREATE VIEW PlayerGoals(player_id, player, goals_scored, first_goal_date) AS
SELECT
    p.id, p.name, COUNT(*), MIN(m.played_on)
FROM
    Players p
INNER JOIN
    Goals g ON p.id = g.scored_by
INNER JOIN
    Matches m ON g.scored_in = m.id
GROUP BY
    p.id
;

CREATE OR REPLACE VIEW Q3(player_id, player, goals_scored, first_goal_date) AS
SELECT
    player_id, player, goals_scored, first_goal_date
FROM
    PlayerGoals
WHERE
    goals_scored >= 6
ORDER BY
    goals_scored DESC, player ASC, player_id ASC
;

-- ----------------------------------------------------------------
CREATE VIEW PlayerCards(player_id, player, yellow_cards, red_cards) AS
SELECT
    p.id,
    p.name,
    COUNT(*) FILTER (WHERE c.card_type = 'yellow'),
    COUNT(*) FILTER (Where c.card_type = 'red')
FROM
    Players p INNER JOIN Cards c
ON
    p.id = c.given_to
GROUP BY
    p.id
;

CREATE OR REPLACE VIEW Q4(player_id, player, yellow_cards, red_cards, discipline_score)  AS
SELECT
    player_id,
    player, yellow_cards,
    red_cards, red_cards * 5 + yellow_cards * 2 as discipline_score
FROM
    PlayerCards
WHERE
    yellow_cards + red_cards >= 2
ORDER BY
    discipline_score DESC, player ASC, player_id ASC
;

-- ----------------------------------------------------------------
CREATE VIEW HomeTeamMatches(match_id, team, goals) AS
SELECT
    m.id, t.country, COUNT(g.scored_in) FILTER (WHERE p.member_of = t.id)
FROM
    Matches m
INNER JOIN
    Involves i ON m.id = i.match
INNER JOIN
    Teams t ON t.id = i.team
LEFT JOIN
    Goals g ON m.id = g.scored_in
LEFT JOIN
    Players p ON g.scored_by = p.id
WHERE
    i.is_home = 'true'
GROUP BY
    m.id, t.country
;

CREATE VIEW AwayTeamMatches(match_id, team, goals) AS
SELECT
    m.id, t.country, COUNT(g.scored_in) FILTER (WHERE p.member_of = t.id)
FROM
    Matches m
INNER JOIN
    Involves i ON m.id = i.match
INNER JOIN
    Teams t ON t.id = i.team
LEFT JOIN
    Goals g ON m.id = g.scored_in
LEFT JOIN
    Players p ON g.scored_by = p.id
WHERE
    i.is_home = 'false'
GROUP BY
    m.id, t.country
;

CREATE OR REPLACE VIEW Q5(match_id, home_team, away_team, goals_for_each_team) AS
SELECT
    h.match_id,
    h.team,
    a.team,
    format('%s-%s', h.goals, a.goals)
FROM
    HomeTeamMatches h
INNER JOIN
    AwayTeamMatches a
ON
    h.match_id = a.match_id
WHERE
    h.goals + a.goals > 4
ORDER BY
    match_id ASC
;

-- ----------------------------------------------------------------
CREATE VIEW SmallGoalDifference(match_id, score, home_team, away_team) AS
SELECT
    h.match_id,
    format('%s-%s', h.goals, a.goals),
    h.team,
    a.team
FROM
    HomeTeamMatches h INNER JOIN AwayTeamMatches a
ON
    h.match_id = a.match_id
WHERE
    ABS(h.goals - a.goals) <= 1
;

CREATE VIEW HomeTeamCards(match_id, yellow_cards, red_cards) AS
SELECT
    m.id,
    COUNT(*) FILTER (WHERE c.card_type = 'yellow'),
    COUNT(*) FILTER (WHERE c.card_type = 'red')
FROM
    Matches m
INNER JOIN
    Involves i ON m.id = i.match AND i.is_home = 'true'
INNER JOIN
    Teams t ON t.id = i.team
INNER JOIN
    Players p ON p.member_of = t.id
LEFT JOIN
    Cards c ON p.id = c.given_to AND m.id = c.given_in
GROUP BY
    m.id
;

CREATE VIEW AwayTeamCards(match_id, yellow_cards, red_cards) AS
SELECT
    m.id,
    COUNT(*) FILTER (WHERE c.card_type = 'yellow'),
    COUNT(*) FILTER (WHERE c.card_type = 'red')
FROM
    Matches m
INNER JOIN
    Involves i ON m.id = i.match AND i.is_home = 'false'
INNER JOIN
    Teams t ON t.id = i.team
INNER JOIN
    Players p ON p.member_of = t.id
LEFT JOIN
    Cards c ON p.id = c.given_to AND m.id = c.given_in
GROUP BY
    m.id
;

CREATE OR REPLACE VIEW Q6(match_id, score, yellow, red) AS
SELECT
    s.match_id,
    s.score,
    (h.yellow_cards + a.yellow_cards),
    (h.red_cards + a.red_cards)
FROM
    SmallGoalDifference s
INNER JOIN
    HomeTeamCards h ON s.match_id = h.match_id
INNER JOIN
    AwayTeamCards a ON s.match_id = a.match_id
WHERE
    (h.yellow_cards + a.yellow_cards >= 1) AND (h.red_cards + a.red_cards >= 1)
ORDER BY
    h.yellow_cards + h.red_cards + a.yellow_cards + a.red_cards DESC,
    s.match_id ASC
;

-- ----------------------------------------------------------------
CREATE VIEW HomeTeamGoals(match_id, team, goals_before_halftime, total_goals) AS
SELECT
    m.id,
    t.country,
    COUNT(*) FILTER (WHERE g.time_scored <= 45),
    COUNT(*)
FROM
    Matches m
INNER JOIN
    Involves i ON m.id = i.match
INNER JOIN
    Teams t ON t.id = i.team
INNER JOIN
    Players p ON p.member_of = t.id
LEFT JOIN
    Goals g ON g.scored_by = p.id
WHERE
    i.is_home = 'true' AND g.scored_in = m.id
GROUP BY
    m.id, t.country
;

CREATE VIEW AwayTeamGoals(match_id, team, goals_before_halftime, total_goals) AS
SELECT
    m.id,
    t.country,
    COUNT(*) FILTER (WHERE g.time_scored <= 45),
    COUNT(*)
FROM
    Matches m
INNER JOIN
    Involves i ON m.id = i.match
INNER JOIN
    Teams t ON t.id = i.team
INNER JOIN
    Players p ON p.member_of = t.id
LEFT JOIN
    Goals g ON g.scored_by = p.id
WHERE
    i.is_home = 'false' AND g.scored_in = m.id
GROUP BY
    m.id, t.country
;

CREATE OR REPLACE VIEW Q7(match_id, winning_team, halftime_score, fulltime_score) AS
SELECT
    h.match_id,
    CASE
        WHEN h.total_goals > a.total_goals THEN h.team
        ELSE a.team
    END,
    format('%s-%s', h.goals_before_halftime, a.goals_before_halftime),
    format('%s-%s', h.total_goals, a.total_goals)
FROM
    HomeTeamGoals h INNER JOIN AwayTeamGoals a
ON
    h.match_id = a.match_id
WHERE
    (h.goals_before_halftime < a.goals_before_halftime AND h.total_goals > a.total_goals)
    OR
    (a.goals_before_halftime < h.goals_before_halftime AND a.total_goals > h.total_goals)
ORDER BY
    h.match_id ASC
;

-- ----------------------------------------------------------------
CREATE VIEW PlayerCareerGoals(player_id, career_goals) AS
SELECT
    p.id,
    COUNT(g.scored_by)
FROM
    Players p
LEFT JOIN
    Goals g
ON
    g.scored_by = p.id
GROUP BY
    p.id
;

CREATE VIEW PlayerCareerCards(player_id, career_cards) AS
SELECT
    p.id,
    COUNT(c.given_to)
FROM
    Players p
LEFT JOIN
    Cards c
ON
    c.given_to = p.id
GROUP BY
    p.id
;

CREATE OR REPLACE FUNCTION Q8(search_term text) RETURNS SETOF TEXT
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.name || ' | '
        || t.country || ' | '
        || p.position || ' | '
        || g.career_goals || ' | '
        || c.career_cards
    FROM
        Players p
    INNER JOIN
        Teams t ON p.member_of = t.id
    INNER JOIN
        PlayerCareerGoals g ON p.id = g.player_id
    INNER JOIN
        PlayerCareerCards c ON p.id = c.player_id
    WHERE
        p.name ILIKE '%' || search_term || '%'
    ORDER BY
        g.career_goals DESC, p.name ASC, p.id ASC
    ;
END;
$$;

-- ----------------------------------------------------------------
CREATE FUNCTION MatchHeaderInformation(_match_id INTEGER) RETURNS
TEXT LANGUAGE plpgsql AS $$
DECLARE
    city TEXT;
    played_on DATE;
    home_team_country TEXT;
    home_team_id INTEGER;
    away_team_country TEXT;
    away_team_id INTEGER;
BEGIN
    SELECT
        m.city,
        m.played_on,
        MAX(CASE WHEN i.is_home = 'true' THEN t.country END),
        MAX(CASE WHEN i.is_home = 'true' THEN t.id END),
        MAX(CASE WHEN i.is_home = 'false' THEN t.country END),
        MAX(CASE WHEN i.is_home = 'false' THEN t.id END)
    INTO
        city,
        played_on,
        home_team_country,
        home_team_id,
        away_team_country,
        away_team_id
    FROM
        Matches m
    INNER JOIN
        Involves i ON m.id = i.match
    INNER JOIN
        Teams t ON i.team = t.id
    WHERE
        m.id = _match_id
    GROUP BY
        m.city,
        m.played_on
    ;
    RETURN '[' || city || ', ' || played_on || '] ' || home_team_country
            || ' (Team ' || home_team_id || ') vs ' || away_team_country
            || ' (Team ' || away_team_id || ')'
    ;
END;
$$;

CREATE FUNCTION MatchScore(_match_id INTEGER) RETURNS
TEXT LANGUAGE plpgsql AS $$
DECLARE
    home_team_half_goals INTEGER;
    away_team_half_goals INTEGER;
    home_team_full_goals INTEGER;
    away_team_full_goals INTEGER;
BEGIN
    SELECT
        COALESCE(h.goals_before_halftime, 0),
        COALESCE(a.goals_before_halftime, 0),
        COALESCE(h.total_goals, 0),
        COALESCE(a.total_goals, 0)
    INTO
        home_team_half_goals,
        away_team_half_goals,
        home_team_full_goals,
        away_team_full_goals
    FROM
        Matches m
    LEFT JOIN
        HomeTeamGoals h ON m.id = h.match_id
    LEFT JOIN
        AwayTeamGoals a ON m.id = a.match_id
    WHERE
        m.id = _match_id
    ;
    RETURN
        'Half-time: ' || home_team_half_goals || '-' || away_team_half_goals || E'\n' ||
        'Full-time: ' || home_team_full_goals || '-' || away_team_full_goals
    ;
END;
$$;

CREATE VIEW EventList(match_id, match_minute, match_event, rating_or_type, player, country, position) AS
SELECT
    g.scored_in,
    g.time_scored,
    'Goal',
    g.rating,
    p.name,
    t.country,
    p.position
FROM
    Goals g
INNER JOIN
    Players p ON g.scored_by = p.id
INNER JOIN
    Teams t ON p.member_of = t.id

UNION ALL

SELECT
    c.given_in,
    c.time_given,
    'Card',
    c.card_type,
    p.name,
    t.country,
    p.position
FROM
    Cards c
INNER JOIN
    Players p ON c.given_to = p.id
INNER JOIN
    Teams t ON p.member_of = t.id
;

CREATE FUNCTION FormatEvents(_match_id INTEGER) RETURNS SETOF TEXT LANGUAGE
plpgsql AS $$
DECLARE
    event_record RECORD;
    has_event BOOLEAN := false;
BEGIN
    FOR event_record IN
        SELECT
            *
        FROM
            EventList
        WHERE
            match_id = _match_id
        ORDER BY
            match_minute ASC,
            CASE match_event
                WHEN 'Goal' THEN 1
                WHEN 'Card' THEN 2
            END,
            rating_or_type ASC,
            player ASC,
            country ASC,
            position ASC
    LOOP
        has_event := true;
        IF event_record.match_event = 'Goal' THEN
            RETURN NEXT
                'Minute ' || event_record.match_minute || ': Goal (' || event_record.rating_or_type ||
                ') - ' || event_record.player || ' (' || event_record.country ||
                ', ' || event_record.position || ')'
            ;
        ELSE
            RETURN NEXT
                'Minute ' || event_record.match_minute || ': Card (' || event_record.rating_or_type ||
                ') - ' || event_record.player || ' (' || event_record.country ||
                ', ' || event_record.position || ')'
            ;
        END IF;
    END LOOP;

    IF NOT has_event
        THEN RETURN NEXT 'No goals or cards occurred in this match.';
    END IF;
END;
$$;

CREATE FUNCTION FinalStatements(_match_id integer) RETURNS SETOF TEXT LANGUAGE
plpgsql AS $$
DECLARE
    home_team TEXT;
    away_team TEXT;
    home_half_goals INTEGER;
    away_half_goals INTEGER;
    home_full_goals INTEGER;
    away_full_goals INTEGER;
    home_red_cards INTEGER;
    away_red_cards INTEGER;
BEGIN
    SELECT
        h.team,
        a.team,
        COALESCE(h.goals_before_halftime, 0),
        COALESCE(a.goals_before_halftime, 0),
        COALESCE(h.total_goals, 0),
        COALESCE(a.total_goals, 0),
        COALESCE(hc.red_cards, 0),
        COALESCE(ac.red_cards, 0)
    INTO
        home_team,
        away_team,
        home_half_goals,
        away_half_goals,
        home_full_goals,
        away_full_goals,
        home_red_cards,
        away_red_cards
    FROM
        Matches m
    LEFT JOIN
        HomeTeamGoals h ON h.match_id = m.id
    LEFT JOIN
        AwayTeamGoals a ON a.match_id = m.id
    LEFT JOIN
        HomeTeamCards hc ON hc.match_id = m.id
    LEFT JOIN
        AwayTeamCards ac ON ac.match_id = m.id
    WHERE
        m.id = _match_id
    ;

    IF home_full_goals = away_full_goals THEN
        RETURN NEXT 'The match ended in a draw.';
    ELSEIF home_full_goals > away_full_goals THEN
        RETURN NEXT home_team || ' wins!';
    ELSE
        RETURN NEXT away_team || ' wins!';
    END IF;

    IF (home_full_goals > away_full_goals AND home_red_cards > 0) THEN
        RETURN NEXT home_team || ' won despite ending up with less than 11 players!';
    END IF;
    IF (away_full_goals > home_full_goals AND away_red_cards > 0) THEN
        RETURN NEXT away_team || ' won despite ending up with less than 11 players!';
    END IF;

    IF (home_half_goals < away_half_goals AND home_full_goals > away_full_goals)
        OR
       (away_half_goals < home_half_goals AND away_full_goals > home_full_goals)
        THEN RETURN NEXT 'A stunning comeback occurred!';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION Q9(_match_id INTEGER) RETURNS TEXT
LANGUAGE plpgsql AS $$
DECLARE
    header TEXT;
    score TEXT;
    events TEXT;
    final_statements TEXT;
    result TEXT := '';
BEGIN
    header:= MatchHeaderInformation(_match_id);
    IF header IS NULL THEN
        RETURN 'Match ID '||  _match_id || ' not found.';
    END IF;
    result := result || header || E'\n';

    score := MatchScore(_match_id);
    result := result || score || E'\n';

    FOR events IN SELECT * FROM FormatEvents(_match_id)
    LOOP
        result := result || events || E'\n';
    END LOOP;

    FOR final_statements IN SELECT * FROM FinalStatements(_match_id)
    LOOP
        result := result || final_statements || E'\n';
    END LOOP;

    RETURN result;
END;
$$;

