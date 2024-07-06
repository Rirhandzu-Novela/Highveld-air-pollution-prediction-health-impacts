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

Secunda = read.csv("AirData/SecundaIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Secunda$date <- dateTime

# Time series -------------------------------------------------------------


plot_ly(data = Secunda, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


SecundaPTS <- timePlot(selectByDate(Secunda),
                          pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                          y.relation = "free")



SecundaMTS  <- timePlot(selectByDate(Secunda),
                           pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                           y.relation = "free")


save(SecundaPTS, SecundaMTS , file = "Graph/Secunda_Timeseriesplot.Rda")

PM2.5 <- timePlot(selectByDate(Secunda, year = 2013),
                  pollutant = "pm2.5")

Secunda_clean <-Secunda %>%
  datify

SPM10Tempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                                 col = "firebrick")
SPM10Tempplot <- timeVariation(Secunda_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                               col = "firebrick")

StrendPM10 <- TheilSen(Secunda_clean, pollutant = "pm10",
                       ylab = "PM10 (µg.m-3)",
                       deseason = TRUE)

save(SPM10Tempplot09, SPM10Tempplot10,
     SPM10Tempplot11,SPM10Tempplot12,
     SPM10Tempplot13,SPM10Tempplot14,
     SPM10Tempplot15,SPM10Tempplot16,
     SPM10Tempplot17,SPM10Tempplot18,
     SPM10Tempplot,StrendPM10,
     file = "Graph/STempoaral_plotPM10.Rda")

SPM2.5Tempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2009")
SPM2.5Tempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2010")
SPM2.5Tempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2011")
SPM2.5Tempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2012")
SPM2.5Tempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2013")
SPM2.5Tempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2014")
SPM2.5Tempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2015")
SPM2.5Tempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2016")
SPM2.5Tempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2017")
SPM2.5Tempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                  col = "firebrick", main = "PM2.5 temporal variation at Secunda in 2018")

SPM2.5Tempplot <- timeVariation(Secunda_clean, stati="median", poll="pm2.5", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "PM2.5 temporal variation at Secunda")
StrendPM2.5 <- TheilSen(Secunda_clean, pollutant = "pm2.5",
                        ylab = "PM2.5 (µg.m-3)",
                        deseason = TRUE,
                        main = "PM2.5 trends at Secunda")

save(SPM2.5Tempplot09, SPM2.5Tempplot10,
     SPM2.5Tempplot11,SPM2.5Tempplot12,
     SPM2.5Tempplot13,SPM2.5Tempplot14,
     SPM2.5Tempplot15,SPM2.5Tempplot16,
     SPM2.5Tempplot17,SPM2.5Tempplot18,
     StrendPM2.5,SPM2.5Tempplot,
     file = "Graph/STempoaral_plotPM2.5.Rda")

SSO2Tempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2009")
SSO2Tempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2010")
SSO2Tempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2011")
SSO2Tempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2012")
SSO2Tempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2013")
SSO2Tempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2014")
SSO2Tempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2015")
SSO2Tempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2016")
SSO2Tempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2017")
SSO2Tempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "SO2 temporal variation at Secunda in 2018")

