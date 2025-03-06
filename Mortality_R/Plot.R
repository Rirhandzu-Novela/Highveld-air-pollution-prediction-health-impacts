library(ggplot2)
library(tidyr)


gertcardR = read.csv("MortData/gertcardRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertcardR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold") ,
    panel.border = element_rect(color = "black", fill = NA, size = 1)   
  )


gertpulR = read.csv("MortData/gertpulRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertpulR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)    
  )

gertcardL = read.csv("MortData/gertcardlag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertcardL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap(~Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )

gertpulL = read.csv("MortData/gertpullag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(gertpulL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap(~Category, nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )


# Nkagngala ---------------------------------------------------------------

nkacardR = read.csv("MortData/nkacardRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkacardR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)    
  )


nkapulR = read.csv("MortData/nkapulRR.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkapulR, aes(x = Category, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Category",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )

nkacardL = read.csv("MortData/nkacardlag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkacardL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap(~Category,  nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Cardiovascular Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )

nkapulL = read.csv("MortData/nkapullag.csv", header = T, sep = ";")


# Create the plot with side-by-side error bars
ggplot(nkapulL, aes(x = Lag, y = RR, color = Pollutant)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymin = LOW, ymax = HIGH), width = 0.2, position = position_dodge(width = 0.5)) +
  facet_wrap(~Category,  nrow = 2, scales = "free") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  labs(
    title = "Pulmonary Mortality RR [95% CI]",
    x = "Lag",
    y = "Relative Risk (RR)"
  ) +
  theme_minimal()+
  theme(
    plot.title = element_text(face = "bold"),   
    axis.title = element_text(face = "bold"),   
    legend.text = element_text(face = "bold"),  
    strip.text = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )

