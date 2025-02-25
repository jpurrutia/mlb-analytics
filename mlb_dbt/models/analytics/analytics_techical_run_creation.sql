-- materialized view that provides a detailed view of technical run creation for each batter in each season
-- Technical Run Creation (TRC) is a metric that measures the number of runs a player creates based on the number of bases they advance and the number of times they get on base.
{{ config(materialized='view') }}

WITH matchup_events AS (
SELECT
	p.result__type
	,p.result__event
	,p.game_pk 
	--,p.result__rbi
	--,p.about__inning
	--,p.count__balls
	--,p.count__strikes
	--,p.count__outs
	,p.matchup__batter__full_name AS batter_name
	--,p.matchup__bat_side__code
	--,p.matchup__pitcher__full_name
	--,p.matchup__pitch_hand__code
	--,p.matchup__splits__men_on_base
	--,p.official_date
	,s.season
	,COUNT(1) AS event_count
FROM mlb_data.mlb_pbp p
LEFT JOIN mlb_data.mlb_schedule__dates__games s
ON p.game_pk = s.game_pk
WHERE s.status__coded_game_state = 'F'
GROUP BY p.result__type, p.result__event, p.game_pk, p.matchup__batter__full_name, s.season
),
event_counts AS (
SELECT 
  batter_name,
  game_pk,
  season,
  SUM(CASE WHEN result__event = 'Balk' THEN event_count ELSE 0 END) as balk,
  SUM(CASE WHEN result__event = 'Batter Out' THEN event_count ELSE 0 END) as batter_out,
  SUM(CASE WHEN result__event = 'Bunt Groundout' THEN event_count ELSE 0 END) as bunt_groundout,
  SUM(CASE WHEN result__event = 'Bunt Lineout' THEN event_count ELSE 0 END) as bunt_lineout,
  SUM(CASE WHEN result__event = 'Bunt Pop Out' THEN event_count ELSE 0 END) as bunt_pop_out,
  SUM(CASE WHEN result__event = 'Catcher Interference' THEN event_count ELSE 0 END) as catcher_interference,
  SUM(CASE WHEN result__event = 'Caught Stealing 2B' THEN event_count ELSE 0 END) as caught_stealing_2b,
  SUM(CASE WHEN result__event = 'Caught Stealing 3B' THEN event_count ELSE 0 END) as caught_stealing_3b,
  SUM(CASE WHEN result__event = 'Caught Stealing Home' THEN event_count ELSE 0 END) as caught_stealing_home,
  SUM(CASE WHEN result__event = 'Double' THEN event_count ELSE 0 END) as double,
  SUM(CASE WHEN result__event = 'Double Play' THEN event_count ELSE 0 END) as double_play,
  SUM(CASE WHEN result__event = 'Field Error' THEN event_count ELSE 0 END) as field_error,
  SUM(CASE WHEN result__event = 'Fielders Choice' THEN event_count ELSE 0 END) as fielders_choice,
  SUM(CASE WHEN result__event = 'Fielders Choice Out' THEN event_count ELSE 0 END) as fielders_choice_out,
  SUM(CASE WHEN result__event = 'Flyout' THEN event_count ELSE 0 END) as flyout,
  SUM(CASE WHEN result__event = 'Forceout' THEN event_count ELSE 0 END) as forceout,
  SUM(CASE WHEN result__event = 'Game Advisory' THEN event_count ELSE 0 END) as game_advisory,
  SUM(CASE WHEN result__event = 'Grounded Into DP' THEN event_count ELSE 0 END) as grounded_into_dp,
  SUM(CASE WHEN result__event = 'Groundout' THEN event_count ELSE 0 END) as groundout,
  SUM(CASE WHEN result__event = 'Hit By Pitch' THEN event_count ELSE 0 END) as hit_by_pitch,
  SUM(CASE WHEN result__event = 'Home Run' THEN event_count ELSE 0 END) as home_run,
  SUM(CASE WHEN result__event = 'Intent Walk' THEN event_count ELSE 0 END) as intent_walk,
  SUM(CASE WHEN result__event = 'Lineout' THEN event_count ELSE 0 END) as lineout,
  SUM(CASE WHEN result__event IS NULL THEN event_count ELSE 0 END) as nan,
  SUM(CASE WHEN result__event = 'Pickoff 1B' THEN event_count ELSE 0 END) as pickoff_1b,
  SUM(CASE WHEN result__event = 'Pickoff 2B' THEN event_count ELSE 0 END) as pickoff_2b,
  SUM(CASE WHEN result__event = 'Pickoff 3B' THEN event_count ELSE 0 END) as pickoff_3b,
  SUM(CASE WHEN result__event = 'Pickoff Caught Stealing 2B' THEN event_count ELSE 0 END) as pickoff_caught_stealing_2b,
  SUM(CASE WHEN result__event = 'Pickoff Caught Stealing 3B' THEN event_count ELSE 0 END) as pickoff_caught_stealing_3b,
  SUM(CASE WHEN result__event = 'Pickoff Caught Stealing Home' THEN event_count ELSE 0 END) as pickoff_caught_stealing_home,
  SUM(CASE WHEN result__event = 'Pitching Substitution' THEN event_count ELSE 0 END) as pitching_substitution,
  SUM(CASE WHEN result__event = 'Pop Out' THEN event_count ELSE 0 END) as pop_out,
  SUM(CASE WHEN result__event = 'Runner Out' THEN event_count ELSE 0 END) as runner_out,
  SUM(CASE WHEN result__event = 'Runner Placed On Base' THEN event_count ELSE 0 END) as runner_placed_on_base,
  SUM(CASE WHEN result__event = 'Sac Bunt' THEN event_count ELSE 0 END) as sac_bunt,
  SUM(CASE WHEN result__event = 'Sac Fly' THEN event_count ELSE 0 END) as sac_fly,
  SUM(CASE WHEN result__event = 'Sac Fly Double Play' THEN event_count ELSE 0 END) as sac_fly_double_play,
  SUM(CASE WHEN result__event = 'Single' THEN event_count ELSE 0 END) as single,
  SUM(CASE WHEN result__event = 'Strikeout' THEN event_count ELSE 0 END) as strikeout,
  SUM(CASE WHEN result__event = 'Strikeout Double Play' THEN event_count ELSE 0 END) as strikeout_double_play,
  SUM(CASE WHEN result__event = 'Triple' THEN event_count ELSE 0 END) as triple,
  SUM(CASE WHEN result__event = 'Triple Play' THEN event_count ELSE 0 END) as triple_play,
  SUM(CASE WHEN result__event = 'Walk' THEN event_count ELSE 0 END) as walk,
  SUM(CASE WHEN result__event = 'Wild Pitch' THEN event_count ELSE 0 END) as wild_pitch,
  SUM(CASE WHEN result__event = 'Stolen Base 2B' THEN event_count ELSE 0 END) as stolen_base_2b,
  SUM(CASE WHEN result__event = 'Stolen Base 3B' THEN event_count ELSE 0 END) as stolen_base_3b,
  SUM(CASE WHEN result__event = 'Caught Stealing' THEN event_count ELSE 0 END) as caught_stealing
FROM matchup_events
--WHERE season = '2024'
GROUP BY batter_name, game_pk, season
ORDER BY batter_name, game_pk, season
),
calc_bases_opportunities AS (
SELECT *,
    single + (double * 2) + (triple * 3) + (home_run * 4) AS tb,
    bunt_groundout + double + field_error + fielders_choice + flyout + grounded_into_dp + groundout + hit_by_pitch + home_run + intent_walk + lineout + pop_out + sac_bunt + sac_fly + single + strikeout + strikeout_double_play + triple + walk AS ab,
    single + double + triple + home_run AS hits,
    single + double + triple + home_run + walk + hit_by_pitch - (caught_stealing_2b + caught_stealing_3b + caught_stealing_home) - grounded_into_dp AS on_base,
    single + (double * 2) + (triple * 3) + (home_run * 4) + 
    (0.26 * (walk + hit_by_pitch - intent_walk)) + 
    (0.52 * (sac_bunt + sac_fly + stolen_base_2b + stolen_base_3b)) AS bases_advanced,
    bunt_groundout + double + field_error + fielders_choice + flyout + grounded_into_dp + groundout + hit_by_pitch + home_run + intent_walk + lineout + pop_out + sac_bunt + sac_fly + single + strikeout + strikeout_double_play + triple + walk + walk + sac_bunt + sac_fly AS opportunities
FROM event_counts
)
SELECT
  batter_name
  ,season
  ,SUM(CASE 
    WHEN opportunities = 0 THEN NULL 
    ELSE (on_base * bases_advanced) / opportunities 
  END) AS technical_rc
FROM calc_bases_opportunities
GROUP BY batter_name, season
ORDER BY 1,2 desc 