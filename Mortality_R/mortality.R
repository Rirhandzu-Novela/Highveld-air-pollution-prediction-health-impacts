library(tidyverse)

# Mortality_data = read_dta("mcd-1997-2018-v1.dta")
# head(Mortality_data)
# write.csv(Mortality_data, file = "Data/Mortality.csv")

Mortality = read.csv("MortData/Mortality.csv", header = T, sep = ";") 
head(Mortality)

Mortality <- Mortality %>% 
 mutate(DeathDate = as.Date(DeathDate, format = "%m/%d/%Y"))


# Gert Sibande ------------------------------------------------------------

# Gert Sibande Above 30 ------------------------------------------------------------

Gertmort <- Mortality %>% 
  filter(death_district == 'Gert Sibande') %>%
  filter(AGEYEAR > 30)

GertAll_counts <-  Gertmort %>%
  group_by(DeathDate) %>%
  dplyr::summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertSex_counts <- Gertmort %>%
  group_by(DeathDate, Sex) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9")

GertAll_counts <- GertAll_counts %>%
  left_join(GertSex_counts, by = "date")

write.csv(GertAll_counts, "MortData/GertMort30.csv", row.names = TRUE)


air_pollution_data = read.csv("AirData/GertsDaily.csv", header = T, sep = ";")

air_pollution_data <- air_pollution_data %>%
  mutate(date = as.Date(date, format = "%Y/%m/%d"))


Cardiovacular <- air_pollution_data %>%
  left_join(GertAll_counts, by = "date")

write.csv(GertPollMort30, "MortData/GertPollMort30.csv", row.names = TRUE)

# Summary 

sumYear30 <- Cardiovacular %>% 
  novaAQM::datify() %>%
  group_by(year) %>%
  dplyr::summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


dfYear30 <-  Cardiovacular  %>%
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

sum30 <- Cardiovacular %>% 
  dplyr::summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


df30 <-  Cardiovacular  %>%
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


# Gert Sibande Cardiovacular ------------------------------------------------------------

GertCardmort <- Mortality %>% 
  filter(death_district == 'Gert Sibande') %>% 
  filter(Underlying_Main_Grp == 'I00_I99')  
  
GertAllcard_counts <-  GertCardmort %>%
  group_by(DeathDate) %>%
  dplyr::summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertSexcard_counts <- GertCardmort %>%
  group_by(DeathDate, Sex) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9")


GertCardmort <- GertCardmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 15 ~ "BelowFif",
    AGEYEAR >= 15 & AGEYEAR <= 64 ~ "FifToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category 
GertAgecard_counts <- GertCardmort %>%
  group_by(DeathDate, age_category) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


# Group by death_date and Underlying_Broad_Grp
Gertcatcard_counts <- GertCardmort %>%
  group_by(DeathDate,  Underlying_Broad_Grp) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from =  Underlying_Broad_Grp, values_from = death_count, values_fill = list(death_count = 0)) %>% 
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

GertPollMort <- GertPollMort %>%
  left_join(Gertcatcard_counts , by = "date")


write.csv(GertPollMort, "MortData/GertPollCardMort.csv", row.names = TRUE)

# Summary 

sumYear <- GertPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  GertPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/GertPollCardMortYearSum.csv")

sum <- GertPollMort %>% 
  select(date, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


df <-  GertPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/GertPollCardMortSum.csv")

sumYear <- GertPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99) %>%
  group_by(year) %>%
  dplyr::summarise(I00_I02 = sum(I00_I02, na.rm = T),
                   I05_I09 = sum(I05_I09, na.rm = T),
                   I10_I15 = sum(I10_I15, na.rm = T),
                   I20_I25 = sum(I20_I25, na.rm = T),
                   I26_I28 = sum(I26_I28, na.rm = T),
                   I30_I52 = sum(I30_I52, na.rm = T),
                   I60_I69 = sum(I60_I69, na.rm = T),
                   I70_I79 = sum(I70_I79, na.rm = T),
                   I80_I89 = sum(I80_I89, na.rm = T),
                   I95_I99 = sum(I95_I99, na.rm = T)) %>%
  pivot_longer(cols = c(I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  GertPollMort  %>%
  select(date, I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99) %>%
  pivot_longer(cols = I00_I02:I95_I99, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/GertCardMortYearSum.csv")

sum <- GertPollMort %>% 
  select(date, I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99) %>%
  dplyr::summarise(I00_I02 = sum(I00_I02, na.rm = T),
                   I05_I09 = sum(I05_I09, na.rm = T),
                   I10_I15 = sum(I10_I15, na.rm = T),
                   I20_I25 = sum(I20_I25, na.rm = T),
                   I26_I28 = sum(I26_I28, na.rm = T),
                   I30_I52 = sum(I30_I52, na.rm = T),
                   I60_I69 = sum(I60_I69, na.rm = T),
                   I70_I79 = sum(I70_I79, na.rm = T),
                   I80_I89 = sum(I80_I89, na.rm = T),
                   I95_I99 = sum(I95_I99, na.rm = T)) %>%
  pivot_longer(cols = c(I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99), 
               names_to = "variable", 
               values_to = "value")



df <-  GertPollMort  %>%
  pivot_longer(cols = I10_I15:I00_I02, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/GertCardMortSum.csv")

# Gert Sibande Pulmonary ------------------------------------------------------------

GertPulmort <- Mortality %>% 
  filter(death_district == 'Gert Sibande') %>% 
  filter(Underlying_Main_Grp == 'J00_J99') %>% 
  filter(!Underlyingcause %in% c("J09", "J10", "J11")) 

GertAllPul_counts <-  GertPulmort %>%
  group_by(DeathDate) %>%
  dplyr::summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertSexPul_counts <- GertPulmort %>%
  group_by(DeathDate, Sex) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9")


GertPulmort <- GertPulmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 15 ~ "BelowFif",
    AGEYEAR >= 15 & AGEYEAR <= 64 ~ "FifToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category 
GertAgePul_counts <- GertPulmort %>%
  group_by(DeathDate, age_category) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

# Group by death_date and Underlying_Broad_Grp
GertcatPull_counts <- GertPulmort %>%
  group_by(DeathDate,  Underlying_Broad_Grp) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from =  Underlying_Broad_Grp, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

GertPollMort <- air_pollution_data %>%
  left_join(GertAllPul_counts, by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertSexPul_counts, by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertAgePul_counts , by = "date")

GertPollMort <- GertPollMort %>%
  left_join(GertcatPull_counts , by = "date")

write.csv(GertPollMort, "MortData/GertPollPulMort.csv", row.names = TRUE)

# Summary

sumYear <- GertPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  GertPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/GertPollPulMortYearSum.csv")

sum <- GertPollMort %>% 
  select(date, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


df <-  GertPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/GertPollPulMortSum.csv")

sumYear <- GertPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99) %>%
  group_by(year) %>%
  dplyr::summarise(J00_J06 = sum(J00_J06, na.rm = T),
                   J09_J18 = sum(J09_J18, na.rm = T),
                   J20_J22 = sum(J20_J22, na.rm = T),
                   J30_J39 = sum(J30_J39, na.rm = T),
                   J40_J47 = sum(J40_J47, na.rm = T),
                   J60_J70 = sum(J60_J70, na.rm = T),
                   J80_J84 = sum(J80_J84, na.rm = T),
                   J85_J86 = sum(J85_J86, na.rm = T),
                   J90_J94 = sum(J90_J94, na.rm = T),
                   J95_J99 = sum(J95_J99, na.rm = T)) %>%
  pivot_longer(cols = c(J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99), 
               names_to = "variable", 
               values_to = "value")



dfYear <-  GertPollMort  %>%
  select(date, J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99) %>%
  pivot_longer(cols = J00_J06:J95_J99, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/GertPulMortYearSum.csv")

sum <- GertPollMort %>% 
  select(date, J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99) %>%
  dplyr::summarise(J00_J06 = sum(J00_J06, na.rm = T),
                   J09_J18 = sum(J09_J18, na.rm = T),
                   J20_J22 = sum(J20_J22, na.rm = T),
                   J30_J39 = sum(J30_J39, na.rm = T),
                   J40_J47 = sum(J40_J47, na.rm = T),
                   J60_J70 = sum(J60_J70, na.rm = T),
                   J80_J84 = sum(J80_J84, na.rm = T),
                   J85_J86 = sum(J85_J86, na.rm = T),
                   J90_J94 = sum(J90_J94, na.rm = T),
                   J95_J99 = sum(J95_J99, na.rm = T)) %>%
  pivot_longer(cols = c(J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99), 
               names_to = "variable", 
               values_to = "value")



df <-  GertPollMort  %>%
  pivot_longer(cols = J09_J18:J30_J39, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/GertPulMortSum.csv")

# Nkangala above 30 ------------------------------------------------------------

Nkamort <- Mortality %>% 
  filter(death_district == 'Nkangala') %>%
  filter(AGEYEAR > 30)

NkaAll_counts <-  Nkamort %>%
  group_by(DeathDate) %>%
  dplyr::summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaSex_counts <- Nkamort %>%
  group_by(DeathDate, Sex) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"9", -"8")

NkaAll_counts <- NkaAll_counts %>%
  left_join(NkaSex_counts, by = "date")

write.csv(NkaAll_counts, "MortData/NkaMort30.csv", row.names = TRUE)

air_pollution_data = read.csv("AirData/NkaDaily.csv", header = T, sep = ";")

air_pollution_data <- air_pollution_data %>%
  mutate(date = as.Date(date, format = "%Y/%m/%d"))


NkaPollMort30 <- air_pollution_data %>%
  left_join(NkaAll_counts, by = "date")

write.csv(NkaPollMort30, "MortData/NkaPollMort30.csv", row.names = TRUE)

# Summary

sumYear30 <- NkaPollMort30 %>% 
  novaAQM::datify() %>%
  group_by(year) %>%
  dplyr::summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


dfYear30 <-  NkaPollMort30  %>%
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

sum30 <- NkaPollMort30 %>% 
  dplyr::summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female), 
               names_to = "variable", 
               values_to = "value")


df30 <-  NkaPollMort30  %>%
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


# Nkangala Cardiovacular ------------------------------------------------------------

NkaCardmort <- Mortality %>% 
  filter(death_district == 'Nkangala') %>% 
  filter(Underlying_Main_Grp == 'I00_I99')  

NkaAllcard_counts <-  NkaCardmort %>%
  group_by(DeathDate) %>%
  dplyr::summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaSexcard_counts <- NkaCardmort %>%
  group_by(DeathDate, Sex) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(-"8", -"9")


NkaCardmort <- NkaCardmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 15 ~ "BelowFif",
    AGEYEAR >= 15 & AGEYEAR <= 64 ~ "FifToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category 
NkaAgecard_counts <- NkaCardmort %>%
  group_by(DeathDate, age_category) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


# Group by death_date and Underlying_Broad_Grp
Nkacatcard_counts <- NkaCardmort %>%
  group_by(DeathDate,  Underlying_Broad_Grp) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from =  Underlying_Broad_Grp, values_from = death_count, values_fill = list(death_count = 0)) %>% 
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

NkaPollMort <- NkaPollMort %>%
  left_join(Nkacatcard_counts , by = "date")

write.csv(NkaPollMort, "MortData/NkaPollCardMort.csv", row.names = TRUE)

# Summary

sumYear <- NkaPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  NkaPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/NkaPollCardMortYearSum.csv")

sum <- NkaPollMort %>% 
  select(date, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


df <-  NkaPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/NkaPollCardMortSum.csv")

sumYear <- NkaPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99) %>%
  group_by(year) %>%
  summarise(I00_I02 = sum(I00_I02, na.rm = T),
            I05_I09 = sum(I05_I09, na.rm = T),
            I10_I15 = sum(I10_I15, na.rm = T),
            I20_I25 = sum(I20_I25, na.rm = T),
            I26_I28 = sum(I26_I28, na.rm = T),
            I30_I52 = sum(I30_I52, na.rm = T),
            I60_I69 = sum(I60_I69, na.rm = T),
            I70_I79 = sum(I70_I79, na.rm = T),
            I80_I89 = sum(I80_I89, na.rm = T),
            I95_I99 = sum(I95_I99, na.rm = T)) %>%
  pivot_longer(cols = c(I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99), 
               names_to = "variable", 
               values_to = "value")



dfYear <-  NkaPollMort  %>%
  select(date, I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99) %>%
  pivot_longer(cols = I00_I02:I95_I99, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/NkaCardMortYearSum.csv")

sum <- NkaPollMort %>% 
  select(date, I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99) %>%
  dplyr::summarise(I00_I02 = sum(I00_I02, na.rm = T),
                   I05_I09 = sum(I05_I09, na.rm = T),
                   I10_I15 = sum(I10_I15, na.rm = T),
                   I20_I25 = sum(I20_I25, na.rm = T),
                   I26_I28 = sum(I26_I28, na.rm = T),
                   I30_I52 = sum(I30_I52, na.rm = T),
                   I60_I69 = sum(I60_I69, na.rm = T),
                   I70_I79 = sum(I70_I79, na.rm = T),
                   I80_I89 = sum(I80_I89, na.rm = T),
                   I95_I99 = sum(I95_I99, na.rm = T)) %>%
  pivot_longer(cols = c(I00_I02, I05_I09, I10_I15, I20_I25, I26_I28, I30_I52, I60_I69, I70_I79, I80_I89, I95_I99), 
               names_to = "variable", 
               values_to = "value")


df <-  NkaPollMort  %>%
  pivot_longer(cols = I10_I15:I95_I99, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/NkaCardMortSum.csv")



# Nkangala Pulmonary ------------------------------------------------------------

NkaPulmort <- Mortality %>% 
  filter(death_district == 'Nkangala') %>% 
  filter(Underlying_Main_Grp == 'J00_J99') %>% 
  filter(!Underlyingcause %in% c("J09", "J10", "J11")) 

NkaAllPul_counts <-  NkaPulmort %>%
  group_by(DeathDate) %>%
  dplyr::summarize(death_count = n())%>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaSexPul_counts <- NkaPulmort %>%
  group_by(DeathDate, Sex) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = Sex, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate,
         Female = "2",
         Male = "1") %>% 
  select(- "8", -"9")


NkaPulmort <- NkaPulmort %>%
  mutate(age_category = case_when(
    AGEYEAR < 15 ~ "BelowFif",
    AGEYEAR >= 15 & AGEYEAR <= 64 ~ "FifToSixtyFour",
    AGEYEAR >= 65 ~ "SixtyFivePlus"
  ))

# Group by death_date and age_category and count deaths
NkaAgePul_counts <- NkaPulmort %>%
  group_by(DeathDate, age_category) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from = age_category, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)


# Group by death_date and Underlying_Broad_Grp
NkacatPull_counts <- NkaPulmort %>%
  group_by(DeathDate,  Underlying_Broad_Grp) %>%
  dplyr::summarize(death_count = n(), .groups = 'drop') %>%
  pivot_wider(names_from =  Underlying_Broad_Grp, values_from = death_count, values_fill = list(death_count = 0)) %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d-%m-%Y")) %>%
  rename(date = DeathDate)

NkaPollMort <- air_pollution_data %>%
  left_join(NkaAllPul_counts, by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkaSexPul_counts, by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkaAgePul_counts , by = "date")

NkaPollMort <- NkaPollMort %>%
  left_join(NkacatPull_counts , by = "date")

write.csv(NkaPollMort, "MortData/NkaPollPulMort.csv", row.names = TRUE)


# Summary 

sumYear <- NkaPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  group_by(year) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  NkaPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/NkaPollPulMortYearSum.csv")

sum <- NkaPollMort %>% 
  select(date, death_count, Male, Female, FifToSixtyFour, SixtyFivePlus) %>%
  summarise(death_count = sum(death_count, na.rm = T),
            Male = sum(Male, na.rm = T),
            Female = sum(Female, na.rm = T),
            FifToSixtyFour = sum(FifToSixtyFour, na.rm = T),
            SixtyFivePlus = sum(SixtyFivePlus, na.rm = T)) %>%
  pivot_longer(cols = c(death_count, Male, Female, FifToSixtyFour, SixtyFivePlus), 
               names_to = "variable", 
               values_to = "value")


df <-  NkaPollMort  %>%
  pivot_longer(cols = pm2.5:SixtyFivePlus, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/NkaPollPulMortSum.csv")

sumYear <- NkaPollMort %>% 
  novaAQM::datify() %>%
  select(date, year, J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99) %>%
  group_by(year) %>%
  dplyr::summarise(J00_J06 = sum(J00_J06, na.rm = T),
            J09_J18 = sum(J09_J18, na.rm = T),
            J20_J22 = sum(J20_J22, na.rm = T),
            J30_J39 = sum(J30_J39, na.rm = T),
            J40_J47 = sum(J40_J47, na.rm = T),
            J60_J70 = sum(J60_J70, na.rm = T),
            J80_J84 = sum(J80_J84, na.rm = T),
            J85_J86 = sum(J85_J86, na.rm = T),
            J90_J94 = sum(J90_J94, na.rm = T),
            J95_J99 = sum(J95_J99, na.rm = T)) %>%
  pivot_longer(cols = c(J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99), 
               names_to = "variable", 
               values_to = "value")


dfYear <-  NkaPollMort  %>%
  select(date,J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99) %>%
  pivot_longer(cols = J00_J06:J95_J99, names_to = "variable") %>%
  novaAQM::datify() %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(year, variable)
  ) %>% 
  left_join(sumYear, by = c("year", "variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(year, variable) 

write.csv(dfYear,"RDA/NkaPulMortYearSum.csv")

sum <- NkaPollMort %>% 
  select(date, J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99) %>%
  dplyr::summarise(J00_J06 = sum(J00_J06, na.rm = T),
            J09_J18 = sum(J09_J18, na.rm = T),
            J20_J22 = sum(J20_J22, na.rm = T),
            J30_J39 = sum(J30_J39, na.rm = T),
            J40_J47 = sum(J40_J47, na.rm = T),
            J60_J70 = sum(J60_J70, na.rm = T),
            J80_J84 = sum(J80_J84, na.rm = T),
            J85_J86 = sum(J85_J86, na.rm = T),
            J90_J94 = sum(J90_J94, na.rm = T),
            J95_J99 = sum(J95_J99, na.rm = T)) %>%
  pivot_longer(cols = c(J00_J06, J09_J18, J20_J22, J30_J39, J40_J47, J60_J70, J80_J84, J85_J86, J90_J94, J95_J99), 
               names_to = "variable", 
               values_to = "value")


df <-  NkaPollMort  %>%
  pivot_longer(cols = J09_J18:J30_J39, names_to = "variable") %>%
  dplyr::summarize(
    novaAQM::tenpointsummary(value) , .by = c(variable)
  ) %>% 
  left_join(sum, by = c("variable")) %>% 
  select(-n, -NAs) %>% 
  rename("Total" = "value") %>% 
  relocate("Total", .after = "variable") %>%
  arrange(variable)

write.csv(df,"RDA/NkaPulMortSum.csv")





