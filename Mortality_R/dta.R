#install.packages("haven")
library("haven")

Mortality_data = read_dta("mcd-1997-2018-v1.dta")
head(Mortality_data)
write.csv(Mortality_data, file = "Data/Mortality.csv")
