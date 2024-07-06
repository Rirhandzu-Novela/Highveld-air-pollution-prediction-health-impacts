
# eMalahleni --------------------------------------------------------------

WNOTempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2009")
WNOTempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2010")
WNOTempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2011")
WNOTempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2012")
WNOTempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2013")
WNOTempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2014")
WNOTempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2015")
WNOTempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2016")
WNOTempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2017")
WNOTempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at eMalahleni in 2018")

WNOTempplot <- timeVariation(eMalahleni_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at eMalahleni")

WtrendNO <- TheilSen(eMalahleni_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at eMalahleni")

save(WNOTempplot09, WNOTempplot10,
     WNOTempplot11,WNOTempplot12,
     WNOTempplot13,WNOTempplot14,
     WNOTempplot15,WNOTempplot16,
     WNOTempplot17,WNOTempplot18,
     WtrendNO,WNOTempplot,
     file = "Graph/WTempoaral_plotNO.Rda")

WNOXTempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2009")
WNOXTempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2010")
WNOXTempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2011")
WNOXTempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2012")
WNOXTempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2013")
WNOXTempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2014")
WNOXTempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2015")
WNOXTempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2016")
WNOXTempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at eMalahleni in 2017")

WNOXTempplot <- timeVariation(eMalahleni_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at eMalahleni")

WtrendNOX <- TheilSen(eMalahleni_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at eMalahleni")

save(WNOXTempplot09, WNOXTempplot10,
     WNOXTempplot11,WNOXTempplot12,
     WNOXTempplot13,WNOXTempplot14,
     WNOXTempplot15,WNOXTempplot16,
     WNOXTempplot17,WNOXTempplot18,
     WtrendNOX,WNOXTempplot,
     file = "Graph/WTempoaral_plotNOX.Rda")

WCOTempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2009")
WCOTempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2010")
WCOTempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2011")
WCOTempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2012")
WCOTempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2013")
WCOTempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2014")
WCOTempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2015")
WCOTempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2016")
WCOTempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2017")
WCOTempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at eMalahleni in 2018")

WCOTempplot <- timeVariation(eMalahleni_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at eMalahleni")

WtrendCO <- TheilSen(eMalahleni_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at eMalahleni")

save(WCOTempplot09, WCOTempplot10,
     WCOTempplot11,WCOTempplot12,
     WCOTempplot13,WCOTempplot14,
     WCOTempplot15,WCOTempplot16,
     WCOTempplot17,WCOTempplot18,
     WtrendCO,WCOTempplot,
     file = "Graph/WTempoaral_plotCO.Rda")

WO3Tempplot09 <- timeVariation(eMalahleni_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2009")
WO3Tempplot10 <- timeVariation(eMalahleni_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2010")
WO3Tempplot11 <- timeVariation(eMalahleni_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2011")
WO3Tempplot12 <- timeVariation(eMalahleni_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2012")
WO3Tempplot13 <- timeVariation(eMalahleni_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2013")
WO3Tempplot14 <- timeVariation(eMalahleni_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2014")
WO3Tempplot15 <- timeVariation(eMalahleni_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2015")
WO3Tempplot16 <- timeVariation(eMalahleni_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2016")
WO3Tempplot17 <- timeVariation(eMalahleni_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2017")
WO3Tempplot18 <- timeVariation(eMalahleni_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at eMalahleni in 2018")
WO3Tempplot <- timeVariation(eMalahleni_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at eMalahleni")

WtrendO3 <- TheilSen(eMalahleni_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at eMalahleni")

save(WO3Tempplot09, WO3Tempplot10,
     WO3Tempplot11,WO3Tempplot12,
     WO3Tempplot13,WO3Tempplot14,
     WO3Tempplot15,WO3Tempplot16,
     WO3Tempplot17,WO3Tempplot18,
     WtrendO3,WO3Tempplot,
     file = "Graph/WTempoaral_plotO3.Rda")

WBoxnoCompare <- ggplot(data = eMalahleni_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

WBoxnoCompare

WBoxnoxCompare <- ggplot(data = eMalahleni_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

WBoxnoxCompare

WBoxo3Compare <- ggplot(data = eMalahleni_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

WBoxnoCompare

WBoxcoCompare <- ggplot(data = eMalahleni_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at eMalahleni",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

WBoxcoCompare


# NO --------------------------------------------------------------------

WNOallpolar <- polarMap(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

WNOstdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

WNOweighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


WNOfrequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

WNOper50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



WNOper60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WNOper70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WNOper80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WNOper90 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WNOper98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WNOper99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



WNO_CPFplot = list(WNOallpolar$plot,
                   WNOstdev$plot,
                   WNOfrequency$plot,
                   WNOweighted$plot,
                   WNOper50$plot,
                   WNOper60$plot,
                   WNOper70$plot,
                   WNOper80$plot,
                   WNOper90$plot,
                   WNOper98$plot,
                   WNOper99$plot)

do.call("grid.arrange", WNO_CPFplot)

# CO --------------------------------------------------------------------

WCOallpolar <- polarMap(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

WCOstdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


WCOweighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


WCOfrequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



WCOper50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



WCOper60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WCOper70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WCOper80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WCOper90 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WCOper98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WCOper99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



WCO_CPFplot = list(WCOallpolar$plot,
                   WCOstdev$plot,
                   WCOfrequency$plot,
                   WCOweighted$plot,
                   WCOper50$plot,
                   WCOper60$plot,
                   WCOper70$plot,
                   WCOper80$plot,
                   WCOper90$plot,
                   WCOper98$plot,
                   WCOper99$plot)

do.call("grid.arrange", WCO_CPFplot)


# NOX --------------------------------------------------------------------

WNOXallpolar <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

WNOXstdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

WNOXweighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


WNOXfrequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


WNOXper50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



WNOXper60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WNOXper70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


WNOXper80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


WNOXper90 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

WNOXper98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WNOXper99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



WNOX_CPFplot = list(WNOXallpolar$plot,
                    WNOXstdev$plot,
                    WNOXfrequency$plot,
                    WNOXweighted$plot,
                    WNOXper50$plot,
                    WNOXper60$plot,
                    WNOXper70$plot,
                    WNOXper80$plot,
                    WNOXper90$plot,
                    WNOXper98$plot,
                    WNOXper99$plot)

do.call("grid.arrange", WNOX_CPFplot)



# O3 ----------------------------------------------------------------------

WO3allpolar <- polarMap(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

WO3stdev <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


WO3weighted <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

WO3frequency <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



WO3per50 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



WO3per60 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


WO3per70 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

WO3per80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

WO3per80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

WO3per80 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



WO3per98 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

WO3per99 <- polarPlot(
  Wpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

WO3_polarplot = list(WO3allpolar$plot,
                     WO3stdev$plot,
                     WO3weighted$plot,
                     WO3frequency$plot,
                     WO3per50$plot,
                     WO3per60$plot,
                     WO3per70$plot,
                     WO3per80$plot,
                     WO3per90$plot,
                     WO3per98$plot,
                     WO3per99$plot)
do.call("grid.arrange", WO3_polarplot)


# Ermelo ------------------------------------------------------------------

ENOTempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2009")
ENOTempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2010")
ENOTempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2011")
ENOTempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2012")
ENOTempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2013")
ENOTempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2014")
ENOTempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2015")
ENOTempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2016")
ENOTempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2017")
ENOTempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Ermelo in 2018")

ENOTempplot <- timeVariation(Ermelo_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Ermelo")

EtrendNO <- TheilSen(Ermelo_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Ermelo")

save(ENOTempplot09, ENOTempplot10,
     ENOTempplot11,ENOTempplot12,
     ENOTempplot13,ENOTempplot14,
     ENOTempplot15,ENOTempplot16,
     ENOTempplot17,ENOTempplot18,
     EtrendNO,ENOTempplot,
     file = "Graph/ETempoaral_plotNO.Rda")

ENOXTempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2009")
ENOXTempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2010")
ENOXTempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2011")
ENOXTempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2012")
ENOXTempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2013")
ENOXTempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2014")
ENOXTempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2015")
ENOXTempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2016")
ENOXTempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Ermelo in 2017")

ENOXTempplot <- timeVariation(Ermelo_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Ermelo")

EtrendNOX <- TheilSen(Ermelo_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Ermelo")

save(ENOXTempplot09, ENOXTempplot10,
     ENOXTempplot11,ENOXTempplot12,
     ENOXTempplot13,ENOXTempplot14,
     ENOXTempplot15,ENOXTempplot16,
     ENOXTempplot17,ENOXTempplot18,
     EtrendNOX,ENOXTempplot,
     file = "Graph/ETempoaral_plotNOX.Rda")

ECOTempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2009")
ECOTempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2010")
ECOTempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2011")
ECOTempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2012")
ECOTempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2013")
ECOTempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2014")
ECOTempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2015")
ECOTempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2016")
ECOTempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2017")
ECOTempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Ermelo in 2018")

ECOTempplot <- timeVariation(Ermelo_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Ermelo")

EtrendCO <- TheilSen(Ermelo_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Ermelo")

save(ECOTempplot09, ECOTempplot10,
     ECOTempplot11,ECOTempplot12,
     ECOTempplot13,ECOTempplot14,
     ECOTempplot15,ECOTempplot16,
     ECOTempplot17,ECOTempplot18,
     EtrendCO,ECOTempplot,
     file = "Graph/ETempoaral_plotCO.Rda")

EO3Tempplot09 <- timeVariation(Ermelo_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2009")
EO3Tempplot10 <- timeVariation(Ermelo_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2010")
EO3Tempplot11 <- timeVariation(Ermelo_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2011")
EO3Tempplot12 <- timeVariation(Ermelo_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2012")
EO3Tempplot13 <- timeVariation(Ermelo_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2013")
EO3Tempplot14 <- timeVariation(Ermelo_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2014")
EO3Tempplot15 <- timeVariation(Ermelo_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2015")
EO3Tempplot16 <- timeVariation(Ermelo_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2016")
EO3Tempplot17 <- timeVariation(Ermelo_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2017")
EO3Tempplot18 <- timeVariation(Ermelo_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Ermelo in 2018")
EO3Tempplot <- timeVariation(Ermelo_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Ermelo")

EtrendO3 <- TheilSen(Ermelo_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Ermelo")

save(EO3Tempplot09, EO3Tempplot10,
     EO3Tempplot11,EO3Tempplot12,
     EO3Tempplot13,EO3Tempplot14,
     EO3Tempplot15,EO3Tempplot16,
     EO3Tempplot17,EO3Tempplot18,
     EtrendO3,EO3Tempplot,
     file = "Graph/ETempoaral_plotO3.Rda")

EBoxnoCompare <- ggplot(data = Ermelo_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

EBoxnoCompare

EBoxnoxCompare <- ggplot(data = Ermelo_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

EBoxnoxCompare

EBoxo3Compare <- ggplot(data = Ermelo_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

EBoxnoCompare

EBoxcoCompare <- ggplot(data = Ermelo_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at Ermelo",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

EBoxcoCompare

# NO --------------------------------------------------------------------

ENOallpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

ENOstdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

ENOweighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


ENOfrequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

ENOper50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



ENOper60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


ENOper70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


ENOper80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


ENOper90 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

ENOper98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

ENOper99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



ENO_CPFplot = list(ENOallpolar$plot,
                   ENOstdev$plot,
                   ENOfrequency$plot,
                   ENOweighted$plot,
                   ENOper50$plot,
                   ENOper60$plot,
                   ENOper70$plot,
                   ENOper80$plot,
                   ENOper90$plot,
                   ENOper98$plot,
                   ENOper99$plot)

do.call("grid.arrange", ENO_CPFplot)

# CO --------------------------------------------------------------------

ECOallpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

ECOstdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


ECOweighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


ECOfrequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



ECOper50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



ECOper60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


ECOper70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


ECOper80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


ECOper90 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

ECOper98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

ECOper99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



ECO_CPFplot = list(ECOallpolar$plot,
                   ECOstdev$plot,
                   ECOfrequency$plot,
                   ECOweighted$plot,
                   ECOper50$plot,
                   ECOper60$plot,
                   ECOper70$plot,
                   ECOper80$plot,
                   ECOper90$plot,
                   ECOper98$plot,
                   ECOper99$plot)

do.call("grid.arrange", ECO_CPFplot)


# NOX --------------------------------------------------------------------

ENOXallpolar <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

ENOXstdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

ENOXweighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


ENOXfrequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


ENOXper50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



ENOXper60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


ENOXper70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


ENOXper80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


ENOXper90 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

ENOXper98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

ENOXper99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



ENOX_CPFplot = list(ENOXallpolar$plot,
                    ENOXstdev$plot,
                    ENOXfrequency$plot,
                    ENOXweighted$plot,
                    ENOXper50$plot,
                    ENOXper60$plot,
                    ENOXper70$plot,
                    ENOXper80$plot,
                    ENOXper90$plot,
                    ENOXper98$plot,
                    ENOXper99$plot)

do.call("grid.arrange", ENOX_CPFplot)



# O3 ----------------------------------------------------------------------

EO3allpolar <- polarMap(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

EO3stdev <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


EO3weighted <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

EO3frequency <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



EO3per50 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



EO3per60 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


EO3per70 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

EO3per80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

EO3per80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

EO3per80 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



EO3per98 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

EO3per99 <- polarPlot(
  Epolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

EO3_polarplot = list(EO3allpolar$plot,
                     EO3stdev$plot,
                     EO3weighted$plot,
                     EO3frequency$plot,
                     EO3per50$plot,
                     EO3per60$plot,
                     EO3per70$plot,
                     EO3per80$plot,
                     EO3per90$plot,
                     EO3per98$plot,
                     E3per99$plot)
do.call("grid.arrange", EO3_polarplot)



# Hendrina ----------------------------------------------------------------

HNOTempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2009")
HNOTempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2010")
HNOTempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2011")
HNOTempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2012")
HNOTempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2013")
HNOTempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2014")
HNOTempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2015")
HNOTempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2016")
HNOTempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2017")
HNOTempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Hendrina in 2018")

HNOTempplot <- timeVariation(Hendrina_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Hendrina")

HtrendNO <- TheilSen(Hendrina_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Hendrina")

save(HNOTempplot09, WNOTempplot10,
     HNOTempplot11,WNOTempplot12,
     HNOTempplot13,WNOTempplot14,
     HNOTempplot15,WNOTempplot16,
     HNOTempplot17,WNOTempplot18,
     HtrendNO,WNOTempplot,
     file = "Graph/HTempoaral_plotNO.Rda")

HNOXTempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2009")
HNOXTempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2010")
HNOXTempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2011")
HNOXTempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2012")
HNOXTempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2013")
HNOXTempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2014")
HNOXTempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2015")
HNOXTempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2016")
HNOXTempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Hendrina in 2017")

HNOXTempplot <- timeVariation(Hendrina_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Hendrina")

HtrendNOX <- TheilSen(Hendrina_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Hendrina")

save(HNOXTempplot09, HNOXTempplot10,
     HNOXTempplot11,HNOXTempplot12,
     HNOXTempplot13,HNOXTempplot14,
     HNOXTempplot15,HNOXTempplot16,
     HNOXTempplot17,HNOXTempplot18,
     HtrendNOX,HNOXTempplot,
     file = "Graph/HTempoaral_plotNOX.Rda")

HCOTempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2009")
HCOTempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2010")
HCOTempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2011")
HCOTempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2012")
HCOTempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2013")
HCOTempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2014")
HCOTempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2015")
HCOTempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2016")
HCOTempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2017")
HCOTempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Hendrina in 2018")

HCOTempplot <- timeVariation(Hendrina_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Hendrina")

HtrendCO <- TheilSen(Hendrina_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Hendrina")

save(HCOTempplot09, HCOTempplot10,
     HCOTempplot11,HCOTempplot12,
     HCOTempplot13,HCOTempplot14,
     HCOTempplot15,HCOTempplot16,
     HCOTempplot17,HCOTempplot18,
     HtrendCO,HCOTempplot,
     file = "Graph/HTempoaral_plotCO.Rda")

HO3Tempplot09 <- timeVariation(Hendrina_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2009")
HO3Tempplot10 <- timeVariation(Hendrina_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2010")
HO3Tempplot11 <- timeVariation(Hendrina_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2011")
HO3Tempplot12 <- timeVariation(Hendrina_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2012")
HO3Tempplot13 <- timeVariation(Hendrina_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2013")
HO3Tempplot14 <- timeVariation(Hendrina_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2014")
HO3Tempplot15 <- timeVariation(Hendrina_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2015")
HO3Tempplot16 <- timeVariation(Hendrina_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2016")
HO3Tempplot17 <- timeVariation(Hendrina_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2017")
HO3Tempplot18 <- timeVariation(Hendrina_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Hendrina in 2018")
HO3Tempplot <- timeVariation(Hendrina_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Hendrina")

HtrendO3 <- TheilSen(Hendrina_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Hendrina")

save(HO3Tempplot09, HO3Tempplot10,
     HO3Tempplot11,HO3Tempplot12,
     HO3Tempplot13,HO3Tempplot14,
     HO3Tempplot15,HO3Tempplot16,
     HO3Tempplot17,HO3Tempplot18,
     HtrendO3,HO3Tempplot,
     file = "Graph/HTempoaral_plotO3.Rda")

HBoxnoCompare <- ggplot(data = Hendrina_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

HBoxnoCompare

HBoxnoxCompare <- ggplot(data = Hendrina_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

HBoxnoxCompare

HBoxo3Compare <- ggplot(data = Hendrina_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

HBoxnoCompare

HBoxcoCompare <- ggplot(data = Hendrina_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at Hendrina",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

HBoxcoCompare

# NO --------------------------------------------------------------------

HNOallpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

HNOstdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

HNOweighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


HNOfrequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


HNOper50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



HNOper60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HNOper70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HNOper80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HNOper90 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HNOper98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HNOper99 <- polarPlot(
  Lpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



HNO_CPFplot = list(HNOallpolar$plot,
                   HNOstdev$plot,
                   HNOfrequency$plot,
                   HNOweighted$plot,
                   HNOper50$plot,
                   HNOper60$plot,
                   HNOper70$plot,
                   HNOper80$plot,
                   HNOper90$plot,
                   HNOper98$plot,
                   HNOper99$plot)

do.call("grid.arrange", HNO_CPFplot)


# CO --------------------------------------------------------------------

HCOallpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO (ppb) concentrations",
  key.position = "right",
  key = TRUE
)

HCOstdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO (ppb) concentrations",
  key.position = "right",
  key = TRUE
)


HCOweighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO (ppb) concentrations",
  key.position = "right",
  key = TRUE
)


HCOfrequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)

HCOper50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO (ppb) sources at 50th percentile",
  key.position = "right",
  key = TRUE
)



HCOper60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HCOper70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HCOper80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HCOper90 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HCOper98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HCOper99 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



HCO_CPFplot = list(HCOallpolar$plot,
                   HCOstdev$plot,
                   HCOfrequency$plot,
                   HCOweighted$plot,
                   HCOper50$plot,
                   HCOper60$plot,
                   HCOper70$plot,
                   HCOper80$plot,
                   HCOper90$plot,
                   HCOper98$plot,
                   HCOper99$plot)

do.call("grid.arrange", HCO_CPFplot)


# NOX --------------------------------------------------------------------

HNOXallpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

HNOXstdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

HNOXweighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


HNOXfrequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


HNOXper50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



HNOXper60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HNOXper70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


HNOXper80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


HNOXper90 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

HNOXper98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HNOXper99 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



HNOX_CPFplot = list(HNOXallpolar$plot,
                    HNOXstdev$plot,
                    HNOXfrequency$plot,
                    HNOXweighted$plot,
                    HNOXper50$plot,
                    HNOXper60$plot,
                    HNOXper70$plot,
                    HNOXper80$plot,
                    HNOXper90$plot,
                    HNOXper98$plot,
                    HNOXper99$plot)

do.call("grid.arrange", HNOX_CPFplot)


# O3 --------------------------------------------------------------------

HO3allpolar <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

HO3stdev <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


HO3weighted <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean 03",
  key.position = "right",
  key = TRUE
)


HO3frequency <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

HO3per50 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)


HO3per60 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


HO3per70 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

HO3per80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

HO3per80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

HO3per80 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



HO3per98 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

HO3per99 <- polarPlot(
  Hpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

HO3_polarplot = list(HO3allpolar$plot,
                     HO3stdev$plot,
                     HO3weighted$plot,
                     HO3frequency$plot,
                     HO3per50$plot,
                     HO3per60$plot,
                     HO3per70$plot,
                     HO3per80$plot,
                     HO3per90$plot,
                     HO3per98$plot,
                     HO3per99$plot)
do.call("grid.arrange", HO3_polarplot)

# Middelburg --------------------------------------------------------------

MNOTempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2009")
MNOTempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2010")
MNOTempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2011")
MNOTempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2012")
MNOTempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2013")
MNOTempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2014")
MNOTempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2015")
MNOTempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2016")
MNOTempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2017")
WNOTempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Middelburg in 2018")

MNOTempplot <- timeVariation(Middelburg_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Middelburg")

MtrendNO <- TheilSen(Middelburg_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Middelburg")

save(MNOTempplot09, MNOTempplot10,
     MNOTempplot11,MNOTempplot12,
     MNOTempplot13,MNOTempplot14,
     MNOTempplot15,MNOTempplot16,
     MNOTempplot17,MNOTempplot18,
     MtrendNO,MNOTempplot,
     file = "Graph/MTempoaral_plotNO.Rda")

MNOXTempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2009")
MNOXTempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2010")
MNOXTempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2011")
MNOXTempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2012")
MNOXTempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2013")
MNOXTempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2014")
MNOXTempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2015")
MNOXTempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2016")
MNOXTempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Middelburg in 2017")

MNOXTempplot <- timeVariation(Middelburg_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Middelburg")

MtrendNOX <- TheilSen(Middelburg_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Middelburg")

save(MNOXTempplot09, MNOXTempplot10,
     MNOXTempplot11,MNOXTempplot12,
     MNOXTempplot13,MNOXTempplot14,
     MNOXTempplot15,MNOXTempplot16,
     MNOXTempplot17,MNOXTempplot18,
     MtrendNOX,MNOXTempplot,
     file = "Graph/MTempoaral_plotNOX.Rda")

MCOTempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2009")
MCOTempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2010")
MCOTempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2011")
MCOTempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2012")
MCOTempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2013")
MCOTempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2014")
MCOTempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2015")
MCOTempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2016")
MCOTempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2017")
WCOTempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Middelburg in 2018")

MCOTempplot <- timeVariation(Middelburg_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Middelburg")

MtrendCO <- TheilSen(Middelburg_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Middelburg")

save(MCOTempplot09, MCOTempplot10,
     MCOTempplot11,MCOTempplot12,
     MCOTempplot13,MCOTempplot14,
     MCOTempplot15,MCOTempplot16,
     MCOTempplot17,MCOTempplot18,
     MtrendCO,MCOTempplot,
     file = "Graph/MTempoaral_plotCO.Rda")

MO3Tempplot09 <- timeVariation(Middelburg_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2009")
MO3Tempplot10 <- timeVariation(Middelburg_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2010")
MO3Tempplot11 <- timeVariation(Middelburg_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2011")
MO3Tempplot12 <- timeVariation(Middelburg_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2012")
MO3Tempplot13 <- timeVariation(Middelburg_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2013")
MO3Tempplot14 <- timeVariation(Middelburg_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2014")
MO3Tempplot15 <- timeVariation(Middelburg_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2015")
MO3Tempplot16 <- timeVariation(Middelburg_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2016")
MO3Tempplot17 <- timeVariation(Middelburg_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2017")
MO3Tempplot18 <- timeVariation(Middelburg_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Middelburg in 2018")
MO3Tempplot <- timeVariation(Middelburg_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Middelburg")

MtrendO3 <- TheilSen(Middelburg_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Middelburg")

save(MO3Tempplot09, MO3Tempplot10,
     MO3Tempplot11,MO3Tempplot12,
     MO3Tempplot13,MO3Tempplot14,
     MO3Tempplot15,MO3Tempplot16,
     MO3Tempplot17,MO3Tempplot18,
     MtrendO3,MO3Tempplot,
     file = "Graph/MTempoaral_plotO3.Rda")

MBoxnoCompare <- ggplot(data = Middelburg_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

MBoxnoCompare

MBoxnoxCompare <- ggplot(data = Middelburg_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

MBoxnoxCompare

MBoxo3Compare <- ggplot(data = Middelburg_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

MBoxnoCompare

MBoxcoCompare <- ggplot(data = Middelburg_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at Middelburg",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

MBoxcoCompare

# NO --------------------------------------------------------------------

MNOallpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

MNOstdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

MNOweighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


MNOfrequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

MNOper50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



MNOper60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MNOper70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


MNOper80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


MNOper90 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

MNOper98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MNOper99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



MNO_CPFplot = list(MNOallpolar$plot,
                   MNOstdev$plot,
                   MNOfrequency$plot,
                   MNOweighted$plot,
                   MNOper50$plot,
                   MNOper60$plot,
                   MNOper70$plot,
                   MNOper80$plot,
                   MNOper90$plot,
                   MNOper98$plot,
                   MNOper99$plot)

do.call("grid.arrange", MNO_CPFplot)

# CO --------------------------------------------------------------------

MCOallpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

MCOstdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


MCOweighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


MCOfrequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



MCOper50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



MCOper60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MCOper70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


MCOper80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


MCOper90 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

MCOper98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MCOper99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



MCO_CPFplot = list(MCOallpolar$plot,
                   MCOstdev$plot,
                   MCOfrequency$plot,
                   MCOweighted$plot,
                   MCOper50$plot,
                   MCOper60$plot,
                   MCOper70$plot,
                   MCOper80$plot,
                   MCOper90$plot,
                   MCOper98$plot,
                   MCOper99$plot)

do.call("grid.arrange", MCO_CPFplot)


# NOX --------------------------------------------------------------------

MNOXallpolar <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

MNOXstdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

MNOXweighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


MNOXfrequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


MNOXper50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



MNOXper60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MNOXper70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


MNOXper80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


MNOXper90 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

MNOXper98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MNOXper99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



MNOX_CPFplot = list(MNOXallpolar$plot,
                    MNOXstdev$plot,
                    MNOXfrequency$plot,
                    MNOXweighted$plot,
                    MNOXper50$plot,
                    MNOXper60$plot,
                    MNOXper70$plot,
                    MNOXper80$plot,
                    MNOXper90$plot,
                    MNOXper98$plot,
                    MNOXper99$plot)

do.call("grid.arrange", MNOX_CPFplot)



# O3 ----------------------------------------------------------------------

MO3allpolar <- polarMap(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

MO3stdev <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


MO3weighted <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

MO3frequency <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



MO3per50 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



MO3per60 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


MO3per70 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

MO3per80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

MO3per80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

MO3per80 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



MO3per98 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

MO3per99 <- polarPlot(
  Mpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

MO3_polarplot = list(MO3allpolar$plot,
                     MO3stdev$plot,
                     MO3weighted$plot,
                     MO3frequency$plot,
                     MO3per50$plot,
                     MO3per60$plot,
                     MO3per70$plot,
                     MO3per80$plot,
                     MO3per90$plot,
                     MO3per98$plot,
                     MO3per99$plot)
do.call("grid.arrange", MO3_polarplot)

# Secunda -----------------------------------------------------------------

SNOTempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2009")
SNOTempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2010")
SNOTempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2011")
SNOTempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2012")
SNOTempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2013")
SNOTempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2014")
SNOTempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2015")
SNOTempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2016")
SNOTempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2017")
SNOTempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="no", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "NO temporal variation at Secunda in 2018")

SNOTempplot <- timeVariation(Secunda_clean, stati="median", poll="no", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "NO temporal variation at Secunda")

StrendNO <- TheilSen(Secunda_clean, pollutant = "no",
                     ylab = "NO (µg.m-3)",
                     deseason = TRUE,
                     main = "NO trends at Secunda")

save(SNOTempplot09, SNOTempplot10,
     SNOTempplot11,SNOTempplot12,
     SNOTempplot13,SNOTempplot14,
     SNOTempplot15,SNOTempplot16,
     SNOTempplot17,SNOTempplot18,
     StrendNO,SNOTempplot,
     file = "Graph/STempoaral_plotNO.Rda")

SNOXTempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2009")
SNOXTempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2010")
SNOXTempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2011")
SNOXTempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2012")
SNOXTempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2013")
SNOXTempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2014")
SNOXTempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2015")
SNOXTempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2016")
SNOXTempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="nox", conf.int = c(0.75, 0.99),
                                col = "firebrick", main = "NOX temporal variation at Secunda in 2017")

SNOXTempplot <- timeVariation(Secunda_clean, stati="median", poll="nox", conf.int = c(0.75, 0.99),
                              col = "firebrick", main = "NOX temporal variation at Secunda")

StrendNOX <- TheilSen(Secunda_clean, pollutant = "nox",
                      ylab = "NOX (µg.m-3)",
                      deseason = TRUE,
                      main = "NOX trends at Secunda")

save(SNOXTempplot09, SNOXTempplot10,
     SNOXTempplot11,SNOXTempplot12,
     SNOXTempplot13,SNOXTempplot14,
     SNOXTempplot15,SNOXTempplot16,
     SNOXTempplot17,SNOXTempplot18,
     StrendNOX,SNOXTempplot,
     file = "Graph/STempoaral_plotNOX.Rda")

SCOTempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2009")
SCOTempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2010")
SCOTempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2011")
SCOTempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2012")
SCOTempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2013")
SCOTempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2014")
SCOTempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2015")
SCOTempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2016")
SCOTempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2017")
SCOTempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="co", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "CO temporal variation at Secunda in 2018")

SCOTempplot <- timeVariation(Secunda_clean, stati="median", poll="co", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "CO temporal variation at Secunda")

StrendCO <- TheilSen(Secunda_clean, pollutant = "co",
                     ylab = "CO (µg.m-3)",
                     deseason = TRUE,
                     main = "CO trends at Secunda")

save(SCOTempplot09, SCOTempplot10,
     SCOTempplot11,SCOTempplot12,
     SCOTempplot13,SCOTempplot14,
     SCOTempplot15,SCOTempplot16,
     SCOTempplot17,SCOTempplot18,
     StrendCO,SCOTempplot,
     file = "Graph/STempoaral_plotCO.Rda")

SO3Tempplot09 <- timeVariation(Secunda_clean %>% filter(year == "2009"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2009")
SO3Tempplot10 <- timeVariation(Secunda_clean %>% filter(year == "2010"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2010")
SO3Tempplot11 <- timeVariation(Secunda_clean %>% filter(year == "2011"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2011")
SO3Tempplot12 <- timeVariation(Secunda_clean %>% filter(year == "2012"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2012")
SO3Tempplot13 <- timeVariation(Secunda_clean %>% filter(year == "2013"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2013")
SO3Tempplot14 <- timeVariation(Secunda_clean %>% filter(year == "2014"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2014")
SO3Tempplot15 <- timeVariation(Secunda_clean %>% filter(year == "2015"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2015")
SO3Tempplot16 <- timeVariation(Secunda_clean %>% filter(year == "2016"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2016")
SO3Tempplot17 <- timeVariation(Secunda_clean %>% filter(year == "2017"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2017")
SO3Tempplot18 <- timeVariation(Secunda_clean %>% filter(year == "2018"), stati="median", poll="o3", conf.int = c(0.75, 0.99),
                               col = "firebrick", main = "O3 temporal variation at Secunda in 2018")
SO3Tempplot <- timeVariation(Secunda_clean, stati="median", poll="o3", conf.int = c(0.75, 0.99),
                             col = "firebrick", main = "O3 temporal variation at Secunda")

StrendO3 <- TheilSen(Secunda_clean, pollutant = "o3",
                     ylab = "O3 (µg.m-3)",
                     deseason = TRUE,
                     main = "O3 trends at Secunda")

save(SO3Tempplot09, SO3Tempplot10,
     SO3Tempplot11,SO3Tempplot12,
     SO3Tempplot13,SO3Tempplot14,
     SO3Tempplot15,SO3Tempplot16,
     SO3Tempplot17,SO3Tempplot18,
     StrendO3,SO3Tempplot,
     file = "Graph/STempoaral_plotO3.Rda")

SBoxnoCompare <- ggplot(data = Secunda_Daily %>%
                          datify() %>%
                          select(no, year) %>%
                          mutate(perc.obs = length(which(!is.na(no))) / n(), .by = year),
                        aes(x = year, y = no)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NO",
    title = "Annual statistical summary of NO at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 140)

SBoxnoCompare

SBoxnoxCompare <- ggplot(data = Secunda_Daily %>%
                           datify() %>%
                           select(nox, year) %>%
                           mutate(perc.obs = length(which(!is.na(nox))) / n(), .by = year),
                         aes(x = year, y = nox)) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "NOX",
    title = "Annual statistical summary of NOX at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 160)

SBoxnoxCompare

SBoxo3Compare <- ggplot(data = Secunda_Daily %>%
                          datify() %>%
                          select(o3, year) %>%
                          mutate(perc.obs = length(which(!is.na(o3))) / n(), .by = year),
                        aes(x = year, y = no )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "O3",
    title = "Annual statistical summary of O3 at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 120)

SBoxnoCompare

SBoxcoCompare <- ggplot(data = Secunda_Daily %>%
                          datify() %>%
                          select(co, year) %>%
                          mutate(perc.obs = length(which(!is.na(co))) / n(), .by = year),
                        aes(x = year, y = co )) +
  geom_boxplot(aes(fill = perc.obs)) +
  theme_bw() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(
    x = "YEAR",
    y = "CO",
    title = "Annual statistical summary of CO at Secunda",
    caption = "Data from SAAQIS") +
  theme(legend.position = "bottom")+
  stat_compare_means(label.y = 6)

SBoxcoCompare

# NO --------------------------------------------------------------------

SNOallpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NO",
  key.position = "right",
  key = TRUE
)

SNOstdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NO",
  key.position = "right",
  key = TRUE
)

SNOweighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NO",
  key.position = "right",
  key = TRUE
)


SNOfrequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)

SNOper50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 50th percentile",
  key.position = "right",
  key = TRUE
)



SNOper60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SNOper70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


SNOper80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


SNOper90 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80, 90),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

SNOper98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90, 98),
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SNOper99 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "no",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO at 99th percentile",
  key.position = "right",
  key = TRUE
)



SNO_CPFplot = list(SNOallpolar$plot,
                   SNOstdev$plot,
                   SNOfrequency$plot,
                   SNOweighted$plot,
                   SNOper50$plot,
                   SNOper60$plot,
                   SNOper70$plot,
                   SNOper80$plot,
                   SNOper90$plot,
                   SNOper98$plot,
                   SNOper99$plot)

do.call("grid.arrange", SNO_CPFplot)

# CO --------------------------------------------------------------------

SCOallpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean CO",
  key.position = "right",
  key = TRUE
)

SCOstdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of CO",
  key.position = "right",
  key = TRUE
)


SCOweighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean CO",
  key.position = "right",
  key = TRUE
)


SCOfrequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of occassion of wind",
  key.position = "right",
  key = TRUE
)



SCOper50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 50th percentile",
  key.position = "right",
  key = TRUE
)



SCOper60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SCOper70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


SCOper80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70, 80),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO from the 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


SCOper90 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

SCOper98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NO from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SCOper99 <- polarPlot(
  SEpolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "co",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "CO at 99th percentile",
  key.position = "right",
  key = TRUE
)



SCO_CPFplot = list(SECOallpolar$plot,
                   SCOstdev$plot,
                   SCOfrequency$plot,
                   SCOweighted$plot,
                   SCOper50$plot,
                   SCOper60$plot,
                   SCOper70$plot,
                   SCOper80$plot,
                   SCOper90$plot,
                   SCOper98$plot,
                   SCOper99$plot)

do.call("grid.arrange", SCO_CPFplot)


# NOX --------------------------------------------------------------------

SNOXallpolar <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean NOX",
  key.position = "right",
  key = TRUE
)

SNOXstdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of NOX",
  key.position = "right",
  key = TRUE
)

SNOXweighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean NOX",
  key.position = "right",
  key = TRUE
)


SNOXfrequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)


SNOXper50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 50th percentile",
  key.position = "right",
  key = TRUE
)



SNOXper60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SNOXper70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)


SNOXper80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)


SNOXper90 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 80th to 90th percentile",
  key.position = "right",
  key = TRUE
)

SNOXper98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SNOXper99 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "nox",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "NOX at 99th percentile",
  key.position = "right",
  key = TRUE
)



SNOX_CPFplot = list(SNOXallpolar$plot,
                    SNOXstdev$plot,
                    SNOXfrequency$plot,
                    SNOXweighted$plot,
                    SNOXper50$plot,
                    SNOXper60$plot,
                    SNOXper70$plot,
                    SNOXper80$plot,
                    SNOXper90$plot,
                    SNOXper98$plot,
                    SNOXper99$plot)

do.call("grid.arrange", SNOX_CPFplot)



# O3 ----------------------------------------------------------------------

SO3allpolar <- polarMap(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Mean O3",
  key.position = "right",
  key = TRUE
)

SO3stdev <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "stdev",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "stdev of O3",
  key.position = "right",
  key = TRUE
)


SO3weighted <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "weighted.mean",
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Weighted mean O3",
  key.position = "right",
  key = TRUE
)

SO3frequency <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "frequency",
  pollutant = "O3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "Frequency of wind",
  key.position = "right",
  key = TRUE
)



SO3per50 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 50,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 50th percentile",
  key.position = "right",
  key = TRUE
)



SO3per60 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(50,60),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 50th to 60th percentile",
  key.position = "right",
  key = TRUE
)


SO3per70 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(60,70),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 60th to 70th percentile",
  key.position = "right",
  key = TRUE
)

SO3per80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

SO3per80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(70,80),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 70th to 80th percentile",
  key.position = "right",
  key = TRUE
)

SO3per80 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(80,90),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 80th to 80th percentile",
  key.position = "right",
  key = TRUE
)



SO3per98 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = c(90,98),
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 from 90th to 98th percentile",
  key.position = "right",
  key = TRUE
)

SO3per99 <- polarPlot(
  Spolar %>% filter(year == "2009"),
  latitude = "latitude",
  longitude = "longitude",
  statistic = "cpf",
  percentile = 99,
  pollutant = "o3",
  provider = c("Satellite" = "Esri.WorldImagery"),
  main = "O3 at 99th percentile",
  key.position = "right",
  key = TRUE
)

SO3_polarplot = list(SO3allpolar$plot,
                     SO3stdev$plot,
                     SO3weighted$plot,
                     SO3frequency$plot,
                     SO3per50$plot,
                     SO3per60$plot,
                     SO3per70$plot,
                     SO3per80$plot,
                     SO3per90$plot,
                     SO3per98$plot,
                     SO3per99$plot)
do.call("grid.arrange", SO3_polarplot)

