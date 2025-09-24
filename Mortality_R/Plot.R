library(ggplot2)
library(tidyr)
library(tidyverse)


gertcardR = read.csv("MortData/Association/GertPollCardMortNORR.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female
gertcardR <- gertcardR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

# Create the plot with side-by-side error bars
ggplot(gertcardR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5),  size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    strip.text = element_text(face = "bold") ,
    panel.border = element_rect(color = "black", fill = NA, size = 1))


gertcardCR = read.csv("MortData/Association/GertPollCardMortCartPM2RR.csv", header = T, sep = ";")

gertcardCR <- gertcardCR %>%
  mutate(Category = factor(Category, levels = c("CVD", "IHD", "CBD")))

# Create the plot with side-by-side error bars
ggplot(gertcardCR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5),  size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    strip.text = element_text(face = "bold") ,
    panel.border = element_rect(color = "black", fill = NA, size = 1))



gertpulR = read.csv("MortData/Association/GertPollPulMortPM2RR.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female
gertpulR <- gertpulR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

# Create the plot with side-by-side error bars
ggplot(gertpulR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16)+
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1))

gertpulRC = read.csv("MortData/Association/GertPollPulMortCartPM2RR.csv", header = T, sep = ";")

gertpulRC <- gertpulRC %>%
  mutate(Category = factor(Category, levels = c("RD", "Pneumonia", "CLRD")))

# Create the plot with side-by-side error bars
ggplot(gertpulRC, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16)+
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1))


gertcardL = read.csv("MortData/Association/GertPollCardMortNO.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female
gertcardL <- gertcardL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

ggplot(gertcardL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~ Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x     = "Lag",
    y     = "Relative Risk (RR)") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title       = element_text(face = "bold"),
    axis.title       = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text       = element_text(face = "bold"),
    panel.border     = element_rect(color = "black", fill = NA),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom")

# legend.direction = "horizontal"
# # right justify it under the 2nd column of the bottom row
# legend.justification = c(1, 0),
# legend.box.just      = "right",
# # give extra bottom margin so it isn’t clipped
# plot.margin = margin(t = 5, r = 5, b = 30, l = 5)


gertcardCL = read.csv("MortData/Association/GertPollCardMortCartPM2.csv", header = T, sep = ";")

gertcardCL <- gertcardCL %>%
  mutate(Category = factor(Category, levels = c("CVD", "IHD", "CBD")))

# Create the plot with side-by-side error bars
ggplot(gertcardCL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"), 
    axis.text = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction  = "horizontal") +
  guides(
    color = guide_legend(
      nrow   = 1,     # force one row
      byrow  = TRUE))



gertpulL = read.csv("MortData/Association/GertPollPulMortPM2.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female
gertpulL <- gertpulL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

ggplot(gertpulL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~ Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x     = "Lag",
    y     = "Relative Risk (RR)") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title       = element_text(face = "bold"),
    axis.title       = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text       = element_text(face = "bold"),
    panel.border     = element_rect(color = "black", fill = NA),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom")


gertpulCL = read.csv("MortData/Association/GertPollPulMortCartNO.csv", header = T, sep = ";")

gertpulCL <- gertpulCL %>%
  mutate(Category = factor(Category, levels = c("RD", "Pneumonia", "CLRD")))

# Create the plot with side-by-side error bars
ggplot(gertpulCL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal")  +
  guides(
    color = guide_legend(
      nrow   = 1,     # force one row
      byrow  = TRUE))



# Nkagngala ---------------------------------------------------------------

nkacardR = read.csv("MortData/Association/NkaPollCardMortPM2RR.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female
nkacardR <- nkacardR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

# Create the plot with side-by-side error bars
ggplot(nkacardR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    axis.text = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1))


nkacardCR = read.csv("MortData/Association/NkaPollCardMortCartSORR.csv", header = T, sep = ";")

nkacardCR <- nkacardCR %>%
  mutate(Category = factor(Category, levels = c("CVD", "IHD", "CBD")))

# Create the plot with side-by-side error bars
ggplot(nkacardCR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    axis.text = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1))


nkapulR = read.csv("MortData/Association/NkaPollPulMortPM1RR.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female
nkapulR <- nkapulR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

# Create the plot with side-by-side error bars
ggplot(nkapulR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1))



nkapulCR = read.csv("MortData/Association/NkaPollPulMortCartPM2RR.csv", header = T, sep = ";")

nkapulCR <- nkapulCR %>%
  mutate(Category = factor(Category, levels = c("RD", "Pneumonia", "CLRD")))

# Create the plot with side-by-side error bars
ggplot(nkapulCR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal",
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1))


nkacardL = read.csv("MortData/Association/NkaPollCardMortNO.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female
nkacardL <- nkacardL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

ggplot(nkacardL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~ Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x     = "Lag",
    y     = "Relative Risk (RR)") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title       = element_text(face = "bold"),
    axis.title       = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text       = element_text(face = "bold"),
    panel.border     = element_rect(color = "black", fill = NA),
    legend.text = element_text(face = "bold"), 
    legend.position  = "bottom",
    legend.direction = "horizontal")



nkacardCL = read.csv("MortData/Association/NkaPollCardMortCartPM2.csv", header = T, sep = ";")

nkacardCL <- nkacardCL %>%
  mutate(Category = factor(Category, levels = c("CVD", "IHD", "CBD")))

# Create the plot with side-by-side error bars
ggplot(nkacardCL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~Category,  nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal") +
  guides(
    color = guide_legend(
      nrow   = 1,     # force one row
      byrow  = TRUE))


nkapulL = read.csv("MortData/Association/NkaPollPulMortNO.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female
nkapulL <- nkapulL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "15-64", "65+")))

