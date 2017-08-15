# R
#
VowelTable <- read.table("area.tsv", header = TRUE, sep = "\t", na.strings = "-");
AverageVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, Intensity)~Speaker+Sex+Text+T, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, Intensity)~Speaker+Sex+Text+T, data=VowelTable, sd);

print("80 + Auto + Woorden")
analysisVowelVF<-lm(Area2 ~ Speaker+T+Text+Speaker*T+T*Text+Speaker*Text+Speaker*T*Text, data=VowelTable)
print(anova(analysisVowelVF))
print(summary.lm(analysisVowelVF))

print("80")
analysisVowelV<-lm(Area2 ~ Speaker+T+Speaker*T, data=VowelTable, subset=VowelTable$Text=="80")
print(anova(analysisVowelV))
print(summary.lm(analysisVowelV))

print("Auto")
analysisVowelF<-lm(Area2 ~ Speaker+T+Speaker*T, data=VowelTable, subset=VowelTable$Text=="Auto")
print(anova(analysisVowelF))
print(summary.lm(analysisVowelF))

print("Woorden")
analysisVowelF<-lm(Area2 ~ Speaker+T+Speaker*T, data=VowelTable, subset=VowelTable$Text=="Auto")
print(anova(analysisVowelF))
print(summary.lm(analysisVowelF))

# Box plot of averages by style
plot(VowelTable[VowelTable$Text=="80",]$T, VowelTable[VowelTable$Text=="80",]$Area2)
plot(VowelTable[VowelTable$Text=="Auto",]$T, VowelTable[VowelTable$Text=="Auto",]$Area2)
plot(VowelTable[VowelTable$Text=="woorden",]$T, VowelTable[VowelTable$Text=="Woorden",]$Area2)

plot(AverageVowels[AverageVowels$Text=="80",]$T, AverageVowels[AverageVowels$Text=="80",]$Area2)
plot(AverageVowels[AverageVowels$Text=="Auto",]$T, AverageVowels[AverageVowels$Text=="Auto",]$Area2)
plot(AverageVowels[AverageVowels$Text=="Woorden",]$T, AverageVowels[AverageVowels$Text=="Woorden",]$Area2)

plot(VowelTable$T, VowelTable$Area2)
