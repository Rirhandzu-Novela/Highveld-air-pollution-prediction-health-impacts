
### Theilsen trends

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


# It can only plot one pollutant at a time. 
model = TheilSen(a, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "eMalahleni O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "eMalahleni CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "NO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "eMalahleni NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "SO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "eMalahleni SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "PM2.5", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "eMalahleni PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "PM10", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "eMalahleni PM10 Deseasonalised Trends", data.col = "black", text.col = "black")


###ERMELO

b = read.csv("ErmeloIM.csv", header = TRUE, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for the TheilSen function
names(b)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
b$date <- dateTime
summary(b)


# It can only plot one pollutant at a time.
model = TheilSen(b, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Ermelo O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(b, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Ermelo CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(b, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Ermelo NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(b, "SO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Ermelo SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(b, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Ermelo PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(b, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Ermelo PM10 Deseasonalised Trends", data.col = "black", text.col = "black")


### Hendrina

c = read.csv("HendrinaIM.csv", header = TRUE, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for the TheilSen function
names(c)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
c$date <- dateTime
summary(c)


# It can only plot one pollutant at a time.
model = TheilSen(c, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Hendrina O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(c, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Hendrina CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(c, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Hendrina NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(c, "SO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Hendrina SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(c, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Hendrina PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(c, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Hendrina PM10 Deseasonalised Trends", data.col = "black", text.col = "black")


### Middelburg
d = read.csv("MiddelburgIM.csv", header = TRUE, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for the TheilSen function
names(d)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
d$date <- dateTime
summary(d)


# It can only plot one pollutant at a time.
model = TheilSen(d, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Middelburg O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(d, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Middelburg CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(d, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Middelburg NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(d, "SO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Middelburg SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(d, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Middelburg PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(d, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Middelburg PM10 Deseasonalised Trends", data.col = "black", text.col = "black")


###secunda
e = read.csv("SecundaIM.csv", header = TRUE, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for the TheilSen function
names(e)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
e$date <- dateTime
summary(e)


# It can only plot one pollutant at a time.
model = TheilSen(e, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Secunda O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(e, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Secunda CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(e, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Secunda NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(e, "SO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Secunda SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(e, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Secunda PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(e, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Secunda PM10 Deseasonalised Trends", data.col = "black", text.col = "black")

allcard = read.csv("carddata.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(allcard)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
allcard$date <- dateTime
# It can only plot one pollutant at a time.
model = TheilSen(allcard, "Count", deseason = TRUE,lab.cex = 2, ylab = "Daily Mortality",
                 main = "All cardiovascular mortality", data.col = "black", text.col = "black")

allpul = read.csv("puldata.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(allpul)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
allpul$date <- dateTime
# It can only plot one pollutant at a time.
model = TheilSen(allpul, "Count", deseason = TRUE,lab.cex = 2, ylab = "Daily Mortality",
                 main = "All respiratory mortality", data.col = "black", text.col = "black")


### Averages

a = read.csv("Averages.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(a)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
a$date <- dateTime
summary(a)


# It can only plot one pollutant at a time. 
model = TheilSen(a, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Highveld O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Highveld CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "NO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Highveld NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "SO2", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Highveld SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "PM2.5", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Highveld PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(a, "PM10", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Highveld PM10 Deseasonalised Trends", data.col = "black", text.col = "black")

