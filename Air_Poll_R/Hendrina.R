# Load packages -----------------------------------------------------------

library(tidyverse)
library(openair)
library(novaAQM)
library(slider)
library(openairmaps)
library(broom)
library(gridExtra)
library(corrplot)
library(Hmisc)
library(plotly)
library(zoo)

Hendrina = read.csv("AirData/HendrinaIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Hendrina$date <- dateTime


# Time series -------------------------------------------------------------


plot_ly(data = Hendrina, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


HendrinaPTS <- timePlot(selectByDate(Hendrina),
                      pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                      y.relation = "free")



HendrinaMTS  <- timePlot(selectByDate(Hendrina),
                       pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                       y.relation = "free")


save(HendrinaPTS, HendrinaMTS , file = "Graph/Hendrina_Timeseriesplot.Rda")

PM2.5 <- timePlot(selectByDate(Hendrina, year = 2013),
                  pollutant = "pm2.5")

Hendrina_clean <-Hendrina %>%
  datify

HPM10Tempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")

HPM10Tempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
HPM10Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "PM10 temporal variation at Hendrina")

HtrendPM10 <- TheilSen(Hendrina_clean, pollutant = "pm10",
                       ylab = "PM10 (µg.m-3)",
                       deseason = TRUE)

save(HPM10Tempplot09, HPM10Tempplot10,
     HPM10Tempplot11,HPM10Tempplot12,
     HPM10Tempplot13,HPM10Tempplot14,
     HPM10Tempplot15,HPM10Tempplot16,
     HPM10Tempplot17,HPM10Tempplot18,
     HPM10Tempplot,HtrendPM10,
     file = "Graph/HTempoaral_plotPM10.Rda")

HPM2.5Tempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2009")
HPM2.5Tempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2010")
HPM2.5Tempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2011")
HPM2.5Tempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2012")
HPM2.5Tempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2013")
HPM2.5Tempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2014")
HPM2.5Tempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2015")
HPM2.5Tempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2016")
HPM2.5Tempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2017")
HPM2.5Tempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Hendrina in 2018")

HPM2.5Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "PM2.5 temporal variation at Hendrina")
HtrendPM2.5 <- TheilSen(Hendrina_clean, pollutant = "pm2.5",
                        ylab = "PM2.5 (µg.m-3)",
                        deseason = TRUE,
                        main = "PM2.5 trends at Hendrina")

save(HPM2.5Tempplot09, HPM2.5Tempplot10,
     HPM2.5Tempplot11,HPM2.5Tempplot12,
     HPM2.5Tempplot13,HPM2.5Tempplot14,
     HPM2.5Tempplot15,HPM2.5Tempplot16,
     HPM2.5Tempplot17,HPM2.5Tempplot18,
     HtrendPM2.5,HPM2.5Tempplot,
     file = "Graph/HTempoaral_plotPM2.5.Rda")

HSO2Tempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2009")
HSO2Tempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2010")
HSO2Tempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2011")
HSO2Tempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2012")
HSO2Tempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2013")
HSO2Tempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2014")
HSO2Tempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2015")
HSO2Tempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2016")
HSO2Tempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2017")
HSO2Tempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Hendrina in 2018")

HSO2Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "SO2 temporal variation at Hendrina")

