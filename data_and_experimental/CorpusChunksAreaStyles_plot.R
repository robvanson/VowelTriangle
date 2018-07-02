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
filename <- "CorpusChunksAreaStyles_plot.pdf"

se <- function(x) sqrt(var(x)/length(x))
ci <- function(x) {if(length(x)>3) {t <- t.test(x); (t$conf.int[[2]]- t$conf.int[[1]])/2} else 0 }

VowelTable <- read.table("IFA_chunks_dataFM_Robust.tsv", header = TRUE, sep = "\t", na.strings = "-");

VowelTable$VowelDensity <- VowelTable$N/VowelTable$Duration
AverageVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Session, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Session, data=VowelTable, sd);


AverageSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, mean);
SdevSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, sd);
SerrSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, se);
CintSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, ci);
NSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, length);

AverageAllVowelsSpeakers <- aggregate(cbind(Area2)~Speaker, data=VowelTable, mean);
SdAllVowelsSpeakers <- aggregate(cbind(Area2)~Speaker, data=VowelTable, sd);

VowelTable <- merge(VowelTable, AverageAllVowelsSpeakers, by=c("Speaker"), suffixes=c("", "Mean"))
VowelTable <- merge(VowelTable, SdAllVowelsSpeakers, by=c("Speaker"), suffixes=c("", "Sd"))
VowelTable$Area2 <- (VowelTable$Area2 - VowelTable$Area2Mean)/VowelTable$Area2Sd

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

# Draw lines with breaks
# Average
par(mai=c(1.02,1.02,0.1,0.42))
plot(as.numeric(AverageAllVowels$Style), AverageAllVowels$Area2, type="b", col=colorlist[3], pch=21, ylab="Normalized vowel space area", cex.lab=2.5, xlab="Speaking style", ylim=c(-0.5,1.5), bg="white", lty=2, lwd=6, cex=1, axes=FALSE, frame.plot=TRUE)
text(x=3.5, y=140, label="Chunks", cex=2.5, pos=3)

Axis(side=1, labels=c("Informal", "Retold", "Text", "Sentences", "Words", "Syllables"), at=1:length(c("Inf", "Ret", "Txt", "Sent", "Words", "Syll")), cex.axis=2)
Axis(side=2, labels=TRUE, cex.axis=1.5)

x <- as.numeric(AverageAllVowels$Style)
segments(x, AverageAllVowels$Area2-CiAllVowels$Area2, x , AverageAllVowels$Area2+CiAllVowels$Area2, col=colorlist[3], lwd=3)
segments(x-0.1, AverageAllVowels$Area2+CiAllVowels$Area2, x+0.1 , AverageAllVowels$Area2+CiAllVowels$Area2, col=colorlist[3], lwd=3)
segments(x-0.1, AverageAllVowels$Area2-CiAllVowels$Area2, x+0.1 , AverageAllVowels$Area2-CiAllVowels$Area2, col=colorlist[3], lwd=3)


legend("topleft", c("Chunks", "Average over speakers (normalized)", "95% confidence intervals"), pch=c(26, 21, 124), pt.bg=colorlist[3], col=c("black", colorlist[3], colorlist[3]), bty="n", cex=1.5, pt.cex=1, lty=c(0, 2, 0), lwd=3)


dev.off(dev.cur())
