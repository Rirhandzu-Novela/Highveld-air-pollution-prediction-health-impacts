# Load necessary libraries
library(tidyverse)
library("openair")
library(dplyr)
library(zoo)

Nka = read.csv("AirData/Nkangala.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Nka$date <- dateTime


df <- Nka %>%
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
  left_join(df, by = "date")

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
    aqhi_o3   = calculate_aqhi(excess_risk_o3, aqhi_o3)
  ) %>%
  mutate(
    weight_pm10 = 1,  # Weight of PM10 is defined to be 1
    weight_no2  = excess_risk_pm10 / excess_risk_no2,
    weight_so2  = excess_risk_pm10 / excess_risk_so2,
    weight_o3   = excess_risk_pm10 / excess_risk_o3
  ) %>%
  rowwise() %>%
  mutate(
    weighted_aqhi = round(
      sum(c(weight_pm10, weight_no2, weight_so2, weight_o3) * 
            c(as.numeric(aqhi_pm10), as.numeric(aqhi_no2), as.numeric(aqhi_so2), as.numeric(aqhi_o3))) / 
        sum(c(weight_pm10, weight_no2, weight_so2, weight_o3)))
  ) %>%
  ungroup()  %>%
  mutate(
    risk_level = case_when(
      weighted_aqhi >= 1 & weighted_aqhi <= 3 ~ "Low risk",
      weighted_aqhi >= 4 & weighted_aqhi <= 6 ~ "Moderate risk",
      weighted_aqhi >= 7 & weighted_aqhi <= 10 ~ "High risk",
      TRUE ~ NA_character_  # Handle any cases that don't match the conditions (if necessary)
    )) %>% 
  select(date, weighted_aqhi, risk_level)

NkaPollCardMort = read.csv("MortData/NkaPollCardMort.csv", header = T, sep = ";")
NkaPollCardMort$date <- as.Date(NkaPollCardMort$date, format = "%Y/%m/%d")

NkacartCardMort = read.csv("MortData/NkacardMort.csv", header = T, sep = ";")
NkacartCardMort$date <- as.Date(NkacartCardMort$date, format = "%Y/%m/%d")


NkacartCardMort <- NkacartCardMort %>% 
  select(date, J09_J18, J20_J22, J40_J47, J80_J84, J95_J99)

NkaPollCardMortAqhi <- NkaPollCardMort %>% 
  left_join(NkacartCardMort, by = "date") %>% 
  left_join(daily_df, by = "date")

write.csv(NkaPollCardMortAqhi, "MortData/NkaPollCardMortAqhi.csv", row.names = TRUE)

# Nkangala pulmonary 

NkaPollPulMort = read.csv("MortData/NkaPollPulMort.csv", header = T, sep = ";")
NkaPollPulMort$date <- as.Date(NkaPollPulMort$date, format = "%Y/%m/%d")

NkacartPulMort = read.csv("MortData/NkaPullMort.csv", header = T, sep = ";")
NkacartPulMort$date <- as.Date(NkacartPulMort$date, format = "%Y/%m/%d")


NkacartPulMort <- NkacartPulMort %>% 
  select(date, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69)

NkaPollPulMortAqhi <- NkaPollPulMort %>% 
  left_join(NkacartPulMort, by = "date") %>% 
  left_join(daily_df, by = "date")

write.csv(NkaPollPulMortAqhi, "MortData/NkaPollPulMortAqhi.csv", row.names = TRUE)


# Gert Sibande

Gert = read.csv("AirData/Gerts.csv", header = T, sep = ";")

# the dates must be a "POSIXct" "POSIXt" object. Those in your csv file are not.
dateTime <- seq(as.POSIXct("2009-01-01 01:00"), as.POSIXct("2018-12-31 22:00"), by = "1 hours", tz = 'UTC')

# replace the dates in your csv file with the created "POSIXct" "POSIXt" date object
Gert$date <- dateTime


df <- Gert %>%
  select(date, o3) %>% 
  mutate(
    ozone_8hr_avg = rollapply(o3, width = 8, FUN = mean, align = "right", fill = NA)
  ) %>%
  mutate(date = as.Date(date)) %>%
  group_by(date) %>%
  summarise(
    o3 = max(rollapply(ozone_8hr_avg, width = 3, FUN = mean, align = "right", fill = NA), na.rm = TRUE)
  )


