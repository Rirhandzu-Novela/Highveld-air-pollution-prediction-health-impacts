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
  select(pm2.5, pm10, so2, no2, ws, wd, relHum, temp, pressure)


eMalahleni_hourlycor <- rcorr(as.matrix(eMalahleni_COR), type = "pearson")
eMalahleni_hourlycor.coeff = eMalahleni_hourlycor$r
eMalahleni_hourlycor.p = eMalahleni_hourlycor$P
eMalahleni_hourlycor.coeff

eMalahlenihourlycorplot <- corrplot.mixed(eMalahleni_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "eMalahleni air pollutant correlation")

# eMalahleni polar --------------------------------------------------------

Wpolar <- eMalahleni_clean %>%
  datify() %>%
  mutate(latitude = -25,877861,
         longitude = 29,186472)

# PM10 --------------------------------------------------------------------

WPM10allpolar <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

WPM10stdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM10",
  key.position = "right",
  key = TRUE
)

WEPM10weighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

WPM2.5stdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

WSO2stdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

WNO2stdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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
  Wpolar %>% filter(year == "2009"),
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

