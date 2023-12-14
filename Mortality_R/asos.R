# LOAD THE DATA INTO THE SESSION
data = read.csv("puldata.csv", header = T, sep = ";")

## Dataframe should have a column name "Date".
names(data)[1] <- 'Date'

## The dates must be a "POSIXct" "POSIXt" object. 
dateTime <- seq(as.POSIXct("2009-01-01"), as.POSIXct("2018-12-31"), by = "24 hours", tz = 'UTC')

## Replace the dates in csv file with the created "POSIXct" "POSIXt" date object
data$Date <- dateTime
summary(data)

## Repalce NAs with 0
data[is.na(data)] = 0

# SET THE DEFAULT ACTION FOR MISSING DATA TO na.exclude
# (MISSING EXCLUDED IN ESTIMATION BUT RE-INSERTED IN PREDICTION/RESIDUALS)
options(na.action="na.exclude")

#################################################################
# PRELIMINARY ANALYSIS
#######################

#############
# FIGURE 1
#############

# SET THE PLOTTING PARAMETERS FOR THE PLOT (SEE ?par)
oldpar <- par(no.readonly=TRUE)
par(mex=0.8,mfrow=c(2,1))

# SUB-PLOT FOR DAILY DEATHS, WITH VERTICAL LINES DEFINING YEARS
plot(data$Date,data$Count,pch=".",main="Daily deaths over time",
     ylab="Daily number of deaths",xlab="Date")
abline(v=data$date[grep("-01-01",data$date)],col=grey(0.6),lty=2)

# THE SAME FOR PM LEVELS
plot(data$Date,data$PM2.5,pch=".",main="PM levels over time",
     ylab="Daily mean PM level (ug/m3)",xlab="Date")
abline(v=data$date[grep("-01-01",data$date)],col=grey(0.6),lty=2)
par(oldpar)
layout(1)

library(dplyr)
df <- data %>% mutate_at(c('Rain'), as.numeric)
df[is.na(df)] = 0
summary(df)
sum(df$Count)

library(splines)
library(ggplot2)

# Generate some example data
set.seed(42)
data <- df(Temperature = runif(100, min = 0, max = 30))

# Define a range of potential knot positions
knots_range <- seq(min(df$Temperature), max(df$Temperature), length.out = 10)

# Create a list to store basis functions
basis_functions <- list()

# Generate basis functions for different knot positions
for (knot in knots_range) {
  basis <- bs(df$Temperature, knots = c(knot), degree = 3, Boundary.knots = c(min(df$Temperature), max(df$Temperature)))
  basis_functions[[as.character(knot)]] <- basis
}

# Prepare data for visualization
plot_data <- data.frame()

# Populate the plot data with basis functions
for (knot in names(basis_functions)) {
  basis_values <- basis_functions[[knot]][, 1]
  temp_data <- data.frame(Temperature = df$Temperature, Basis_Value = basis_values, Knot_Position = knot)
  plot_data <- rbind(plot_data, temp_data)
}

# Convert Knot_Position to a factor
plot_data$Knot_Position <- factor(plot_data$Knot_Position)

# Create the visualization using ggplot2
ggplot(plot_data, aes(x = Temperature, y = Basis_Value, color = Knot_Position)) +
  geom_line(size = 1) +
  scale_color_manual(values = rainbow(length(knots_range)), name = "Knot Position") +
  labs(x = "Temperature", y = "Basis Function Value") +
  theme_minimal()
