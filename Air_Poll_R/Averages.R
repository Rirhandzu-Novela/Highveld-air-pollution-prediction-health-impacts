### Temporal variation

library("openair")


### Gert Sibande

Gerts = read.csv("Data/Gerts.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Gerts$date <- dateTime



daily <- timeAverage(Gerts, avg.time = "day")
write.csv(daily,"Data/GertsDaily.csv")






### Nkangala

Nka = read.csv("Data/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime



daily <- timeAverage(Nka, avg.time = "day")
write.csv(daily,"Data/NkaDaily.csv")



###DOW
start = as.POSIXct("2009-01-01")
end = as.POSIXct("2018-12-31")

dat = data.frame(Date = seq.POSIXt(from = start,
                                   to = end,
                                   by = "DSTday"))

# see ?strptime for details of formats you can extract

# day of the week as numeric (Monday is 1)
dat$weekday1 = as.numeric(format(dat$Date, format = "%u"))

# abbreviated weekday name
dat$weekday2 = format(dat$Date, format = "%a")

# full weekday name
dat$weekday3 = format(dat$Date, format = "%A")

dat
write.csv(dat,"Data/dow.csv")


