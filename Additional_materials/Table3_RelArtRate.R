# R
library("lmtest")

TaskTable <- read.table("Patient_data.tsv", header = TRUE, sep = "\t", na.strings = "-");
PatakaTable <- read.table("../Data/Pataka_results.tsv", header = TRUE, sep = "\t", na.strings = "-");
TaskTable <- subset(merge(TaskTable, PatakaTable, by = c("Speaker", "T"), suffixes = c("", ".pataka"), sort = TRUE, all=TRUE), select = c("Speaker","T","Name","Task","Sex","N","Area2","Area1","i.dist","u.dist","a.dist","Nsyll","Npause","Duration.pataka","Phon.time","speech.rate","art.rate","ASD"));

# Convert to T0, T1, T2 table
T0Table <- subset(TaskTable, subset = T == 0, select = c("Speaker", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "art.rate"))
T1Table <- subset(TaskTable, subset = T == 1, select = c("Speaker", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "art.rate"))
T2Table <- subset(TaskTable, subset = T == 2, select = c("Speaker", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "art.rate"))
names(T2Table) <- paste(names(T2Table),".T2", sep="")
names(T2Table)[1] <- "Speaker"
names(T2Table)[2] <- "Task"
names(T2Table)[3] <- "Sex"

TimeTable <- merge(T0Table, T1Table, by = c("Speaker", "Task", "Sex"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTable <- merge(TimeTable, T2Table, by = c("Speaker", "Task", "Sex"), sort = TRUE, all = TRUE)

selectionList <- names(TimeTable)[grep("^T[.]", names(TimeTable), invert = TRUE)]
selectionList <- selectionList[grep("^Sex[.]T[12]", selectionList, invert = TRUE)]
selectionList <- selectionList[grep("^Task[.]vowels[.]T[12]", selectionList, invert = TRUE)]
TimeTable <- subset(TimeTable, select = c(selectionList))

print(cor.test(TimeTable[TimeTable$Task=="Dapre",]$art.rate.T0, TimeTable[TimeTable$Task=="Dapre",]$art.rate.T1))
print(cor.test(TimeTable[TimeTable$Task=="Dapre",]$art.rate.T0, TimeTable[TimeTable$Task=="Dapre",]$art.rate.T2))
print(cor.test(TimeTable[TimeTable$Task=="Dapre",]$art.rate.T1, TimeTable[TimeTable$Task=="Dapre",]$art.rate.T2))

# Calculate RelART1/T2
TimeTable$RelAR.T1 <- TimeTable$art.rate.T1 / TimeTable$art.rate.T0
TimeTable$RelAR.T2 <- TimeTable$art.rate.T2 / TimeTable$art.rate.T0

print(cor.test(TimeTable[TimeTable$Task=="Dapre",]$RelAR.T1, TimeTable[TimeTable$Task=="Dapre",]$RelAR.T2))

############################################################################################################
#
# Add Averaged Norm Scores from plot experiment
#
ScoreTableIndividual <- read.table("PlotScores.tsv", header = TRUE, sep = "\t", na.strings = "-");
ScoreTableIndividual$VowelDensity <- ScoreTableIndividual$N/ScoreTableIndividual$Duration
ScoreTableIndividual$T <- as.factor(ScoreTableIndividual$T)

# Normalize scores
ScoreTableIndividual$NormScore <- ScoreTableIndividual$Score
for(eval in unique(ScoreTableIndividual$Evaluator)){
	ScoreTableIndividual[ScoreTableIndividual$Evaluator==eval,]$NormScore <- as.vector(scale(ScoreTableIndividual[ScoreTableIndividual$Evaluator==eval,]$Score))
}

ScoreTable <- aggregate(cbind(Score, NormScore)~Name+Speaker+T+Task+Sex+N+Area2+Area1+i.dist+u.dist+a.dist+Duration+Intensity, data=ScoreTableIndividual, mean);

T0TableScores <- subset(ScoreTable, subset = T == 0, select = c("Speaker", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T1TableScores <- subset(ScoreTable, subset = T == 1, select = c("Speaker", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T2TableScores <- subset(ScoreTable, subset = T == 2, select = c("Speaker", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
names(T2TableScores) <- paste(names(T2TableScores),".T2", sep="")
names(T2TableScores)[1] <- "Speaker"
names(T2TableScores)[2] <- "Task"
names(T2TableScores)[3] <- "Sex"

TimeTableScores <- merge(T0TableScores, T1TableScores, by = c("Speaker", "Task", "Sex"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTableScores <- merge(TimeTableScores, T2TableScores, by = c("Speaker", "Task", "Sex"), sort = TRUE, all = TRUE)

TimeTableScores <- subset(TimeTableScores, select=c("Speaker", "Task", "Sex", "NormScore.T0", "NormScore.T1", "NormScore.T2"))

TimeTable <- merge(TimeTable, TimeTableScores, by = c("Speaker", "Task", "Sex"), sort = TRUE, all = TRUE)

############################################################################################################


# Linear model
# All
print("", quote=FALSE)
print("Words + Dapre", quote=FALSE)

# T1
modelT1 <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT1 <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + N.T1, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + N.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + N.T2, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + N.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

# Words
print("", quote=FALSE)
print("Words", quote=FALSE)
WordsTimeTable <- subset(TimeTable, subset=Task=="Words")

# T1
modelT1 <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, WordsTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT1 <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + N.T1, WordsTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + N.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, WordsTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + N.T2, WordsTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + N.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

# Dapre
print("", quote=FALSE)
print("Dapre", quote=FALSE)
DapreTimeTable <- subset(TimeTable, subset=Task=="Dapre")

# T1
modelT1 <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT1 <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + NormScore.T1, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + NormScore.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + i.dist.T2, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + i.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0 + i.dist.T2 + NormScore.T2 + NormScore.T0, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("RelArt.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area.T0 + i.dist.T2 + NormScore.T2 + NormScore.T0  R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


# Art rate
print("", quote=FALSE)
modelT2 <- lm(art.rate.T2 ~ art.rate.T0, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("art.rate.T2 ~ art.rate.T0  R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(art.rate.T2 ~ art.rate.T0 + a.dist.T2*i.dist.T2*u.dist.T2*Area2.T2, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("art.rate.T2 ~ art.rate.T0 + a.dist.T2*i.dist.T2*u.dist.T2*Area.T2  R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(art.rate.T2 ~ art.rate.T0 + a.dist.T1*i.dist.T1*u.dist.T1*Area2.T1, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("art.rate.T2 ~ art.rate.T0 + a.dist.T1*i.dist.T1*u.dist.T1*Area.T1  R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelT2 <- lm(art.rate.T2 ~ art.rate.T0 + a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("art.rate.T2 ~ art.rate.T0 + a.dist.T0*i.dist.T0*u.dist.T0*Area.T0  R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


# Leave one out tests
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models: T1", quote=FALSE)
speakerList <- unique(DapreTimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(DapreTimeTable, subset=!(Speaker == subject))
	testTable <- subset(DapreTimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$RelAR.T1 - mean(trainTable$RelAR.T1, na.rm = TRUE)))
	
	model <- lm(RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, trainTable)
	predART1 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$RelAR.T1 - predART1))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("RelAR.T1 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("RelAR.T1 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


# Leave one out tests
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models: T2", quote=FALSE)
speakerList <- unique(DapreTimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(DapreTimeTable, subset=!(Speaker == subject))
	testTable <- subset(DapreTimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$RelAR.T2 - mean(trainTable$RelAR.T2, na.rm = TRUE)))
	
	model <- lm(RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0, trainTable)
	predART2 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$RelAR.T2 - predART2))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("RelAR.T2 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("RelAR.T2 ~ a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


# Leave one out tests
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models: T2", quote=FALSE)
speakerList <- unique(DapreTimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(DapreTimeTable, subset=!(Speaker == subject))
	testTable <- subset(DapreTimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$art.rate.T2 - mean(trainTable$art.rate.T2, na.rm = TRUE)))
	
	model <- lm(art.rate.T2 ~ art.rate.T0, trainTable)
	predART2 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$art.rate.T2 - predART2))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("art.rate.T2 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("art.rate.T2 ~ art.rate.T0 + a.dist.T0*i.dist.T0*u.dist.T0*Area2.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))/rmse_mean), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

