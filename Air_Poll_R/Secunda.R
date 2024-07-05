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

Secunda = read.csv("Data/Secunda.csv", header = T, sep = ";")

Secunda <- Secunda %>%
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
names(Secunda)[1] <- 'date'

# The dates must be a "POSIXct" "POSIXt" object.
date <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')
# date <- date[-length(date)]
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
Secunda$date <- date


summary(Secunda)

Secunda_clean <- Secunda %>%
  mutate(across(-date, ~ if_else(. <= 0 | is.infinite(.), NA_real_, .))) %>%
  mutate(pm10 = case_when(pm10 > 2000 ~ NA, .default = pm10)) %>%
  mutate(pm2.5 = case_when(pm2.5 > 800 ~ NA, .default = pm2.5)) %>%
  mutate(so2 = case_when(so2 > 150 ~ NA, .default = so2)) %>%
  mutate(no2 = case_when(no2 > 200 ~ NA, .default = no2)) %>%
  mutate(no = case_when(no > 300 ~ NA, .default = no)) %>%
  mutate(nox = case_when(nox > 300 ~ NA, .default = nox)) %>%
  mutate(o3 = case_when(o3 > 250 ~ NA, .default = o3)) %>%
  mutate(co = case_when(co > 20 ~ NA, .default = co)) %>%
  mutate(ws = case_when(ws > 15 ~ NA, .default = ws)) %>%
  mutate(temp = case_when(temp > 37 ~ NA, .default = temp)) %>%
  mutate(pressure = case_when(pressure < 830 ~ NA, .default = pressure)) %>%
  mutate(pressure = case_when(pressure > 870 ~ NA, .default = pressure)) %>%
  mutate(pm10 = ifelse(year(date) == 2015 & pm10 > 300, NA, pm10)) %>%
  mutate(co = case_when(between(date, as_datetime("2012-04-01 00:00:00"), as_datetime("2012-07-31 23:00:00")) ~ NA, .default = co)) %>%
  mutate(co = ifelse(year(date) == 2017 & co > 10, NA, co)) %>%
  mutate(no2 = ifelse(year(date) ==  2011 & no2 > 100, NA, no2)) %>%
  mutate(nox = ifelse(year(date) == 2011 & nox > 200, NA, nox)) %>%
  mutate(temp = case_when(between(date, as_datetime("2012-04-10 00:00:00"), as_datetime("2012-06-30 23:00:00")) ~ NA, .default = temp)) %>%
  mutate(temp = case_when(between(date, as_datetime("2013-08-15 00:00:00"), as_datetime("2013-09-30 23:00:00")) ~ NA, .default = temp))


Secunda_clean$date <- format(Secunda_clean$date, "%Y-%m-%d %H:%M:%S")

SecundaIM <- na_kalman(Secunda_clean, model = "StructTS", smooth = TRUE, type = "trend")
summary(SecundaIM)

usermodel <- arima(Secunda_clean$temp, order = c(1, 0, 1))$model
SecundaIMT <- na_kalman(Secunda_clean$temp, model = usermodel)
SecundaIM$temp <- SecundaIMT


usermodel <- arima(Secunda_clean$relHum, order = c(0, 0, 0))$model
SecundaIMRH <- na_kalman(Secunda_clean$relHum, model = usermodel)
SecundaIM$relHum <- SecundaIMRH

write_csv(SecundaIM, file = "Data/SecundaIM.csv")

# Time series -------------------------------------------------------------


plot_ly(data = Secunda, x = ~date, y = ~pm2.5, type = 'scatter', mode = 'lines+markers',
        marker = list(color = 'blue'), line = list(color = 'blue')) %>%
  layout(title = 'PM2.5 Levels Over Time',
         xaxis = list(title = 'Date'),
         yaxis = list(title = 'PM2.5'))


SecundaPTS <- timePlot(selectByDate(Secunda_clean),
                          pollutant = c("pm2.5", "pm10", "co", "no", "no2", "nox", "so2"),
                          y.relation = "free")



SecundaPTS  <- timePlot(selectByDate(Secunda_clean),
                           pollutant = c("ws", "wd", "temp", "relHum", "pressure"),
                           y.relation = "free")


save(Secunda, SecundaMTS , file = "Data/Secunda_Timeseriesplot.Rda")

PM2.5 <- timePlot(selectByDate(Secunda_clean, year = 2013),
                  pollutant = "pm2.5")

Secunda_clean <-Secunda_clean %>%
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


SNOTempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2009")
SNOTempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2010")
SNOTempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2011")
SNOTempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2012")
SNOTempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2013")
SNOTempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2014")
SNOTempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2015")
SNOTempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2016")
SNOTempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2017")
SNOTempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2018")

