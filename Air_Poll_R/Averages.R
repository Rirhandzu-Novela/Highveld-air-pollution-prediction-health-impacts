### Temporal variation

library("openair")


### eMalahleni

eMalahleni = read.csv("Data/eMalahleniIM.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
df$date <- dateTime



daily <- timeAverage(eMalahleni, avg.time = "day")
write.csv(daily,"Data/eMalahleniDaily.csv")
summary(daily)

Yearly <- timeAverage(a, avg.time = "year")
write.csv(Yearly,"Data/eMalahleniYearly.csv")

### Ermelo

b = read.csv("Data/ErmeloIM.csv", header = T, sep = ";")

daily <- timeAverage(b, avg.time = "day")
write.csv(daily,"Data/ErmeloDaily.csv")
summary(daily)

Yearly <- timeAverage(b, avg.time = "year")
write.csv(Yearly,"Data/ErmeloYearly.csv")

### Hendrina

c = read.csv("HendrinaIM.csv", header = T, sep = ";")

daily <- timeAverage(c, avg.time = "day")
write.csv(daily,"Data/HendrinaDaily.csv")
summary(daily)

Yearly <- timeAverage(c, avg.time = "year")
write.csv(Yearly,"Data/HendrinaYearly.csv")

### Middelburg

d = read.csv("MiddelburgIM.csv", header = T, sep = ";")

daily <- timeAverage(d, avg.time = "day")
write.csv(daily,"Data/MiddelburgDaily.csv")
summary(daily)

Yearly <- timeAverage(d, avg.time = "year")
write.csv(Yearly,"Data/MiddelburgYearly.csv")

### Secunda

e = read.csv("SecundaIM.csv", header = T, sep = ";")

daily <- timeAverage(e, avg.time = "day")
write.csv(daily,"Data/SecundaDaily.csv")
summary(daily)

Yearly <- timeAverage(e, avg.time = "year")
write.csv(Yearly,"Data/SecundaYearly.csv")

### Mortality
allcard = read.csv("Data/carddata.csv", header = T, sep = ";")

Yearly <- timeAverage(allcard, avg.time = "year")
write.csv(Yearly,"Data/allcardYearly.csv")

card64 = read.csv("Data/carddata64.csv", header = T, sep = ";")

Yearly <- timeAverage(card64, avg.time = "year")
write.csv(Yearly,"Data/card64Yearly.csv")

card65 = read.csv("Data/carddata65.csv", header = T, sep = ";")

Yearly <- timeAverage(card65, avg.time = "year")
write.csv(Yearly,"Data/card65Yearly.csv")

cardmale = read.csv("Data/carddatamale.csv", header = T, sep = ";")

Yearly <- timeAverage(cardmale, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/cardmaleYearly.csv")

cardfema = read.csv("Data/carddatafema.csv", header = T, sep = ";")

Yearly <- timeAverage(cardfema, avg.time = "year")
write.csv(Yearly,"Data/cardfemaYearly.csv")

allpul = read.csv("Data/puldata.csv", header = T, sep = ";")

Yearly <- timeAverage(allpul, avg.time = "year")
write.csv(Yearly,"Data/allpulYearly.csv")

pul64 = read.csv("Data/puldata64.csv", header = T, sep = ";")

Yearly <- timeAverage(pul64, avg.time = "year")
write.csv(Yearly,"Data/pul64Yearly.csv")

pul65 = read.csv("puldata65.csv", header = T, sep = ";")

Yearly <- timeAverage(pul65, avg.time = "year")
write.csv(Yearly,"Data/pul65Yearly.csv")

pulmale = read.csv("puldatamale.csv", header = T, sep = ";")

Yearly <- timeAverage(pulmale, avg.time = "year")
write.csv(Yearly,"Data/pulmaleYearly.csv")

pulfema = read.csv("puldatafema.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(pulfema)[1] <- 'Date'

Yearly <- timeAverage(pulfema, avg.time = "year")
write.csv(Yearly,"Data/pulfemaYearly.csv")

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

df1 = read.csv("Data/carddata.csv", header = T, sep = ";")
df2 = read.csv("Data/dow.csv", header = T, sep = ";")

ncarddata <- left_join(df1, df2, by=c("date"))
head(ncarddata)
write.csv(ncarddata, "Data/ncarddata.csv", row.names = TRUE)
