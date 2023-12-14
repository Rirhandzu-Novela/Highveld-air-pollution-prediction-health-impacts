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


daily <- timeAverage(a, avg.time = "day")
write.csv(daily,"/Users/REAL/Documents/eMalahleniDaily.csv")
summary(daily)
Yearly <- timeAverage(a, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/eMalahleniYearly.csv")

### Ermelo

b = read.csv("ErmeloIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(b)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
b$date <- dateTime
summary(b)

daily <- timeAverage(b, avg.time = "day")
write.csv(daily,"/Users/REAL/Documents/ErmeloDaily.csv")
summary(daily)
Yearly <- timeAverage(b, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/ErmeloYearly.csv")

### Hendrina

c = read.csv("HendrinaIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(c)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
c$date <- dateTime
summary(c)

daily <- timeAverage(c, avg.time = "day")
write.csv(daily,"/Users/REAL/Documents/HendrinaDaily.csv")
summary(daily)
Yearly <- timeAverage(c, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/HendrinaYearly.csv")

### Middelburg

d = read.csv("MiddelburgIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(d)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
d$date <- dateTime
summary(d)

daily <- timeAverage(d, avg.time = "day")
write.csv(daily,"/Users/REAL/Documents/MiddelburgDaily.csv")
summary(daily)
Yearly <- timeAverage(d, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/MiddelburgYearly.csv")

### Secunda

e = read.csv("SecundaIM.csv", header = T, sep = ";")

# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(e)[1] <- 'Date'

# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')

# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
e$date <- dateTime
summary(e)

daily <- timeAverage(e, avg.time = "day")
write.csv(daily,"/Users/REAL/Documents/SecundaDaily.csv")
summary(daily)
Yearly <- timeAverage(e, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/SecundaYearly.csv")


allcard = read.csv("carddata.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(allcard)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
allcard$date <- dateTime
Yearly <- timeAverage(allcard, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/allcardYearly.csv")

card64 = read.csv("carddata64.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(card64)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
card64$date <- dateTime
Yearly <- timeAverage(card64, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/card64Yearly.csv")

card65 = read.csv("carddata65.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(card65)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
card65$date <- dateTime
Yearly <- timeAverage(card65, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/card65Yearly.csv")

cardmale = read.csv("carddatamale.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(cardmale)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
cardmale$date <- dateTime
Yearly <- timeAverage(cardmale, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/cardmaleYearly.csv")

cardfema = read.csv("carddatafema.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(cardfema)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
cardfema$date <- dateTime
Yearly <- timeAverage(cardfema, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/cardfemaYearly.csv")

allpul = read.csv("puldata.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(allpul)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
allpul$date <- dateTime
Yearly <- timeAverage(allpul, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/allpulYearly.csv")

pul64 = read.csv("puldata64.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(pul64)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
pul64$date <- dateTime
Yearly <- timeAverage(pul64, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/pul64Yearly.csv")

pul65 = read.csv("puldata65.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(pul65)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
pul65$date <- dateTime
Yearly <- timeAverage(pul65, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/pul65Yearly.csv")

pulmale = read.csv("puldatamale.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(pulmale)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
pulmale$date <- dateTime
Yearly <- timeAverage(pulmale, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/pulmaleYearly.csv")

pulfema = read.csv("puldatafema.csv", header = T, sep = ";")
# Dataframe should have a column name "Date". It is mandatory for OpenAir
names(pulfema)[1] <- 'Date'
# The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')
# Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
pulfema$date <- dateTime
Yearly <- timeAverage(pulfema, avg.time = "year")
write.csv(Yearly,"/Users/REAL/Documents/pulfemaYearly.csv")

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
write.csv(dat,"/Users/REAL/Documents/dow.csv")

df1 = read.csv("carddata.csv", header = T, sep = ";")
df2 = read.csv("dow.csv", header = T, sep = ";")

ncarddata <- left_join(df1, df2, by=c("date"))
head(ncarddata)
write.csv(ncarddata, "C:\\Users\\REAL\\Documents\\ncarddata.csv", row.names = TRUE)
