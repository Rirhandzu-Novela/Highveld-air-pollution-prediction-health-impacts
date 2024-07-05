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

Middelburg = read.csv("Data/Middelburg.csv", header = T, sep = ";")

Middelburg <- Middelburg %>%
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
names(Middelburg)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
# date <- date[-length(date)]
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Middelburg$date <- date



summary(Middelburg)

Middelburg_clean <- Middelburg %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 600 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 300 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 200 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 60 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 300 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 300 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 150 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 4 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(pressure = case_when(pressure < 840 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 870 ~ NA, .default = pressure)) %>%
  mutate(no = ifelse(year(date) == 2010 & no > 150, NA, no)) %>%
  mutate(nox = ifelse(year(date) ==  2011 & nox > 100, NA, nox)) %>%
  mutate(so2 = ifelse(year(date) == 2012 & so2 > 80, NA, so2)) %>%
  mutate(so2 = ifelse(year(date) == 2014 & so2 > 150, NA, so2)) %>%
  mutate(pm10 = ifelse(year(date) == 2014 & pm10 > 300, NA, pm10)) %>%
  mutate(pm10 = ifelse(year(date) == 2016 & pm10 > 300, NA, pm10)) %>%
  mutate(o3 = case_when(between(date, as_datetime("2013-06-01 00:00:00"), as_datetime("2013-06-30 23:00:00")) ~ NA, .default = o3)) %>%
  mutate(o3 = case_when(between(date, as_datetime("2012-06-01 00:00:00"), as_datetime("2012-06-30 23:00:00")) ~ NA, .default = o3)) %>%
  mutate(o3 = case_when(between(date, as_datetime("2013-04-01 00:00:00"), as_datetime("2013-04-30 23:00:00")) ~ NA, .default = o3))

Middelburg_clean$date <- format(Middelburg_clean$date, "%Y-%m-%d %H:%M:%S")

summary(Middelburg_clean)

