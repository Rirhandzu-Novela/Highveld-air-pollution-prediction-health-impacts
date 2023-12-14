
library("openair")
Mortality = read.csv("District mortality.csv", header = T, sep = ";")
head(Mortality)

ds = format(as.Date(Mortality$DeathDate, '%m/%d/%Y'), '%d/%m/%Y')
head(ds)
head(Mortality)
Mortality$DeathDate <- ds
head(Mortality)

write.csv(Mortality, "C:\\Users\\REAL\\Documents\\Mortality.csv", row.names = TRUE)

disMortality = read.csv("Mortality.csv", header = T, sep = ";")
head(disMortality)

Cardmort =subset(disMortality, Underlyingcause == '1')
head(Cardmort)
write.csv(Cardmort, "C:\\Users\\REAL\\Documents\\Cardmort.csv", row.names = TRUE)

pulmort =subset(disMortality, Underlyingcause == '2')
head(pulmort)
write.csv(pulmort, "C:\\Users\\REAL\\Documents\\pulmort.csv", row.names = TRUE)

maleCardmort =subset(Cardmort, Sex == '1')
head(maleCardmort)
write.csv(maleCardmort, "C:\\Users\\REAL\\Documents\\maleCardmort.csv", row.names = TRUE)

femaleCardmort =subset(Cardmort, Sex == '2')
head(femaleCardmort)
write.csv(femaleCardmort, "C:\\Users\\REAL\\Documents\\femaleCardmort.csv", row.names = TRUE)

malepulmort =subset(pulmort, Sex == '1')
head(malepulmort)
write.csv(malepulmort, "C:\\Users\\REAL\\Documents\\malepulmort.csv", row.names = TRUE)

femalepulmort =subset(pulmort, Sex == '2')
head(femalepulmort)
write.csv(femalepulmort, "C:\\Users\\REAL\\Documents\\femalepulmort.csv", row.names = TRUE)

GertCardmort =subset(Cardmort, death_district == '1')
head(GertCardmort)
write.csv(GertCardmort, "C:\\Users\\REAL\\Documents\\GertCardmort.csv", row.names = TRUE)

nkaCardmort =subset(Cardmort, death_district == '2')
head(nkaCardmort)
write.csv(nkaCardmort, "C:\\Users\\REAL\\Documents\\nkaCardmort.csv", row.names = TRUE)

gertpulmort =subset(pulmort, death_district == '1')
head(gertpulmort)
write.csv(gertpulmort, "C:\\Users\\REAL\\Documents\\gertpulmort.csv", row.names = TRUE)

nkapulmort =subset(pulmort, death_district == '2')
head(nkapulmort)
write.csv(nkapulmort, "C:\\Users\\REAL\\Documents\\nkapulmort.csv", row.names = TRUE)

Cardmort10 =subset(Cardmort, AGEYEAR <= '10')
head(Cardmort10)
write.csv(Cardmort10, "C:\\Users\\REAL\\Documents\\Cardmort10.csv", row.names = TRUE)

Cardmort64 =subset(Cardmort, AGEYEAR > '10' & AGEYEAR <= '64')
head(Cardmort64)
write.csv(Cardmort64, "C:\\Users\\REAL\\Documents\\Cardmort64.csv", row.names = TRUE)

Cardmort65 =subset(Cardmort, AGEYEAR >= '65')
head(Cardmort65)
write.csv(Cardmort65, "C:\\Users\\REAL\\Documents\\Cardmort65.csv", row.names = TRUE)

pulmort10 =subset(pulmort, AGEYEAR <= '10')
head(pulmort10)
write.csv(pulmort10, "C:\\Users\\REAL\\Documents\\pulmort10.csv", row.names = TRUE)

pulmort64 =subset(pulmort, AGEYEAR > '10' & AGEYEAR <= '64')
head(pulmort64)
write.csv(pulmort64, "C:\\Users\\REAL\\Documents\\pulmort64.csv", row.names = TRUE)

pulmort65 =subset(pulmort, AGEYEAR >= '65')
head(pulmort65)
write.csv(pulmort65, "C:\\Users\\REAL\\Documents\\pulmort65.csv", row.names = TRUE)

library(dplyr)
all = read.csv("allpulmort.csv", header = T, sep = ";")
class(all$DeathDate)
all <- all %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(all$DeathDate)

x = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, all, length)
head(x)
write.csv(x, "C:\\Users\\REAL\\Documents\\pul.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pul.csv", header = T, sep = ";")

puldata <- left_join(df1, df2, by=c("date"))
head(puldata)
write.csv(puldata, "C:\\Users\\REAL\\Documents\\puldata.csv", row.names = TRUE)


allc = read.csv("allcardmort.csv", header = T, sep = ";")
class(allc$DeathDate)
allc <- allc %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allc$DeathDate)

y = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allc, length)
head(y)
write.csv(y, "C:\\Users\\REAL\\Documents\\card.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("card.csv", header = T, sep = ";")

carddata <- left_join(df1, df2, by=c("date"))
head(carddata)
write.csv(carddata, "C:\\Users\\REAL\\Documents\\carddata.csv", row.names = TRUE)

all = read.csv("allpulmort.csv", header = T, sep = ";")
class(all$DeathDate)
all <- all %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(all$DeathDate)

x = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, all, length)
head(x)
write.csv(x, "C:\\Users\\REAL\\Documents\\pul.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pul.csv", header = T, sep = ";")

puldata <- left_join(df1, df2, by=c("date"))
head(puldata)
write.csv(puldata, "C:\\Users\\REAL\\Documents\\puldata.csv", row.names = TRUE)

library(dplyr)
all10 = read.csv("allcardmort10.csv", header = T, sep = ";")
class(all10$DeathDate)
all10 <- all10 %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(all10$DeathDate)

k = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, all10, length)
head(k)
write.csv(k, "C:\\Users\\REAL\\Documents\\card10.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("card10.csv", header = T, sep = ";")

carddata10 <- left_join(df1, df2, by=c("date"))
head(carddata10)
write.csv(carddata10, "C:\\Users\\REAL\\Documents\\carddata10.csv", row.names = TRUE)

all64 = read.csv("allcardmort64.csv", header = T, sep = ";")
class(all64$DeathDate)
all64 <- all64 %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(all64$DeathDate)

l = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, all64, length)
head(l)
write.csv(l, "C:\\Users\\REAL\\Documents\\card64.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("card64.csv", header = T, sep = ";")

carddata64 <- left_join(df1, df2, by=c("date"))
head(carddata64)
write.csv(carddata64, "C:\\Users\\REAL\\Documents\\carddata64.csv", row.names = TRUE)

all65 = read.csv("allcardmort65.csv", header = T, sep = ";")
class(all65$DeathDate)
all65 <- all65 %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(all65$DeathDate)

m = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, all65, length)
head(m)
write.csv(m, "C:\\Users\\REAL\\Documents\\card65.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("card65.csv", header = T, sep = ";")

carddata65 <- left_join(df1, df2, by=c("date"))
head(carddata65)
write.csv(carddata65, "C:\\Users\\REAL\\Documents\\carddata65.csv", row.names = TRUE)

allmale = read.csv("allcardmortmale.csv", header = T, sep = ";")
class(allmale$DeathDate)
allmale <- allmale %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allmale$DeathDate)

n = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allmale, length)
head(n)
write.csv(n, "C:\\Users\\REAL\\Documents\\cardmale.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("cardmale.csv", header = T, sep = ";")

carddatamale <- left_join(df1, df2, by=c("date"))
head(carddatamale)
write.csv(carddatamale, "C:\\Users\\REAL\\Documents\\carddatamale.csv", row.names = TRUE)

allfema = read.csv("allcardmortfema.csv", header = T, sep = ";")
class(allfema$DeathDate)
allfema <- allfema %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allfema$DeathDate)

p = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allfema, length)
head(p)
write.csv(p, "C:\\Users\\REAL\\Documents\\cardfema.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("cardfema.csv", header = T, sep = ";")

carddatafema <- left_join(df1, df2, by=c("date"))
head(carddatafema)
write.csv(carddatafema, "C:\\Users\\REAL\\Documents\\carddatafema.csv", row.names = TRUE)

allp10 = read.csv("allpulmort10.csv", header = T, sep = ";")
class(allp10$DeathDate)
allp10 <- allp10 %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allp10$DeathDate)

q = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allp10, length)
head(q)
write.csv(q, "C:\\Users\\REAL\\Documents\\pul10.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pul10.csv", header = T, sep = ";")