HtrendSO2 <- TheilSen(Hendrina_clean, pollutant = "so2",
                      ylab = "SO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "SO2 trends at Hendrina")

save(HSO2Tempplot09, HSO2Tempplot10,
     HSO2Tempplot11,HSO2Tempplot12,
     HSO2Tempplot13,HSO2Tempplot14,
     HSO2Tempplot15,HSO2Tempplot16,
     HSO2Tempplot17,HSO2Tempplot18,
     HtrendSO2,HSO2Tempplot,
     file = "Graph/HTempoaral_plotSO2.Rda")

HNO2Tempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2009")
HNO2Tempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2010")
HNO2Tempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2011")
HNO2Tempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2012")
HNO2Tempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2013")
HNO2Tempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2014")
HNO2Tempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2015")
HNO2Tempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2016")
HNO2Tempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2017")
HNO2Tempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Hendrina in 2018")

HNO2Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NO2 temporal variation at Hendrina")


HtrendNO2 <- TheilSen(Hendrina_clean, pollutant = "no2",
                      ylab = "NO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "NO2 trends at Hendrina")

save(HNO2Tempplot09, HNO2Tempplot10,
     HNO2Tempplot11,HNO2Tempplot12,
     HNO2Tempplot13,HNO2Tempplot14,
     HNO2Tempplot15,HNO2Tempplot16,
     HNO2Tempplot17,HNO2Tempplot18,
     HtrendNO2,HNO2Tempplot,
     file = "Graph/HTempoaral_plotNO2.Rda")



# AMS Averages and exceedances --------------------------------------------

Hendrina_date <- Hendrina_clean %>%
  select(date, pm2.5, o3, co, no2, nox, no, so2, pm10) %>%
  pivot_longer(cols = c(pm2.5, o3, no2, no, nox, so2, co, pm10), names_to = "variable") %>%
  mutate(unit = case_when(
    variable == "pm2.5" ~ "Âµg.m-3",
    variable == "o3" ~ "ppb",
    variable == "no" ~ "ppb",
    variable == "nox" ~ "ppb",
    variable == "no2" ~ "ppb",
    variable == "no" ~ "ppb",
    variable == "co" ~ "ppm",
    variable == "pm10" ~ "Âµg.m-3",
    variable == "so2" ~ "ppb",
    TRUE ~ NA_character_
  )) %>%
  mutate(station = "Hendrina")

Hendrina_annual_summary <- Hendrina_date %>% datify %>% 
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  )

write.csv(Hendrina_annual_summary,"Graph/Hendrina_annual_summary.csv")

Hendrina_monthly_hour_ex <- novaAQM::compareAQS(df = Hendrina_date %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "hour",
                                              by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

Hendrina_season_hour_ex <- novaAQM::compareAQS(df = Hendrina_date %>%
                                               ungroup() %>%
                                               datify() %>%
                                               mutate(place = station,
                                                      instrument = "SAAQIS"),
                                             period = "hour",
                                             by_period = quos(season, year)) %>%
  ungroup() %>%
  arrange(pollutant) %>%
  relocate(pollutant, .after = place)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
Hendrina_season_hour_ex <- Hendrina_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

Hendrina_annual_hour_ex <- novaAQM::compareAQS(df = Hendrina_date %>%
                                               ungroup() %>%
                                               datify() %>%
                                               mutate(place = station,
                                                      instrument = "SAAQIS"),
                                             period = "hour",
                                             by_period = quos(year)) %>%
  ungroup() %>%
  arrange(pollutant, year) %>%
  relocate(pollutant, .after = place)

# Daily averages

Hendrina_Daily <- timeAverage(Hendrina_clean, avg.time = "day") %>%
  mutate(station = all_of("Hendrina"))


Hendrina_Day  <- Hendrina_Daily %>%
  select(date, station, pm2.5, o3, no2, no, nox, so2, co, pm10) %>%
  pivot_longer(cols = c(pm2.5, o3,  no2, no, nox, so2, co, pm10), names_to = "variable") %>%
  mutate(unit = case_when(
    variable == "pm10" ~ "Âµg.m-3",
    variable == "pm2.5" ~ "Âµg.m-3",
    variable == "o3" ~ "ppb",
    variable == "so2" ~ "ppb",
    variable == "no" ~ "ppb",
    variable == "no2" ~ "ppb",
    variable == "nox" ~ "ppb",
    variable == "co" ~ "ppm",
    TRUE ~ NA_character_
  ))


Hendrina_month_daily_ex <- novaAQM::compareAQS(df = Hendrina_Day %>%
                                               ungroup() %>%
                                               datify() %>%
                                               mutate(place = station,
                                                      instrument = "SAAQIS"),
                                             period = "day",
                                             by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



Hendrina_season_daily_ex <- novaAQM::compareAQS(df = Hendrina_Day %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "day",
                                              by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
Hendrina_season_daily_ex <- Hendrina_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




Hendrina_annual_daily_ex <- novaAQM::compareAQS(df = Hendrina_Day %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "day",
                                              by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(Hendrina_monthly_hour_ex, Hendrina_season_hour_ex, Hendrina_month_daily_ex, Hendrina_season_daily_ex,
     Hendrina_annual_daily_ex, Hendrina_annual_hour_ex,  file = "Graph/Hendrina_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

HBoxPM2.5Compare <- ggplot(data = Hendrina_Daily %>%
                             datify() %>%
                             select(pm2.5, year),
                           aes(x = year, y = pm2.5 )) +
  geom_boxplot() +
  geom_hline(yintercept = 40, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM2.5",
    title = "Annual statistical summary of PM2.5 at Hendrina") +
  theme(legend.position = "bottom")

HBoxPM2.5Compare


HBoxPM10Compare <- ggplot(data = Hendrina_Daily %>%
                            datify() %>%
                            select(pm10, year),
                          aes(x = year, y = pm10 )) +
  geom_boxplot() +
  geom_hline(yintercept = 75, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM10",
    title = "Annual statistical summary of PM10 at Hendrina") +
  theme(legend.position = "bottom")

HBoxPM10Compare

HBoxso2Compare <- ggplot(data = Hendrina_Daily %>%
                           datify() %>%
                           select(so2, year),
                         aes(x = year, y = so2 )) +
  geom_boxplot() +
  geom_hline(yintercept = 48, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "SO2",
    title = "Annual statistical summary of SO2 at Hendrina") +
  theme(legend.position = "bottom")

HBoxso2Compare

HBoxno2Compare <- ggplot(data = Hendrina_Daily %>%
                           datify() %>%
                           select(no2, year),
                         aes(x = year, y = no2 )) +
  geom_boxplot() +
  geom_hline(yintercept = 92, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO2",
    title = "Annual statistical summary of NO2 at Hendrina") +
  theme(legend.position = "bottom")

HBoxno2Compare



save(HBoxPM2.5Compare,
     HBoxPM10Compare,
     HBoxso2Compare,
     HBoxno2Compare,
     file = "Graph/HBox_plot.Rda")

# Correlation -------------------------------------------------------------


Hendrina_COR <- Hendrina_clean %>%
  select(pm2.5, pm10, so2, no2, ws, wd, relHum, temp, pressure)


Hendrina_hourlycor <- rcorr(as.matrix(Hendrina_COR), type = "pearson")
Hendrina_hourlycor.coeff = Hendrina_hourlycor$r
Hendrina_hourlycor.p = Hendrina_hourlycor$P
Hendrina_hourlycor.coeff

Hendrinahourlycorplot <- corrplot.mixed(Hendrina_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Hendrina air pollutant correlation")


# Hendrina polar ----------------------------------------------------------

Hpolar <- Hendrina_clean %>%
  mutate(latitude = -26.151197,
         longitude = 29.716484)

plot_polar_cluster <- function(data,
                               pollutant,
                               statistic   = "mean",
                               n.clusters  = 6,
                               cols        = "Set2",
                               main.stat   = NULL,
                               main.clust  = NULL) {
  
  # 1. Statistic plot
  stat_obj  <- polarPlot(data,
                         pollutant = pollutant,
                         statistic = statistic,
                         main      = main.stat)
  stat_plot <- stat_obj$plot
  
  # 2. Cluster plot
  cluster_obj  <- polarCluster(data,
                               pollutant  = pollutant,
                               n.clusters = n.clusters,
                               cols       = cols,
                               main       = main.clust)
  clust_plot   <- cluster_obj$plot
  
  # 3. Cluster summary table
  stats        <- cluster_obj$clust_stats
  pct_col      <- paste0(pollutant, "_percent")
  mean_col     <- paste0("mean_", pollutant)
  stats_tbl    <- stats %>%
    select(-all_of(pct_col)) %>%
    mutate(!!mean_col := round(.data[[mean_col]], 2))
  table_grob   <- tableGrob(stats_tbl)
  
  # 4. Arrange side‑by‑side
  grid.arrange(stat_plot, clust_plot, table_grob, nrow = 1)
}

Hpolarplotpm1 <- plot_polar_cluster(Hpolar,
                                    pollutant  = "pm10",
                                    statistic  = "mean",
                                    n.clusters = 6,
                                    cols       = "Set2",
                                    main.stat  = "PM10 mean",
                                    main.clust = "PM10 clusters")

Hpolarplotpm2 <- plot_polar_cluster(Hpolar,
                                    pollutant  = "pm2.5",
                                    statistic  = "mean",
                                    n.clusters = 6,
                                    cols       = "Set2",
                                    main.stat  = "PM2.5 mean",
                                    main.clust = "PM2.5 clusters")


Hpolarplotso <- plot_polar_cluster(Hpolar,
                                   pollutant  = "so2",
                                   statistic  = "mean",
                                   n.clusters = 6,
                                   cols       = "Set2",
                                   main.stat  = "SO2 mean",
                                   main.clust = "SO2 clusters")

Hpolarplotno <- plot_polar_cluster(Hpolar,
                                   pollutant  = "no2",
                                   statistic  = "mean",
                                   n.clusters = 6,
                                   cols       = "Set2",
                                   main.stat  = "NO2 mean",
                                   main.clust = "NO2 clusters")

# PM10 --------------------------------------------------------------------



HPM10allpolar <- polarMap(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

HPM10stdev <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM10",
  key.position = "right",
  key = TRUE
)

HPM10weighted <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM10",
  key.position = "right",
  key = TRUE
)


HPM10frequency <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


HPM10per50 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 at 50th percentile",
  key.position = "right",
  key = TRUE
)



HPM10per60 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50, 60),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HPM10per70 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60, 70),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HPM10per80 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HPM10per90 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HPM10per98 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HPM10per99 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 at 99th percentile",
  key.position = "right",
  key = TRUE
)



HPM10_CPFplot = list(HPM10allpolar$plot,
                     HPM10stdev$plot,
                     HPM10frequency$plot,
                     HPM10weighted$plot,
                     HPM10per50$plot,
                     HPM10per60$plot,
                     HPM10per70$plot,
                     HPM10per80$plot,
                     HPM10per90$plot,
                     HPM10per98$plot,
                     HPM10per99$plot)

do.call("grid.arrange", HPM10_CPFplot)


# PM2.5 -------------------------------------------------------------------

HPM2.5allpolar <- polarMap(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

HPM2.5stdev <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM2.5",
  key.position = "right",
  key = TRUE
)


HPM2.5weighted <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM2.5",
  key.position = "right",
  key = TRUE
)

HPM2.5frequency <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

HPM2.5per50 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 at 50th percentile",
  key.position = "right",
  key = TRUE
)



HPM2.5per60 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HPM2.5per70 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HPM2.5per80 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HPM2.5per90 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HPM2.5per98 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HPM2.5per99 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 at 99th percentile",
  key.position = "right",
  key = TRUE
)



HPM2.5_CPFplot = list(HPM2.5allpolar$plot,
                      HPM2.5stdev$plot,
                      HPM2.5frequency$plot,
                      HPM2.5weighted$plot,
                      HPM2.5per50$plot,
                      HPM2.5per60$plot,
                      HPM2.5per70$plot,
                      HPM2.5per80$plot,
                      HPM2.5per90$plot,
                      HPM2.5per98$plot,
                      HPM2.5per99$plot)

do.call("grid.arrange", HPM2.5_CPFplot)


# SO2 --------------------------------------------------------------------


HSO2allpolar <- polarMap(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

HSO2stdev <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of SO2",
  key.position = "right",
  key = TRUE
)

HSO2weighted <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean SO2",
  key.position = "right",
  key = TRUE
)


HSO2frequency <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

HSO2per50 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 at 50th percentile",
  key.position = "right",
  key = TRUE
)



HSO2per60 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HSO2per70 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HSO2per80 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HSO2per90 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)


HSO2per98 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HSO2per99 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2 at 99th percentile",
  key.position = "right",
  key = TRUE
)



