# Load the other scripts
source(here::here("R/utils.R"))
source(here::here("R/load-data.R"))

# fbs games only for the summary 
fbs_only_games <- total_game_data |> 
  dplyr::filter(team_name %in% fbs_only) |> 
  dplyr::group_by(game_code) |> 
  dplyr::mutate(has_fbs_teams = sum(team_name %in% fbs_only) > 1) |>
  dplyr::filter(has_fbs_teams == TRUE) |> 
  dplyr::ungroup() 

# total non-fbs games
total_games <- total_game_data  |> 
  dplyr::distinct(game_code) |> 
  dplyr::summarise(total = dplyr::n())

# calculations
total_fbs_games <- fbs_only_games |> 
  dplyr::distinct(game_code) |> 
  dplyr::summarise(total = dplyr::n())

avg_duration <- total_game_data |> 
  dplyr::summarise(avg = round(mean(minutes), 0))

avg_plays_per_game <- fbs_only_games |> 
  dplyr::summarise(avg = round(mean(all_plays), 1))

avg_hours <- floor(avg_duration / 60)
avg_mins <- round(avg_duration %% 60)

# drives per game 
avg_drives_per_game <- fbs_only_games |> 
  dplyr::group_by(game_code) |> 
  dplyr::mutate(total_drives = sum(drives)) |> 
  dplyr::ungroup() |> 
  dplyr::summarise(avg = sprintf("%.1f", round(mean(total_drives), 1)))

# points scraping 
points_url <- "http://cfbstats.com/2023/leader/national/team/offense/split20/category09/sort01.html"

# Read the HTML content from the URL
webpage <- rvest::read_html(points_url)

points_table <- webpage |> 
  rvest::html_nodes("table") |> 
  rvest::html_table(fill = TRUE)

pts_tb <- as.data.frame(points_table)

avg_pts_per_game <- pts_tb |> 
  dplyr::summarise(avg = sprintf("%.1f", round(sum(Points)/ sum(G),1)))

# last season data
last_yr_plays <- 68.7 
last_yr_pts <- 27.2
last_yr_drives <- 24.5
last_yr_duration <- 207

# diffs
plays_diff <- last_yr_plays - avg_plays_per_game
pts_diff <- last_yr_pts - as.numeric(avg_pts_per_game)
drives_diff <- last_yr_drives - as.numeric(avg_drives_per_game)
duration_diff <- avg_duration - last_yr_duration

if (duration_diff > 0) {
  duration_message <- "minutes longer"
} else if (duration_diff < 0) {
  duration_message <- "fewer minutes"
} else {
  duration_message <- "the same duration"
}
