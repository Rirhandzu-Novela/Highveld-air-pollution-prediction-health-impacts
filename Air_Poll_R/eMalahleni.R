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
library(ggpubr)
library(imputeTS)
library(dplyr)
library(zoo)

eMalahleni = read.csv("AirData/eMalahleniIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
eMalahleni$date <- dateTime


# TIMESERIES --------------------------------------------------------------

plot_ly(data = eMalahleni, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))



eMalahleniPTS <- timePlot(selectByDate(eMalahleni),
                          pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                          y.relation = "free")


eMalahleniMTS  <- timePlot(selectByDate(eMalahleni),
                           pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                           y.relation = "free")


save(eMalahleniPTS, eMalahleniMTS , file = "Graph/eMalahleni_Timeseriesplot.Rda")


eMalahleni_clean <- eMalahleni %>%
  datify()


WPM10Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2009")
WPM10Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2010")
WPM10Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2011")
WPM10Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2012")

WPM10Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2013")
WPM10Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2014")
WPM10Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2015")
WPM10Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2016")
WPM10Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2017")
WPM10Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick", main = "PM10 temporal variation at eMalahleni in 2018")

WPM10Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "PM10 temporal variation at eMalahleni")

WtrendPM10 <- TheilSen(eMalahleni_clean, pollutant = "pm10",
                       ylab = "PM10 (µg.m-3)",
                       deseason = TRUE,
                       main = "PM10 trends at eMalahleni")

save(WPM10Tempplot09, WPM10Tempplot10,
     WPM10Tempplot11,WPM10Tempplot12,
     WPM10Tempplot13,WPM10Tempplot14,
     WPM10Tempplot15,WPM10Tempplot16,
     WPM10Tempplot17,WPM10Tempplot18,
     WtrendPM10,WPM10Tempplot,
     file = "Graph/WTempoaral_plotPM10.Rda")


WPM2.5Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2009")
WPM2.5Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2010")
WPM2.5Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2011")
WPM2.5Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2012")
WPM2.5Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2013")
WPM2.5Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2014")
WPM2.5Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2015")
WPM2.5Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2016")
WPM2.5Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2017")
WPM2.5Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at eMalahleni in 2018")

WPM2.5Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "PM2.5 temporal variation at eMalahleni")
WtrendPM2.5 <- TheilSen(eMalahleni_clean, pollutant = "pm2.5",
                        ylab = "PM2.5 (µg.m-3)",
                        deseason = TRUE,
                        main = "PM2.5 trends at eMalahleni")

save(WPM2.5Tempplot09, WPM2.5Tempplot10,
     WPM2.5Tempplot11,WPM2.5Tempplot12,
     WPM2.5Tempplot13,WPM2.5Tempplot14,
     WPM2.5Tempplot15,WPM2.5Tempplot16,
     WPM2.5Tempplot17,WPM2.5Tempplot18,
     WtrendPM2.5,WPM2.5Tempplot,
     file = "Graph/WTempoaral_plotPM2.5.Rda")

WSO2Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2009")
WSO2Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2010")
WSO2Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2011")
WSO2Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2012")
WSO2Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2013")
WSO2Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2014")
WSO2Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2015")
WSO2Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2016")
WSO2Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2017")
WSO2Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at eMalahleni in 2018")

WSO2Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "SO2 temporal variation at eMalahleni")

