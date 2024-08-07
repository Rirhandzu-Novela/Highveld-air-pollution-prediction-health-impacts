library(ggplot2)
library(tidyr)


gertcardR = read.csv("MortData/gertcardRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertcardR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  labs(
    title = "Relative Risk (RR) with Error Bars for Different Pollutants",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()


gertpulR = read.csv("MortData/gertpulRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertpulR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  labs(
    title = "Relative Risk (RR) with Error Bars for Different Pollutants",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()

gertcardL = read.csv("MortData/gertcardlag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertcardL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap( ~ Category) +
  labs(
    title = "RR and 95% CI",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()

gertpulL = read.csv("MortData/gertpullag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertpulL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap( ~ Category) +
  labs(
    title = "RR and 95% CI",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()


# Nkagngala ---------------------------------------------------------------

nkacardR = read.csv("MortData/nkacardRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkacardR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  labs(
    title = "Relative Risk (RR) with Error Bars for Different Pollutants",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()


nkapulR = read.csv("MortData/nkapulRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkapulR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  labs(
    title = "Relative Risk (RR) with Error Bars for Different Pollutants",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()

nkacardL = read.csv("MortData/nkacardlag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkacardL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap( ~ Category) +
  labs(
    title = "RR and 95% CI",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()

nkapulL = read.csv("MortData/nkapullag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkapulL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap( ~ Category) +
  labs(
    title = "RR and 95% CI",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()

