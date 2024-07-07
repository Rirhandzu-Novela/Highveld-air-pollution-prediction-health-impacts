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


Ermelo = read.csv("AirData/ErmeloIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Ermelo$date <- dateTime

# Time series -------------------------------------------------------------


plot_ly(data = Ermelo, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


ErmeloPTS <- timePlot(selectByDate(Ermelo),
                          pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                          y.relation = "free")

ErmeloMTS  <- timePlot(selectByDate(Ermelo),
                           pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                           y.relation = "free")

save(ErmeloPTS, ErmeloMTS , file = "Graph/Ermelo_Timeseriesplot.Rda")


Ermelo_clean <-Ermelo %>%
  datify

PM2.5 <- timePlot(selectByDate(Ermelo_clean, year = 2013),
                  pollutant = "pm2.5")


EPM10Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
EPM10Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")

EtrendPM10 <- TheilSen(Ermelo_clean, pollutant = "pm10",
         ylab = "PM10 (µg.m-3)",
         deseason = TRUE)

save(EPM10Tempplot09, EPM10Tempplot10,
     EPM10Tempplot11,EPM10Tempplot12,
     EPM10Tempplot13,EPM10Tempplot14,
     EPM10Tempplot15,EPM10Tempplot16,
     EPM10Tempplot17,EPM10Tempplot18,
     EPM10Tempplot,EtrendPM10,
     file = "Graph/ETempoaral_plotPM10.Rda")

EPM2.5Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2009")
EPM2.5Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2010")
EPM2.5Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2011")
EPM2.5Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2012")
EPM2.5Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2013")

EPM2.5Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2014")
EPM2.5Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2015")
EPM2.5Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2016")
EPM2.5Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2017")
EPM2.5Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Ermelo in 2018")

EPM2.5Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "PM2.5 temporal variation at Ermelo")

EtrendPM2.5 <- TheilSen(Ermelo_clean, pollutant = "pm2.5",
                        ylab = "PM2.5 (µg.m-3)",
                        deseason = TRUE,
                        main = "PM2.5 trends at Ermelo")

save(EPM2.5Tempplot09, EPM2.5Tempplot10,
     EPM2.5Tempplot11,EPM2.5Tempplot12,
     EPM2.5Tempplot13,EPM2.5Tempplot14,
     EPM2.5Tempplot15,EPM2.5Tempplot16,
     EPM2.5Tempplot17,EPM2.5Tempplot18,
     EtrendPM2.5,EPM2.5Tempplot,
     file = "Graph/ETempoaral_plotPM2.5.Rda")

ESO2Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2009")
ESO2Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2010")
ESO2Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2011")
ESO2Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2012")
ESO2Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2013")
ESO2Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2014")
ESO2Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2015")
ESO2Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2016")
ESO2Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2017")
ESO2Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Ermelo in 2018")

ESO2Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "SO2 temporal variation at Ermelo")

