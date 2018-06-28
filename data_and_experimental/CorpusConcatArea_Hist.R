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
filename <- "CorpusConcatArea_hist.pdf"

se <- function(x) sqrt(var(x)/length(x))
ci <- function(x) {if(length(x)>3) {t <- t.test(x); (t$conf.int[[2]]- t$conf.int[[1]])/2} else 0 }

VowelTable <- read.table("IFA_concat_dataFM_Robust.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$VowelDensity <- VowelTable$N/VowelTable$Duration
AverageVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Session, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker+Sex+Style+Session, data=VowelTable, sd);

AverageSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, mean);
SdevSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, sd);
SerrSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, se);
CintSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, ci);
NSpeakerVowels <- aggregate(cbind(Area1, Area2, N, i.dist, u.dist, a.dist, Duration, VowelDensity)~Speaker, data=VowelTable, length);

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
par(family="Helvetica")
barplot(sort(AverageSpeakerVowels$Area2), names.arg=as.character(AverageSpeakerVowels[order(AverageSpeakerVowels$Area2),"Speaker"]))


dev.off(dev.cur())
