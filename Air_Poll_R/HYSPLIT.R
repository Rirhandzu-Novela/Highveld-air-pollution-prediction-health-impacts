# Load packages -----------------------------------------------------------

library(tidyverse)
library(openair)
library(novaAQM)
library(splitr)
library(devtools)
library(plotly)
library(openairmaps)
library(corrplot)
library(Hmisc)
##animator

# OpenAir -----------------------------------------------------------------

#GET METEOROLOGY DATA

getMet <- function(year = 2023, month = 1,
                   path_met = "~/TrajData/") {
  for (i in seq_along(year)) {
    for (j in seq_along(month)) {
      download.file(
        url = paste0(
          "https://www.ready.noaa.gov/data/archives/reanalysis/RP",
          year[i], sprintf("%02d", month[j]), ".gbl"
        ),
        destfile = paste0(
          path_met, "RP", year[i],
          sprintf("%02d", month[j]), ".gbl"
        ),
        mode = "wb"
      )
    }
  }
}


#getMet(year = 2024, month = 1:2, path_met =  "C:/Users/REAL/Downloads/sasolBase2AQcampaings/TrajData/")

## RUN HYSPLIT MODEL

source_gist("https://gist.github.com/davidcarslaw/c67e33a04ff6e1be0cd7357796e4bdf5",
            filename = "run_hysplit.R")

#file_list <- list.files(hysplit_output, "hysplit_output.txt", full.name = TRUE)

data_out <- run_hysplit(
  latitude = -26.56123474,
  longitude = 29.08227378,
  runtime = -96,
  start_height = 10,
  model_height = 10000,
  start = "2023-01-01",
  end = "2023-12-31",
  hysplit_exec = "C:/hysplit/exec",
  hysplit_input = "C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/TrajData",
  hysplit_output = "C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/RDS",
  site = "eMbalenhle")


saveRDS(data_out, file = "C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/RDS/WTrajData.rds")

## USE OPENAIR TO PLOT TRAJECTORIES


trajec <- readRDS("C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/RDS/WTrajData.rds")

head(trajec)

selectByDate(trajec,
             start = "10-03-2023",
             end = "20-03-2023"
) %>%
  trajPlot(
    map.cols = openColours("hue", 10),
    col = "grey30"
  )



## make a day column
trajec$day <- as.Date(trajec$date)

## plot it choosing a specific layout
selectByDate(trajec,
             start = "10/3/2023",
             end = "20/3/2023"
) %>%
  trajPlot(
    type = "day",
    layout = c(6, 2)
  )

selectByDate(trajec,
             start = "10/3/2023",
             end = "20/3/2023"
) %>%
  trajPlot(
    group = "day", col = "turbo",
    lwd = 2, key.pos = "top",
    key.col = 4,
    xlim = c(25, 35),
    ylim = c(-35, -22)
  )


# Trajectories ----------------------------------------------------------------


## Allocate trajectories to different wind direction

alloc <- trajec

id <- which(alloc$hour.inc == 0)
y0 <- alloc$lat[id[1]]
x0 <- alloc$lon[id[1]]

## calculate angle and then assign sector
alloc <- mutate(
  alloc,
  angle = atan2(lon - x0, lat - y0) * 360 / 2 / pi,
  angle = ifelse(angle < 0, angle + 360 , angle),
  sector = cut(angle,
               breaks = seq(22.5, 382.5, 45),
               labels = c("NE", "E", "SE",
                          "S", "SW", "W",
                          "NW", "N")),
  sector = as.character(sector),
  sector = ifelse(is.na(sector), "N", sector)
)

alloc <- group_by(alloc, date, sector) %>%
  mutate(n = n()) %>%
  group_by(date) %>%
  arrange(date, n) %>%
  slice_tail(n = 1) %>%
  mutate(sector = ifelse(n > 50, sector, "unallocated")) %>%
  select(date, sector, n)

# combine with trajectories
traj <- left_join(trajec, alloc, by = "date")

trajP <- left_join(traj, eMalahleniIM, by = "date")

group_by(trajP, sector) %>%
  summarise(PM10 = mean(pm10, na.rm = TRUE))

group_by(trajP, sector) %>%
  summarise(n = n()) %>%
  mutate(percent = 100 * n / nrow(trajP))


gg <- ggplot(trajP, aes(x = date, y = pm10, color = sector)) +
  geom_point() +
  labs(title = 'PM10 Wind Direction Clustering',
       x = 'Date',
       y = 'PM10')

# Convert ggplot to Plotly
p <- ggplotly(gg)



filter(trajP, lat > -34 & lat < -22 & lon > 25 & lon < 33) %>%
  trajLevel(
    pollutant = "co",
    statistic = "pscf",
    percentile = 50,
    smooth = FALSE,
    col = "increment",
    border = "white",
    grid.col = "transparent"
  )


trajLevel(trajP,
          pollutant = "co",
          statistic =  "sqtba",
          map.fill = FALSE,
          cols = "default",
          lat.inc = 0.5,
          lon.inc = 0.5,
          xlim = c(25, 33),
          ylim = c(-34, -22),
          grid.col = "transparent"
)


clust <- trajCluster(trajec, method = "Angle",
                     n.cluster = 6,
                     col = "Set2",
                     map.cols = openColours("Paired", 10),
                     grid.col = "transparent")

#trajPlot(clust$data$traj, group = "cluster", grid.col = "transparent")

trajLevel(clust$data$traj, type = "cluster",
          col = "increment",
          border = NA, grid.col = "transparent")

