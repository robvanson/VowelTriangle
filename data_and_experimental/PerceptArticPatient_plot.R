# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#
#
library("lmtest")
#
# A4 size in Inches
OutputWidth <-  11.692;
OutputHeight <- 7.5;
#
filenameTextWords <- "PerceptualArtRateVSA_hist_TextWords.pdf"
filenameText <- "PerceptualArtRateVSA_hist_Text.pdf"
filenameWords <- "PerceptualArtRateVSA_hist_Words.pdf"


LexpTableIndividual <- read.table("ListeningExp.tsv", header = TRUE, sep = "\t", na.strings = "-");
LexpTableIndividual$T <- factor(LexpTableIndividual$T, ordered=TRUE)
LexpTableIndividual$Speaker <- factor(LexpTableIndividual$Speaker, ordered=FALSE)

PatakaTable <- read.table("Pataka_results.tsv", header = TRUE, sep = "\t", na.strings = "-");

VowelTable <- read.table("Patient_data_Robust.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$T <- factor(VowelTable$T, ordered=TRUE)
VowelTable$Speaker <- factor(VowelTable$Speaker, ordered=TRUE)

# Normalize scores
LexpTableIndividual$NormRating <- LexpTableIndividual$Rating
for(eval in unique(LexpTableIndividual$Evaluator)){
	LexpTableIndividual[LexpTableIndividual$Evaluator==eval,]$NormRating <- as.vector(scale(LexpTableIndividual[LexpTableIndividual$Evaluator==eval,]$Rating))
}

LexpTable <- aggregate(cbind(Rating, NormRating)~Speaker+T+Sex, data=LexpTableIndividual, mean);
VowelTable <- merge(VowelTable, LexpTable, by=c("Speaker", "T", "Sex"), sort = TRUE, all = TRUE)
VowelTable <- merge(VowelTable, PatakaTable, by = c("Speaker", "T"), suffixes = c("", ".pataka"), sort = TRUE, all=TRUE)


# Convert to T0, T1, T2 table
T0Table <- subset(VowelTable, subset = T == 0)
T1Table <- subset(VowelTable, subset = T == 1)
T2Table <- subset(VowelTable, subset = T == 2)
names(T2Table) <- paste(names(T2Table),".T2", sep="")
names(T2Table)[1] <- "Speaker"
names(T2Table)[2] <- "T"
names(T2Table)[3] <- "Sex"
names(T2Table)[4] <- "Name"
names(T2Table)[5] <- "Task"

TimeTable <- merge(T0Table, T1Table, by = c("Speaker", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTable <- merge(TimeTable, T2Table, by = c("Speaker", "Task"), sort = TRUE, all = TRUE)

# Indexed values on time T0
TimeTable$IdxNormRating.T1 <- 100 + 12*(TimeTable$NormRating.T1 - TimeTable$NormRating.T0)
TimeTable$IdxNormRating.T2 <- 100 + 12*(TimeTable$NormRating.T2 - TimeTable$NormRating.T0)

TimeTable$Idxart.rate.T1 <- 100 * TimeTable$art.rate.T1 / TimeTable$art.rate.T0
TimeTable$Idxart.rate.T2 <- 100 * TimeTable$art.rate.T2 / TimeTable$art.rate.T0

TimeTable$IdxArea2.T1 <- 100 * TimeTable$Area2.T1 / TimeTable$Area2.T0
TimeTable$IdxArea2.T2 <- 100 * TimeTable$Area2.T2 / TimeTable$Area2.T0

TimeTable$Idx.i.dist.T1 <- 100 * TimeTable$i.dist.T1 / TimeTable$i.dist.T0
TimeTable$Idx.i.dist.T2 <- 100 * TimeTable$i.dist.T2 / TimeTable$i.dist.T0

TimeTable$Idx.a.dist.T1 <- 100 * TimeTable$a.dist.T1 / TimeTable$a.dist.T0
TimeTable$Idx.a.dist.T2 <- 100 * TimeTable$a.dist.T2 / TimeTable$a.dist.T0

TimeTable$Idx.u.dist.T1 <- 100 * TimeTable$u.dist.T1 / TimeTable$u.dist.T0
TimeTable$Idx.u.dist.T2 <- 100 * TimeTable$u.dist.T2 / TimeTable$u.dist.T0


# Mean values and CI 
ci <- function(x) {if(length(x)>3) {t <- t.test(x, na.rm=TRUE); (t$conf.int[[2]]- t$conf.int[[1]])/2} else 0 }

# Plot figure
pdf(filenameTextWords, width=OutputWidth, height=OutputHeight, useDingbats=FALSE);

indexLabels <- c("Perc.", "A. Rate", "VSA", "a-dist", "i-dist", "u-dist")
indexSpace <- c(0, 0.5, 0.7, 0.5, 0.5, 0.5)

combinedTable <- merge(TimeTable[TimeTable$Task=="Words",], TimeTable[TimeTable$Task=="Dapre",], by=c("Speaker", "Sex"))
IndexedValues.T1 <- c(
mean(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T1, na.rm=TRUE),
mean(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T1, na.rm=TRUE),
mean((combinedTable$IdxArea2.T1.x+combinedTable$IdxArea2.T1.y)/2, na.rm=TRUE),
mean((combinedTable$Idx.a.dist.T1.x+combinedTable$Idx.a.dist.T1.y)/2, na.rm=TRUE),
mean((combinedTable$Idx.i.dist.T1.x+combinedTable$Idx.i.dist.T1.y)/2, na.rm=TRUE),
mean((combinedTable$Idx.u.dist.T1.x+combinedTable$Idx.u.dist.T1.y)/2, na.rm=TRUE)
)
IndexedValues.T1.CI <- c(
ci(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T1),
ci(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T1),
ci((combinedTable$IdxArea2.T1.x+combinedTable$IdxArea2.T1.y)/2),
ci((combinedTable$Idx.a.dist.T1.x+combinedTable$Idx.a.dist.T1.y)/2),
ci((combinedTable$Idx.i.dist.T1.x+combinedTable$Idx.i.dist.T1.y)/2),
ci((combinedTable$Idx.u.dist.T1.x+combinedTable$Idx.u.dist.T1.y)/2)
)
IndexedValues.T2 <- c(
mean(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T2, na.rm=TRUE),
mean(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T2, na.rm=TRUE),
mean((combinedTable$IdxArea2.T2.x+combinedTable$IdxArea2.T2.y)/2, na.rm=TRUE),
mean((combinedTable$Idx.a.dist.T2.x+combinedTable$Idx.a.dist.T2.y)/2, na.rm=TRUE),
mean((combinedTable$Idx.i.dist.T2.x+combinedTable$Idx.i.dist.T2.y)/2, na.rm=TRUE),
mean((combinedTable$Idx.u.dist.T2.x+combinedTable$Idx.u.dist.T2.y)/2, na.rm=TRUE)
)
IndexedValues.T2.CI <- c(
ci(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T2),
ci(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T2),
ci((combinedTable$IdxArea2.T2.x+combinedTable$IdxArea2.T2.y)/2),
ci((combinedTable$Idx.a.dist.T2.x+combinedTable$Idx.a.dist.T2.y)/2),
ci((combinedTable$Idx.i.dist.T2.x+combinedTable$Idx.i.dist.T2.y)/2),
ci((combinedTable$Idx.u.dist.T2.x+combinedTable$Idx.u.dist.T2.y)/2)
)

par(mai=c(1.04,1.02,0.3,0.42))
par(family="Helvetica")
colorlist <- c("green1", "red1", "darkblue", "deeppink4", "gold4", "darkolivegreen", "skyblue", "red", "deeppink", "green")

x <- barplot(c(IndexedValues.T1, 0, IndexedValues.T2), ylim=c(0, 120), ylab="Indexed value: T0 = 100", cex.lab=2, cex.axis=1.5, col=c(colorlist[1:6], "grey", colorlist[1:6]), space=c(indexSpace, 0.5, indexSpace))
abline(h=100, lty=2)
abline(h=0, lty=1, lwd=3)
axis(side=1, labels=c(indexLabels, " ", indexLabels), at=x, cex.axis=1.5, las=3, tick=FALSE)
axis(at=c(2.5, 10.9), tick=TRUE, side=1, labels=FALSE)
mtext("T1:", at=c(-0.5), line=2, side=1, cex=2)
mtext("T2:", at=c(9.65), line=2, side=1, cex=2)

segments(x, c(IndexedValues.T1, 0, IndexedValues.T2), x, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), lwd=2)
segments(x-0.1, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), x+0.1, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), lwd=2)


