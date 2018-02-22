# R

se <- function(x) sqrt(var(x)/length(x))
ci <- function(x) {t <- t.test(x); (t$conf.int[[2]]- t$conf.int[[1]])/2}


VowelTable <- read.table("IFA_corpus_concat.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$Style <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);

# Linear models
print("", quote=FALSE)
print("Report Concat", quote=FALSE)
print(paste("# Items: ", length(VowelTable$Area2)), quote=FALSE)

print("", quote=FALSE)
print("R^2 adjusted", quote=FALSE)

modelSpeaker <- lm(Area2 ~ Speaker, VowelTable)
aicmodelSpeaker <- AIC(modelSpeaker)
x <- summary(modelSpeaker)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeaker),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeakerStyle <- lm(Area2 ~ Speaker + Style, VowelTable)
aicmodelSpeakerStyle <- AIC(modelSpeakerStyle)
x <- summary(modelSpeakerStyle)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker + Style R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeakerStyle),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeakerStyleX <- lm(Area2 ~ Speaker*Style, VowelTable)
aicmodelSpeakerStyleX <- AIC(modelSpeakerStyleX)
x <- summary(modelSpeakerStyleX)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker*Style R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeakerStyleX),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeakerStyleTextX <- lm(Area2 ~ Speaker*Style + Session, VowelTable)
aicmodelSpeakerStyleTextX <- AIC(modelSpeakerStyleTextX)
x <- summary(modelSpeakerStyleTextX)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker*Style + Session R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeakerStyleTextX),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeakerStyleTextX <- lm(Area2 ~ Speaker*Style + Speaker*Session, VowelTable)
aicmodelSpeakerStyleTextX <- AIC(modelSpeakerStyleTextX)
x <- summary(modelSpeakerStyleTextX)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker*Style + Speaker*Session R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeakerStyleTextX),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeakerStyleTextXX <- lm(Area2 ~ Speaker*Style + Speaker*Session + Style*Session, VowelTable)
aicmodelSpeakerStyleTextXX <- AIC(modelSpeakerStyleTextXX)
x <- summary(modelSpeakerStyleTextXX)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker*Style + Speaker*Session + Style*Session R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeakerStyleTextXX),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeakerStyleTextXXX <- lm(Area2 ~ Speaker*Style*Session, VowelTable)
aicmodelSpeakerStyleTextXXX <- AIC(modelSpeakerStyleTextXXX)
x <- summary(modelSpeakerStyleTextXXX)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area2 ~ Speaker*Style*Session R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeakerStyleTextXXX),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)
