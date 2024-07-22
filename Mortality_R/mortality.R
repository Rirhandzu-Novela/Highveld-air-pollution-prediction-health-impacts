library(tidyverse)


Mortality = read.csv("MortData/Mortality.csv", header = T, sep = ";") 
head(Mortality)

Mortality <- Mortality %>% 
 mutate(DeathDate = as.Date(DeathDate, format = "%m/%d/%Y"))



### Gert sibande

Gertmort <- Mortality %>% 
  filter(death_district == 'Gert Sibande') %>%
  filter(AGEYEAR > 30)

GertAll_counts <-  Gertmort %>%
  group_by(DeathDate) %>%
  summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertSex_counts <- Gertmort %>%
  group_by(DeathDate, Sex) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9")

GertAll_counts <- GertAll_counts %>%
  left_join(GertSex_counts, by = "date")

write.csv(GertAll_counts, "MortData/GertMort30.csv", row.names = TRUE)


Gerts30 = read.csv("MortData/GertMort30.csv", header = T, sep = ";")

Gerts30$date <- as.Date(Gerts30$date, format = "%Y/%m/%d")

sumYear30 <- Gerts30 %>% 
  novaAQM::datify() %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


dfYear30 <-  Gerts30  %>%
  pivot_longer(cols = death_count:Female, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear30, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear30,"RDA/GertYearSum30.csv")

sum30 <- Gerts30 %>% 
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


df30 <-  Gerts30  %>%
  pivot_longer(cols = death_count:Female, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum30, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df30,"RDA/GertSum30.csv")




### Cardiovacular
GertCardmort <- Mortality %>% 
  filter(death_district == 'Gert Sibande') %>% 
  filter(Underlying_Main_Grp == 'J00_J99')  
  
GertAllcard_counts <-  GertCardmort %>%
  group_by(DeathDate) %>%
  summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertSexcard_counts <- GertCardmort %>%
  group_by(DeathDate, Sex) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9")


GertCardmort <- GertCardmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 10 ~ "BelowTen",
    AGEYEAR >= 10 & AGEYEAR <= 64 ~ "TenToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category and count deaths
GertAgecard_counts <- GertCardmort %>%
  group_by(DeathDate, age_category) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


air_pollution_data = read.csv("AirData/GertsDaily.csv", header = T, sep = ";")


air_pollution_data <- air_pollution_data %>%
  mutate(date = as.Date(date, format = "%Y/%m/%d"))


GertPollMort <- air_pollution_data %>%
  left_join(GertAllcard_counts, by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertSexcard_counts, by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertAgecard_counts , by = "date")

write.csv(GertPollMort, "MortData/GertPollCardMort.csv", row.names = TRUE)




### Pulmonary

GertPulmort <- Mortality %>% 
  filter(death_district == 'Gert Sibande') %>% 
  filter(Underlying_Main_Grp == 'I00_I99')  

GertAllPul_counts <-  GertPulmort %>%
  group_by(DeathDate) %>%
  summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertSexPul_counts <- GertPulmort %>%
  group_by(DeathDate, Sex) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9")


GertPulmort <- GertPulmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 10 ~ "BelowTen",
    AGEYEAR >= 10 & AGEYEAR <= 64 ~ "TenToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category and count deaths
GertAgePul_counts <- GertPulmort %>%
  group_by(DeathDate, age_category) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


GertPollMort <- air_pollution_data %>%
  left_join(GertAllPul_counts, by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertSexPul_counts, by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertAgePul_counts , by = "date")

write.csv(GertPollMort, "MortData/GertPollPulMort.csv", row.names = TRUE)



### Nkangala

Nkamort <- Mortality %>% 
  filter(death_district == 'Nkangala') %>%
  filter(AGEYEAR > 30)

NkaAll_counts <-  Nkamort %>%
  group_by(DeathDate) %>%
  summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaSex_counts <- Nkamort %>%
  group_by(DeathDate, Sex) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9", -"8")

NkaAll_counts <- NkaAll_counts %>%
  left_join(NkaSex_counts, by = "date")

write.csv(NkaAll_counts, "MortData/NkaMort30.csv", row.names = TRUE)


Nka30 = read.csv("MortData/NkaMort30.csv", header = T, sep = ";")

Nka30$date <- as.Date(Nka30$date, format = "%Y/%m/%d")

sumYear30 <- Nka30 %>% 
  novaAQM::datify() %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


dfYear30 <-  Nka30  %>%
  pivot_longer(cols = death_count:Female, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear30, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear30,"RDA/NkaYearSum30.csv")

sum30 <- Nka30 %>% 
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


df30 <-  Nka30  %>%
  pivot_longer(cols = death_count:Female, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum30, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df30,"RDA/NkaSum30.csv")


### Cardiovacular

NkaCardmort <- Mortality %>% 
  filter(death_district == 'Nkangala') %>% 
  filter(Underlying_Main_Grp == 'J00_J99')  

NkaAllcard_counts <-  NkaCardmort %>%
  group_by(DeathDate) %>%
  summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaSexcard_counts <- NkaCardmort %>%
  group_by(DeathDate, Sex) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"8", -"9")


NkaCardmort <- NkaCardmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 10 ~ "BelowTen",
    AGEYEAR >= 10 & AGEYEAR <= 64 ~ "TenToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category and count deaths
NkaAgecard_counts <- NkaCardmort %>%
  group_by(DeathDate, age_category) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


air_pollution_data = read.csv("AirData/NkaDaily.csv", header = T, sep = ";")


air_pollution_data <- air_pollution_data %>%
  mutate(date = as.Date(date, format = "%Y/%m/%d"))


NkaPollMort <- air_pollution_data %>%
  left_join(NkaAllcard_counts, by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkaSexcard_counts, by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkaAgecard_counts , by = "date")

write.csv(NkaPollMort, "MortData/NkaPollCardMort.csv", row.names = TRUE)




### Pulmonary

NkaPulmort <- Mortality %>% 
  filter(death_district == 'Nkangala') %>% 
  filter(Underlying_Main_Grp == 'I00_I99')  

NkaAllPul_counts <-  NkaPulmort %>%
  group_by(DeathDate) %>%
  summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaSexPul_counts <- NkaPulmort %>%
  group_by(DeathDate, Sex) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(- "8", -"9")


NkaPulmort <- NkaPulmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 10 ~ "BelowTen",
    AGEYEAR >= 10 & AGEYEAR <= 64 ~ "TenToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category and count deaths
NkaAgePul_counts <- NkaPulmort %>%
  group_by(DeathDate, age_category) %>%
  summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


NkaPollMort <- air_pollution_data %>%
  left_join(NkaAllPul_counts, by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkaSexPul_counts, by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkaAgePul_counts , by = "date")

write.csv(NkaPollMort, "MortData/NkaPollPulMort.csv", row.names = TRUE)