ggplot(nkapulL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~ Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x     = "Lag",
    y     = "Relative Risk (RR)") +
  guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title       = element_text(face = "bold"),
    axis.title       = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text       = element_text(face = "bold"),
    panel.border     = element_rect(color = "black", fill = NA),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal")


nkapulCL = read.csv("MortData/Association/NkaPollPulMortCartPM2.csv", header = T, sep = ";")

nkapulCL <- nkapulCL %>%
  mutate(Category = factor(Category, levels = c("RD", "Pneumonia", "CLRD")))

# Create the plot with side-by-side error bars
ggplot(nkapulCL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5), size = 3) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5), size = 0.8) +
  facet_wrap(~Category,  nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed",  color = "red", size = 0.8) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)") +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold", color = "black"),
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    legend.text = element_text(face = "bold"),
    legend.position  = "bottom",
    legend.direction = "horizontal") +
  guides(
    color = guide_legend(
      nrow   = 1,     # force one row
      byrow  = TRUE))


## Combined Plots ----------------------------------------------------------

library(dplyr)
library(ggplot2)
library(patchwork)
library(purrr) 


gertcardCL <- read.csv("MortData/NkaCVD.csv", header = TRUE, sep = ";")

# Function to plot one panel
make_rr_plot <- function(df, cat, pol) {
  subdf <- df %>%
    filter(Category == cat, Pollutant == pol) %>%
    mutate(lag_num = as.integer(gsub("^lag", "", lag)))
  
  ggplot(subdf, aes(x = lag_num, y = RR)) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "red", linewidth = 0.6) +
    geom_errorbar(aes(ymin = ci.low, ymax = ci.hi), width = 0.25, linewidth = 0.7) +
    geom_point(size = 2.6) +
    scale_x_continuous(breaks = 0:14, name = "Lag (days)") +
    labs(
      title = paste(cat, "RR by Lag for", pol),
      y     = "Relative Risk (RR)"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title   = element_text(face = "bold", hjust = 0.5),
      axis.title   = element_text(face = "bold"),
      axis.text    = element_text(face = "bold", color = "black", size = 15),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8) # <- border per plot
    )
}

# Define order
cats <- c("CVD","IHD","CBD")
pols <- c("PM2.5","SO2","NO2")

# Generate all 9 plots
plots <- expand.grid(Category = cats, Pollutant = pols, stringsAsFactors = FALSE) %>%
  mutate(plot = purrr::map2(Category, Pollutant, ~ make_rr_plot(gertcardCL, .x, .y)))

# Arrange in 3x3
final_plot <- (plots$plot[[1]] | plots$plot[[2]] | plots$plot[[3]]) /
  (plots$plot[[4]] | plots$plot[[5]] | plots$plot[[6]]) /
  (plots$plot[[7]] | plots$plot[[8]] | plots$plot[[9]])

final_plot


# --- Load data ---
gertpulCL <- read.csv("MortData/NkaRD.csv", header = TRUE, sep = ";")

# --- Helper: one panel per (Category, Pollutant) ---
make_rr_plot <- function(df, cat, pol) {
  subdf <- df %>%
    filter(Category == cat, Pollutant == pol) %>%
    mutate(lag_num = as.integer(gsub("^lag", "", lag))) %>%
    arrange(lag_num)
  
  ggplot(subdf, aes(x = lag_num, y = RR)) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "red", linewidth = 0.6) +
    geom_errorbar(aes(ymin = ci.low, ymax = ci.hi), width = 0.25, linewidth = 0.7) +
    geom_point(size = 2.6) +
    # If you want a trend line, uncomment this:
    # geom_line(linewidth = 0.5) +
    scale_x_continuous(breaks = 0:14, name = "Lag (days)") +
    labs(
      title = paste(cat, "RR by Lag for", pol),
      y     = "Relative Risk (RR)"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title   = element_text(face = "bold", hjust = 0.5),
      axis.title   = element_text(face = "bold"),
      axis.text    = element_text(face = "bold", color = "black", size = 15),
      panel.background = element_rect(fill = "white", colour = NA),
      panel.border     = element_rect(color = "black", fill = NA, linewidth = 0.8)  # <-- border per subplot
    )
}

# --- Fixed order for rows and columns ---
cats <- c("RD","Pneumonia","CLRD")          # row-wise (top to bottom)
pols <- c("PM2.5","SO2","NO2")        # column-wise (left to right)

# --- Build the 9 plots in row-major order ---
plots_tbl <- expand.grid(Category = cats, Pollutant = pols, stringsAsFactors = FALSE) %>%
  mutate(plot = map2(Category, Pollutant, ~ make_rr_plot(gertpulCL, .x, .y)))

# --- Arrange 3×3 (free y because each panel is independent) ---
final_plot <- wrap_plots(plots_tbl$plot, ncol = 3, nrow = 3, byrow = TRUE)

# OPTIONAL: add a single border around the whole layout (keep or remove)
final_plot <- final_plot & theme(
  plot.margin  = margin(6, 6, 6, 6),
  panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8)
)

# --- Show it ---
final_plot