HSO2_CPFplot = list(HSO2allpolar$plot,
                    HSO2stdev$plot,
                    HSO2frequency$plot,
                    HSO2weighted$plot,
                    HSO2per50$plot,
                    HSO2per60$plot,
                    HSO2per70$plot,
                    HSO2per80$plot,
                    HSO2per90$plot,
                    HSO2per98$plot,
                    HSO2per99$plot)

do.call("grid.arrange", HSO2_CPFplot)



# NO2 --------------------------------------------------------------------

HNO2allpolar <- polarMap(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

HNO2stdev <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO2",
  key.position = "right",
  key = TRUE
)

HNO2weighted <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO2",
  key.position = "right",
  key = TRUE
)


HNO2frequency <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


HNO2per50 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 at 50th percentile",
  key.position = "right",
  key = TRUE
)



HNO2per60 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HNO2per70 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HNO2per80 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HNO2per90 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HNO2per98 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HNO2per99 <- polarPlot(
  Hpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 at 99th percentile",
  key.position = "right",
  key = TRUE
)



HNO2_CPFplot = list(HNO2allpolar$plot,
                    HNO2stdev$plot,
                    HNO2frequency$plot,
                    HNO2weighted$plot,
                    HNO2per50$plot,
                    HNO2per60$plot,
                    HNO2per70$plot,
                    HNO2per80$plot,
                    HNO2per90$plot,
                    HNO2per98$plot,
                    HNO2per99$plot)