text(9.5, 120, labels="Words + Text", pos=1, cex=2)
text(x[13]+1, 100, labels="T0", pos=3, cex=1)

rect(((x[1]+x[2])/2 - 0.35), 19, ((x[1]+x[2])/2 + 0.4), 61, col="white", border="white", lty=0)
rect(((x[8]+x[9])/2 - 0.35), 19, ((x[8]+x[9])/2 + 0.4), 61, col="white", border="white", lty=0)
rect(((x[4]+x[5])/2 - 0.35), 19, ((x[4]+x[5])/2 + 0.4), 61, col="white", border="white", lty=0)
rect(((x[11]+x[12])/2 - 0.35), 19, ((x[11]+x[12])/2 + 0.4), 61, col="white", border="white", lty=0)

text((x[1]+x[2])/2, 40, labels="Articulation", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[8]+x[9])/2, 40, labels="Articulation", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[4]+x[5])/2, 40, labels="Vowel Space", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[11]+x[12])/2, 40, labels="Vowel Space", adj=c(0.5, 0.5), cex=2, srt=90)

text(x[3], 5, labels="Area", adj=c(0, 0.5), cex=1.5, srt=90, col="white")
text(x[4], 5, labels="a", adj=c(0.5, 0), cex=2, col="white")
text(x[5], 5, labels="i", adj=c(0.5, 0), cex=2, col="white")
text(x[6], 5, labels="u", adj=c(0.5, 0), cex=2, col="white")
text(x[10], 5, labels="Area", adj=c(0, 0.5), cex=1.5, srt=90, col="white")
text(x[11], 5, labels="a", adj=c(0.5, 0), cex=2, col="white")
text(x[12], 5, labels="i", adj=c(0.5, 0), cex=2, col="white")
text(x[13], 5, labels="u", adj=c(0.5, 0), cex=2, col="white")

