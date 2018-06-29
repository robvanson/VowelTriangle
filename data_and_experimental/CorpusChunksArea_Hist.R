# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#
library(ggplot2)
# A4 size in Inches
OutputWidth <-  11.692;
OutputHeight <- 7.5;
#
filename <- "CorpusChunksArea_hist.pdf"

se <- function(x) sqrt(var(x)/length(x))
ci <- function(x) {if(length(x)>3) {t <- t.test(x); (t$conf.int[[2]]- t$conf.int[[1]])/2} else 0 }

VowelTable <- read.table("IFA_chunks_dataFM_Robust.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$VowelDensity <- VowelTable$N/VowelTable$Duration
AverageVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Session, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Session, data=VowelTable, sd);

AverageSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, mean);
SdevSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, sd);
SerrSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, se);
CintSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, ci);
NSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, length);
AverageSpeakerVowels$Symbol = '\\VE'
AverageSpeakerVowels[AverageSpeakerVowels$Speaker %in% c("R", "K", "H", "D", "O"), ]$Symbol = '\\MA'

AverageAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, mean);
SdAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, sd);
SeAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, se);
CiAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, ci);


# Plot averages per speaker by style
VowelTable$Style <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);
VowelTable$StyleNum <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);

# Plot figure
pdf(filename, width=OutputWidth, height=OutputHeight, useDingbats=FALSE);

SpeakerList <- c("N","I","G","L","E","R","K","H", "D", "O")
colorlist <- c("darkgreen", "darkred", "darkblue", "deeppink4", "green", "blue", "red", "deeppink", "gold4", "darkolivegreen")
i <- 1

# Average
par(mai=c(1.02,1.02,0.2,0.42))
par(family="Helvetica")
x <- barplot(sort(AverageSpeakerVowels$Area2), ylim=c(0, 120), ylab="Mean vowel space area (2SD) %", xlab="Speaker", cex.lab=2, col="gray90")

segments(x, AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2-CintSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2/2, x, AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2+CintSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2/2)
segments(x-0.1, AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2+CintSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2/2, x+0.1, AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2+CintSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2/2)
segments(x-0.1, AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2-CintSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2/2, x+0.1, AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2-CintSpeakerVowels[order(AverageSpeakerVowels$Area2),]$Area2/2)

text(x, 5, cex=3, col="black", labels=AverageSpeakerVowels$Symbol,vfont=c("sans serif","bold"))

axis(side=1, labels=as.character(AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),"Speaker"]), at=x, cex.axis=1.5)
abline(h=0, lwd=3)
legend("topleft", c("Chunks", "95% confidence intervals"), pch=c(26, 124), pt.bg="white", col=c("black"), bty="n", cex=1.5, pt.cex=1.5, lty=c(0), lwd=4)

dev.off(dev.cur())