EtrendSO2 <- TheilSen(Ermelo_clean, pollutant = "so2",
                      ylab = "SO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "SO2 trends at Ermelo")

save(ESO2Tempplot09, ESO2Tempplot10,
     ESO2Tempplot11,ESO2Tempplot12,
     ESO2Tempplot13,ESO2Tempplot14,
     ESO2Tempplot15,ESO2Tempplot16,
     ESO2Tempplot17,ESO2Tempplot18,
     EtrendSO2,ESO2Tempplot,
     file = "Graph/ETempoaral_plotSO2.Rda")

ENO2Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2009")
ENO2Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2010")
ENO2Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2011")
ENO2Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2012")
ENO2Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2013")
ENO2Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2014")
ENO2Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2015")
ENO2Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2016")
ENO2Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2017")
ENO2Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Ermelo in 2018")

ENO2Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NO2 temporal variation at Ermelo")


EtrendNO2 <- TheilSen(Ermelo_clean, pollutant = "no2",
                      ylab = "NO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "NO2 trends at Ermelo")

save(ENO2Tempplot09, ENO2Tempplot10,
     ENO2Tempplot11,ENO2Tempplot12,
     ENO2Tempplot13,ENO2Tempplot14,
     ENO2Tempplot15,ENO2Tempplot16,
     ENO2Tempplot17,ENO2Tempplot18,
     EtrendNO2,ENO2Tempplot,
     file = "Graph/ETempoaral_plotNO2.Rda")




# AMS Averages and exceedances --------------------------------------------

Ermelo_date <- Ermelo_clean %>%
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
  mutate(station = "Ermelo")

Ermelo_monthly_hour_ex <- novaAQM::compareAQS(df = Ermelo_date %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "hour",
                                                  by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

Ermelo_season_hour_ex <- novaAQM::compareAQS(df = Ermelo_date %>%
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
Ermelo_season_hour_ex <- Ermelo_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

Ermelo_annual_hour_ex <- novaAQM::compareAQS(df = Ermelo_date %>%
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

Ermelo_Daily <- timeAverage(Ermelo_clean, avg.time = "day") %>%
  mutate(station = all_of("Ermelo"))


Ermelo_Day  <- Ermelo_Daily %>%
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


Ermelo_month_daily_ex <- novaAQM::compareAQS(df = Ermelo_Day %>%
                                                   ungroup() %>%
                                                   datify() %>%
                                                   mutate(place = station,
                                                          instrument = "SAAQIS"),
                                                 period = "day",
                                                 by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



Ermelo_season_daily_ex <- novaAQM::compareAQS(df = Ermelo_Day %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "day",
                                                  by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))

Ermelo_season_daily_ex <- Ermelo_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




Ermelo_annual_daily_ex <- novaAQM::compareAQS(df = Ermelo_Day %>%
                                                    ungroup() %>%
                                                    datify() %>%
                                                    mutate(place = station,
                                                           instrument = "SAAQIS"),
                                                  period = "day",
                                                  by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(Ermelo_monthly_hour_ex, Ermelo_season_hour_ex, Ermelo_month_daily_ex, Ermelo_season_daily_ex,
     Ermelo_annual_daily_ex, Ermelo_annual_hour_ex,  file = "Graph/Ermelo_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

EBoxPM2.5Compare <- ggplot(data = Ermelo_Daily %>%
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
    title = "Annual statistical summary of PM2.5 at Ermelo") +
  theme(legend.position = "bottom")

EBoxPM2.5Compare


EBoxPM10Compare <- ggplot(data = Ermelo_Daily %>%
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
    title = "Annual statistical summary of PM10 at Ermelo") +
  theme(legend.position = "bottom")

EBoxPM10Compare

EBoxso2Compare <- ggplot(data = Ermelo_Daily %>%
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
    title = "Annual statistical summary of SO2 at Ermelo") +
  theme(legend.position = "bottom")

EBoxso2Compare

EBoxno2Compare <- ggplot(data = Ermelo_Daily %>%
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
    title = "Annual statistical summary of NO2 at Ermelo") +
  theme(legend.position = "bottom")

EBoxno2Compare



save(EBoxPM2.5Compare,
     EBoxPM10Compare,
     EBoxso2Compare,
     EBoxno2Compare,
     file = "Graph/EBox_plot.Rda")

# Correlation -------------------------------------------------------------


Ermelo_COR <- Ermelo_clean %>%
  select(pm2.5, pm10, so2, no2, ws, wd, relHum, temp, pressure)


Ermelo_hourlycor <- rcorr(as.matrix(Ermelo_COR), type = "pearson")
Ermelo_hourlycor.coeff = Ermelo_hourlycor$r
Ermelo_hourlycor.p = Ermelo_hourlycor$P
Ermelo_hourlycor.coeff

Ermelohourlycorplot <- corrplot.mixed(Ermelo_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Ermelo air pollutant correlation")



Ermelo09 <- Ermelo %>%
  filter(year(date) == "2009")

  # Dataframe should have a column name "date". It is mandatory for OpenAir
names(Ermelo)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Ermelo$date <- date


# Ermelo polar --------------------------------------------------------

Epolar <- Ermelo_clean %>%
  datify() %>%
  mutate(latitude = -26.493348,
         longitude = 29.968054)

# PM10 --------------------------------------------------------------------

EPM10allpolar <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

EPM10stdev <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM10",
  key.position = "right",
  key = TRUE
)

EPM10weighted <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM10",
  key.position = "right",
  key = TRUE
)


EPM10frequency <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


EPM10per50 <- polarPlot(
  Epolar,
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



EPM10per60 <- polarPlot(
  Epolar,
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


EPM10per70 <- polarPlot(
  Epolar,
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


EPM10per80 <- polarPlot(
  Epolar,
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


EPM10per90 <- polarPlot(
  Epolar,
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

EPM10per98 <- polarPlot(
  Epolar,
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


EPM10per99 <- polarPlot(
  Epolar,
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



EPM10_CPFplot = list(EPM10allpolar$plot,
                     EPM10stdev$plot,
                     EPM10frequency$plot,
                     EPM10weighted$plot,
                     EPM10per50$plot,
                     EPM10per60$plot,
                     EPM10per70$plot,
                     EPM10per80$plot,
                     EPM10per90$plot,
                     EPM10per98$plot,
                     EPM10per99$plot)

do.call("grid.arrange", EPM10_CPFplot)

# PM2.5 -------------------------------------------------------------------

EPM2.5allpolar <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

EPM2.5stdev <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM2.5",
  key.position = "right",
  key = TRUE
)


EPM2.5weighted <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM2.5",
  key.position = "right",
  key = TRUE
)

EPM2.5frequency <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

EPM2.5per50 <- polarPlot(
  Epolar,
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



EPM2.5per60 <- polarPlot(
  Epolar,
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


EPM2.5per70 <- polarPlot(
  Epolar,
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


EPM2.5per80 <- polarPlot(
  Epolar,
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


EPM2.5per90 <- polarPlot(
  Epolar,
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

EPM2.5per98 <- polarPlot(
  Epolar,
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

EPM2.5per99 <- polarPlot(
  Epolar,
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



EPM2.5_CPFplot = list(EPM2.5allpolar$plot,
                      EPM2.5stdev$plot,
                      EPM2.5frequency$plot,
                      EPM2.5weighted$plot,
                      EPM2.5per50$plot,
                      EPM2.5per60$plot,
                      EPM2.5per70$plot,
                      EPM2.5per80$plot,
                      EPM2.5per90$plot,
                      EPM2.5per98$plot,
                      EPM2.5per99$plot)

do.call("grid.arrange", EPM2.5_CPFplot)

# SO2 --------------------------------------------------------------------


ESO2allpolar <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

ESO2stdev <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of SO2",
  key.position = "right",
  key = TRUE
)

ESO2weighted <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean SO2",
  key.position = "right",
  key = TRUE
)


ESO2frequency <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


ESO2per50 <- polarPlot(
  Epolar,
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



ESO2per60 <- polarPlot(
  Epolar,
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


ESO2per70 <- polarPlot(
  Epolar,
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


ESO2per80 <- polarPlot(
  Epolar,
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


ESO2per90 <- polarPlot(
  Epolar,
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

ESO2per98 <- polarPlot(
  Epolar,
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


ESO2per99 <- polarPlot(
  Epolar,
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



ESO2_CPFplot = list(ESO2allpolar$plot,
                    ESO2stdev$plot,
                    ESO2frequency$plot,
                    ESO2weighted$plot,
                    ESO2per50$plot,
                    ESO2per60$plot,
                    ESO2per70$plot,
                    ESO2per80$plot,
                    ESO2per90$plot,
                    ESO2per98$plot,
                    ESO2per99$plot)

do.call("grid.arrange", ESO2_CPFplot)

# NO2 --------------------------------------------------------------------

ENO2allpolar <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

ENO2stdev <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO2",
  key.position = "right",
  key = TRUE
)

ENO2weighted <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO2",
  key.position = "right",
  key = TRUE
)


ENO2frequency <- polarPlot(
  Epolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


ENO2per50 <- polarPlot(
  Epolar,
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



ENO2per60 <- polarPlot(
  Epolar,
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


ENO2per70 <- polarPlot(
  Epolar,
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


ENO2per80 <- polarPlot(
  Epolar,
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



ENO2per90 <- polarPlot(
  Epolar,
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

ENO2per98 <- polarPlot(
  Epolar,
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


ENO2per99 <- polarPlot(
  Epolar,
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



ENO2_CPFplot = list(ENO2allpolar$plot,
                    ENO2stdev$plot,
                    ENO2frequency$plot,
                    ENO2weighted$plot,
                    ENO2per50$plot,
                    ENO2per60$plot,
                    ENO2per70$plot,
                    ENO2per80$plot,
                    ENO2per90$plot,
                    ENO2per98$plot,
                    ENO2per99$plot)

do.call("grid.arrange", ENO2_CPFplot)

