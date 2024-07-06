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


Middelburg = read.csv("AirData/MiddelburgIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Middelburg$date <- dateTime

# Time series -------------------------------------------------------------


plot_ly(data = Middelburg, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


MiddelburgPTS <- timePlot(selectByDate(Middelburg),
                        pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                        y.relation = "free")



MiddelburgMTS  <- timePlot(selectByDate(Middelburg),
                         pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                         y.relation = "free")


save(MiddelburgPTS, MiddelburgMTS , file = "Graph/Middelburg_Timeseriesplot.Rda")


Middelburg_clean <-Middelburg %>%
  datify()

PM2.5 <- timePlot(selectByDate(Middelburg_clean, year = 2013),
                  pollutant = "pm2.5")

MPM10Tempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
MPM10Tempplot <- timeVariation(Middelburg_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                               col = "firebrick")

MtrendPM10 <- TheilSen(Middelburg_clean, pollutant = "pm10",
                       ylab = "PM10 (µg.m-3)",
                       deseason = TRUE)

save(MPM10Tempplot09, MPM10Tempplot10,
     MPM10Tempplot11,MPM10Tempplot12,
     MPM10Tempplot13,MPM10Tempplot14,
     MPM10Tempplot15,MPM10Tempplot16,
     MPM10Tempplot17,MPM10Tempplot18,
     MPM10Tempplot,MtrendPM10,
     file = "Graph/MTempoaral_plotPM10.Rda")

MPM2.5Tempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2009")
MPM2.5Tempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2010")
MPM2.5Tempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2011")
MPM2.5Tempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2012")
MPM2.5Tempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2013")
MPM2.5Tempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2014")
MPM2.5Tempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2015")
MPM2.5Tempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2016")
MPM2.5Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2017")
MPM2.5Tempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Middelburg in 2018")

MPM2.5Tempplot <- timeVariation(Middelburg_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "PM2.5 temporal variation at Middelburg")
MtrendPM2.5 <- TheilSen(Middelburg_clean, pollutant = "pm2.5",
                        ylab = "PM2.5 (µg.m-3)",
                        deseason = TRUE,
                        main = "PM2.5 trends at Middelburg")

save(MPM2.5Tempplot09, MPM2.5Tempplot10,
     MPM2.5Tempplot11,MPM2.5Tempplot12,
     MPM2.5Tempplot13,MPM2.5Tempplot14,
     MPM2.5Tempplot15,MPM2.5Tempplot16,
     MPM2.5Tempplot17,MPM2.5Tempplot18,
     MtrendPM2.5,MPM2.5Tempplot,
     file = "Graph/MTempoaral_plotPM2.5.Rda")

MSO2Tempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2009")
MSO2Tempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2010")
MSO2Tempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2011")
MSO2Tempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2012")
MSO2Tempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2013")
MSO2Tempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2014")
MSO2Tempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2015")
MSO2Tempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2016")
MSO2Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2017")
MSO2Tempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Middelburg in 2018")

MSO2Tempplot <- timeVariation(Middelburg_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "SO2 temporal variation at Middelburg")

MtrendSO2 <- TheilSen(Middelburg_clean, pollutant = "so2",
                      ylab = "SO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "SO2 trends at Middelburg")

save(MSO2Tempplot09, MSO2Tempplot10,
     MSO2Tempplot11,MSO2Tempplot12,
     MSO2Tempplot13,MSO2Tempplot14,
     MSO2Tempplot15,MSO2Tempplot16,
     MSO2Tempplot17,MSO2Tempplot18,
     MtrendSO2,MSO2Tempplot,
     file = "Graph/MTempoaral_plotSO2.Rda")

MNO2Tempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2009")
MNO2Tempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2010")
MNO2Tempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2011")
MNO2Tempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2012")
MNO2Tempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2013")
MNO2Tempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2014")
MNO2Tempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2015")
MNO2Tempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2016")
MNO2Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2017")
MNO2Tempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Middelburg in 2018")

MNO2Tempplot <- timeVariation(Middelburg_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NO2 temporal variation at Middelburg")


MtrendNO2 <- TheilSen(Middelburg_clean, pollutant = "no2",
                      ylab = "NO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "NO2 trends at Middelburg")

save(MNO2Tempplot09, MNO2Tempplot10,
     MNO2Tempplot11,MNO2Tempplot12,
     MNO2Tempplot13,MNO2Tempplot14,
     MNO2Tempplot15,MNO2Tempplot16,
     MNO2Tempplot17,MNO2Tempplot18,
     MtrendNO2,MNO2Tempplot,
     file = "Graph/MTempoaral_plotNO2.Rda")





# AMS Averages and exceedances --------------------------------------------

Middelburg_date <- Middelburg_clean %>%
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
  mutate(station = "Middelburg")

Middelburg_monthly_hour_ex <- novaAQM::compareAQS(df = Middelburg_date %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "hour",
                                              by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

Middelburg_season_hour_ex <- novaAQM::compareAQS(df = Middelburg_date %>%
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
Middelburg_season_hour_ex <- Middelburg_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

Middelburg_annual_hour_ex <- novaAQM::compareAQS(df = Middelburg_date %>%
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

Middelburg_Daily <- timeAverage(Middelburg_clean, avg.time = "day") %>%
  mutate(station = all_of("Middelburg"))


Middelburg_Day  <- Middelburg_Daily %>%
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


Middelburg_month_daily_ex <- novaAQM::compareAQS(df = Middelburg_Day %>%
                                               ungroup() %>%
                                               datify() %>%
                                               mutate(place = station,
                                                      instrument = "SAAQIS"),
                                             period = "day",
                                             by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



Middelburg_season_daily_ex <- novaAQM::compareAQS(df = Middelburg_Day %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "day",
                                              by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
Middelburg_season_daily_ex <- Middelburg_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




Middelburg_annual_daily_ex <- novaAQM::compareAQS(df = Middelburg_Day %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "day",
                                              by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(Middelburg_monthly_hour_ex, Middelburg_season_hour_ex, Middelburg_month_daily_ex, Middelburg_season_daily_ex,
     Middelburg_annual_daily_ex, Middelburg_annual_hour_ex,  file = "Graph/Middelburg_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

MBoxPM2.5Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of PM2.5 at Middelburg") +
  theme(legend.position = "bottom")

MBoxPM2.5Compare


MBoxPM10Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of PM10 at Middelburg") +
  theme(legend.position = "bottom")

MBoxPM10Compare

MBoxso2Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of SO2 at Middelburg") +
  theme(legend.position = "bottom")

MBoxso2Compare

MBoxno2Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of NO2 at Middelburg") +
  theme(legend.position = "bottom")

MBoxno2Compare



save(MBoxPM2.5Compare,
     MBoxPM10Compare,
     MBoxso2Compare,
     MBoxno2Compare,
     file = "Graph/MBox_plot.Rda")

# Correlation -------------------------------------------------------------


Middelburg_COR <- Middelburg_clean %>%
  select(pm2.5, pm10, so2, no2, ws, wd, relHum, temp, pressure)


Middelburg_hourlycor <- rcorr(as.matrix(Middelburg_COR), type = "pearson")
Middelburg_hourlycor.coeff = Middelburg_hourlycor$r
Middelburg_hourlycor.p = Middelburg_hourlycor$P
Middelburg_hourlycor.coeff

Middelburghourlycorplot <- corrplot.mixed(Middelburg_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Middelburg air pollutant correlation")

# Middelburg polar --------------------------------------------------------

Mpolar <- Middelburg_clean %>%
  datify() %>%
  mutate(latitude = -25.796056,
         longitude = 29.462823)

# PM10 --------------------------------------------------------------------

MPM10allpolar <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

MPM10stdev <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM10",
  key.position = "right",
  key = TRUE
)

MPM10weighted <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM10",
  key.position = "right",
  key = TRUE
)


MPM10frequency <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


MPM10per50 <- polarPlot(
  Mpolar,
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



MPM10per60 <- polarPlot(
  Mpolar,
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


MPM10per70 <- polarPlot(
  Mpolar,
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


MPM10per80 <- polarPlot(
  Mpolar,
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


MPM10per90 <- polarPlot(
  Mpolar,
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

MPM10per98 <- polarPlot(
  Mpolar,
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


MPM10per99 <- polarPlot(
  Mpolar,
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



MPM10_CPFplot = list(MPM10allpolar$plot,
                     MPM10stdev$plot,
                     MPM10frequency$plot,
                     MPM10weighted$plot,
                     MPM10per50$plot,
                     MPM10per60$plot,
                     MPM10per70$plot,
                     MPM10per80$plot,
                     MPM10per90$plot,
                     MPM10per98$plot,
                     MPM10per99$plot)

do.call("grid.arrange", MPM10_CPFplot)

# PM2.5 -------------------------------------------------------------------

MPM2.5allpolar <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

MPM2.5stdev <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM2.5",
  key.position = "right",
  key = TRUE
)


MPM2.5weighted <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM2.5",
  key.position = "right",
  key = TRUE
)

MPM2.5frequency <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

MPM2.5per50 <- polarPlot(
  Mpolar,
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



MPM2.5per60 <- polarPlot(
  Mpolar,
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


MPM2.5per70 <- polarPlot(
  Mpolar,
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


MPM2.5per80 <- polarPlot(
  Mpolar,
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


MPM2.5per90 <- polarPlot(
  Mpolar,
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

MPM2.5per98 <- polarPlot(
  Mpolar,
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

MPM2.5per99 <- polarPlot(
  Mpolar,
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



MPM2.5_CPFplot = list(MPM2.5allpolar$plot,
                      MPM2.5stdev$plot,
                      MPM2.5frequency$plot,
                      MPM2.5weighted$plot,
                      MPM2.5per50$plot,
                      MPM2.5per60$plot,
                      MPM2.5per70$plot,
                      MPM2.5per80$plot,
                      MPM2.5per90$plot,
                      MPM2.5per98$plot,
                      MPM2.5per99$plot)

do.call("grid.arrange", MPM2.5_CPFplot)

# SO2 --------------------------------------------------------------------


MSO2allpolar <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

MSO2stdev <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of SO2",
  key.position = "right",
  key = TRUE
)

MSO2weighted <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean SO2",
  key.position = "right",
  key = TRUE
)


MSO2frequency <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


MSO2per50 <- polarPlot(
  Mpolar,
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



MSO2per60 <- polarPlot(
  Mpolar,
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


MSO2per70 <- polarPlot(
  Mpolar,
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


MSO2per80 <- polarPlot(
  Mpolar,
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


MSO2per90 <- polarPlot(
  Mpolar,
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

MSO2per98 <- polarPlot(
  Mpolar,
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


MSO2per99 <- polarPlot(
  Mpolar,
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




MSO2_CPFplot = list(MSO2allpolar$plot,
                    MSO2stdev$plot,
                    MSO2frequency$plot,
                    MSO2weighted$plot,
                    MSO2per50$plot,
                    MSO2per60$plot,
                    MSO2per70$plot,
                    MSO2per80$plot,
                    MSO2per90$plot,
                    MSO2per98$plot,
                    MSO2per99$plot)

do.call("grid.arrange", MSO2_CPFplot)

# NO2 --------------------------------------------------------------------

MNO2allpolar <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

MNO2stdev <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO2",
  key.position = "right",
  key = TRUE
)

MNO2weighted <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO2",
  key.position = "right",
  key = TRUE
)


MNO2frequency <- polarPlot(
  Mpolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


MNO2per50 <- polarPlot(
  Mpolar,
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



MNO2per60 <- polarPlot(
  Mpolar,
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


MNO2per70 <- polarPlot(
  Mpolar,
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


MNO2per80 <- polarPlot(
  Mpolar,
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


MNO2per90 <- polarPlot(
  Mpolar,
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

MNO2per98 <- polarPlot(
  Mpolar,
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


MNO2per99 <- polarPlot(
  Mpolar,
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



MNO2_CPFplot = list(MNO2allpolar$plot,
                    MNO2stdev$plot,
                    MNO2frequency$plot,
                    MNO2weighted$plot,
                    MNO2per50$plot,
                    MNO2per60$plot,
                    MNO2per70$plot,
                    MNO2per80$plot,
                    MNO2per90$plot,
                    MNO2per98$plot,
                    MNO2per99$plot)

do.call("grid.arrange", MNO2_CPFplot)


