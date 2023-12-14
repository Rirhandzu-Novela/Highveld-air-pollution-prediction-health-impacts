### Temporal variation


### eMalahleni

a = read.csv("eMalahleniDaily.csv", header = T, sep = ";")
summary(a)

plot(a$date,a$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "eMalahleni PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "eMalahleni PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "eMalahleni NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "eMalahleni SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

### Ermelo

b = read.csv("ErmeloDaily.csv", header = T, sep = ";")
summary(a)


plot(daily$Day,daily$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Ermelo PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Ermelo PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Ermelo NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Ermelo SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)



### Hendrina

c = read.csv("HendrinaDaily.csv", header = T, sep = ";")

plot(daily$Day,daily$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Hendrina PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Hendrina PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Hendrina NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Hendrina SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

### Middelburg

d = read.csv("MiddelburgDaily.csv", header = T, sep = ";")

plot(daily$Day,daily$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Middelburg PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Middelburg PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Middelburg NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Middelburg SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

### Secunda

e = read.csv("SecundaDaily.csv", header = T, sep = ";")

plot(daily$Day,daily$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Secunda PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Secunda PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Secunda NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(daily$Day,daily$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Secunda SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

