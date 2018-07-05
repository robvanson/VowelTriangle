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
filenameText <- "PerceptualSpaceCorr_plotText.pdf"


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

# Corr tests
TextData <- TimeTable[TimeTable$Task == "Dapre",]
WordsData <- TimeTable[TimeTable$Task == "Words",]

Area2NormRatingText.T0 <- cor.test(TextData$NormRating.T0, TextData$Area2.T0)
Area2NormRatingText.T1 <- cor.test(TextData$NormRating.T1, TextData$Area2.T1)
Area2NormRatingText.T2 <- cor.test(TextData$NormRating.T2, TextData$Area2.T2)

Area2Corr <- c(Area2NormRatingText.T0$estimate[[1]], Area2NormRatingText.T1$estimate[[1]], Area2NormRatingText.T2$estimate[[1]])
Area2P.value <- c(Area2NormRatingText.T0$p.value[[1]], Area2NormRatingText.T1$p.value[[1]], Area2NormRatingText.T2$p.value[[1]])
Area2Significance <- c("", "", "")
Area2Significance[Area2P.value < 0.05] = "*"
Area2Significance[Area2P.value < 0.01] = "**"

i.dist.NormRatingText.T0 <- cor.test(TextData$NormRating.T0, TextData$i.dist.T0)
i.dist.NormRatingText.T1 <- cor.test(TextData$NormRating.T1, TextData$i.dist.T1)
i.dist.NormRatingText.T2 <- cor.test(TextData$NormRating.T2, TextData$i.dist.T2)

i.dist.Corr <- c(i.dist.NormRatingText.T0$estimate[[1]], i.dist.NormRatingText.T1$estimate[[1]], i.dist.NormRatingText.T2$estimate[[1]])
i.dist.P.value <- c(i.dist.NormRatingText.T0$p.value[[1]], i.dist.NormRatingText.T1$p.value[[1]], i.dist.NormRatingText.T2$p.value[[1]])
i.dist.Significance <- c("", "", "")
i.dist.Significance[i.dist.P.value < 0.05] = "*"
i.dist.Significance[i.dist.P.value < 0.01] = "**"

a.dist.NormRatingText.T0 <- cor.test(TextData$NormRating.T0, TextData$a.dist.T0)
a.dist.NormRatingText.T1 <- cor.test(TextData$NormRating.T1, TextData$a.dist.T1)
a.dist.NormRatingText.T2 <- cor.test(TextData$NormRating.T2, TextData$a.dist.T2)

a.dist.Corr <- c(a.dist.NormRatingText.T0$estimate[[1]], a.dist.NormRatingText.T1$estimate[[1]], a.dist.NormRatingText.T2$estimate[[1]])
a.dist.P.value <- c(a.dist.NormRatingText.T0$p.value[[1]], a.dist.NormRatingText.T1$p.value[[1]], a.dist.NormRatingText.T2$p.value[[1]])
a.dist.Significance <- c("", "", "")
a.dist.Significance[a.dist.P.value < 0.05] = "*"
a.dist.Significance[a.dist.P.value < 0.05] = "**"

u.dist.NormRatingText.T0 <- cor.test(TextData$NormRating.T0, TextData$u.dist.T0)
u.dist.NormRatingText.T1 <- cor.test(TextData$NormRating.T1, TextData$u.dist.T1)
u.dist.NormRatingText.T2 <- cor.test(TextData$NormRating.T2, TextData$u.dist.T2)

u.dist.Corr <- c(u.dist.NormRatingText.T0$estimate[[1]], u.dist.NormRatingText.T1$estimate[[1]], u.dist.NormRatingText.T2$estimate[[1]])
u.dist.P.value <- c(u.dist.NormRatingText.T0$p.value[[1]], u.dist.NormRatingText.T1$p.value[[1]], u.dist.NormRatingText.T2$p.value[[1]])
u.dist.Significance <- c("", "", "")
u.dist.Significance[u.dist.P.value < 0.05] = "*"
u.dist.Significance[u.dist.P.value < 0.05] = "**"


# Plot

# Plot figure
pdf(filenameText, width=OutputWidth, height=OutputHeight, useDingbats=FALSE);

colorlist <- c("green1", "red1", "darkblue", "deeppink4", "gold4", "darkolivegreen", "blue", "red", "deeppink", "green")
par(mai=c(1.04,1.02,0.3,0.42))

bglist = c("white", "white", "white")
bglist[Area2P.value < 0.05] = colorlist[3]
plot(0:2, Area2Corr, ylim=c(0, 0.6), pch=21, type="o", axes = FALSE,, bg=bglist, col=colorlist[3], cex=2, lwd=2, cex.lab=2, ylab=expression("Correlation Coeff" %->% "R"), xlab="Time")

bglist = c("white", "white", "white")
bglist[i.dist.P.value < 0.05] = colorlist[5]
lines(0:2, i.dist.Corr, ylim=c(0, 0.6), pch=22, type="o", bg=bglist, col=colorlist[5], cex=2, lwd=2)

bglist = c("white", "white", "white")
bglist[a.dist.P.value < 0.05] = colorlist[4]
lines(0:2, a.dist.Corr, ylim=c(0, 0.6), pch=23, type="o", bg=bglist, col=colorlist[4], cex=2, lwd=2)

bglist = c("white", "white", "white")
bglist[u.dist.P.value < 0.05] = colorlist[6]
lines(0:2, u.dist.Corr, ylim=c(0, 0.6), pch=24, type="o", bg=bglist, col=colorlist[6], cex=2, lwd=2)

text(0:2, Area2Corr, Area2Significance, cex=2, pos=4, col=colorlist[3])
text(0:2, i.dist.Corr, i.dist.Significance, cex=2, pos=4, col=colorlist[5])
text(0:2, a.dist.Corr, a.dist.Significance, cex=2, pos=4, col=colorlist[4])
text(0:2, u.dist.Corr, u.dist.Significance, cex=2, pos=4, col=colorlist[6])
axis(2, pos=-0.05, cex.axis=1.5)
axis(1, at=c(0, 1, 2), labels=c("T0", "T1", "T2"), pos=0, cex=2, cex.axis=2)
abline(h=0, lwd=2)

# Legend
text(1.5, (Area2Corr[2]+Area2Corr[3])/2+0.01, labels="VSA", cex=2, pos=3, col=colorlist[3])
text(1.5, (i.dist.Corr[2]+i.dist.Corr[3])/2, labels="i", cex=3, pos=3, col=colorlist[5])
text(1.5, (a.dist.Corr[2]+a.dist.Corr[3])/2+0.05, labels="a", cex=3, pos=3, col=colorlist[4])
text(1.5, (u.dist.Corr[2]+u.dist.Corr[3])/2, labels="u", cex=3, pos=1, col=colorlist[6])

legend("topright", legend=c("*: p<0.05", "**: p<0.01"), pch=c(21, 26), bty="n", col=c(colorlist[3]), pt.bg=c(colorlist[3]), cex=2, xjust=1)

polygon(c(0, 0.35, 0.175), c(0.16, 0.131, 0.01), lwd=1, col="grey")
segments(0.175, 0.1, 0, 0.16, lwd=2)
segments(0.175, 0.1, 0.35, 0.131, lwd=2)
segments(0.175, 0.1, 0.175, 0.01, lwd=2)
text(c(0.01, 0-0.02, 0.35+0.02, 0.175+0.03), c(0.08, 0.16, 0.131, 0.01), labels=c("vsa", "i", "u", "a"), cex=1.5)

dev.off(dev.cur())