dev.off(dev.cur())

# Text Mean values and CI 

# Plot figure
pdf(filenameText, width=OutputWidth, height=OutputHeight, useDingbats=FALSE);

indexLabels <- c("Perc.", "A. Rate", "VSA", "a-dist", "i-dist", "u-dist", "a/u-dist")
indexSpace <- c(0, 0.5, 0.7, 0.5, 0.5, 0.5, 0.5)

combinedTable <- TimeTable[TimeTable$Task=="Dapre",]
IndexedValues.T1 <- c(
mean(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T1, na.rm=TRUE),
mean(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T1, na.rm=TRUE),
mean(combinedTable$IdxArea2.T1, na.rm=TRUE),
mean(combinedTable$Idx.a.dist.T1, na.rm=TRUE),
mean(combinedTable$Idx.i.dist.T1, na.rm=TRUE),
mean(combinedTable$Idx.u.dist.T1, na.rm=TRUE),
mean(100*combinedTable$Idx.a.dist.T1/combinedTable$Idx.u.dist.T1, na.rm=TRUE)
)
IndexedValues.T1.CI <- c(
ci(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T1),
ci(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T1),
ci(combinedTable$IdxArea2.T1),
ci(combinedTable$Idx.a.dist.T1),
ci(combinedTable$Idx.i.dist.T1),
ci(combinedTable$Idx.u.dist.T1),
ci(100*combinedTable$Idx.a.dist.T1/combinedTable$Idx.u.dist.T1)
)
IndexedValues.T2 <- c(
mean(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T2, na.rm=TRUE),
mean(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T2, na.rm=TRUE),
mean(combinedTable$IdxArea2.T2, na.rm=TRUE),
mean(combinedTable$Idx.a.dist.T2, na.rm=TRUE),
mean(combinedTable$Idx.i.dist.T2, na.rm=TRUE),
mean(combinedTable$Idx.u.dist.T2, na.rm=TRUE),
mean(100*combinedTable$Idx.a.dist.T2/combinedTable$Idx.u.dist.T2, na.rm=TRUE)
)
IndexedValues.T2.CI <- c(
ci(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T2),
ci(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T2),
ci(combinedTable$IdxArea2.T2),
ci(combinedTable$Idx.a.dist.T2),
ci(combinedTable$Idx.i.dist.T2),
ci(combinedTable$Idx.u.dist.T2),
ci(100*combinedTable$Idx.a.dist.T2/combinedTable$Idx.u.dist.T2)
)

