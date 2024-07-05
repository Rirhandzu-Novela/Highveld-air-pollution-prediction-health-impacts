# Load packages -----------------------------------------------------------

library(tidyverse)
library(openair)
library(novaAQM)
library(openairmaps)
library(broom)
library(gridExtra)


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
 Wpolarv %>% filter(year == "2009"),
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


# NO --------------------------------------------------------------------

WNOallpolar <- polarMap(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

WNOstdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

WNOweighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


WNOfrequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

WNOper50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



WNOper60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WNOper70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WNOper80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WNOper90 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WNOper98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WNOper99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



WNO_CPFplot = list(WNOallpolar$plot,
                   WNOstdev$plot,
                   WNOfrequency$plot,
                   WNOweighted$plot,
                   WNOper50$plot,
                   WNOper60$plot,
                   WNOper70$plot,
                   WNOper80$plot,
                   WNOper90$plot,
                   WNOper98$plot,
                   WNOper99$plot)

do.call("grid.arrange", WNO_CPFplot)

# CO --------------------------------------------------------------------

WCOallpolar <- polarMap(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

WCOstdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


WCOweighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


WCOfrequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



WCOper50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



WCOper60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WCOper70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WCOper80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WCOper90 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WCOper98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WCOper99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



WCO_CPFplot = list(WCOallpolar$plot,
                   WCOstdev$plot,
                   WCOfrequency$plot,
                   WCOweighted$plot,
                   WCOper50$plot,
                   WCOper60$plot,
                   WCOper70$plot,
                   WCOper80$plot,
                   WCOper90$plot,
                   WCOper98$plot,
                   WCOper99$plot)

do.call("grid.arrange", WCO_CPFplot)


# NOX --------------------------------------------------------------------

WNOXallpolar <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

WNOXstdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

WNOXweighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


WNOXfrequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


WNOXper50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



WNOXper60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WNOXper70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WNOXper80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WNOXper90 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WNOXper98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WNOXper99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



WNOX_CPFplot = list(WNOXallpolar$plot,
                    WNOXstdev$plot,
                    WNOXfrequency$plot,
                    WNOXweighted$plot,
                    WNOXper50$plot,
                    WNOXper60$plot,
                    WNOXper70$plot,
                    WNOXper80$plot,
                    WNOXper90$plot,
                    WNOXper98$plot,
                    WNOXper99$plot)

do.call("grid.arrange", WNOX_CPFplot)



# O3 ----------------------------------------------------------------------

WO3allpolar <- polarMap(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

WO3stdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


WO3weighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

WO3frequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



WO3per50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



WO3per60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WO3per70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

WO3per80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

WO3per80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

WO3per80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



WO3per98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WO3per99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

WO3_polarplot = list(WO3allpolar$plot,
                     WO3stdev$plot,
                     WO3weighted$plot,
                     WO3frequency$plot,
                     WO3per50$plot,
                     WO3per60$plot,
                     WO3per70$plot,
                     WO3per80$plot,
                     WO3per90$plot,
                     WO3per98$plot,
                     WO3per99$plot)
do.call("grid.arrange", WO3_polarplot)


# Ermelo polar --------------------------------------------------------

Epolar <- Ermelo_clean %>%
  datify() %>%
  mutate(latitude = -26,493348,
         longitude = 29,968054)

# PM10 --------------------------------------------------------------------

EPM10allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

EPM10stdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
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
  Epolarv %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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

EPM2.5allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

EPM2.5stdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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


ESO2allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

ESO2stdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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

ENO2allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

ENO2stdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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


# NO --------------------------------------------------------------------

ENOallpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

ENOstdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

ENOweighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


ENOfrequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

ENOper50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



ENOper60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


ENOper70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


ENOper80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


ENOper90 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

ENOper98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

ENOper99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



ENO_CPFplot = list(ENOallpolar$plot,
                   ENOstdev$plot,
                   ENOfrequency$plot,
                   ENOweighted$plot,
                    ENOper50$plot,
                    ENOper60$plot,
                    ENOper70$plot,
                    ENOper80$plot,
                    ENOper90$plot,
                   ENOper98$plot,
                    ENOper99$plot)

do.call("grid.arrange", ENO_CPFplot)

# CO --------------------------------------------------------------------

ECOallpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

ECOstdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


ECOweighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


ECOfrequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



ECOper50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



ECOper60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


ECOper70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


ECOper80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


ECOper90 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

ECOper98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

ECOper99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



ECO_CPFplot = list(ECOallpolar$plot,
                   ECOstdev$plot,
                   ECOfrequency$plot,
                   ECOweighted$plot,
                   ECOper50$plot,
                   ECOper60$plot,
                   ECOper70$plot,
                   ECOper80$plot,
                   ECOper90$plot,
                   ECOper98$plot,
                   ECOper99$plot)

do.call("grid.arrange", ECO_CPFplot)


# NOX --------------------------------------------------------------------

ENOXallpolar <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

ENOXstdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

ENOXweighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


ENOXfrequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


ENOXper50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



ENOXper60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


ENOXper70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


ENOXper80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


ENOXper90 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

ENOXper98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

ENOXper99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



ENOX_CPFplot = list(ENOXallpolar$plot,
                    ENOXstdev$plot,
                    ENOXfrequency$plot,
                    ENOXweighted$plot,
                    ENOXper50$plot,
                    ENOXper60$plot,
                    ENOXper70$plot,
                    ENOXper80$plot,
                    ENOXper90$plot,
                    ENOXper98$plot,
                    ENOXper99$plot)

do.call("grid.arrange", ENOX_CPFplot)



# O3 ----------------------------------------------------------------------

EO3allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

EO3stdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


EO3weighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

EO3frequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



EO3per50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



EO3per60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


EO3per70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

EO3per80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

EO3per80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

EO3per80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



EO3per98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

EO3per99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

EO3_polarplot = list(EO3allpolar$plot,
                       EO3stdev$plot,
                       EO3weighted$plot,
                       EO3frequency$plot,
                       EO3per50$plot,
                     EO3per60$plot,
                       EO3per70$plot,
                     EO3per80$plot,
                       EO3per90$plot,
                       EO3per98$plot,
                       E3per99$plot)
do.call("grid.arrange", EO3_polarplot)


# Hendrina polar ----------------------------------------------------------

Hpolar <- LAMS_clean %>%
  datify() %>%
  mutate(latitude = -26,151197,
         longitude = 29,716484)

# PM10 --------------------------------------------------------------------



HPM10allpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

HPM10stdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
                     PM10per99$plot)

do.call("grid.arrange", HPM10_CPFplot)


# PM2.5 -------------------------------------------------------------------

HPM2.5allpolar <- polarMap(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

HPM2.5stdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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


HSO2allpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

HSO2stdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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

HNO2allpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

HNO2stdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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
  Hpolar %>% filter(year == "2009"),
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

# NO --------------------------------------------------------------------

HNOallpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

HNOstdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

HNOweighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


HNOfrequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


HNOper50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



HNOper60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HNOper70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HNOper80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HNOper90 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HNOper98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HNOper99 <- polarPlot(
  Lpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



HNO_CPFplot = list(HNOallpolar$plot,
                   HNOstdev$plot,
                   HNOfrequency$plot,
                   HNOweighted$plot,
                   HNOper50$plot,
                   HNOper60$plot,
                   HNOper70$plot,
                   HNOper80$plot,
                   HNOper90$plot,
                   HNOper98$plot,
                   HNOper99$plot)

do.call("grid.arrange", HNO_CPFplot)


# CO --------------------------------------------------------------------

HCOallpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO (ppb) concentrations",
  key.position = "right",
  key = TRUE
)

HCOstdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO (ppb) concentrations",
  key.position = "right",
  key = TRUE
)


HCOweighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO (ppb) concentrations",
  key.position = "right",
  key = TRUE
)


HCOfrequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)