MiddelburgIM <- na_kalman(Middelburg_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(MiddelburgIM)

usermodel <- arima(Middelburg_clean$temp, order = c(1, 0, 1))$model
MiddelburgIMT <- na_kalman(Middelburg_clean$temp, model = usermodel)
MiddelburgIM$temp <- MiddelburgIMT


usermodel <- arima(Middelburg_clean$relHum, order = c(0, 0, 0))$model
MiddelburgIMRH <- na_kalman(Middelburg_clean$relHum, model = usermodel)
MiddelburgIM$relHum <- MiddelburgIMRH

summary(MiddelburgIM)

write_csv(MiddelburgIM, file = "Data/MiddelburgIM.csv")


# Time series -------------------------------------------------------------


plot_ly(data = Middelburg, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


MiddelburgPTS <- timePlot(selectByDate(Middelburg_clean),
                        pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                        y.relation = "free")



MiddelburgPTS  <- timePlot(selectByDate(Middelburg_clean),
                         pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                         y.relation = "free")


save(Middelburg, MiddelburgMTS , file = "Data/Middelburg_Timeseriesplot.Rda")


Middelburg_clean <-Middelburg_clean %>%
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
WSO2Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="so2", conf.int = c(0.75, 0.99),
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


MNOTempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2009")
MNOTempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2010")
MNOTempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2011")
MNOTempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2012")
MNOTempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2013")
MNOTempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2014")
MNOTempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2015")
MNOTempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2016")
MNOTempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2017")
WNOTempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2018")

MNOTempplot <- timeVariation(Middelburg_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Middelburg")

MtrendNO <- TheilSen(Middelburg_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Middelburg")

save(MNOTempplot09, MNOTempplot10,
     MNOTempplot11,MNOTempplot12,
     MNOTempplot13,MNOTempplot14,
     MNOTempplot15,MNOTempplot16,
     MNOTempplot17,MNOTempplot18,
     MtrendNO,MNOTempplot,
     file = "Graph/MTempoaral_plotNO.Rda")

MNOXTempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2009")
MNOXTempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2010")
MNOXTempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2011")
MNOXTempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2012")
MNOXTempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2013")
MNOXTempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2014")
MNOXTempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2015")
MNOXTempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2016")
MNOXTempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2017")

MNOXTempplot <- timeVariation(Middelburg_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Middelburg")

MtrendNOX <- TheilSen(Middelburg_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Middelburg")

save(MNOXTempplot09, MNOXTempplot10,
     MNOXTempplot11,MNOXTempplot12,
     MNOXTempplot13,MNOXTempplot14,
     MNOXTempplot15,MNOXTempplot16,
     MNOXTempplot17,MNOXTempplot18,
     MtrendNOX,MNOXTempplot,
     file = "Graph/MTempoaral_plotNOX.Rda")

MCOTempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2009")
MCOTempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2010")
MCOTempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2011")
MCOTempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2012")
MCOTempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2013")
MCOTempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2014")
MCOTempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2015")
MCOTempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2016")
MCOTempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2017")
WCOTempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2018")

MCOTempplot <- timeVariation(Middelburg_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Middelburg")

MtrendCO <- TheilSen(Middelburg_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Middelburg")

save(MCOTempplot09, MCOTempplot10,
     MCOTempplot11,MCOTempplot12,
     MCOTempplot13,MCOTempplot14,
     MCOTempplot15,MCOTempplot16,
     MCOTempplot17,MCOTempplot18,
     MtrendCO,MCOTempplot,
     file = "Graph/MTempoaral_plotCO.Rda")

MO3Tempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2009")
MO3Tempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2010")
MO3Tempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2011")
MO3Tempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2012")
MO3Tempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2013")
MO3Tempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2014")
MO3Tempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2015")
MO3Tempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2016")
MO3Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2017")
MO3Tempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2018")
MO3Tempplot <- timeVariation(Middelburg_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Middelburg")

MtrendO3 <- TheilSen(Middelburg_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Middelburg")

save(MO3Tempplot09, MO3Tempplot10,
     MO3Tempplot11,MO3Tempplot12,
     MO3Tempplot13,MO3Tempplot14,
     MO3Tempplot15,MO3Tempplot16,
     MO3Tempplot17,MO3Tempplot18,
     MtrendO3,MO3Tempplot,
     file = "Graph/MTempoaral_plotO3.Rda")


# AMS Averages and exceedances --------------------------------------------

Middelburg_date <- Middelburg_clean %>%
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
    title = "Annual statistical summary of PM2.5 at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

MBoxPM2.5Compare


MBoxPM10Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of PM10 at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 240)

MBoxPM10Compare

MBoxso2Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of SO2 at Middelburg",
    caption = "Data from AMS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

MBoxso2Compare

MBoxno2Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of NO2 at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 100)

MBoxno2Compare

MBoxnoCompare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of NO at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

MBoxnoCompare

MBoxnoxCompare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of NOX at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

MBoxnoxCompare

MBoxo3Compare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of O3 at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

MBoxnoCompare

MBoxcoCompare <- ggplot(data = Middelburg_Daily %>%
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
    title = "Annual statistical summary of CO at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

MBoxcoCompare

save(MBoxPM2.5Compare,
     MBoxPM10Compare,
     MBoxso2Compare,
     MBoxno2Compare,
     MBoxnoCompare,
     MBoxcoCompare,
     MBoxnoxCompare,
     MBoxo3Compare,
     file = "Graph/MBox_plot.Rda")

# Correlation -------------------------------------------------------------


Middelburg_COR <- Middelburg_clean %>%
  select(pm2.5, pm10, so2, no2, nox, no, co, o3, ws, wd, relHum, temp, pressure, rain)


Middelburg_hourlycor <- rcorr(as.matrix(Middelburg_COR), type = "pearson")
Middelburg_hourlycor.coeff = Middelburg_hourlycor$r
Middelburg_hourlycor.p = Middelburg_hourlycor$P
Middelburg_hourlycor.coeff

Middelburghourlycorplot <- corrplot.mixed(Middelburg_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Middelburg air pollutant correlation")


