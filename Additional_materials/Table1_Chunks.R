# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#

se <- function(x) sqrt(var(x)/length(x))
ci <- function(x) {t <- t.test(x); (t$conf.int[[2]]- t$conf.int[[1]])/2}

VowelTable <- read.table("IFA_corpus_data.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$Style <- factor(VowelTable$Style, levels=c("I", "R", "T", "S", "W", "Y"), ordered=T);


# Linear models
print("", quote=FALSE)
print("Report Chunks", quote=FALSE)
print(paste("# Chunks: ", length(VowelTable$Area2)), quote=FALSE)

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


# Leave one out tests
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models: Chunks", quote=FALSE)
speakerList <- unique(VowelTable$Speaker)
styleList <- unique(VowelTable$Style[VowelTable$Style != "I"])
sessionList <- unique(VowelTable$Session)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	for(style in styleList){
		for(session in sessionList){
			chunkList <- subset(VowelTable, subset=Speaker == subject & Style == style & Session == session)$Name
			for(chunkName in chunkList){
				trainTable <- subset(VowelTable, subset=!(Name == chunkName))
				testTable <- subset(VowelTable, subset=Name == chunkName)
				
				diff0 <- c(diff0, (testTable$Area2 - mean(trainTable$Area2, na.rm = TRUE)))
				
				model <- lm(Area2 ~ Speaker*Style, trainTable)
				predArea <- predict(model, testTable)
				diff1 <- c(diff1, (testTable$Area2 - predArea))
				
				model <- lm(Area2 ~ Speaker*Style*Session, trainTable)
				predArea <- predict(model, testTable)
				diff2 <- c(diff2, (testTable$Area2 - predArea))
			}
		}
	};
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("Area2 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("Area2 ~ Speaker*Style", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("Area2 ~ Speaker*Style*Session", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff2**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff2**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff2), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff2)/mae_mean, na.rm = TRUE), na.rm = TRUE), ")", sep=""), quote=FALSE)