HCOper50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO (ppb) sources at 50th percentile",
  key.position = "right",
  key = TRUE
)



HCOper60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HCOper70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HCOper80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HCOper90 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HCOper98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HCOper99 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



HCO_CPFplot = list(HCOallpolar$plot,
                   HCOstdev$plot,
                   HCOfrequency$plot,
                   HCOweighted$plot,
                   HCOper50$plot,
                   HCOper60$plot,
                   HCOper70$plot,
                   HCOper80$plot,
                   HCOper90$plot,
                   HCOper98$plot,
                   HCOper99$plot)

do.call("grid.arrange", HCO_CPFplot)


# NOX --------------------------------------------------------------------

HNOXallpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

HNOXstdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

HNOXweighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


HNOXfrequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


HNOXper50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



HNOXper60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HNOXper70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HNOXper80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HNOXper90 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HNOXper98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HNOXper99 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



HNOX_CPFplot = list(HNOXallpolar$plot,
                   HNOXstdev$plot,
                   HNOXfrequency$plot,
                   HNOXweighted$plot,
                   HNOXper50$plot,
                   HNOXper60$plot,
                   HNOXper70$plot,
                   HNOXper80$plot,
                   HNOXper90$plot,
                   HNOXper98$plot,
                   HNOXper99$plot)

