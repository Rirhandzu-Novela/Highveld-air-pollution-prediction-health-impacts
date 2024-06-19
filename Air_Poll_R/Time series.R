### Temporal variation

library("openair")


### eMalahleni

a = read.csv("Data/eMalahleniIM.csv", header = T, sep = ";")


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

b = read.csv("Data/ErmeloIM.csv", header = T, sep = ";")


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

c = read.csv("Data/HendrinaIM.csv", header = T, sep = ";")


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

d = read.csv("Data/MiddelburgIM.csv", header = T, sep = ";")


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

e = read.csv("Data/SecundaIM.csv", header = T, sep = ";")

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
