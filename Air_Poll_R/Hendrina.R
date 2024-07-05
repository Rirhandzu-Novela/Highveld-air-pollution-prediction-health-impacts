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

# Read dat files ----------------------------------------------------------

Hendrina = read.csv("Data/Hendrina.csv", header = T, sep = ";")

Hendrina <- Hendrina %>%
  rename(so2 = SO2,
         co = CO,
         no = NO,
         no2 = NO2,
         nox = NOx,
         pm10 = PM10,
         pm2.5 = PM2.5,
         o3 = O3,
         ws = Amb.Wspeed,
         wd = Amb.WDirection,
         temp = Temperature,
         relHum = Amb.RelHum,
         pressure = Amb.Pressure,
         rain = Rain,
         date = Date.Time)

# Dataframe should have a column name "date". It is mandatory for OpenAir
names(Hendrina)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
#date <- date[-length(date)]
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Hendrina$date <- date


summary(Hendrina)

Hendrina_clean <- Hendrina %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 800 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 300 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 400 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 100 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 250 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 300 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 150 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 4 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(pressure = case_when(pressure < 825 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 850 ~ NA, .default = pressure)) %>%
  mutate(nox = ifelse(year(date) == 2009 & nox > 250, NA, nox)) %>%
  mutate(nox = ifelse(year(date) ==  2010 & nox > 250, NA, nox)) %>%
  mutate(so2 = ifelse(year(date) == 2013 & so2 > 200, NA, so2)) %>%
  mutate(so2 = ifelse(year(date) == 2014 & so2 > 200, NA, so2)) %>%
  mutate(so2 = ifelse(year(date) == 2015 & so2 > 200, NA, so2))

Hendrina_clean$date <- format(Hendrina_clean$date, "%Y-%m-%d %H:%M:%S")

summary(Hendrina_clean)

