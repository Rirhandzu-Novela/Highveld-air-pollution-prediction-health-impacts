
### Theilsen trends

library("openair")

### Gert Sibande

Gerts = read.csv("Data/Gerts.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Gerts$date <- dateTime


# It can only plot one pollutant at a time. 
model = TheilSen(Gerts, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Gert Sibande O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Gert Sibande CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "NO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Gert Sibande NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "SO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Gert Sibande SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "PM2.5", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Gert Sibande PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Gerts, "PM10", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Gert Sibande PM10 Deseasonalised Trends", data.col = "black", text.col = "black")


### Nkangala

Nka = read.csv("Data/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime



# It can only plot one pollutant at a time.
model = TheilSen(Nka, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Nkangala CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "SO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Nkangala PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Nkangala PM10 Deseasonalised Trends", data.col = "black", text.col = "black")


