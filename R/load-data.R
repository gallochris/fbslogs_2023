# Load the utils.R script
source(here::here("R/utils.R"))

# temporarily remove file 
folder_purge <- here::here("data/sportsource-data-2023")

# Delete the folder
unlink(folder_purge, recursive = TRUE) 

# Unzip the file 
file_add <- here::here("data/sportsource-data-2023.zip")

# Unzip the file
unzip(file_add, exdir = here::here("data/")) 

# load fbs only teams 
fbs_only <- readr::read_csv(here::here("data/fbs.csv"))$team

# load in historical data 
hist_time <- readr::read_csv(here::here("data/historical-duration.csv"))

# team codes and names
team_data <- readr::read_csv(here::here("data/sportsource-data-2023/team.csv")) |> 
  dplyr::rename(code = `Team Code`, name = Name) |> 
  dplyr::select(-`Conference Code`) |> 
  dplyr::mutate(name = dplyr::case_match(name, 
            "Louisiana-Lafayette" ~ "Louisiana",
            "Louisiana-Monroe" ~ "Louisiana Monroe",
            "Massachusetts" ~ "UMass",
            "Miami (Florida)" ~ "Miami",
            "Miami (Ohio)" ~ "Miami (OH)",
            "Mississippi" ~ "Ole Miss",
            "North Carolina State" ~ "NC State",
            .default = name
            )) 

# stadium codes and names
stadium_data <- readr::read_csv(here::here("data/sportsource-data-2023/stadium.csv")) |> 
  dplyr::rename(stadium_code = `Stadium Code`, stadium_name = Name) |>
  dplyr::select(stadium_code, stadium_name)

# load the game data 
game_data <- readr::read_csv(here::here("data/sportsource-data-2023/game.csv")) |> 
  dplyr::rename(game_code = `Game Code`, 
                date = Date,
                away = `Visit Team Code`,
                home = `Home Team Code`,
                stadium_code = `Stadium Code`,
                site = Site) |> 
  tidyr::pivot_longer(cols = c(away, home), names_to = "home_away", values_to = "team_code")  


# load the game statistics
minutes_data <- readr::read_csv(here::here("data/sportsource-data-2023/game-statistics.csv")) |> 
  dplyr::rename(game_code = `Game Code`, 
                attendance = Attendance,
                minutes = Duration
  ) |> 
  dplyr::mutate(minutes = dplyr::if_else(
    game_code == "0234074920231028", 202, minutes)) |>
  dplyr::mutate(minutes = dplyr::if_else(
    game_code == "0288005120231104", 209, minutes))


# grab the points and plays
plays_data <- readr::read_csv(here::here("data/sportsource-data-2023/team-game-statistics.csv")) |> 
  dplyr::rename(team_code = `Team Code`,
                game_code = `Game Code`,
                points = Points,
                rush_plays = `Rush Att`,
                pass_plays = `Pass Att`) |>
  dplyr::mutate(all_plays = pass_plays + rush_plays) |> 
  dplyr::select(game_code, team_code, points, all_plays)

# drives 
drive_data <- readr::read_csv(here::here("data/sportsource-data-2023/drive.csv")) |> 
  dplyr::rename(team_code = `Team Code`,
                game_code = `Game Code`,
                drive_num = `Drive Number`,
                start_period = `Start Period`) |> 
  dplyr::select(game_code, team_code, drive_num, start_period) |>
  dplyr::group_by(game_code, team_code) |> 
  dplyr::summarise(drives = dplyr::n(),
                   drives_1st_half = sum(start_period %in% c(1, 2)),
                   drives_2nd_half = sum(start_period %in% c(3, 4)),
                   drives_overtime = sum(start_period >= 5)) |> 
  dplyr::ungroup()

# total_game_data 
total_game_data <- game_data |> 
  dplyr::group_by(game_code) |> 
  dplyr::rowwise() |> 
  dplyr::mutate(team_name = team_name_lookup(team_data, team_code)) |> 
  dplyr::ungroup() |> 
  dplyr::select(-site) |> 
  dplyr::left_join(minutes_data, by = "game_code") |> 
  dplyr::mutate(hours = floor(minutes / 60),
                extra_min = minutes %% 60, 
                duration = paste0(hours, " hours ", extra_min, " minutes")) |> 
  dplyr::filter(!is.na(minutes)) |> 
  dplyr::arrange(-minutes) |> 
  dplyr::select(-hours, -extra_min, -attendance) |> 
  dplyr::left_join(plays_data, by = c("game_code", "team_code")) |> 
  dplyr::left_join(drive_data, by = c("game_code", "team_code")) |> 
  dplyr::left_join(stadium_data, by = "stadium_code") |> 
  dplyr::select(game_code, date, stadium_code, stadium_name, home_away, 
                team_code, team_name, points, drives, drives_1st_half, 
                drives_2nd_half, drives_overtime, minutes, duration,
                all_plays)

write.csv(total_game_data, here::here("data/sportsource-data-2023/tidy-games.csv"))

# update date
current_date <- Sys.Date()

