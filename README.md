# FBS Logs

This goal of this project is to track the duration of 2023 FBS college football games and surface pace of play data. This data can be used to analyze [recent rule changes](https://footballfoundation.org/news/2023/7/20/important-rule-changes-for-the-2023-college-football-season.aspx).

### Data sources
The data used on this site is provided by [SportSource Analytics](http://sportsourceanalytics.com/). 
Historical data is corroborated using [cfbfastR](https://cfbfastr.sportsdataverse.org/index.html), [stats.ncaa.org](https://stats.ncaa.org/reports/game_length?id=21853), and [collegefootballdata.com](https://collegefootballdata.com/).

### Technical bits 

The site is built using the [Distill framework](https://rstudio.github.io/distill/). All data manipulation is done using [R programming language](https://www.r-project.org/). [Node.js](https://nodejs.org/en) is used to automate the fetching of data downloads. 

This project was inspired by [Matt Herman's COVID-19 Tracking project](https://westchester-covid.mattherman.info/). 