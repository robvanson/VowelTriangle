# R
#
VowelTable <- read.table("VowelReductionTest.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$VowelDensity <- VowelTable$N/VowelTable$Duration
AverageVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Text, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Text, data=VowelTable, sd);


#for (Speaker in c("N","I","G","L","E","R","K","H", "D", "O")) {
#print(Speaker)
#print(t.test(VowelTable[VowelTable$Style=="VI"&VowelTable$Speaker==Speaker,]$Area, VowelTable[VowelTable$Style=="VT"&VowelTable$Speaker==Speaker,]$Area));
#};

#analysisVowel<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Speaker=="VI"|VowelTable$Style=="VT")
#analysisVowel<-lm(cbind(i.dist,u.dist,a.dist) ~ Speaker+Style, data=VowelTable)
#analysisVowel<-lm(Area ~ Speaker+Style, data=VowelTable, subset=VowelTable$Text=="V")

print("V + F")
analysisVowelVF<-lm(Area2 ~ Speaker+Style+Text+Speaker*Style+Style*Text+Speaker*Text+Speaker*Style*Text, data=VowelTable)
print(anova(analysisVowelVF))
print(summary.lm(analysisVowelVF))

print("V")
analysisVowelV<-lm(Area2 ~ Speaker+Style+Speaker*Style, data=VowelTable, subset=VowelTable$Text=="V")
print(anova(analysisVowelV))
print(summary.lm(analysisVowelV))

print("F")
analysisVowelF<-lm(Area2 ~ Speaker+Style + Speaker*Style, data=VowelTable, subset=VowelTable$Text=="F")
print(anova(analysisVowelF))
print(summary.lm(analysisVowelF))

# Box plot of averages by style
VowelTable$Style <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);
plot(VowelTable[VowelTable$Text=="V",]$Style, VowelTable[VowelTable$Text=="V",]$Area2)
plot(VowelTable[VowelTable$Text=="F",]$Style, VowelTable[VowelTable$Text=="F",]$Area2)

plot(AverageVowels[AverageVowels$Text=="V",]$Style, AverageVowels[AverageVowels$Text=="V",]$Area2)
plot(AverageVowels[AverageVowels$Text=="F",]$Style, AverageVowels[AverageVowels$Text=="F",]$Area2)

plot(VowelTable$Style, VowelTable$Area2)

if(0){
# Explained variance:
print("Area2 ~ Speaker")
analysisVowelVFSpeaker<-lm(Area2 ~ Speaker, data=VowelTable)
print(anova(analysisVowelVFSpeaker))
print(summary.lm(analysisVowelVFSpeaker))
print(c("D","E", "G", "H", "I", "K", "L", "N", "O", "R"))
predict(analysisVowelVFSpeaker, data.frame( Speaker=c("D","E", "G", "H", "I", "K", "L", "N", "O", "R")))

print("Area2 ~ Style")
analysisVowelVFStyle<-lm(Area2 ~ Style, data=VowelTable)
print(anova(analysisVowelVFStyle))
print(summary.lm(analysisVowelVFStyle))
print(c("I","R", "T", "S", "W", "Y"))
predict(analysisVowelVFStyle, data.frame( Style=factor(c("I","R", "T", "S", "W", "Y"), levels=c("I", "R", "T", "S", "W", "Y"))))

print("Area2 ~ Text")
analysisVowelText<-lm(Area2 ~ Text, data=VowelTable)
print(anova(analysisVowelText))
print(summary.lm(analysisVowelText))
print(c("F","V"))
predict(analysisVowelText, data.frame( Text=c("F", "V")))

print("Area2 ~ Sex")
analysisVowelSex<-lm(Area2 ~ Sex, data=VowelTable)
print(anova(analysisVowelSex))
print(summary.lm(analysisVowelSex))
print(c("F","V"))
predict(analysisVowelSex, data.frame(Sex=c("F", "M")))

print("Area2 ~ Sex + Text + Sex*Text")
analysisVowelSexText<-lm(Area2 ~ Sex + Text + Sex*Text, data=VowelTable)
print(anova(analysisVowelSexText))
print(summary.lm(analysisVowelSexText))
print(c("F","V"))
predict(analysisVowelSexText, data.frame(Sex=c("F", "M"), Text=c("F", "V")))
}
