library(imputeTS)
library(tidyverse)
library("openair")


# Imputation --------------------------------------------------------------

df <- read.csv('AirData/Nkangala.csv', header = T, sep = ';')


data <- df %>%
  mutate(across(.cols = -Amb.Temp, ~ ifelse(. < 0, NA, .)))
summary(data)

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')


# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
data$date <- dateTime


imputes <- na_kalman(data, model = "StructTS", smooth = TRUE, type = "trend")
summary(imputes)


impT <- arima(data$Amb.Temp, order = c(1, 0, 1))$model 
temp <- na_kalman(data, model = impT)


imputes$Amb.Temp <- temp$Amb.Temp


impR <- arima(data$Amb.RelHum, order = c(1, 0, 0))$model 
Relhum <- na_kalman(data, model = impR)

imputes$Amb.RelHum <- Relhum$Amb.RelHum

summary(imputes)

write.csv(imputes,"AirData/NkangalaIM.csv")

# Daily Ave ---------------------------------------------------------------



Nka = read.csv("AirData/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime



daily <- timeAverage(Nka, avg.time = "day")
write.csv(daily,"AirData/NkaDaily.csv")


# Time series -------------------------------------------------------------

Nka = read.csv("AirData/NkaDaily.csv", header = T, sep = ";")


Nka$date <- as.Date(Nka$date, format = "%Y/%m/%d")

NkaYearSum <- Nka %>%
  pivot_longer(cols = pm2.5:pressure, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) 
write.csv(NkaYearSum,"RDA/NkaYearSum.csv")

NkaSum <-  Nka %>%
  pivot_longer(cols = pm2.5:pressure, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) 
write.csv(NkaSum,"RDA/NkaSum.csv")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime

timeVariation(Nka, pollutant = "O3", main = "Nkangala O3 Temporal variation", ylab = "O3 (ppb)")
timeVariation(Nka, pollutant = "CO", main = "Nkangala CO Temporal variation", ylab = "CO (ppm)")
timeVariation(Nka, pollutant = "PM10", main = "Nkangala PM10 Temporal variation", ylab = "PM10 (ug/m3)")
timeVariation(Nka, pollutant = "PM2.5",main = "Nkangala PM2.5 Temporal variation", ylab = "PM2.5 (ug/m3)")
timeVariation(Nka, pollutant = "SO2", main = "Nkangala SO2 Temporal variation", ylab = "SO2 (ppb)")
timeVariation(Nka, pollutant = "NO2", main = "Nkangala N02 Temporal variation", ylab = "NO2 (ppb)")


timePlot(Nka, pollutant = "NO2", main = "Nkangala NO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "NO2 (ppb)")
timePlot(Nka, pollutant = "SO2", main = "Nkangala SO2 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "SO2 (ppb)")
timePlot(Nka, pollutant = "PM10", main = "Nkangala PM10 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM10 (ug/m3)" )
timePlot(Nka, pollutant = "PM2.5", main = "Nkangala PM2.5 daily concentrations", xlab = "Time (Daily)", avg.time = "day", ylab = "PM2.5 (ug/m3)")

timePlot(Nka, pollutant = "NO2", main = "Nkangala NO2 monthly concentrations", xlab = "Time", avg.time = "month")
timePlot(Nka, pollutant = "NO2",main = "Nkangala NO2 annual concentrations",xlab = "Time", avg.time = "year")


plot(Nka$Day,Nka$PM10, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM10 (ug/m3)",  main = "Nkangala PM10 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$PM2.5, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "PM2.5 (ug/m3)",  main = "Nkangala PM2.5 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$NO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "NO2 (PPb)",  main = "Nkangala NO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

plot(Nka$Day,Nka$SO2, type = "l", lwd=2, cex.lab=1.5, cex.axis=1.5, xlab = "Time (Daily)",  ylab = "SO2 (ug/m3)",  main = "Nkangala SO2 daily concentrations", cex.main=1.5) 
abline(h = 50,col="red",lwd=2)

model = TheilSen(Nka, "O3", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala O3 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "CO", deseason = TRUE,lab.cex = 2, ylab = "Concentration (ppm)",
                 main = "Nkangala CO Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "NO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala NO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "SO2", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ppb)",
                 main = "Nkangala SO2 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "PM2.5", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Nkangala PM2.5 Deseasonalised Trends", data.col = "black", text.col = "black")
model = TheilSen(Nka, "PM10", deseason = TRUE, lab.cex = 2, ylab = "Concentration (ug/m3)",
                 main = "Nkangala PM10 Deseasonalised Trends", data.col = "black", text.col = "black")




# DOW ---------------------------------------------------------------------


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
write.csv(dat,"AirData/dow.csv")

# AQHI --------------------------------------------------------------------
Nka = read.csv("AirData/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime


dfo3 <- Nka %>%
  select(date, o3) %>% 
  mutate(
    ozone_8hr_avg = rollapply(o3, width = 8, FUN = mean, align = "right", fill = NA)
  ) %>%
  mutate(date = as.Date(date)) %>%
  group_by(date) %>%
  summarise(
    o3 = max(rollapply(ozone_8hr_avg, width = 3, FUN = mean, align = "right", fill = NA), na.rm = TRUE)
  )


NkaDaily = read.csv("AirData/NkaDaily.csv", header = T, sep = ";")
NkaDaily$date <- as.Date(NkaDaily$date, format = "%Y/%m/%d")

NkaDaily <- NkaDaily %>% 
  select(-o3) %>% 
  left_join(dfo3, by = "date") 

beta_values <- list(
  pm2.5 = 0.00065,
  pm10  = 0.00041,
  no2   = 0.00072,
  so2   = 0.00059,
  o3    = 0.00043
)

# Calculate the excess risk for each pollutant
NkaDaily <- NkaDaily %>%
  select(date, pm2.5, pm10, so2, no2, o3) %>% 
  mutate(
    excess_risk_pm2.5 = 100 * (exp(beta_values$pm2.5 * `pm2.5`) - 1),
    excess_risk_pm10  = 100 * (exp(beta_values$pm10  * `pm10`)  - 1),
    excess_risk_no2   = 100 * (exp(beta_values$no2   * `no2`)   - 1),
    excess_risk_so2   = 100 * (exp(beta_values$so2   * `so2`)   - 1),
    excess_risk_o3    = 100 * (exp(beta_values$o3    * `o3`)    - 1)
  )


# Define the thresholds for each pollutant based on excess risk
aqhi_pm10 <- c(0, 0.21, 0.42, 0.63, 0.84, 1.05, 1.26, 1.47, 1.68, 1.89, Inf)
aqhi_no2 <- c(0, 0.24, 0.48, 0.72, 0.96, 1.20, 1.44, 1.68, 1.92, 2.16, Inf)
aqhi_so2 <- c(0, 0.4, 0.8, 1.2, 1.6, 2.0, 2.4, 2.8, 3.2, 3.6, Inf)
aqhi_o3 <- c(0, 0.87, 1.74, 2.61, 3.48, 4.35, 5.22, 6.09, 6.96, 7.83, Inf)

# Function to calculate AQHI for each pollutant based on excess risk
calculate_aqhi <- function(excess_risk, thresholds) {
  cut(excess_risk, breaks = thresholds, labels = 1:10, right = FALSE)
}

# Apply the AQHI classification to the dataframe
daily_df <- NkaDaily %>%
  mutate(
    aqhi_pm10 = calculate_aqhi(excess_risk_pm10, aqhi_pm10),
    aqhi_no2  = calculate_aqhi(excess_risk_no2, aqhi_no2),
    aqhi_so2  = calculate_aqhi(excess_risk_so2, aqhi_so2),
    aqhi_o3   = calculate_aqhi(excess_risk_o3, aqhi_o3)) %>%
  mutate(
    weight_pm10 = 1,  # Weight of PM10 is defined to be 1
    weight_no2  =  0.853,
    weight_so2  =  0.519,
    weight_o3   =  0.236) %>%
  rowwise() %>%
  mutate(
    weighted_aqhi = round(
      sum(c(weight_pm10, weight_no2, weight_so2, weight_o3) * 
            c(as.numeric(aqhi_pm10), as.numeric(aqhi_no2), as.numeric(aqhi_so2), as.numeric(aqhi_o3))) / 
        sum(c(weight_pm10, weight_no2, weight_so2, weight_o3)))) %>%
  ungroup()  %>%
  mutate(
    risk_level = case_when(
      weighted_aqhi >= 1 & weighted_aqhi <= 3 ~ "Low risk",
      weighted_aqhi >= 4 & weighted_aqhi <= 6 ~ "Moderate risk",
      weighted_aqhi >= 7 & weighted_aqhi <= 10 ~ "High risk",
      TRUE ~ NA_character_  # Handle any cases that don't match the conditions (if necessary)
    )) %>% 
  select(date, weighted_aqhi, risk_level)

NkaMort30 = read.csv("MortData/NkaPollMort30.csv", header = T, sep = ";")
NkaMort30$date <- as.Date(NkaMort30$date, format = "%Y/%m/%d")


NkaMort30Aqhi <- NkaMort30 %>% 
  left_join(daily_df, by = "date")

write.csv(NkaMort30Aqhi, "MortData/NkaMort30Aqhi.csv", row.names = TRUE) 


# Group by year and risk_level, then count the number of days in each risk_level per year
Nkarisk_level_counts <- NkaMort30Aqhi %>%
  group_by(weighted_aqhi) %>%
  summarise(days_count = n(),
            pm2.5 = mean(pm2.5),
            pm10 = mean(pm10),
            so2 = mean(so2),
            no2 = mean(no2),
            o3 = mean(o3),
            .groups = "drop")


# Optionally, save the result to a CSV file
write.csv(Nkarisk_level_counts, "RDA/Nkarisk_level_counts.csv", row.names = TRUE)


# heatmap

df <- NkaMort30Aqhi %>%
  mutate(
    year = format(date, "%Y"),                # Extract the year
    day_of_year = as.numeric(format(date, "%j")),  # Day of the year (1-365)
    color = case_when(                        # Categorize risk levels into colors
      weighted_aqhi >= 1 & weighted_aqhi <= 3 ~ "green",
      weighted_aqhi >= 4 & weighted_aqhi <= 5 ~ "yellow",
      weighted_aqhi >= 6 & weighted_aqhi <= 7 ~ "orange",
      weighted_aqhi >= 8 & weighted_aqhi <= 9 ~ "red",
      weighted_aqhi == 10 ~ "purple"
    )
  ) %>%
  mutate(
    risk_category = factor(color, levels = c("green", "yellow", "orange", "red", "purple"),
                           labels = c("Good (1-3)", "Moderate (4-5)", "Unhealthy (6-7)", "Very Unhealthy (8-9)", "Hazardous (10+)"))
  )

# Plot the heatmap with a legend
ggplot(df, aes(x = day_of_year, y = year, fill = risk_category)) +
  geom_tile(color = "white") +                    # Add white grid lines
  scale_fill_manual(
    values = c(
      "Good (1-3)" = "green",
      "Moderate (4-5)" = "yellow",
      "Unhealthy (6-7)" = "orange",
      "Very Unhealthy (8-9)" = "red",
      "Hazardous (10+)" = "purple"
    ),
    name = "Risk Levels"                          # Legend title
  ) +
  scale_x_continuous(
    breaks = c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335),  # Approximate start of each month
    labels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  ) +
  labs(
    title = "Nkangala Daily Air Quality Health Index",
    x = "Month",
    y = "Year"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(face = "bold", angle = 90, hjust = 1), # Rotate x-axis labels for better readability
    axis.text.y = element_text(face = "bold"),
    legend.position = "bottom",                        # Move legend below the plot
    legend.title = element_text(size = 10, face = "bold"),            # Adjust legend title size
    legend.text = element_text(face = "bold", size = 8),
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold"))






