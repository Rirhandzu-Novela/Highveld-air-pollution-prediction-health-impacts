### Temporal variation

library("openair")


### eMalahleni

a = read.csv("eMalahleniIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(a)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
a$date <- dateTime
summary(a)

timeVariation(a, pollutant = "O3", main = "eMalahleni O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(a, pollutant = "CO", main = "eMalahleni CO Temporal variation", ylab = "CO (ppm)")
timeVariation(a, pollutant = "PM10", main = "eMalahleni PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(a, pollutant = "PM2.5",main = "eMalahleni PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(a, pollutant = "SO2", main = "eMalahleni SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(a, pollutant = "NO2", main = "eMalahleni N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(a, pollutant = "NO2", main = "eMalahleni NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(a, pollutant = "SO2", main = "eMalahleni SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "SO2 (ppb)")
timePlot(a, pollutant = "PM10", main = "eMalahleni PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "PM10 (ug/m3)")
timePlot(a, pollutant = "PM2.5", main = "eMalahleni PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(a, pollutant = "NO2", main = "eMalahleni NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(a, pollutant = "NO2",main = "eMalahleni NO2 annual concentrations",xlab = "Time", avg.time = "year")

### Ermelo

b = read.csv("ErmeloIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(b)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
b$date <- dateTime
summary(b)

timeVariation(b, pollutant = "O3", main = "Ermelo O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(b, pollutant = "CO", main = "Ermelo CO Temporal variation", ylab = "CO (ppm)")
timeVariation(b, pollutant = "PM10", main = "Ermelo PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(b, pollutant = "PM2.5",main = "Ermelo PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(b, pollutant = "SO2", main = "Ermelo SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(b, pollutant = "NO2", main = "Ermelo N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(b, pollutant = "NO2", main = "Ermelo NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(b, pollutant = "SO2", main = "Ermelo SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(b, pollutant = "PM10", main = "Ermelo PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)" )
timePlot(b, pollutant = "PM2.5", main = "Ermelo PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(b, pollutant = "NO2", main = "Ermelo NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(b, pollutant = "NO2",main = "Ermelo NO2 annual concentrations",xlab = "Time", avg.time = "year")




### Hendrina

c = read.csv("HendrinaIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(c)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
c$date <- dateTime
summary(c)

timeVariation(c, pollutant = "O3", main = "Hendrina O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(c, pollutant = "CO", main = "Hendrina CO Temporal variation", ylab = "CO (ppm)")
timeVariation(c, pollutant = "PM10",  main = "Hendrina PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(c, pollutant = "PM2.5", main = "Hendrina PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(c, pollutant = "SO2", main = "Hendrina SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(c, pollutant = "NO2", main = "Hendrina NO2 Temporal variation", ylab = "NO2 (ppb)")

timePlot(c, pollutant = "NO2", main = "Hendrina NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(c, pollutant = "SO2", main = "Hendrina SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(c, pollutant = "PM10", main = "Hendrina PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)")
timePlot(c, pollutant = "PM2.5", main = "Hendrina PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(c, pollutant = "NO2", main = "eMalahleni NO2 daily concentrations", avg.time = "day")
timePlot(c, pollutant = "NO2",main = "eMalahleni NO2 annual concentrations", avg.time = "year")


### Middelburg

d = read.csv("MiddelburgIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(d)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
d$date <- dateTime
summary(d)

timeVariation(d, pollutant = "O3", main = "Middelburg O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(d, pollutant = "CO", main = "Middelburg CO Temporal variation", ylab = "CO (ppm)")
timeVariation(d, pollutant = "PM10", main = "Middelburg PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(d, pollutant = "PM2.5", main = "Middelburg PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(d, pollutant = "SO2", main = "Middelburg SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(d, pollutant = "NO2", main = "Middelurg NO2 Temporal variation", ylab = "NO2 (ppb)")

timePlot(d, pollutant = "NO2", main = "Middelburg NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(d, pollutant = "SO2", main = "Middelburg SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(d, pollutant = "PM10", main = "Middelburg PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)")
timePlot(d, pollutant = "PM2.5", main = "Middelburg PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "PM2.5 (ug/m3)")



timePlot(d, pollutant = "NO2", main = "eMalahleni NO2 daily concentrations", avg.time = "day")
timePlot(d, pollutant = "NO2",main = "eMalahleni NO2 annual concentrations", avg.time = "year")



### Secunda

e = read.csv("SecundaIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(e)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
e$date <- dateTime
summary(e)

timeVariation(e, pollutant = "O3", main = "Secunda O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(e, pollutant = "CO", main = "Secunda CO Temporal variation", ylab = "CO (ppm)")
timeVariation(e, pollutant = "PM10", main = "Secunda PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(e, pollutant = "PM2.5", main = "Secunda PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(e, pollutant = "SO2", main = "Secunda SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(e, pollutant = "NO2", main = "Secunda NO2 Temporal variation", ylab = "NO2 (ppb)")

timePlot(e, pollutant = "NO2", main = "Secunda NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(e, pollutant = "SO2", main = "Secunda SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(e, pollutant = "PM10", main = "Secunda PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)")
timePlot(e, pollutant = "PM2.5", main = "Secunda PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")


timePlot(e, pollutant = "NO2", main = "eMalahleni NO2 daily concentrations", avg.time = "day")
timePlot(e, pollutant = "NO2",main = "eMalahleni NO2 annual concentrations", avg.time = "year")

### Averages

f = read.csv("Averages.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(f)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
f$date <- dateTime
summary(f)

timeVariation(f, pollutant = "O3", main = "Highveld O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(f, pollutant = "CO", main = "Highveld CO Temporal variation", ylab = "CO (ppm)")
timeVariation(f, pollutant = "PM10", main = "Highveld PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(f, pollutant = "PM2.5",main = "Highveld PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(f, pollutant = "SO2", main = "Highveld SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(f, pollutant = "NO2", main = "Highveld N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(f, pollutant = "NO2", main = "Highveld NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(f, pollutant = "SO2", main = "Highveld SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "SO2 (ppb)")
timePlot(f, pollutant = "PM10", main = "Highveld PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day",  ylab = "PM10 (ug/m3)")
timePlot(f, pollutant = "PM2.5", main = "Highveld PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(f, pollutant = "NO2", main = "Highveld NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(f, pollutant = "NO2",main = "Highveld NO2 annual concentrations",xlab = "Time", avg.time = "year")