do.call("grid.arrange", HNOX_CPFplot)


# O3 --------------------------------------------------------------------

HO3allpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

HO3stdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


HO3weighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean 03",
  key.position = "right",
  key = TRUE
)


HO3frequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

HO3per50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)


HO3per60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HO3per70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

HO3per80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

HO3per80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

HO3per80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



HO3per98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HO3per99 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

HO3_polarplot = list(HO3allpolar$plot,
                     HO3stdev$plot,
                     HO3weighted$plot,
                     HO3frequency$plot,
                     HO3per50$plot,
                     HO3per60$plot,
                     HO3per70$plot,
                     HO3per80$plot,
                     HO3per90$plot,
                     HO3per98$plot,
                     HO3per99$plot)
do.call("grid.arrange", HO3_polarplot)

# Middelburg polar --------------------------------------------------------

Mpolar <- Middelburg_clean %>%
  datify() %>%
  mutate(latitude = -25,796056,
         longitude = 29,462823)

# PM10 --------------------------------------------------------------------

MPM10allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

MPM10stdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
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
  Mpolarv %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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

MPM2.5allpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

MPM2.5stdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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


MSO2allpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

MSO2stdev <- polarPlot(
 Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
 Mpolar %>% filter(year == "2009"),
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
 Mpolar %>% filter(year == "2009"),
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

MNO2allpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

MNO2stdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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
  Mpolar %>% filter(year == "2009"),
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


# NO --------------------------------------------------------------------

MNOallpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

MNOstdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

MNOweighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


MNOfrequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

MNOper50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



MNOper60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MNOper70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


MNOper80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


MNOper90 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

MNOper98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MNOper99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



MNO_CPFplot = list(MNOallpolar$plot,
                   MNOstdev$plot,
                   MNOfrequency$plot,
                   MNOweighted$plot,
                   MNOper50$plot,
                   MNOper60$plot,
                   MNOper70$plot,
                   MNOper80$plot,
                   MNOper90$plot,
                   MNOper98$plot,
                   MNOper99$plot)

do.call("grid.arrange", MNO_CPFplot)

# CO --------------------------------------------------------------------

MCOallpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

MCOstdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


MCOweighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


MCOfrequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



MCOper50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



MCOper60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MCOper70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


MCOper80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


MCOper90 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

MCOper98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MCOper99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



MCO_CPFplot = list(MCOallpolar$plot,
                   MCOstdev$plot,
                   MCOfrequency$plot,
                   MCOweighted$plot,
                   MCOper50$plot,
                   MCOper60$plot,
                   MCOper70$plot,
                   MCOper80$plot,
                   MCOper90$plot,
                   MCOper98$plot,
                   MCOper99$plot)

do.call("grid.arrange", MCO_CPFplot)


# NOX --------------------------------------------------------------------

MNOXallpolar <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

MNOXstdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

MNOXweighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


MNOXfrequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


MNOXper50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



MNOXper60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MNOXper70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


MNOXper80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


MNOXper90 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

MNOXper98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MNOXper99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



MNOX_CPFplot = list(MNOXallpolar$plot,
                    MNOXstdev$plot,
                    MNOXfrequency$plot,
                    MNOXweighted$plot,
                    MNOXper50$plot,
                    MNOXper60$plot,
                    MNOXper70$plot,
                    MNOXper80$plot,
                    MNOXper90$plot,
                    MNOXper98$plot,
                    MNOXper99$plot)

do.call("grid.arrange", MNOX_CPFplot)



# O3 ----------------------------------------------------------------------

MO3allpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

MO3stdev <- polarPlot(
 Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


MO3weighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

MO3frequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



MO3per50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



MO3per60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MO3per70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

MO3per80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

MO3per80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

MO3per80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



MO3per98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MO3per99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

MO3_polarplot = list(MO3allpolar$plot,
                     MO3stdev$plot,
                     MO3weighted$plot,
                     MO3frequency$plot,
                     MO3per50$plot,
                     MO3per60$plot,
                     MO3per70$plot,
                     MO3per80$plot,
                     MO3per90$plot,
                     MO3per98$plot,
                     MO3per99$plot)
do.call("grid.arrange", MO3_polarplot)

# Secunda polar --------------------------------------------------------

Spolar <- Secunda_clean %>%
  datify() %>%
  mutate(latitude = -26,550639,
         longitude = 29,079028)

# PM10 --------------------------------------------------------------------

SPM10allpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm10",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM10",
  key.position = "right",
  key = TRUE
)

SPM10stdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
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
  Spolarv %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Epolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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

SPM2.5allpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "pm2.5",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean PM2.5",
  key.position = "right",
  key = TRUE
)

