
### Theilsen trends

library("openair")

### eMalahleni

a = read.csv("Data/eMalahleniIM.csv", header = T, sep = ";")



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

b = read.csv("Data/ErmeloIM.csv", header = TRUE, sep = ";")


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

c = read.csv("Data/HendrinaIM.csv", header = TRUE, sep = ";")



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
d = read.csv("Data/MiddelburgIM.csv", header = TRUE, sep = ";")

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
e = read.csv("Data/SecundaIM.csv", header = TRUE, sep = ";")


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

