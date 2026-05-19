#!/bin/bash

mkdir -p results

write_result() {
  local file="$1"
  local title="$2"
  local query="$3"

  {
    echo "# $title"
    echo
    echo '```text'
    psql -d football_db -c "$query"
    echo '```'
  } > "$file"
}

write_result \
  "results/q1_oldest_player.md" \
  "Q1: Oldest Player" \
  "SELECT * FROM Q1;"

write_result \
  "results/q2_team_total_matches.md" \
  "Q2: Teams With At Least Five Matches" \
  "SELECT * FROM Q2;"

write_result \
  "results/q3_top_goal_scorers.md" \
  "Q3: Players With Six or More Goals" \
  "SELECT * FROM Q3;"

write_result \
  "results/q4_discipline_scores.md" \
  "Q4: Player Discipline Scores" \
  "SELECT * FROM Q4;"

write_result \
  "results/q5_high_scoring_matches.md" \
  "Q5: High Scoring Matches" \
  "SELECT * FROM Q5;"

write_result \
  "results/q6_close_matches_with_cards.md" \
  "Q6: Close Matches With Cards" \
  "SELECT * FROM Q6;"

write_result \
  "results/q7_comeback_wins.md" \
  "Q7: Comeback Wins" \
  "SELECT * FROM Q7;"

write_result \
  "results/q8_player_search.md" \
  "Q8: Player Search" \
  "SELECT * FROM Q8('Li');"

write_result \
  "results/q9_match_report.md" \
  "Q9: Match Report" \
  "SELECT Q9(200);"

echo "Saved formatted results to results/"
