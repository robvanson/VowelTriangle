# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#
library(ggplot2)
# A4 size in Inches
OutputWidth <-  11.692;
OutputHeight <- 8.267;
#
filename <- "Figure2.pdf"

se <- function(x) sqrt(var(x)/length(x))
ci <- function(x) {t <- t.test(x); (t$conf.int[[2]]- t$conf.int[[1]])/2}

VowelTable <- read.table("IFA_corpus_data.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$VowelDensity <- VowelTable$N/VowelTable$Duration
AverageVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Text, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Text, data=VowelTable, sd);

AverageSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, mean);
SdevSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, sd);
SerrSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, se);
CintSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, ci);
NSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style, data=VowelTable, length);

AverageAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, mean);
SdAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, sd);
SeAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, se);
CiAllVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Style, data=VowelTable, ci);


# Plot averages per speaker by style
VowelTable$Style <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);
VowelTable$StyleNum <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);

# Plot figure
pdf(filename, width=OutputWidth, height=OutputHeight);

SpeakerList <- c("N","I","G","L","E","R","K","H", "D", "O")
colorlist <- c("darkgreen", "darkred", "darkblue", "deeppink4", "green", "blue", "red", "deeppink", "gold4", "darkolivegreen")
i <- 1

# Draw lines with breaks
# Average
par(mai=c(1.02,1.02,0.82,0.42))
plot(as.numeric(AverageAllVowels$Style), AverageAllVowels$Area2, type="b", col="black", pch=21, ylab="Vowel space area (2SD)", cex.lab=2.5, xlab="Speaking style", ylim=c(51,145), bg="black", lty=2, axes=FALSE, frame.plot=TRUE)

Axis(side=1, labels=c("Informal", "Retold", "Text", "Sentences", "Words", "Syllables"), at=1:length(c("Inf", "Ret", "Txt", "Sent", "Words", "Syll")), cex.axis=2)
Axis(side=2, labels=TRUE, cex.axis=1.5)
text(x=c(1:6), y=52, pos=1, cex=1.5, labels=aggregate(NSpeakerVowels$N~Style, data=NSpeakerVowels, mean)[,2])

# All the speakers
epsilon <- 0.03
for(i in 1:length(SpeakerList)){
	xSpeaker <- as.numeric(AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Style)
	ySpeaker <- AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Area2
	lines(xSpeaker, ySpeaker, type="l", col=colorlist[[i]], pch=SpeakerList[[i]])
	lines(xSpeaker, ySpeaker, type="p", col="white", cex=3, pch=22, bg="white")
}

# Fill in the labels
lines(as.numeric(AverageAllVowels$Style), AverageAllVowels$Area2, type="p", col="black", pch=21, ylab="Vowel space area (2SD)", xlab="Speaking style", ylim=c(55,145), bg="black", lty=2)
# All the speakers
for(i in 1:length(SpeakerList)){
	xSpeaker <- as.numeric(AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Style)
	ySpeaker <- AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Area2
	ciSpeaker <- CintSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Area2
	
	lines(AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Style, AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]],]$Area2, type="p", col=colorlist[[i]], pch=SpeakerList[[i]], cex=1.5)

	if(AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]]& AverageSpeakerVowels$Style=="Y",]$Sex == "F"){
		sexlabel = '\\VE'
	} else {sexlabel = '\\MA'}
	text(length(c("I", "R", "T", "S", "W", "Y")), AverageSpeakerVowels[AverageSpeakerVowels$Speaker==SpeakerList[[i]]& AverageSpeakerVowels$Style=="Y",]$Area2, pos=4, cex=2, labels=sexlabel,vfont=c("sans serif","bold"))

	# Confidence bars
	xSpeaker <- xSpeaker + runif(1, -0.04, 0.04)
	segments(xSpeaker, ySpeaker-ciSpeaker, xSpeaker, ySpeaker+ciSpeaker)
	segments(xSpeaker-epsilon, ySpeaker-ciSpeaker, xSpeaker+epsilon, ySpeaker-ciSpeaker)
	segments(xSpeaker-epsilon, ySpeaker+ciSpeaker, xSpeaker+epsilon, ySpeaker+ciSpeaker)
}

legend("topleft", c("Average over all speakers", "95% confidence intervals", "Female: E, G, I, L, N", "Male: D, H, K, O, R"), pch=c(21, 124, 26, 26), pt.bg=c("black"), bty="n", cex=1.5, pt.cex=1.5)
dev.off(dev.cur())
