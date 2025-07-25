library(ggplot2)
library(tidyr)
library(tidyverse)


gertcardR = read.csv("MortData/GertPollCardMortPM2RR.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female, All
gertcardR <- gertcardR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

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


gertcardCR = read.csv("MortData/GertPollCardMortCartNORR.csv", header = T, sep = ";")

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



gertpulR = read.csv("MortData/GertPollPulMortNORR.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female, All
gertpulR <- gertpulR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

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

gertpulRC = read.csv("MortData/GertPollPulMortCartNORR.csv", header = T, sep = ";")

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


gertcardL = read.csv("MortData/GertPollCardMortPM2.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female, All
gertcardL <- gertcardL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

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


gertcardCL = read.csv("MortData/GertPollCardMortCartSO.csv", header = T, sep = ";")

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



gertpulL = read.csv("MortData/GertPollPulMortPM2.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female, All
gertpulL <- gertpulL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

ggplot(gertpulL, aes(x = Lag, y = RR, color = Pollutant)) +
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
    legend.position  = "bottom")


gertpulCL = read.csv("MortData/GertPollPulMortCartPM2.csv", header = T, sep = ";")

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

nkacardR = read.csv("MortData/NkaPollCardMortNORR.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female, All
nkacardR <- nkacardR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

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


nkacardCR = read.csv("MortData/NkaPollCardMortCartNORR.csv", header = T, sep = ";")

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


nkapulR = read.csv("MortData/NkaPollPulMortNORR.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female, All
nkapulR <- nkapulR %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

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



nkapulCR = read.csv("MortData/NkaPollPulMortCartNORR.csv", header = T, sep = ";")

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


nkacardL = read.csv("MortData/NkaPollCardMortPM2.csv", header = T, sep = ";")

#  Re-order your facets so that the first row is Male, Female, All
nkacardL <- nkacardL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

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



nkacardCL = read.csv("MortData/NkaPollCardMortCartSO.csv", header = T, sep = ";")

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


nkapulL = read.csv("MortData/NkaPollPulMortSO.csv", header = T, sep = ";")

# Re-order your facets so that the first row is Male, Female, All
nkapulL <- nkapulL %>%
  mutate(Category = factor(Category, levels = c("Male", "Female", "All", "FifteenToSixtyFour", "SixtyFivePlus")))

ggplot(nkapulL, aes(x = Lag, y = RR, color = Pollutant)) +
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


nkapulCL = read.csv("MortData/NkaPollPulMortCartSO.csv", header = T, sep = ";")

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