puldata10 <- left_join(df1, df2, by=c("date"))
head(puldata10)
write.csv(puldata10, "C:\\Users\\REAL\\Documents\\puldata10.csv", row.names = TRUE)

allp64 = read.csv("allpulmort64.csv", header = T, sep = ";")
class(allp64$DeathDate)
allp64 <- allp64 %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allp64$DeathDate)

r = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allp64, length)
head(r)
write.csv(r, "C:\\Users\\REAL\\Documents\\pul64.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pul64.csv", header = T, sep = ";")

puldata64 <- left_join(df1, df2, by=c("date"))
head(puldata64)
write.csv(puldata64, "C:\\Users\\REAL\\Documents\\puldata64.csv", row.names = TRUE)

allp65 = read.csv("allpulmort65.csv", header = T, sep = ";")
class(allp65$DeathDate)
allp65 <- allp65 %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allp65$DeathDate)

s = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allp65, length)
head(s)
write.csv(s, "C:\\Users\\REAL\\Documents\\pul65.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pul65.csv", header = T, sep = ";")

puldata65 <- left_join(df1, df2, by=c("date"))
head(puldata65)
write.csv(puldata65, "C:\\Users\\REAL\\Documents\\puldata65.csv", row.names = TRUE)

allpmale = read.csv("allpulmortmale.csv", header = T, sep = ";")
class(allpmale$DeathDate)
allpmale <- allpmale %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allpmale$DeathDate)

t = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allpmale, length)
head(t)
write.csv(t, "C:\\Users\\REAL\\Documents\\pulmale.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pulmale.csv", header = T, sep = ";")

puldatamale <- left_join(df1, df2, by=c("date"))
head(puldatamale)
write.csv(puldatamale, "C:\\Users\\REAL\\Documents\\puldatamale.csv", row.names = TRUE)

allpfema = read.csv("allpulmortfema.csv", header = T, sep = ";")
class(allpfema$DeathDate)
allpfema <- allpfema %>% 
  mutate(DeathDate = as.Date(DeathDate, format = "%d/%m/%Y"))
class(allpfema$DeathDate)

v = aggregate(cbind(Count =  DeathDate) ~  DeathDate + Underlyingcause, allpfema, length)
head(v)
write.csv(v, "C:\\Users\\REAL\\Documents\\pulfema.csv", row.names = TRUE)


df1 = read.csv("AveragesDaily.csv", header = T, sep = ";")
df2 = read.csv("pulfema.csv", header = T, sep = ";")

puldatafema <- left_join(df1, df2, by=c("date"))
head(puldatafema)
write.csv(puldatafema, "C:\\Users\\REAL\\Documents\\puldatafema.csv", row.names = TRUE)


allcard = read.csv("carddata.csv", header = T, sep = ";")
summary(allcard)
sum(allcard$Count)

card64 = read.csv("carddata64.csv", header = T, sep = ";")
summary(card64)
card64[is.na(card64)] = 0
sum(card64$Count)

card65 = read.csv("carddata65.csv", header = T, sep = ";")
summary(card65)
card65[is.na(card65)] = 0
sum(card65$Count)

cardmale = read.csv("carddatamale.csv", header = T, sep = ";")
summary(cardmale)
cardmale[is.na(cardmale)] = 0
sum(cardmale$Count)

cardfema = read.csv("carddatafema.csv", header = T, sep = ";")
summary(cardfema)
cardfema[is.na(cardfema)] = 0
sum(cardfema$Count)

allpul = read.csv("puldata.csv", header = T, sep = ";")
summary(allpul)
allpul[is.na(allpul)] = 0
sum(allpul$Count)

pul64 = read.csv("puldata64.csv", header = T, sep = ";")
summary(pul64)
pul64[is.na(pul64)] = 0
sum(pul64$Count)

pul65 = read.csv("puldata65.csv", header = T, sep = ";")
summary(pul65)
pul65[is.na(pul65)] = 0
sum(pul65$Count)

pulmale = read.csv("puldatamale.csv", header = T, sep = ";")
summary(pulmale)
pulmale[is.na(pulmale)] = 0
sum(pulmale$Count)

pulfema = read.csv("puldatafema.csv", header = T, sep = ";")
summary(pulfema)
pulfema[is.na(pulfema)] = 0
sum(pulfema$Count)


