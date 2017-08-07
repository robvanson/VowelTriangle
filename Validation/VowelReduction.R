# R
#
VowelTable <- read.table("VowelReductionTest.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$Style <- factor(VowelTable$Style, levels=c("VI", "VT", "VS", "VW", "VY"), ordered=T);
AverageVowels <- aggregate(cbind(Area, N, i.dist, u.dist, a.dist)~Speaker+Sex+Style, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area, N, i.dist, u.dist, a.dist)~Speaker+Sex+Style, data=VowelTable, sd);


#for (Speaker in c("N","I","G","L","E","R","K","H", "D", "O")) {
#print(Speaker)
#print(t.test(VowelTable[VowelTable$Style=="VI"&VowelTable$Speaker==Speaker,]$Area, VowelTable[VowelTable$Style=="VT"&VowelTable$Speaker==Speaker,]$Area));
#};

#analysisVowel<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Speaker=="VI"|VowelTable$Style=="VT")
#analysisVowel<-lm(cbind(i.dist,u.dist,a.dist) ~ Speaker+Style, data=VowelTable)
analysisVowel<-lm(Area ~ Speaker+Style, data=VowelTable)
print(anova(analysisVowel))
print(summary.lm(analysisVowel))

# Box plot of averages by style
plot(VowelTable$Style, VowelTable$Area)

plot(AverageVowels$Style, AverageVowels$Area)