WtrendSO2 <- TheilSen(eMalahleni_clean, pollutant = "so2",
                      ylab = "SO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "SO2 trends at eMalahleni")

save(WSO2Tempplot09, WSO2Tempplot10,
     WSO2Tempplot11,WSO2Tempplot12,
     WSO2Tempplot13,WSO2Tempplot14,
     WSO2Tempplot15,WSO2Tempplot16,
     WSO2Tempplot17,WSO2Tempplot18,
     WtrendSO2,WSO2Tempplot,
     file = "Graph/WTempoaral_plotSO2.Rda")

WNO2Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2009")
WNO2Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2010")
WNO2Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2011")
WNO2Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2012")
WNO2Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2013")
WNO2Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2014")
WNO2Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2015")
WNO2Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2016")
WNO2Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2017")
WNO2Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at eMalahleni in 2018")

WNO2Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NO2 temporal variation at eMalahleni")


WtrendNO2 <- TheilSen(eMalahleni_clean, pollutant = "no2",
                      ylab = "NO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "NO2 trends at eMalahleni")

save(WNO2Tempplot09, WNO2Tempplot10,
     WNO2Tempplot11,WNO2Tempplot12,
     WNO2Tempplot13,WNO2Tempplot14,
     WNO2Tempplot15,WNO2Tempplot16,
     WNO2Tempplot17,WNO2Tempplot18,
     WtrendNO2,WNO2Tempplot,
     file = "Graph/WTempoaral_plotNO2.Rda")




# AMS Averages and exceedances --------------------------------------------

eMalahleni_date <- eMalahleni_clean %>%
  select(date,  pm2.5, o3, co, no2, nox, no, so2, pm10) %>%
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
  mutate(station = "eMalahleni")

eMalahleni_annual_summary <- eMalahleni_date %>% datify %>% 
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  )

write.csv(eMalahleni_annual_summary,"Graph/eMalahleni_annual_summary.csv")

eMalahleni_monthly_hour_ex <- novaAQM::compareAQS(df = eMalahleni_date %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "hour",
                                                  by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

eMalahleni_season_hour_ex <- novaAQM::compareAQS(df = eMalahleni_date %>%
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
eMalahleni_season_hour_ex <- eMalahleni_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

eMalahleni_annual_hour_ex <- novaAQM::compareAQS(df = eMalahleni_date %>%
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

eMalahleni_Daily <- timeAverage(eMalahleni_clean, avg.time = "day") %>%
  mutate(station = all_of("eMalahleni"))


eMalahleni_Day  <- eMalahleni_Daily %>%
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


eMalahleni_month_daily_ex <- novaAQM::compareAQS(df = eMalahleni_Day %>%
                                                   ungroup() %>%
                                                   datify() %>%
                                                   mutate(place = station,
                                                          instrument = "SAAQIS"),
                                                 period = "day",
                                                 by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



eMalahleni_season_daily_ex <- novaAQM::compareAQS(df = eMalahleni_Day %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "day",
                                                  by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
eMalahleni_season_daily_ex <- eMalahleni_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




eMalahleni_annual_daily_ex <- novaAQM::compareAQS(df = eMalahleni_Day %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "day",
                                                  by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(eMalahleni_monthly_hour_ex, eMalahleni_season_hour_ex, eMalahleni_month_daily_ex, eMalahleni_season_daily_ex,
     eMalahleni_annual_daily_ex, eMalahleni_annual_hour_ex,  file = "Graph/eMalahleni_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

WBoxPM2.5Compare <- ggplot(data = eMalahleni_Daily %>%
                             datify() %>%
                             select(pm2.5, year),
                           aes(x = year, y = pm2.5)) +
  geom_boxplot() +
  geom_hline(yintercept = 40, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM2.5",
    title = "Annual statistical summary of PM2.5 at eMalahleni") +
  theme(legend.position = "bottom")

WBoxPM2.5Compare


WBoxPM10Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of PM10 at eMalahleni") +
  theme(legend.position = "bottom")

WBoxPM10Compare

WBoxso2Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of SO2 at eMalahleni") +
  theme(legend.position = "bottom")

WBoxso2Compare

WBoxno2Compare <- ggplot(data = eMalahleni_Daily %>%
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
    title = "Annual statistical summary of NO2 at eMalahleni") +
  theme(legend.position = "bottom")

WBoxno2Compare

save(WBoxPM2.5Compare,
     WBoxPM10Compare,
     WBoxso2Compare,
     WBoxno2Compare,
     file = "Graph/WBox_plot.Rda")

# Correlation -------------------------------------------------------------


eMalahleni_COR <- eMalahleni_clean %>%
  select(date, pm2.5, pm10, so2, no2, ws, wd, relHum, temp, pressure)


eMalahleni_hourlycor <- rcorr(as.matrix(eMalahleni_COR |> select(-date)), type = "pearson")
eMalahleni_hourlycor.coeff = eMalahleni_hourlycor$r
eMalahleni_hourlycor.p = eMalahleni_hourlycor$P
eMalahleni_hourlycor.coeff

eMalahlenihourlycorplot <- corrplot.mixed(eMalahleni_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "eMalahleni air pollutant correlation")

polls <- c("pm2.5","pm10","so2","no2","ws","wd","relHum","temp")

corPlot(eMalahleni_COR,
        pollutant = polls,
        type      = "year",
        lower     = TRUE,
        upper     = FALSE,
        layout    = c(4,3),
        main      = paste("eMalahleni air pollutant correlations"))
# eMalahleni polar --------------------------------------------------------

Wpolar <- eMalahleni_clean %>%
  mutate(latitude = -25.877861,
         longitude = 29.186472)

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

Wpolarplotpm1 <- plot_polar_cluster(Wpolar,
                                    pollutant  = "pm10",
                                    statistic  = "mean",
                                    n.clusters = 6,
                                    cols       = "Set2",
                                    main.stat  = "PM10 mean",
                                    main.clust = "PM10 clusters")

Wpolarplotpm2 <- plot_polar_cluster(Wpolar,
                                    pollutant  = "pm2.5",
                                    statistic  = "mean",
                                    n.clusters = 6,
                                    cols       = "Set2",
                                    main.stat  = "PM2.5 mean",
                                    main.clust = "PM2.5 clusters")


Wpolarplotso <- plot_polar_cluster(Wpolar,
                                   pollutant  = "so2",
                                   statistic  = "mean",
                                   n.clusters = 6,
                                   cols       = "Set2",
                                   main.stat  = "SO2 mean",
                                   main.clust = "SO2 clusters")

Wpolarplotno <- plot_polar_cluster(Wpolar,
                                   pollutant  = "no2",
                                   statistic  = "mean",
                                   n.clusters = 6,
                                   cols       = "Set2",
                                   main.stat  = "NO2 mean",
                                   main.clust = "NO2 clusters")
# PM10 --------------------------------------------------------------------

WPM10allpolar <- polarMap(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

WPM10stdev <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM10",
  key.position = "right",
  key = TRUE
)

WPM10weighted <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM10",
  key.position = "right",
  key = TRUE
)


WPM10frequency <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


WPM10per50 <- polarPlot(
  Wpolar,
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



WPM10per60 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10  from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WPM10per70 <- polarPlot(
  Wpolar,
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


WPM10per80 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM10 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WPM10per90 <- polarPlot(
  Wpolar,
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

WPM10per98 <- polarPlot(
  Wpolar,
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


WPM10per99 <- polarPlot(
  Wpolar,
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



WPM10_CPFplot = list(WPM10allpolar$plot,
                     WPM10stdev$plot,
                     WPM10frequency$plot,
                     WPM10weighted$plot,
                     WPM10per50$plot,
                     WPM10per60$plot,
                     WPM10per70$plot,
                     WPM10per80$plot,
                     WPM10per90$plot,
                     WPM10per98$plot,
                     WPM10per99$plot)

do.call("grid.arrange", WPM10_CPFplot)

# PM2.5 -------------------------------------------------------------------

WPM2.5allpolar <- polarMap(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

WPM2.5stdev <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM2.5",
  key.position = "right",
  key = TRUE
)


WPM2.5weighted <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM2.5",
  key.position = "right",
  key = TRUE
)

WPM2.5frequency <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

WPM2.5per50 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 50th percentile",
  key.position = "right",
  key = TRUE
)



WPM2.5per60 <- polarPlot(
  Wpolar,
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


WPM2.5per70 <- polarPlot(
  Wpolar,
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


WPM2.5per80 <- polarPlot(
  Wpolar,
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


WPM2.5per90 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WPM2.5per98 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "PM2.5 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WPM2.5per99 <- polarPlot(
  Wpolar,
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



WPM2.5_CPFplot = list(WPM2.5allpolar$plot,
                      WPM2.5stdev$plot,
                      WPM2.5frequency$plot,
                      WPM2.5weighted$plot,
                      WPM2.5per50$plot,
                      WPM2.5per60$plot,
                      WPM2.5per70$plot,
                      WPM2.5per80$plot,
                      WPM2.5per90$plot,
                      WPM2.5per98$plot,
                      WPM2.5per99$plot)

do.call("grid.arrange", WPM2.5_CPFplot)

# SO2 --------------------------------------------------------------------


WSO2allpolar <- polarMap(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

WSO2stdev <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of SO2",
  key.position = "right",
  key = TRUE
)

WSO2weighted <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean SO2",
  key.position = "right",
  key = TRUE
)


WSO2frequency <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


WSO2per50 <- polarPlot(
  Wpolar,
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



WSO2per60 <- polarPlot(
  Wpolar,
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


WSO2per70 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "SO2  from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WSO2per80 <- polarPlot(
  Wpolar,
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


WSO2per90 <- polarPlot(
  Wpolar,
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

WSO2per98 <- polarPlot(
  Wpolar,
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


WSO2per99 <- polarPlot(
  Wpolar,
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



WSO2_CPFplot = list(WSO2allpolar$plot,
                    WSO2stdev$plot,
                    WSO2frequency$plot,
                    WSO2weighted$plot,
                    WSO2per50$plot,
                    WSO2per60$plot,
                    WSO2per70$plot,
                    WSO2per80$plot,
                    WSO2per90$plot,
                    WSO2per98$plot,
                    WSO2per99$plot)

do.call("grid.arrange", WSO2_CPFplot)


# NO2 --------------------------------------------------------------------

WNO2allpolar <- polarMap(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

WNO2stdev <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO2",
  key.position = "right",
  key = TRUE
)

WNO2weighted <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO2",
  key.position = "right",
  key = TRUE
)


WNO2frequency <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


WNO2per50 <- polarPlot(
  Wpolar,
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



WNO2per60 <- polarPlot(
  Wpolar,
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


WNO2per70 <- polarPlot(
  Wpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60, 70),
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO2 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WNO2per80 <- polarPlot(
  Wpolar,
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


WNO2per90 <- polarPlot(
  Wpolar,
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

WNO2per98 <- polarPlot(
  Wpolar,
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


WNO2per99 <- polarPlot(
  Wpolar,
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



WNO2_CPFplot = list(WNO2allpolar$plot,
                    WNO2stdev$plot,
                    WNO2frequency$plot,
                    WNO2weighted$plot,
                    WNO2per50$plot,
                    WNO2per60$plot,
                    WNO2per70$plot,
                    WNO2per80$plot,
                    WNO2per90$plot,
                    WNO2per98$plot,
                    WNO2per99$plot)

do.call("grid.arrange", WNO2_CPFplot)


# AQHI --------------------------------------------------------------------

W = read.csv("AirData/eMalahleniIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
W$date <- dateTime


df <- W %>%
  select(date, o3) %>% 
  mutate(
    ozone_8hr_avg = rollapply(o3, width = 8, FUN = mean, align = "right", fill = NA)
  ) %>%
  mutate(date = as.Date(date)) %>%
  group_by(date) %>%
  summarise(
    o3 = max(rollapply(ozone_8hr_avg, width = 3, FUN = mean, align = "right", fill = NA), na.rm = TRUE)
  )


Wdaily <- timeAverage(W, avg.time = "day")

Wdaily <- Wdaily %>% 
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
WdailyR <- Wdaily %>%
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
daily_df <- WdailyR %>%
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


WPollAqhi <- Wdaily %>% 
  left_join(daily_df, by = "date")

write.csv(WPollAqhi, "AirData/WPollAqhi.csv", row.names = TRUE)

# Group by year and risk_level, then count the number of days in each risk_level per year

Wrisk_level_counts <- WPollAqhi %>%
  group_by(weighted_aqhi) %>%
  summarise(days_count = n(),
            pm2.5 = mean(pm2.5),
            pm10 = mean(pm10),
            so2 = mean(so2),
            no2 = mean(no2),
            o3 = mean(o3),
            .groups = "drop")


# Optionally, save the result to a CSV file
write.csv(Wrisk_level_counts, "RDA/Wrisk_level_counts.csv", row.names = TRUE)


# heatmap

df <- WPollAqhi %>%
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
    title = "eMalahleni Daily Air Quality Health Index",
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
