### Temporal variation

library("openair")


### Gert Sibande

Gerts = read.csv("Data/Gerts.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Gerts$date <- dateTime


timeVariation(Gerts, pollutant = "O3", main = "Gert Sibande O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(Gerts, pollutant = "CO", main = "Gert Sibande CO Temporal variation", ylab = "CO (ppm)")
timeVariation(Gerts, pollutant = "PM10", main = "Gert Sibande PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(Gerts, pollutant = "PM2.5",main = "Gert Sibande PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(Gerts, pollutant = "SO2", main = "Gert Sibande SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(Gerts, pollutant = "NO2", main = "Gert Sibande N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(Gerts, pollutant = "NO2", main = "Gert Sibande NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(Gerts, pollutant = "SO2", main = "Gert Sibande SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "SO2 (ppb)")
timePlot(Gerts, pollutant = "PM10", main = "Gert Sibande PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "PM10 (ug/m3)")
timePlot(a, pollutant = "PM2.5", main = "Gert Sibande PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(Gerts, pollutant = "NO2", main = "Gert Sibande NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(Gerts, pollutant = "NO2",main = "Gert Sibande NO2 annual concentrations",xlab = "Time", avg.time = "year")

### Nkangala

Nka = read.csv("Data/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime


timeVariation(Nka, pollutant = "O3", main = "Nkangala O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(Nka, pollutant = "CO", main = "Nkangala CO Temporal variation", ylab = "CO (ppm)")
timeVariation(Nka, pollutant = "PM10", main = "Nkangala PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(Nka, pollutant = "PM2.5",main = "Nkangala PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(Nka, pollutant = "SO2", main = "Nkangala SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(Nka, pollutant = "NO2", main = "Nkangala N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(Nka, pollutant = "NO2", main = "Nkangala NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(Nka, pollutant = "SO2", main = "Nkangala SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(Nka, pollutant = "PM10", main = "Nkangala PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)" )
timePlot(Nka, pollutant = "PM2.5", main = "Nkangala PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(Nka, pollutant = "NO2", main = "Nkangala NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(Nka, pollutant = "NO2",main = "Nkangala NO2 annual concentrations",xlab = "Time", avg.time = "year")

