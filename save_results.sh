#!/bin/bash

mkdir -p results

{
  echo "# Q1: Oldest Player"
  echo
  psql -d football_db -c "SELECT * FROM Q1;"
} > results/q1_oldest_player.md

{
  echo "# Q2: Teams With At Least Five Matches"
  echo
  psql -d football_db -c "SELECT * FROM Q2;"
} > results/q2_team_total_matches.md

{
  echo "# Q3: Players With Six or More Goals"
  echo
  psql -d football_db -c "SELECT * FROM Q3;"
} > results/q3_top_goal_scorers.md

{
  echo "# Q4: Player Discipline Scores"
  echo
  psql -d football_db -c "SELECT * FROM Q4;"
} > results/q4_discipline_scores.md

{
  echo "# Q5: High Scoring Matches"
  echo
  psql -d football_db -c "SELECT * FROM Q5;"
} > results/q5_high_scoring_matches.md

{
  echo "# Q6: Close Matches With Cards"
  echo
  psql -d football_db -c "SELECT * FROM Q6;"
} > results/q6_close_matches_with_cards.md

{
  echo "# Q7: Comeback Wins"
  echo
  psql -d football_db -c "SELECT * FROM Q7;"
} > results/q7_comeback_wins.md

{
  echo "# Q8: Player Search"
  echo
  psql -d football_db -c "SELECT * FROM Q8('Li');"
} > results/q8_player_search.md

{
  echo "# Q9: Match Report"
  echo
  psql -d football_db -c "SELECT Q9(200);"
} > results/q9_match_report.md
