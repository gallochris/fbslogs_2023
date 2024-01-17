# team name lookup function 
team_name_lookup <- function(team_data, team_code) {
  team_name <- team_data$name[team_data$code == team_code]
  
  if (length(team_name) == 0) {
    return("Team not found")
  } else {
    return(as.character(team_name))
  }
}

# plotly function 
ggplotly_config <- function(x, ...) {
  plotly::ggplotly(x, tooltip = "text", ...) |> 
    plotly::layout(
      xaxis = list(fixedrange = TRUE),
      yaxis = list(fixedrange = TRUE),
      font = list(family = "IBM Plex Sans Condensed"),
      hoverlabel = list(font = list(family = "IBM Plex Sans Condensed"), align = "left")
    ) |> 
    plotly::config(displayModeBar = FALSE)
}