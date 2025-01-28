# Finishing is not just an end; 
# it's the punctuation mark that completes the story, 
# the brushstroke that finalizes the masterpiece. 
# It transforms effort into accomplishment, turning dreams into reality.


# Load necessary libraries
library(tidyverse)
library("openair")
library(dplyr)
library(zoo)

# Load the dataset
# Replace 'air_quality_data.xlsx' with the name of your Excel file
data <- read.csv("MortData/NkaPollCardMortAqhi.csv", header = T, sep = ";") 

# Convert the 'date' column to Date format
data$date <- as.Date(data$date)

# Extract the year from the date column
data$year <- format(data$date, "%Y")

# Group by year and risk_level, then count the number of days in each risk_level per year

risk_level_counts <- data %>%
  group_by(weighted_aqhi) %>%
  summarise(days_count = n(),
            pm2.5 = mean(pm2.5),
            pm10 = mean(pm10),
            so2 = mean(so2),
            no2 = mean(no2),
            o3 = mean(o3),
            .groups = "drop")


# Optionally, save the result to a CSV file
write.csv(risk_level_counts, "RDA/Nkarisk_level_counts.csv", row.names = TRUE)


# Exceedances


# Calculate the number of days pollutants exceed the daily standards
exceedance_counts <- data %>%
  mutate(
    pm2.5_exceed = ifelse(pm2.5 > 40, 1, 0),  # PM2.5 exceeds 40
    pm10_exceed = ifelse(pm10 > 75, 1, 0),    # PM10 exceeds 75
    so2_exceed = ifelse(so2 > 48, 1, 0)       # SO2 exceeds 48
  ) %>%
  group_by(year) %>%
  summarise(
    pm2.5_exceed_days = sum(pm2.5_exceed, na.rm = TRUE),
    pm10_exceed_days = sum(pm10_exceed, na.rm = TRUE),
    so2_exceed_days = sum(so2_exceed, na.rm = TRUE)
  )


# Optionally, save the result to a CSV file
write.csv(exceedance_counts, "RDA/Nkaexceedance_counts.csv", row.names = FALSE)


# heatmap

df <- data %>%
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