SPM2.5stdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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


SSO2allpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "so2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean SO2",
  key.position = "right",
  key = TRUE
)

SSO2stdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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

SNO2allpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no2",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO2",
  key.position = "right",
  key = TRUE
)

SNO2stdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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
  Spolar %>% filter(year == "2009"),
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


# NO --------------------------------------------------------------------

SNOallpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

SNOstdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

SNOweighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


SNOfrequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

SNOper50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



SNOper60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SNOper70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


SNOper80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


SNOper90 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

SNOper98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SNOper99 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



SNO_CPFplot = list(SNOallpolar$plot,
                   SNOstdev$plot,
                   SNOfrequency$plot,
                   SNOweighted$plot,
                   SNOper50$plot,
                   SNOper60$plot,
                   SNOper70$plot,
                   SNOper80$plot,
                   SNOper90$plot,
                   SNOper98$plot,
                   SNOper99$plot)

do.call("grid.arrange", SNO_CPFplot)

# CO --------------------------------------------------------------------

SCOallpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

SCOstdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


SCOweighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


SCOfrequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



SCOper50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



SCOper60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SCOper70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


SCOper80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


SCOper90 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

SCOper98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SCOper99 <- polarPlot(
  SEpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



SCO_CPFplot = list(SECOallpolar$plot,
                   SCOstdev$plot,
                   SCOfrequency$plot,
                   SCOweighted$plot,
                   SCOper50$plot,
                   SCOper60$plot,
                   SCOper70$plot,
                   SCOper80$plot,
                   SCOper90$plot,
                   SCOper98$plot,
                   SCOper99$plot)

do.call("grid.arrange", SCO_CPFplot)


# NOX --------------------------------------------------------------------

SNOXallpolar <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

SNOXstdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

SNOXweighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


SNOXfrequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


SNOXper50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



SNOXper60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SNOXper70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


SNOXper80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


SNOXper90 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

SNOXper98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SNOXper99 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



SNOX_CPFplot = list(SNOXallpolar$plot,
                    SNOXstdev$plot,
                    SNOXfrequency$plot,
                    SNOXweighted$plot,
                    SNOXper50$plot,
                    SNOXper60$plot,
                    SNOXper70$plot,
                    SNOXper80$plot,
                    SNOXper90$plot,
                    SNOXper98$plot,
                    SNOXper99$plot)

do.call("grid.arrange", SNOX_CPFplot)



# O3 ----------------------------------------------------------------------

SO3allpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

SO3stdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


SO3weighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

SO3frequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



SO3per50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



SO3per60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SO3per70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

SO3per80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

SO3per80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

SO3per80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



SO3per98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SO3per99 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

SO3_polarplot = list(SO3allpolar$plot,
                     SO3stdev$plot,
                     SO3weighted$plot,
                     SO3frequency$plot,
                     SO3per50$plot,
                     SO3per60$plot,
                     SO3per70$plot,
                     SO3per80$plot,
                     SO3per90$plot,
                     SO3per98$plot,
                     SO3per99$plot)
do.call("grid.arrange", SO3_polarplot)
