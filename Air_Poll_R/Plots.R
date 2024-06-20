### Temporal variation


### Gert Sibande

Gerts = read.csv("Data/GertsDaily.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Gerts$date <- dateTime

plot(Gerts$date,Gerts$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Gert Sibande PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Gerts$date,Gerts$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Gert Sibande PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Gerts$date,Gerts$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Gert Sibande NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Gerts$date,Gerts$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Gert Sibande SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)


### Nkangala

Nka = read.csv("Data/NkangalaDaily.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime


plot(Nka$Day,Nka$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Nkangala PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Nkangala PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Nkangala NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Nkangala SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)