HendrinaIM <- na_kalman(Hendrina_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(HendrinaIM)

usermodel <- arima(Hendrina_clean$temp, order = c(1, 0, 1))$model
HendrinaIMT <- na_kalman(Hendrina_clean$temp, model = usermodel)
HendrinaIM$temp <- HendrinaIMT


usermodel <- arima(Hendrina_clean$relHum, order = c(0, 0, 0))$model
HendrinaIMRH <- na_kalman(Hendrina_clean$relHum, model = usermodel)
HendrinaIM$relHum <- HendrinaIMRH

summary(HendrinaIM)


write_csv(HendrinaIM, file = "Data/HendrinaIM.csv")

# Time series -------------------------------------------------------------


plot_ly(data = Hendrina, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


HendrinaPTS <- timePlot(selectByDate(Hendrina_clean),
                      pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                      y.relation = "free")



HendrinaPTS  <- timePlot(selectByDate(Hendrina_clean),
                       pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                       y.relation = "free")


save(Hendrina, HendrinaMTS , file = "Data/Hendrina_Timeseriesplot.Rda")

PM2.5 <- timePlot(selectByDate(Hendrina_clean, year = 2013),
                  pollutant = "pm2.5")

Hendrina_clean <-Hendrina_clean %>%
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
EPM10Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="pm10", conf.int = c(0.75, 0.99),
                               col = "firebrick")

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


HNOTempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2009")
HNOTempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2010")
HNOTempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2011")
HNOTempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2012")
HNOTempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2013")
HNOTempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2014")
HNOTempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2015")
HNOTempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2016")
HNOTempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2017")
HNOTempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2018")

HNOTempplot <- timeVariation(Hendrina_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Hendrina")

HtrendNO <- TheilSen(Hendrina_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Hendrina")

save(HNOTempplot09, WNOTempplot10,
     HNOTempplot11,WNOTempplot12,
     HNOTempplot13,WNOTempplot14,
     HNOTempplot15,WNOTempplot16,
     HNOTempplot17,WNOTempplot18,
     HtrendNO,WNOTempplot,
     file = "Graph/HTempoaral_plotNO.Rda")

HNOXTempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2009")
HNOXTempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2010")
HNOXTempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2011")
HNOXTempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2012")
HNOXTempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2013")
HNOXTempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2014")
HNOXTempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2015")
HNOXTempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2016")
HNOXTempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2017")

HNOXTempplot <- timeVariation(Hendrina_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Hendrina")

HtrendNOX <- TheilSen(Hendrina_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Hendrina")

save(HNOXTempplot09, HNOXTempplot10,
     HNOXTempplot11,HNOXTempplot12,
     HNOXTempplot13,HNOXTempplot14,
     HNOXTempplot15,HNOXTempplot16,
     HNOXTempplot17,HNOXTempplot18,
     HtrendNOX,HNOXTempplot,
     file = "Graph/HTempoaral_plotNOX.Rda")

HCOTempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2009")
HCOTempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2010")
HCOTempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2011")
HCOTempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2012")
HCOTempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2013")
HCOTempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2014")
HCOTempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2015")
HCOTempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2016")
HCOTempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2017")
HCOTempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2018")

HCOTempplot <- timeVariation(Hendrina_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Hendrina")

HtrendCO <- TheilSen(Hendrina_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Hendrina")

save(HCOTempplot09, HCOTempplot10,
     HCOTempplot11,HCOTempplot12,
     HCOTempplot13,HCOTempplot14,
     HCOTempplot15,HCOTempplot16,
     HCOTempplot17,HCOTempplot18,
     HtrendCO,HCOTempplot,
     file = "Graph/HTempoaral_plotCO.Rda")

HO3Tempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2009")
HO3Tempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2010")
HO3Tempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2011")
HO3Tempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2012")
HO3Tempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2013")
HO3Tempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2014")
HO3Tempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2015")
HO3Tempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2016")
HO3Tempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2017")
HO3Tempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2018")
HO3Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Hendrina")

HtrendO3 <- TheilSen(Hendrina_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Hendrina")

save(HO3Tempplot09, HO3Tempplot10,
     HO3Tempplot11,HO3Tempplot12,
     HO3Tempplot13,HO3Tempplot14,
     HO3Tempplot15,HO3Tempplot16,
     HO3Tempplot17,HO3Tempplot18,
     HtrendO3,HO3Tempplot,
     file = "Graph/HTempoaral_plotO3.Rda")


# AMS Averages and exceedances --------------------------------------------

Hendrina_date <- Hendrina_clean %>%
  select(date, station, pm2.5, o3, co, no2, nox, no, so2, pm10) %>%
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
  ))

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
                             select(pm2.5, year) %>%
                             mutate(perc.obs = length(which(!is.na(pm2.5))) / n(), .by = year),
                           aes(x = year, y = pm2.5 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  geom_hline(yintercept = 40, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM2.5",
    title = "Annual statistical summary of PM2.5 at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

HBoxPM2.5Compare


HBoxPM10Compare <- ggplot(data = Hendrina_Daily %>%
                            datify() %>%
                            select(pm10, year) %>%
                            mutate(perc.obs = length(which(!is.na(pm10))) / n(), .by = year),
                          aes(x = year, y = pm10 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  geom_hline(yintercept = 75, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "PM10",
    title = "Annual statistical summary of PM10 at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 240)

HBoxPM10Compare

HBoxso2Compare <- ggplot(data = Hendrina_Daily %>%
                           datify() %>%
                           select(so2, year) %>%
                           mutate(perc.obs = length(which(!is.na(so2))) / n(), .by = year),
                         aes(x = year, y = so2 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  geom_hline(yintercept = 48, linetype = "dashed", color = "red") +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "SO2",
    title = "Annual statistical summary of SO2 at Hendrina",
    caption = "Data from AMS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

HBoxso2Compare

HBoxno2Compare <- ggplot(data = Hendrina_Daily %>%
                           datify() %>%
                           select(no2, year) %>%
                           mutate(perc.obs = length(which(!is.na(no2))) / n(), .by = year),
                         aes(x = year, y = no2 )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO2",
    title = "Annual statistical summary of NO2 at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 100)

HBoxno2Compare

HBoxnoCompare <- ggplot(data = Hendrina_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

HBoxnoCompare

HBoxnoxCompare <- ggplot(data = Hendrina_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

HBoxnoxCompare

HBoxo3Compare <- ggplot(data = Hendrina_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

HBoxnoCompare

HBoxcoCompare <- ggplot(data = Hendrina_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

HBoxcoCompare

save(HBoxPM2.5Compare,
     HBoxPM10Compare,
     HBoxso2Compare,
     HBoxno2Compare,
     HBoxnoCompare,
     HBoxcoCompare,
     HBoxnoxCompare,
     HBoxo3Compare,
     file = "Graph/HBox_plot.Rda")

# Correlation -------------------------------------------------------------


Hendrina_COR <- Hendrina_clean %>%
  select(pm2.5, pm10, so2, no2, nox, no, co, o3, ws, wd, relHum, temp, pressure, rain)


Hendrina_hourlycor <- rcorr(as.matrix(Hendrina_COR), type = "pearson")
Hendrina_hourlycor.coeff = Hendrina_hourlycor$r
Hendrina_hourlycor.p = Hendrina_hourlycor$P
Hendrina_hourlycor.coeff

Hendrinahourlycorplot <- corrplot.mixed(Hendrina_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Hendrina air pollutant correlation")


