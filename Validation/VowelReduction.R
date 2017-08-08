# R
#
VowelTable <- read.table("VowelReductionTest.tsv", header = TRUE, sep = "\t", na.strings = "-");
AverageVowels <- aggregate(cbind(Area, N, i.dist, u.dist, a.dist)~Speaker+Sex+Style+Text, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area, N, i.dist, u.dist, a.dist)~Speaker+Sex+Style+Text, data=VowelTable, sd);


#for (Speaker in c("N","I","G","L","E","R","K","H", "D", "O")) {
#print(Speaker)
#print(t.test(VowelTable[VowelTable$Style=="VI"&VowelTable$Speaker==Speaker,]$Area, VowelTable[VowelTable$Style=="VT"&VowelTable$Speaker==Speaker,]$Area));
#};

#analysisVowel<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Speaker=="VI"|VowelTable$Style=="VT")
#analysisVowel<-lm(cbind(i.dist,u.dist,a.dist) ~ Speaker+Style, data=VowelTable)
#analysisVowel<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Text=="V")

print("V + F")
analysisVowelVF<-lm(Area ~ Speaker+Style+Text, data=VowelTable)
print(anova(analysisVowelVF))
print(summary.lm(analysisVowelVF))

print("V")
analysisVowelV<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Text=="V")
print(anova(analysisVowelV))
print(summary.lm(analysisVowelV))

print("F")
analysisVowelF<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Text=="F")
print(anova(analysisVowelF))
print(summary.lm(analysisVowelF))

# Box plot of averages by style
VowelTable$Style <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);
plot(VowelTable[VowelTable$Text=="V",]$Style, VowelTable[VowelTable$Text=="V",]$Area)
plot(VowelTable[VowelTable$Text=="F",]$Style, VowelTable[VowelTable$Text=="F",]$Area)

plot(AverageVowels[AverageVowels$Text=="V",]$Style, AverageVowels[AverageVowels$Text=="V",]$Area)
plot(AverageVowels[AverageVowels$Text=="F",]$Style, AverageVowels[AverageVowels$Text=="F",]$Area)

plot(VowelTable$Style, VowelTable$Area)