SNOTempplot <- timeVariation(Secunda_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Secunda")

StrendNO <- TheilSen(Secunda_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Secunda")

save(SNOTempplot09, SNOTempplot10,
     SNOTempplot11,SNOTempplot12,
     SNOTempplot13,SNOTempplot14,
     SNOTempplot15,SNOTempplot16,
     SNOTempplot17,SNOTempplot18,
     StrendNO,SNOTempplot,
     file = "Graph/STempoaral_plotNO.Rda")

SNOXTempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2009")
SNOXTempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2010")
SNOXTempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2011")
SNOXTempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2012")
SNOXTempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2013")
SNOXTempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2014")
SNOXTempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2015")
SNOXTempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2016")
SNOXTempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2017")

SNOXTempplot <- timeVariation(Secunda_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Secunda")

StrendNOX <- TheilSen(Secunda_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Secunda")

save(SNOXTempplot09, SNOXTempplot10,
     SNOXTempplot11,SNOXTempplot12,
     SNOXTempplot13,SNOXTempplot14,
     SNOXTempplot15,SNOXTempplot16,
     SNOXTempplot17,SNOXTempplot18,
     StrendNOX,SNOXTempplot,
     file = "Graph/STempoaral_plotNOX.Rda")

SCOTempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2009")
SCOTempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2010")
SCOTempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2011")
SCOTempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2012")
SCOTempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2013")
SCOTempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2014")
SCOTempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2015")
SCOTempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2016")
SCOTempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2017")
SCOTempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2018")

SCOTempplot <- timeVariation(Secunda_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Secunda")

StrendCO <- TheilSen(Secunda_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Secunda")

save(SCOTempplot09, SCOTempplot10,
     SCOTempplot11,SCOTempplot12,
     SCOTempplot13,SCOTempplot14,
     SCOTempplot15,SCOTempplot16,
     SCOTempplot17,SCOTempplot18,
     StrendCO,SCOTempplot,
     file = "Graph/STempoaral_plotCO.Rda")

SO3Tempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2009")
SO3Tempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2010")
SO3Tempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2011")
SO3Tempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2012")
SO3Tempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2013")
SO3Tempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2014")
SO3Tempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2015")
SO3Tempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2016")
SO3Tempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2017")
SO3Tempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2018")
SO3Tempplot <- timeVariation(Secunda_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Secunda")

StrendO3 <- TheilSen(Secunda_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Secunda")

save(SO3Tempplot09, SO3Tempplot10,
     SO3Tempplot11,SO3Tempplot12,
     SO3Tempplot13,SO3Tempplot14,
     SO3Tempplot15,SO3Tempplot16,
     SO3Tempplot17,SO3Tempplot18,
     StrendO3,SO3Tempplot,
     file = "Graph/STempoaral_plotO3.Rda")


# AMS Averages and exceedances --------------------------------------------

Secunda_date <- Secunda_clean %>%
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
  ))


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
    title = "Annual statistical summary of PM2.5 at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

SBoxPM2.5Compare


SBoxPM10Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of PM10 at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 240)

SBoxPM10Compare

SBoxso2Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of SO2 at Secunda",
    caption = "Data from AMS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

SBoxso2Compare

SBoxno2Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of NO2 at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 100)

SBoxno2Compare

SBoxnoCompare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of NO at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

SBoxnoCompare

SBoxnoxCompare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of NOX at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

SBoxnoxCompare

SBoxo3Compare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of O3 at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

SBoxnoCompare

SBoxcoCompare <- ggplot(data = Secunda_Daily %>%
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
    title = "Annual statistical summary of CO at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

SBoxcoCompare

save(SBoxPM2.5Compare,
     SBoxPM10Compare,
     SBoxso2Compare,
     SBoxno2Compare,
     SBoxnoCompare,
     SBoxcoCompare,
     SBoxnoxCompare,
     SBoxo3Compare,
     file = "Graph/SBox_plot.Rda")

# Correlation -------------------------------------------------------------


Secunda_COR <- Secunda_clean %>%
  select(pm2.5, pm10, so2, no2, nox, no, co, o3, ws, wd, relHum, temp, pressure, rain)


Secunda_hourlycor <- rcorr(as.matrix(Secunda_COR), type = "pearson")
Secunda_hourlycor.coeff = Secunda_hourlycor$r
Secunda_hourlycor.p = Secunda_hourlycor$P
Secunda_hourlycor.coeff

Secundahourlycorplot <- corrplot.mixed(Secunda_hourlycor.coeff, mar = c(0,0,1,0), lower = 'number', upper = 'ellipse', title = "Secunda air pollutant correlation")


