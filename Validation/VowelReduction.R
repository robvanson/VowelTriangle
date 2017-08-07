# R
#
VowelTable <- read.table("VowelReductionTest.tsv", header = TRUE, sep = "\t", na.strings = "-");
AverageVowels <- aggregate(cbind(Area, N, i.dist, u.dist, a.dist)~Speaker+Sex+Style, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area, N, i.dist, u.dist, a.dist)~Speaker+Sex+Style, data=VowelTable, sd);


#for (Speaker in c("N","I","G","L","E","R","K","H", "D", "O")) {
#print(Speaker)
#print(t.test(VowelTable[VowelTable$Style=="VI"&VowelTable$Speaker==Speaker,]$Area, VowelTable[VowelTable$Style=="VT"&VowelTable$Speaker==Speaker,]$Area));
#};

#analysisVowel<-lm(Area ~ Speaker+Style, VowelTable, subset=VowelTable$Style=="VI"|VowelTable$Style=="VT")
analysisVowel<-lm(Area ~ Speaker+Style, VowelTable)
print(anova(analysisVowel))
print(summary.lm(analysisVowel))