par(mai=c(1.07,1.02,0.3,0.42))
par(family="Helvetica")
colorlist <- c("green1", "red1", "darkblue", "deeppink4", "gold4", "darkolivegreen", "skyblue", "red", "deeppink", "green")

x <- barplot(c(IndexedValues.T1, 0, IndexedValues.T2), ylim=c(0, 150), ylab="Indexed value: T0 = 100", cex.lab=2, cex.axis=1.5, col=c(colorlist[1:7], "grey", colorlist[1:7]), space=c(indexSpace, 0.5, indexSpace))
abline(h=100, lty=2)
abline(h=0, lty=1, lwd=3)
axis(side=1, labels=c(indexLabels, " ", indexLabels), at=x, cex.axis=1.5, las=3, tick=FALSE)
axis(at=c(2.85, 10.9), tick=TRUE, side=1, labels=FALSE)
segments(c(2.85, (x[10]+x[11])/2), c(0,0), c(2.85, (x[10]+x[11])/2), c(40,40), lty=2)
mtext("T1:", at=c(-0.5), line=2, side=1, cex=2)
mtext("T2:", at=c(11.1), line=2, side=1, cex=2)

segments(x, c(IndexedValues.T1, 0, IndexedValues.T2), x, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), lwd=2)
segments(x-0.1, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), x+0.1, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), lwd=2)

text(11.5, 150, labels="Text", pos=1, cex=2)
text(-0.2, 100, labels="T0", pos=3, cex=2)

rect(((x[1]+x[2])/2 - 0.35), 18, ((x[1]+x[2])/2 + 0.4), 62, col="white", border="white", lty=0)
rect(((x[9]+x[10])/2 - 0.35), 18, ((x[9]+x[10])/2 + 0.4), 62, col="white", border="white", lty=0)
rect(((x[4]+x[5])/2 - 0.35), 17, ((x[4]+x[5])/2 + 0.4), 63, col="white", border="white", lty=0)
rect(((x[12]+x[13])/2 - 0.35), 17, ((x[12]+x[13])/2 + 0.4), 63, col="white", border="white", lty=0)

text((x[1]+x[2])/2, 40, labels="Articulation", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[9]+x[10])/2, 40, labels="Articulation", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[4]+x[5])/2, 40, labels="Vowel Space", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[12]+x[13])/2, 40, labels="Vowel Space", adj=c(0.5, 0.5), cex=2, srt=90)

text(x[3], 5, labels="Area", adj=c(0, 0.5), cex=1.5, srt=90, col="white")
text(x[4], 5, labels="a", adj=c(0.5, 0), cex=2, col="white")
text(x[5], 5, labels="i", adj=c(0.5, 0), cex=2, col="white")
text(x[6], 5, labels="u", adj=c(0.5, 0), cex=2, col="white")
text(x[7], 2, labels=expression(over(a, u)), adj=c(0.5, 0), cex=2, col="black")
text(x[11], 5, labels="Area", adj=c(0, 0.5), cex=1.5, srt=90, col="white")
text(x[12], 5, labels="a", adj=c(0.5, 0), cex=2, col="white")
text(x[13], 5, labels="i", adj=c(0.5, 0), cex=2, col="white")
text(x[14], 5, labels="u", adj=c(0.5, 0), cex=2, col="white")
text(x[15], 2, labels=expression(over(a, u)), adj=c(0.5, 0), cex=2, col="black")

dev.off(dev.cur())

# Words Mean values and CI 
pdf(filenameWords, width=OutputWidth, height=OutputHeight, useDingbats=FALSE);