do.call("grid.arrange", HNO2_CPFplot)


# AQHI --------------------------------------------------------------------

H = read.csv("AirData/HendrinaIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
H$date <- dateTime


df <- H %>%
  select(date, o3) %>% 
  mutate(
    ozone_8hr_avg = rollapply(o3, width = 8, FUN = mean, align = "right", fill = NA)
  ) %>%
  mutate(date = as.Date(date)) %>%
  group_by(date) %>%
  summarise(
    o3 = max(rollapply(ozone_8hr_avg, width = 3, FUN = mean, align = "right", fill = NA), na.rm = TRUE)
  )


Hdaily <- timeAverage(H, avg.time = "day")

Hdaily <- Hdaily %>% 
  select(-o3) %>% 
  left_join(df, by = "date")

beta_values <- list(
  pm2.5 = 0.00065,
  pm10  = 0.00041,
  no2   = 0.00072,
  so2   = 0.00059,
  o3    = 0.00043
)

# Calculate the excess risk for each pollutant
HdailyR <- Hdaily %>%
  select(date, pm2.5, pm10, so2, no2, o3) %>% 
  mutate(
    excess_risk_pm2.5 = 100 * (exp(beta_values$pm2.5 * `pm2.5`) - 1),
    excess_risk_pm10  = 100 * (exp(beta_values$pm10  * `pm10`)  - 1),
    excess_risk_no2   = 100 * (exp(beta_values$no2   * `no2`)   - 1),
    excess_risk_so2   = 100 * (exp(beta_values$so2   * `so2`)   - 1),
    excess_risk_o3    = 100 * (exp(beta_values$o3    * `o3`)    - 1)
  )


# Define the thresholds for each pollutant based on excess risk
aqhi_pm10 <- c(0, 0.21, 0.42, 0.63, 0.84, 1.05, 1.26, 1.47, 1.68, 1.89, Inf)
aqhi_no2 <- c(0, 0.24, 0.48, 0.72, 0.96, 1.20, 1.44, 1.68, 1.92, 2.16, Inf)
aqhi_so2 <- c(0, 0.4, 0.8, 1.2, 1.6, 2.0, 2.4, 2.8, 3.2, 3.6, Inf)
aqhi_o3 <- c(0, 0.87, 1.74, 2.61, 3.48, 4.35, 5.22, 6.09, 6.96, 7.83, Inf)

# Function to calculate AQHI for each pollutant based on excess risk
calculate_aqhi <- function(excess_risk, thresholds) {
  cut(excess_risk, breaks = thresholds, labels = 1:10, right = FALSE)
}

# Apply the AQHI classification to the dataframe
daily_df <- HdailyR %>%
  mutate(
    aqhi_pm10 = calculate_aqhi(excess_risk_pm10, aqhi_pm10),
    aqhi_no2  = calculate_aqhi(excess_risk_no2, aqhi_no2),
    aqhi_so2  = calculate_aqhi(excess_risk_so2, aqhi_so2),
    aqhi_o3   = calculate_aqhi(excess_risk_o3, aqhi_o3)
  ) %>%
  mutate(
    weight_pm10 = 1,  # Weight of PM10 is defined to be 1
    weight_no2  =  0.853,
    weight_so2  =  0.519,
    weight_o3   =  0.236) %>%
  rowwise() %>%
  mutate(
    weighted_aqhi = round(
      sum(c(weight_pm10, weight_no2, weight_so2, weight_o3) * 
            c(as.numeric(aqhi_pm10), as.numeric(aqhi_no2), as.numeric(aqhi_so2), as.numeric(aqhi_o3))) / 
        sum(c(weight_pm10, weight_no2, weight_so2, weight_o3)))
  ) %>%
  ungroup()  %>%
  mutate(
    risk_level = case_when(
      weighted_aqhi >= 1 & weighted_aqhi <= 3 ~ "Low risk",
      weighted_aqhi >= 4 & weighted_aqhi <= 6 ~ "Moderate risk",
      weighted_aqhi >= 7 & weighted_aqhi <= 10 ~ "High risk",
      TRUE ~ NA_character_  # Handle any cases that don't match the conditions (if necessary)
    )) %>% 
  select(date, weighted_aqhi, risk_level)


HPollAqhi <- Hdaily %>% 
  left_join(daily_df, by = "date")

write.csv(HPollAqhi, "AirData/HPollAqhi.csv", row.names = TRUE)

# Group by year and risk_level, then count the number of days in each risk_level per year

Hrisk_level_counts <- HPollAqhi %>%
  group_by(weighted_aqhi) %>%
  summarise(days_count = n(),
            pm2.5 = mean(pm2.5),
            pm10 = mean(pm10),
            so2 = mean(so2),
            no2 = mean(no2),
            o3 = mean(o3),
            .groups = "drop")


# Optionally, save the result to a CSV file
write.csv(Hrisk_level_counts, "RDA/Hrisk_level_counts.csv", row.names = TRUE)


# heatmap

df <- HPollAqhi %>%
  mutate(
    year = format(date, "%Y"),                # Extract the year
    day_of_year = as.numeric(format(date, "%j")),  # Day of the year (1-365)
    color = case_when(                        # Categorize risk levels into colors
      weighted_aqhi >= 1 & weighted_aqhi <= 3 ~ "green",
      weighted_aqhi >= 4 & weighted_aqhi <= 5 ~ "yellow",
      weighted_aqhi >= 6 & weighted_aqhi <= 7 ~ "orange",
      weighted_aqhi >= 8 & weighted_aqhi <= 9 ~ "red",
      weighted_aqhi == 10 ~ "purple"
    )
  ) %>%
  mutate(
    risk_category = factor(color, levels = c("green", "yellow", "orange", "red", "purple"),
                           labels = c("Good (1-3)", "Moderate (4-5)", "Unhealthy (6-7)", "Very Unhealthy (8-9)", "Hazardous (10+)"))
  )

# Plot the heatmap with a legend
ggplot(df, aes(x = day_of_year, y = year, fill = risk_category)) +
  geom_tile(color = "white") +                    # Add white grid lines
  scale_fill_manual(
    values = c(
      "Good (1-3)" = "green",
      "Moderate (4-5)" = "yellow",
      "Unhealthy (6-7)" = "orange",
      "Very Unhealthy (8-9)" = "red",
      "Hazardous (10+)" = "purple"
    ),
    name = "Risk Levels"                          # Legend title
  ) +
  scale_x_continuous(
    breaks = c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335),  # Approximate start of each month
    labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  ) +
  labs(
    title = "Hendrina Daily Air Quality Health Index",
    x = "Month",
    y = "Year"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(face = "bold", angle = 90, hjust = 1), # Rotate x-axis labels for better readability
    axis.text.y = element_text(face = "bold"),
    legend.position = "bottom",                        # Move legend below the plot
    legend.title = element_text(size = 10, face = "bold"),            # Adjust legend title size
    legend.text = element_text(face = "bold", size = 8),
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold"))