SSO2Tempplot <- timeVariation(Secunda_clean, stati="median", poll="so2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "SO2 temporal variation at Secunda")

StrendSO2 <- TheilSen(Secunda_clean, pollutant = "so2",
                      ylab = "SO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "SO2 trends at Secunda")

save(SSO2Tempplot09, SSO2Tempplot10,
     SSO2Tempplot11,SSO2Tempplot12,
     SSO2Tempplot13,SSO2Tempplot14,
     SSO2Tempplot15,SSO2Tempplot16,
     SSO2Tempplot17,SSO2Tempplot18,
     StrendSO2,SSO2Tempplot,
     file = "Graph/STempoaral_plotSO2.Rda")

SNO2Tempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2009")
SNO2Tempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2010")
SNO2Tempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2011")
SNO2Tempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2012")
SNO2Tempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2013")
SNO2Tempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2014")
SNO2Tempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2015")
SNO2Tempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2016")
SNO2Tempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2017")
SNO2Tempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="no2", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NO2 temporal variation at Secunda in 2018")

SNO2Tempplot <- timeVariation(Secunda_clean, stati="median", poll="no2", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NO2 temporal variation at Secunda")


StrendNO2 <- TheilSen(Secunda_clean, pollutant = "no2",
                      ylab = "NO2 (µg.m-3)",
                      deseason = TRUE,
                      main = "NO2 trends at Secunda")

save(SNO2Tempplot09, SNO2Tempplot10,
     SNO2Tempplot11,SNO2Tempplot12,
     SNO2Tempplot13,SNO2Tempplot14,
     SNO2Tempplot15,SNO2Tempplot16,
     SNO2Tempplot17,SNO2Tempplot18,
     StrendNO2,SNO2Tempplot,
     file = "Graph/STempoaral_plotNO2.Rda")





# AMS Averages and exceedances --------------------------------------------

Secunda_date <- Secunda_clean %>%
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
  mutate(station = "Secunda")

Secunda_monthly_hour_ex <- novaAQM::compareAQS(df = Secunda_date %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "hour",
                                              by_period = quos(month, year)) %>%
  ungroup() %>%
  arrange(pollutant, month) %>%
  relocate(pollutant, .after = place)

Secunda_season_hour_ex <- novaAQM::compareAQS(df = Secunda_date %>%
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
Secunda_season_hour_ex <- Secunda_season_hour_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)

Secunda_annual_hour_ex <- novaAQM::compareAQS(df = Secunda_date %>%
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

Secunda_Daily <- timeAverage(Secunda_clean, avg.time = "day") %>%
  mutate(station = all_of("Secunda"))


Secunda_Day  <- Secunda_Daily %>%
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
  )) %>%
  mutate(station = "Secunda")


Secunda_month_daily_ex <- novaAQM::compareAQS(df = Secunda_Day %>%
                                               ungroup() %>%
                                               datify() %>%
                                               mutate(place = station,
                                                      instrument = "SAAQIS"),
                                             period = "day",
                                             by_period = quos(month, year)) %>%
  #ungroup() %>%
  arrange(pollutant, month)



Secunda_season_daily_ex <- novaAQM::compareAQS(df = Secunda_Day %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "day",
                                              by_period = quos(year, season)) %>%
  #ungroup() %>%
  arrange(pollutant, season)
season_order = tibble(season = c("autum", "winter", "spring", "summer"), season_nr = c(1, 2, 3, 4))
Secunda_season_daily_ex <- Secunda_season_daily_ex %>% left_join(season_order) %>% arrange(pollutant, season_nr)




Secunda_annual_daily_ex <- novaAQM::compareAQS(df = Secunda_Day %>%
                                                ungroup() %>%
                                                datify() %>%
                                                mutate(place = station,
                                                       instrument = "SAAQIS"),
                                              period = "day",
                                              by_period = quos(year)) %>%
  #ungroup() %>%
  arrange(pollutant, year)

save(Secunda_monthly_hour_ex, Secunda_season_hour_ex, Secunda_month_daily_ex, Secunda_season_daily_ex,
     Secunda_annual_daily_ex, Secunda_annual_hour_ex,  file = "Graph/Secunda_Exceedances.Rda")

# Box plots ---------------------------------------------------------------

SBoxPM2.5Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of PM2.5 at Secunda") +
  theme(legend.position = "bottom")

SBoxPM2.5Compare


SBoxPM10Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of PM10 at Secunda") +
  theme(legend.position = "bottom")

SBoxPM10Compare

SBoxso2Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of SO2 at Secunda") +
  theme(legend.position = "bottom")

SBoxso2Compare

SBoxno2Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of NO2 at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")

SBoxno2Compare



save(SBoxPM2.5Compare,
     SBoxPM10Compare,
     SBoxso2Compare,
     SBoxno2Compare,
     file = "Graph/SBox_plot.Rda")

# Correlation -------------------------------------------------------------


Secunda_COR <- Secunda_clean %>%
  select(pm2.5, pm10, so2, no2, ws, wd, relHum, temp, pressure)


Secunda_hourlycor <- rcorr(as.matrix(Secunda_COR), type = "pearson")
Secunda_hourlycor.coeff = Secunda_hourlycor$r
Secunda_hourlycor.p = Secunda_hourlycor$P
Secunda_hourlycor.coeff

Secundahourlycorplot <- corrplot.mixed(Secunda_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Secunda air pollutant correlation")


# Secunda polar --------------------------------------------------------

Spolar <- Secunda_clean %>%
  datify() %>%
  mutate(latitude = -26.550639,
         longitude = 29.079028)

# PM10 --------------------------------------------------------------------

SPM10allpolar <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

SPM10stdev <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM10",
  key.position = "right",
  key = TRUE
)

SPM10weighted <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM10",
  key.position = "right",
  key = TRUE
)


SPM10frequency <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


SPM10per50 <- polarPlot(
  Spolar,
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



SPM10per60 <- polarPlot(
  Spolar,
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


SPM10per70 <- polarPlot(
  Spolar,
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


SPM10per80 <- polarPlot(
  Spolar,
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


SPM10per90 <- polarPlot(
  Spolar,
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

SPM10per98 <- polarPlot(
  Spolar,
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



SPM10per99 <- polarPlot(
  Spolar,
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



SPM10_CPFplot = list(SPM10allpolar$plot,
                     SPM10stdev$plot,
                     SPM10frequency$plot,
                     SPM10weighted$plot,
                     SPM10per50$plot,
                     SPM10per60$plot,
                     SPM10per70$plot,
                     SPM10per80$plot,
                     SPM10per90$plot,
                     SPM10per98$plot,
                     SPM10per99$plot)

do.call("grid.arrange", SPM10_CPFplot)

# PM2.5 -------------------------------------------------------------------

SPM2.5allpolar <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

SPM2.5stdev <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of PM2.5",
  key.position = "right",
  key = TRUE
)


SPM2.5weighted <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean PM2.5",
  key.position = "right",
  key = TRUE
)

SPM2.5frequency <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

SPM2.5per50 <- polarPlot(
  Spolar,
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



SPM2.5per60 <- polarPlot(
  Spolar,
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


SPM2.5per70 <- polarPlot(
  Spolar,
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


SPM2.5per80 <- polarPlot(
  Spolar,
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


SPM2.5per90 <- polarPlot(
  Spolar,
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

SPM2.5per98 <- polarPlot(
  Spolar,
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

SPM2.5per99 <- polarPlot(
  Spolar,
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



SPM2.5_CPFplot = list(SPM2.5allpolar$plot,
                      SPM2.5stdev$plot,
                      SPM2.5frequency$plot,
                      SPM2.5weighted$plot,
                      SPM2.5per50$plot,
                      SPM2.5per60$plot,
                      SPM2.5per70$plot,
                      SPM2.5per80$plot,
                      SPM2.5per90$plot,
                      SPM2.5per98$plot,
                      SPM2.5per99$plot)


do.call("grid.arrange", SPM2.5_CPFplot)

# SO2 --------------------------------------------------------------------


SSO2allpolar <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

SSO2stdev <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of SO2",
  key.position = "right",
  key = TRUE
)

SSO2weighted <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean SO2",
  key.position = "right",
  key = TRUE
)


SSO2frequency <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


SSO2per50 <- polarPlot(
  Spolar,
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



SSO2per60 <- polarPlot(
  Spolar,
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


SSO2per70 <- polarPlot(
  Spolar,
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


SSO2per80 <- polarPlot(
  Spolar,
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


SSO2per90 <- polarPlot(
  Spolar,
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

SSO2per98 <- polarPlot(
  Spolar,
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


SSO2per99 <- polarPlot(
  Spolar,
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



SSO2_CPFplot = list(SSO2allpolar$plot,
                    SSO2stdev$plot,
                    SSO2frequency$plot,
                    SSO2weighted$plot,
                    SSO2per50$plot,
                    SSO2per60$plot,
                    SSO2per70$plot,
                    SSO2per80$plot,
                    SSO2per90$plot,
                    SSO2per98$plot,
                    SSO2per99$plot)

do.call("grid.arrange", SSO2_CPFplot)

# NO2 --------------------------------------------------------------------

SNO2allpolar <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

SNO2stdev <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO2",
  key.position = "right",
  key = TRUE
)

SNO2weighted <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO2",
  key.position = "right",
  key = TRUE
)


SNO2frequency <- polarPlot(
  Spolar,
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


SNO2per50 <- polarPlot(
  Spolar,
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



SNO2per60 <- polarPlot(
  Spolar,
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


SNO2per70 <- polarPlot(
  Spolar,
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


SNO2per80 <- polarPlot(
  Spolar,
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


SNO2per90 <- polarPlot(
  Spolar,
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

SNO2per98 <- polarPlot(
  Spolar,
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


SNO2per99 <- polarPlot(
  Spolar,
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



SNO2_CPFplot = list(SNO2allpolar$plot,
                    SNO2stdev$plot,
                    SNO2frequency$plot,
                    SNO2weighted$plot,
                    SNO2per50$plot,
                    SNO2per60$plot,
                    SNO2per70$plot,
                    SNO2per80$plot,
                    SNO2per90$plot,
                    SNO2per98$plot,
                    SNO2per99$plot)

do.call("grid.arrange", SNO2_CPFplot)



# Temperature -------------------------------------------------------------


STempplot09 <- trendLevel(Spolar %>% filter(year == "2009"), pollutant = "temp")
STempplot10 <- trendLevel(Spolar %>% filter(year == "2010"), pollutant = "temp")
STempplot11 <- trendLevel(Spolar %>% filter(year == "2011"), pollutant = "temp")
STempplot12 <- trendLevel(Spolar %>% filter(year == "2012"), pollutant = "temp")
STempplot13 <- trendLevel(Spolar %>% filter(year == "2013"), pollutant = "temp")
STempplot14 <- trendLevel(Spolar %>% filter(year == "2014"), pollutant = "temp")
STempplot15 <- trendLevel(Spolar %>% filter(year == "2015"), pollutant = "temp")
STempplot16 <- trendLevel(Spolar %>% filter(year == "2016"), pollutant = "temp")
STempplot17 <- trendLevel(Spolar %>% filter(year == "2017"), pollutant = "temp")
STempplot17 <- trendLevel(Spolar %>% filter(year == "2017"), pollutant = "temp")
STempplot18 <- trendLevel(Spolar %>% filter(year == "2018"), pollutant = "temp")
STempplot <- trendLevel(Spolar, pollutant = "temp")

save(STempplot09, STempplot10,
     STempplot11,STempplot12,
     STempplot13,STempplot14,
     STempplot15,STempplot16,
     STempplot17,STempplot18,
     STempplot,
     file = "Graph/STemp_plot.Rda")