indexLabels <- c("Perc.", "A. Rate", "VSA", "a-dist", "i-dist", "u-dist", "a/u-dist")

combinedTable <- TimeTable[TimeTable$Task=="Words",]
IndexedValues.T1 <- c(
mean(TimeTable[TimeTable$Task=="Words",]$IdxNormRating.T1, na.rm=TRUE),
mean(TimeTable[TimeTable$Task=="Words",]$Idxart.rate.T1, na.rm=TRUE),
mean(combinedTable$IdxArea2.T1, na.rm=TRUE),
mean(combinedTable$Idx.a.dist.T1, na.rm=TRUE),
mean(combinedTable$Idx.i.dist.T1, na.rm=TRUE),
mean(combinedTable$Idx.u.dist.T1, na.rm=TRUE),
mean(100*combinedTable$Idx.a.dist.T1/combinedTable$Idx.u.dist.T1, na.rm=TRUE)
)
IndexedValues.T1.CI <- c(
ci(TimeTable[TimeTable$Task=="Words",]$IdxNormRating.T1),
ci(TimeTable[TimeTable$Task=="Words",]$Idxart.rate.T1),
ci(combinedTable$IdxArea2.T1),
ci(combinedTable$Idx.a.dist.T1),
ci(combinedTable$Idx.i.dist.T1),
ci(combinedTable$Idx.u.dist.T1),
ci(100*combinedTable$Idx.a.dist.T1/combinedTable$Idx.u.dist.T1)
)
IndexedValues.T2 <- c(
mean(TimeTable[TimeTable$Task=="Words",]$IdxNormRating.T2, na.rm=TRUE),
mean(TimeTable[TimeTable$Task=="Words",]$Idxart.rate.T2, na.rm=TRUE),
mean(combinedTable$IdxArea2.T2, na.rm=TRUE),
mean(combinedTable$Idx.a.dist.T2, na.rm=TRUE),
mean(combinedTable$Idx.i.dist.T2, na.rm=TRUE),
mean(combinedTable$Idx.u.dist.T2, na.rm=TRUE),
mean(100*combinedTable$Idx.a.dist.T2/combinedTable$Idx.u.dist.T2, na.rm=TRUE)
)
IndexedValues.T2.CI <- c(
ci(TimeTable[TimeTable$Task=="Words",]$IdxNormRating.T2),
ci(TimeTable[TimeTable$Task=="Words",]$Idxart.rate.T2),
ci(combinedTable$IdxArea2.T2),
ci(combinedTable$Idx.a.dist.T2),
ci(combinedTable$Idx.i.dist.T2),
ci(combinedTable$Idx.u.dist.T2),
ci(100*combinedTable$Idx.a.dist.T2/combinedTable$Idx.u.dist.T2)
)

par(mai=c(1.07,1.02,0.3,0.42))
par(family="Helvetica")
colorlist <- c("green1", "red1", "darkblue", "deeppink4", "gold4", "darkolivegreen", "skyblue", "red", "deeppink", "green")

x <- barplot(c(IndexedValues.T1, 0, IndexedValues.T2), ylim=c(0, 150), ylab="Indexed value: T0 = 100", cex.lab=2, cex.axis=1.5, col=c(colorlist[1:7], "grey", colorlist[1:7]), space=c(indexSpace, 0.5, indexSpace))
abline(h=100, lty=2)
abline(h=0, lty=1, lwd=3)
axis(side=1, labels=c(indexLabels, " ", indexLabels), at=x, cex.axis=1.5, las=3, tick=FALSE)
axis(at=c(2.85, 10.9), tick=TRUE, side=1, labels=FALSE)
segments(c(2.85, (x[10]+x[11])/2), c(0,0), c(2.85, (x[10]+x[11])/2), c(40,40), lty=2)
mtext("T1:", at=c(-0.5), line=2, side=1, cex=2)
mtext("T2:", at=c(11.1), line=2, side=1, cex=2)

segments(x, c(IndexedValues.T1, 0, IndexedValues.T2), x, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), lwd=2)
segments(x-0.1, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), x+0.1, c(IndexedValues.T1, 0, IndexedValues.T2)+c(IndexedValues.T1.CI, 0, IndexedValues.T2.CI), lwd=2)

