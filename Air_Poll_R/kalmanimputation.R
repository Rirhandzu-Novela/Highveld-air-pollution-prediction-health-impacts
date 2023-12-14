install.packages("imputeTS")
library(imputeTS)
data <- read.csv('eMalahleni.csv', header = T, sep = ';')
                  
head(data)

# your dataframe should have a column name "Date". It is mandatory for OpenAir
names(data)[1] <- 'Date'

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 23:00"), by = "1 hours", tz = 'UTC')


# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
data$date <- dateTime
summary(data)

class(data)

tsdata <- ts(data, start=c(2009, 1), end=c(2018, 12), frequency=87647) 
class(tsdata)

imputes <- na_kalman(tsdata, model = "StructTS", smooth = TRUE, type = "trend")
summary(imputes)

write.csv(daily,"/Users/REAL/Documents/eMalahleniIMP.csv")

imp <- arima(tsdata, order = c(1, 0, 1))$model 


