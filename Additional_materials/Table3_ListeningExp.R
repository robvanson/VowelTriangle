# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#
#
LexpTableIndividual <- read.table("ListeningExp.tsv", header = TRUE, sep = "\t", na.strings = "-");
LexpTableIndividual$T <- factor(LexpTableIndividual$T, ordered=TRUE)
LexpTableIndividual$Speaker <- factor(LexpTableIndividual$Speaker, ordered=FALSE)

VowelTable <- read.table("Patient_data.tsv", header = TRUE, sep = "\t", na.strings = "-");
VowelTable$T <- factor(VowelTable$T, ordered=TRUE)
VowelTable$Speaker <- factor(VowelTable$Speaker, ordered=TRUE)

# Normalize scores
LexpTableIndividual$NormRating <- LexpTableIndividual$Rating
for(eval in unique(LexpTableIndividual$Evaluator)){
	LexpTableIndividual[LexpTableIndividual$Evaluator==eval,]$NormRating <- as.vector(scale(LexpTableIndividual[LexpTableIndividual$Evaluator==eval,]$Rating))
}

LexpTable <- aggregate(cbind(Rating, NormRating)~Speaker+T+Sex, data=LexpTableIndividual, mean);

VowelTable <- merge(subset(VowelTable, subset=Task=="Dapre"), LexpTable, by=c("Speaker", "T", "Sex"), sort = TRUE, all = TRUE)


# Dapre
print("", quote=FALSE)
print("Dapre All", quote=FALSE)