cluster_trajP <- inner_join(cleaned_data,
                  filter(clust$data$traj, hour.inc == 0),
                  by = "date")


table(cluster_trajP[["cluster"]])

group_by(cluster_trajP, cluster) %>%
  summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))


gg <- ggplot(cluster_trajP, aes(x = date, y = pm10, color = cluster)) +
  geom_point() +
  labs(title = 'PM10 Trajectory Clustering',
       x = 'Date',
       y = 'PM10')

# Convert ggplot to Plotly
p <- ggplotly(gg)




# Ermelo ----------------------------------------------------------------

## RUN HYSPLIT MODEL
source_gist("https://gist.github.com/davidcarslaw/c67e33a04ff6e1be0cd7357796e4bdf5",
            filename = "run_hysplit.R")

Ldata_out <- run_hysplit(
  latitude = -26.38097458,
  longitude = 28.93727302,
  runtime = -96,
  start_height = 10,
  model_height = 10000,
  start = "2023-01-01",
  end = "2023-12-31",
  hysplit_exec = "C:/hysplit/exec",
  hysplit_input = "C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/TrajData",
  hysplit_output = "C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/RDS",
  site = "eMbalenhle")


saveRDS(Ldata_out, file = "C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/RDS/LTrajData.rds")



trajec <- readRDS("C:/Users/User/Documents/GitHub/Health-impacts-of-air-pollution/RDS/LTrajData.rds")

head(trajec)

selectByDate(trajec,
             start = "10-03-2023",
             end = "20-03-2023"
) %>%
  trajPlot(
    map.cols = openColours("hue", 10),
    col = "grey30"
  )



## make a day column
trajec$day <- as.Date(trajec$date)

## plot it choosing a specific layout
selectByDate(trajec,
             start = "10/3/2023",
             end = "20/3/2023"
) %>%
  trajPlot(
    type = "day",
    layout = c(6, 2)
  )

selectByDate(trajec,
             start = "10/3/2023",
             end = "20/3/2023"
) %>%
  trajPlot(
    group = "day", col = "turbo",
    lwd = 2, key.pos = "top",
    key.col = 4,
    xlim = c(25, 35),
    ylim = c(-35, -22)
  )


# Trajectories ----------------------------------------------------------------


## Allocate trajectories to different wind direction

alloc <- trajec

id <- which(alloc$hour.inc == 0)
y0 <- alloc$lat[id[1]]
x0 <- alloc$lon[id[1]]

## calculate angle and then assign sector
alloc <- mutate(
  alloc,
  angle = atan2(lon - x0, lat - y0) * 360 / 2 / pi,
  angle = ifelse(angle < 0, angle + 360 , angle),
  sector = cut(angle,
               breaks = seq(22.5, 382.5, 45),
               labels = c("NE", "E", "SE",
                          "S", "SW", "W",
                          "NW", "N")),
  sector = as.character(sector),
  sector = ifelse(is.na(sector), "N", sector)
)

alloc <- group_by(alloc, date, sector) %>%
  mutate(n = n()) %>%
  group_by(date) %>%
  arrange(date, n) %>%
  slice_tail(n = 1) %>%
  mutate(sector = ifelse(n > 50, sector, "unallocated")) %>%
  select(date, sector, n)

# combine with trajectories
traj <- left_join(trajec, alloc, by = "date")

trajP <- left_join(traj, ErmeloIM, by = "date")

group_by(trajP, sector) %>%
  summarise(PM10 = mean(pm10, na.rm = TRUE))

group_by(trajP, sector) %>%
  summarise(n = n()) %>%
  mutate(percent = 100 * n / nrow(trajP))


gg <- ggplot(trajP, aes(x = date, y = pm10, color = sector)) +
  geom_point() +
  labs(title = 'PM10 Wind Direction Clustering',
       x = 'Date',
       y = 'PM10')

# Convert ggplot to Plotly
p <- ggplotly(gg)



filter(trajP, lat > -34 & lat < -22 & lon > 25 & lon < 33) %>%
  trajLevel(
    pollutant = "no2",
    statistic = "pscf",
    percentile = 50,
    smooth = FALSE,
    col = "increment",
    border = "white",
    grid.col = "transparent"
  )


trajLevel(trajP,
          pollutant = "no2",
          statistic =  "sqtba",
          map.fill = FALSE,
          cols = "default",
          lat.inc = 0.5,
          lon.inc = 0.5,
          xlim = c(25, 33),
          ylim = c(-34, -22),
          grid.col = "transparent"

)


clust <- trajCluster(trajec, method = "Angle",
                     n.cluster = 1,
                     col = "Set2",
                     map.cols = openColours("Paired", 10),
                     xlim = c(25, 33),
                     ylim = c(-34, -22),
                     grid.col = "transparent")

#trajPlot(clust$data$traj, group = "cluster", grid.col = "transparent")

trajLevel(clust$data$traj, type = "cluster",
          col = "increment",
          border = NA, grid.col = "transparent")

cluster_trajP <- inner_join(cleaned_data,
                            filter(clust$data$traj, hour.inc == 0),
                            by = "date")


table(cluster_trajP[["cluster"]])

group_by(cluster_trajP, cluster) %>%
  summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))


gg <- ggplot(cluster_trajP, aes(x = date, y = pm10, color = cluster)) +
  geom_point() +
  labs(title = 'PM10 Trajectory Clustering',
       x = 'Date',
       y = 'PM10')

# Convert ggplot to Plotly
p <- ggplotly(gg)