text(11.5, 150, labels="Words", pos=1, cex=2)
text(-0.2, 100, labels="T0", pos=3, cex=2)

rect(((x[1]+x[2])/2 - 0.35), 18, ((x[1]+x[2])/2 + 0.4), 62, col="white", border="white", lty=0)
rect(((x[9]+x[10])/2 - 0.35), 18, ((x[9]+x[10])/2 + 0.4), 62, col="white", border="white", lty=0)
rect(((x[4]+x[5])/2 - 0.35), 17, ((x[4]+x[5])/2 + 0.4), 63, col="white", border="white", lty=0)
rect(((x[12]+x[13])/2 - 0.35), 17, ((x[12]+x[13])/2 + 0.4), 63, col="white", border="white", lty=0)

text((x[1]+x[2])/2, 40, labels="Articulation", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[9]+x[10])/2, 40, labels="Articulation", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[4]+x[5])/2, 40, labels="Vowel Space", adj=c(0.5, 0.5), cex=2, srt=90)
text((x[12]+x[13])/2, 40, labels="Vowel Space", adj=c(0.5, 0.5), cex=2, srt=90)

text(x[3], 5, labels="Area", adj=c(0, 0.5), cex=1.5, srt=90, col="white")
text(x[4], 5, labels="a", adj=c(0.5, 0), cex=2, col="white")
text(x[5], 5, labels="i", adj=c(0.5, 0), cex=2, col="white")
text(x[6], 5, labels="u", adj=c(0.5, 0), cex=2, col="white")
text(x[7], 2, labels=expression(over(a, u)), adj=c(0.5, 0), cex=2, col="black")
text(x[11], 5, labels="Area", adj=c(0, 0.5), cex=1.5, srt=90, col="white")
text(x[12], 5, labels="a", adj=c(0.5, 0), cex=2, col="white")
text(x[13], 5, labels="i", adj=c(0.5, 0), cex=2, col="white")
text(x[14], 5, labels="u", adj=c(0.5, 0), cex=2, col="white")
text(x[15], 2, labels=expression(over(a, u)), adj=c(0.5, 0), cex=2, col="black")

dev.off(dev.cur())


# Statistics

# ArtRate
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T1, TimeTable[TimeTable$Task=="Dapre",]$Idxart.rate.T2, paired=TRUE, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

# NormRating
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T1, mu=0, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T2, mu=0, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T1, TimeTable[TimeTable$Task=="Dapre",]$IdxNormRating.T2, paired=TRUE, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

# Dapre
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$IdxArea2.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$IdxArea2.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idx.i.dist.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idx.i.dist.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idx.a.dist.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idx.a.dist.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idx.u.dist.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Dapre",]$Idx.u.dist.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

# Words
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$IdxArea2.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$IdxArea2.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.i.dist.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.i.dist.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.a.dist.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.a.dist.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.u.dist.T1, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.u.dist.T2, mu=100, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)

# Words+Dapre                                                                            
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$IdxArea2.T1+TimeTable[TimeTable$Task=="Dapre",]$IdxArea2.T1   , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$IdxArea2.T2+TimeTable[TimeTable$Task=="Dapre",]$IdxArea2.T2    , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
                                                                            
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.i.dist.T1+TimeTable[TimeTable$Task=="Dapre",]$Idx.i.dist.T1   , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.i.dist.T2+TimeTable[TimeTable$Task=="Dapre",]$Idx.i.dist.T2  , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
                                                                            
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.a.dist.T1+TimeTable[TimeTable$Task=="Dapre",]$Idx.a.dist.T1  , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.a.dist.T2+TimeTable[TimeTable$Task=="Dapre",]$Idx.a.dist.T2  , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
                                                                            
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.u.dist.T1+TimeTable[TimeTable$Task=="Dapre",]$Idx.u.dist.T1  , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
cat(capture.output(t.test(TimeTable[TimeTable$Task=="Words",]$Idx.u.dist.T2+TimeTable[TimeTable$Task=="Dapre",]$Idx.u.dist.T2   , mu=200, na.rm=TRUE)), sep = "\n", file = "", append = TRUE)