modelSpeaker <- lm(NormRating ~ u.dist, VowelTable)
aicmodelSpeaker <- AIC(modelSpeaker)
x <- summary(modelSpeaker)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating ~ u.dist R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeaker),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeaker <- lm(NormRating ~ u.dist + i.dist, VowelTable)
aicmodelSpeaker <- AIC(modelSpeaker)
x <- summary(modelSpeaker)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating ~ u.dist + i.dist R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeaker),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelSpeaker <- lm(NormRating ~ u.dist + i.dist + Speaker, VowelTable)
aicmodelSpeaker <- AIC(modelSpeaker)
x <- summary(modelSpeaker)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating ~ u.dist + i.dist + Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelSpeaker),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# Convert to T0, T1, T2 table
T0Table <- subset(VowelTable, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Rating", "NormRating"))
T1Table <- subset(VowelTable, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Rating", "NormRating"))
T2Table <- subset(VowelTable, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Rating", "NormRating"))
names(T2Table) <- paste(names(T2Table),".T2", sep="")
names(T2Table)[1] <- "Speaker"
names(T2Table)[2] <- "T"
names(T2Table)[3] <- "Task"
names(T2Table)[4] <- "Sex"

TimeTable <- merge(T0Table, T1Table, by = c("Speaker", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTable <- merge(TimeTable, T2Table, by = c("Speaker", "Task"), sort = TRUE, all = TRUE)

selectionList <- names(TimeTable)[grep("^T[.]", names(TimeTable), invert = TRUE)]
selectionList <- selectionList[grep("^Sex[.]T[12]", selectionList, invert = TRUE)]
selectionList <- selectionList[grep("^Task[.]vowels[.]T[12]", selectionList, invert = TRUE)]
TimeTable <- subset(TimeTable, select = c(selectionList))
names(TimeTable)[1] <- "Speaker"
names(TimeTable)[2] <- "Task"
names(TimeTable)[3] <- "Sex"

TimeTable$RelNRT10 <- TimeTable$NormRating.T1 / TimeTable$NormRating.T0
TimeTable$RelNRT20 <- TimeTable$NormRating.T2 / TimeTable$NormRating.T0
TimeTable$RelNRT12 <- TimeTable$NormRating.T2 / TimeTable$NormRating.T1

TimeTable$Relu.distT10 <- TimeTable$u.dist.T1 / TimeTable$u.dist.T0
TimeTable$Relu.distT20 <- TimeTable$u.dist.T2 / TimeTable$u.dist.T0
TimeTable$Relu.distT12 <- TimeTable$u.dist.T2 / TimeTable$u.dist.T1


# Dapre
print("", quote=FALSE)
print("Dapre", quote=FALSE)

# NormRating

modelT <- lm(NormRating.T0 ~ u.dist.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T0 ~ u.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T0 ~ u.dist.T0 + a.dist.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T0 ~ u.dist.T0 + a.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


modelT <- lm(NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex + N.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex + N.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


print("", quote=FALSE)
modelT <- lm(NormRating.T1 ~ NormRating.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T1 ~ NormRating.T0 + i.dist.T1, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + i.dist.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T1 ~ NormRating.T0 + i.dist.T1 + i.dist.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + i.dist.T1 + i.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T1 ~ NormRating.T0 + i.dist.T1 + i.dist.T0 + a.dist.T1, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + i.dist.T1 + i.dist.T0 + a.dist.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T1 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


print("", quote=FALSE)
modelT <- lm(NormRating.T2 ~ NormRating.T1, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T2 ~ NormRating.T1 + a.dist.T2, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 + a.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T2 ~ NormRating.T1 + a.dist.T2 + i.dist.T2, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 + a.dist.T2 + i.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT <- lm(NormRating.T2 ~ NormRating.T1 + a.dist.T2 + i.dist.T2 + u.dist.T2, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 + a.dist.T2 + i.dist.T2 + u.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


modelT <- lm(NormRating.T2 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0, TimeTable)
aicmodelT <- AIC(modelT)
x <- summary(modelT)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

# Leave one out tests
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models", quote=FALSE)
speakerList <- levels(TimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(TimeTable, subset=!(Speaker == subject))
	testTable <- subset(TimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$NormRating.T0 - mean(trainTable$NormRating.T0, na.rm = TRUE)))
	
	model <- lm(NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex + N.T0, trainTable)
	predNormRatingT0 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$NormRating.T0 - predNormRatingT0))
	
	model <- lm(NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex + N.T0, trainTable)
	predNormRatingT0 <- predict(model, testTable)
	diff2 <- c(diff2, (testTable$NormRating.T0 - predNormRatingT0))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("NormRating.T0 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormRating.T0 ~ u.dist.T0 + a.dist.T0 + Sex + N.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(TimeTable, subset=!(Speaker == subject))
	testTable <- subset(TimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$NormRating.T1 - mean(trainTable$NormRating.T1, na.rm = TRUE)))
	
	model <- lm(NormRating.T1 ~ NormRating.T0 + i.dist.T1 + a.dist.T1 + i.dist.T0, trainTable)
	predNormRatingT1 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$NormRating.T1 - predNormRatingT1))
	
	model <- lm(NormRating.T1 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0, trainTable)
	predNormRatingT1 <- predict(model, testTable)
	diff2 <- c(diff2, (testTable$NormRating.T1 - predNormRatingT1))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("NormRating.T1 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + i.dist.T1 + a.dist.T1 + i.dist.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff2**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff2**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff2), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff2), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


diff0 <- c()
diff1 <- c()
diff2 <- c()
diff3 <- c()
for(subject in speakerList){
	trainTable <- subset(TimeTable, subset=!(Speaker == subject))
	testTable <- subset(TimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$NormRating.T2 - mean(trainTable$NormRating.T2, na.rm = TRUE)))
	
	model <- lm(NormRating.T2 ~ NormRating.T1, trainTable)
	predNormRatingT1 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$NormRating.T2 - predNormRatingT1))
	
	model <- lm(NormRating.T2 ~ NormRating.T1 + a.dist.T2 + i.dist.T2 + u.dist.T2, trainTable)
	predNormRatingT1 <- predict(model, testTable)
	diff2 <- c(diff2, (testTable$NormRating.T2 - predNormRatingT1))
	
	model <- lm(NormRating.T2 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0, trainTable)
	predNormRatingT1 <- predict(model, testTable)
	diff3 <- c(diff3, (testTable$NormRating.T2 - predNormRatingT1))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("NormRating.T2 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 + a.dist.T2 + i.dist.T2 + u.dist.T2", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff2**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff2**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff2), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff2), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormRating.T2 ~ NormRating.T0 + i.dist.T1 * a.dist.T1 * u.dist.T1 + i.dist.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff3**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff3**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff3), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff3), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