formatted_date <- format(current_date, "%b %d, %Y")

# GAME data
week_one_date <- as.Date("08/27/2023", format = "%m/%d/%Y")

week_two_date <- as.Date("09/06/2023", format = "%m/%d/%Y")

week_three_date <- as.Date("09/13/2023", format = "%m/%d/%Y")

week_four_date <- as.Date("09/20/2023", format = "%m/%d/%Y")

week_five_date <- as.Date("09/27/2023", format = "%m/%d/%Y")

week_six_date <- as.Date("10/3/2023", format = "%m/%d/%Y")

week_seven_date <- as.Date("10/9/2023", format = "%m/%d/%Y")

week_eight_date <- as.Date("10/16/2023", format = "%m/%d/%Y")

week_nine_date <- as.Date("10/23/2023", format = "%m/%d/%Y")

week_ten_date <- as.Date("10/30/2023", format = "%m/%d/%Y")

week_eleven_date <- as.Date("11/06/2023", format = "%m/%d/%Y")

week_twelve_date <- as.Date("11/13/2023", format = "%m/%d/%Y")

week_thirteen_date <- as.Date("11/20/2023", format = "%m/%d/%Y")

week_fourteen_date <- as.Date("11/26/2023", format = "%m/%d/%Y")

week_fifteen_date <- as.Date("12/07/2023", format = "%m/%d/%Y")

week_bowl <- as.Date("12/08/2023", format = "%m/%d/%Y")

# Create new column using case_when
tidy_games_pivot <- readr::read_csv(here::here("data/sportsource-data-2023/tidy-games.csv")) |> 
  dplyr::mutate(date = as.Date(date, format = "%m/%d/%Y")) |>
  dplyr::mutate(week = dplyr::case_when(
    week_one_date > date ~ 0,
    week_one_date < date & week_two_date > date ~ 1,
    week_two_date < date & week_three_date > date ~ 2,
    week_three_date < date & week_four_date > date ~ 3, 
    week_four_date < date & week_five_date > date ~ 4, 
    week_five_date < date & week_six_date > date ~ 5,
    week_six_date < date & week_seven_date > date ~ 6,
    week_seven_date < date & week_eight_date > date ~ 7,
    week_eight_date < date & week_nine_date > date ~ 8,
    week_nine_date < date & week_ten_date > date ~ 9,
    week_ten_date < date & week_eleven_date > date ~ 10,
    week_eleven_date < date & week_twelve_date > date ~ 11,
    week_twelve_date < date & week_thirteen_date > date ~ 12,
    week_thirteen_date < date & week_fourteen_date > date ~ 13,
    week_fourteen_date < date & week_fifteen_date > date ~ 14,
    week_fifteen_date < date & week_bowl > date ~ 15,
    week_bowl < date ~ 15,
    TRUE ~ as.numeric(date)
  )) |> 
  dplyr::group_by(game_code) |> 
  tidyr::pivot_wider(
    id_cols = c(game_code, minutes, stadium_name, duration, week),
    names_from = home_away,
    values_from = c(team_name, points, drives, all_plays),
    values_fn = list
  ) |> 
  dplyr::ungroup() |> 
  dplyr::select(game_code, week, team_name_home, points_home, team_name_away, 
                points_away, drives_home, drives_away, all_plays_home, all_plays_away, minutes)

table_games <- tidy_games_pivot |> 
  dplyr::arrange(-minutes) |> 
  dplyr::mutate(score_sentence = dplyr::if_else(
    as.numeric(points_home) > as.numeric(points_away), paste0(team_name_home, " ", points_home, ", ", team_name_away, " ", points_away),
    paste0(team_name_away, " ", points_away, ", ", team_name_home, " ", points_home)
  )) |> 
  dplyr::mutate(total_drives = as.numeric(drives_home) + as.numeric(drives_away), 
                total_points = as.numeric(points_home) + as.numeric(points_away),
                total_plays = as.numeric(all_plays_home) +
                  as.numeric(all_plays_away)) |> 
  dplyr::select(week, score_sentence, team_name_home, team_name_away, total_drives, total_points, total_plays, minutes) |> 
  dplyr::arrange(-week)

# Team data
team_data <- readr::read_csv(here::here("data/sportsource-data-2023/tidy-games.csv")) |> 
             dplyr::filter(team_name %in% fbs_only) |> 
             dplyr::group_by(team_name) |> 
             dplyr::summarise(sum_games = dplyr::n(),
                              pyg = sum(all_plays) / sum_games,
                              dpg = sum(drives) / sum_games,
                              ppg = sum(points) / sum_games,
                              mpg = sum(minutes) / sum_games,
                              ) |> 
             dplyr::mutate(across(where(is.numeric), 
                                  ~ round(., digits = 1)))


# summary table 
by_week <- table_games |> 
  dplyr::group_by(week) |> 
  dplyr::summarise(
    num_games = dplyr::n(),
    across(
      c(total_drives, total_points, total_plays, minutes),
      ~ round(mean(., na.rm = TRUE),1)
    ),
    .groups = 'drop'
  )