GertDaily = read.csv("AirData/GertsDaily.csv", header = T, sep = ";")
GertDaily$date <- as.Date(GertDaily$date, format = "%Y/%m/%d")

GertDaily <- GertDaily %>% 
  select(-o3) %>% 
  left_join(df, by = "date")

beta_values <- list(
  pm2.5 = 0.00065,
  pm10  = 0.00041,
  no2   = 0.00072,
  so2   = 0.00059,
  o3    = 0.00043
)

# Calculate the excess risk for each pollutant
GertDaily <- GertDaily %>%
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
daily_df <- GertDaily %>%
  mutate(
    aqhi_pm10 = calculate_aqhi(excess_risk_pm10, aqhi_pm10),
    aqhi_no2  = calculate_aqhi(excess_risk_no2, aqhi_no2),
    aqhi_so2  = calculate_aqhi(excess_risk_so2, aqhi_so2),
    aqhi_o3   = calculate_aqhi(excess_risk_o3, aqhi_o3)
  ) %>%
  mutate(
    weight_pm10 = 1,  # Weight of PM10 is defined to be 1
    weight_no2  = excess_risk_pm10 / excess_risk_no2,
    weight_so2  = excess_risk_pm10 / excess_risk_so2,
    weight_o3   = excess_risk_pm10 / excess_risk_o3
  ) %>%
  rowwise() %>%
  mutate(
    weighted_aqhi = round(
      sum(c(weight_pm10, weight_no2, weight_so2, weight_o3) * 
            c(as.numeric(aqhi_pm10), as.numeric(aqhi_no2), as.numeric(aqhi_so2), as.numeric(aqhi_o3))) / 
        sum(c(weight_pm10, weight_no2, weight_so2, weight_o3)))
  ) %>%
  ungroup()  %>%
  mutate(
    risk_level = case_when(
      weighted_aqhi >= 1 & weighted_aqhi <= 3 ~ "Low risk",
      weighted_aqhi >= 4 & weighted_aqhi <= 6 ~ "Moderate risk",
      weighted_aqhi >= 7 & weighted_aqhi <= 10 ~ "High risk",
      TRUE ~ NA_character_  # Handle any cases that don't match the conditions (if necessary)
    )) %>% 
  select(date, weighted_aqhi, risk_level)

# Cardiovascular
GertPollCardMort = read.csv("MortData/GertPollCardMort.csv", header = T, sep = ";")
GertPollCardMort$date <- as.Date(GertPollCardMort$date, format = "%Y/%m/%d")

GertcartCardMort = read.csv("MortData/GertcardMort.csv", header = T, sep = ";")
GertcartCardMort$date <- as.Date(GertcartCardMort$date, format = "%Y/%m/%d")


GertcartCardMort <- GertcartCardMort %>% 
  select(date, J09_J18, J20_J22, J40_J47, J80_J84, J95_J99)

GertPollCardMortAqhi <- GertPollCardMort %>% 
  left_join(GertcartCardMort, by = "date") %>% 
  left_join(daily_df, by = "date")

write.csv(GertPollCardMortAqhi, "MortData/GertPollCardMortAqhi.csv", row.names = TRUE)

# Pulmonary 

GertPollPulMort = read.csv("MortData/GertPollPulMort.csv", header = T, sep = ";")
GertPollPulMort$date <- as.Date(GertPollPulMort$date, format = "%Y/%m/%d")

GertcartPulMort = read.csv("MortData/GertPullMort.csv", header = T, sep = ";")
GertcartPulMort$date <- as.Date(GertcartPulMort$date, format = "%Y/%m/%d")


GertcartPulMort <- GertcartPulMort %>% 
  select(date, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69)

GertPollPulMortAqhi <- GertPollPulMort %>% 
  left_join(GertcartPulMort, by = "date") %>% 
  left_join(daily_df, by = "date")

write.csv(GertPollPulMortAqhi, "MortData/GertPollPulMortAqhi.csv", row.names = TRUE)
