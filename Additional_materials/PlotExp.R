# R
#
ScoreTableIndividual <- read.table("PlotScores.tsv", header = TRUE, sep = "\t", na.strings = "-");
ScoreTableIndividual$VowelDensity <- ScoreTableIndividual$N/ScoreTableIndividual$Duration
ScoreTableIndividual$T <- as.factor(ScoreTableIndividual$T)

# Normalize scores
ScoreTableIndividual$NormScore <- ScoreTableIndividual$Score
for(eval in unique(ScoreTableIndividual$Evaluator)){
	ScoreTableIndividual[ScoreTableIndividual$Evaluator==eval,]$NormScore <- as.vector(scale(ScoreTableIndividual[ScoreTableIndividual$Evaluator==eval,]$Score))
}

T0TableIndividual <- subset(ScoreTableIndividual, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T1TableIndividual <- subset(ScoreTableIndividual, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T2TableIndividual <- subset(ScoreTableIndividual, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
names(T2TableIndividual) <- paste(names(T2TableIndividual),".T2", sep="")
names(T2TableIndividual)[1] <- "Speaker"
names(T2TableIndividual)[3] <- "Task"

TimeTableIndividual <- merge(T0TableIndividual, T1TableIndividual, by = c("Speaker", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTableIndividual <- merge(TimeTableIndividual, T2TableIndividual, by = c("Speaker", "Task"), sort = TRUE, all = TRUE)


ScoreTable <- aggregate(cbind(Score, NormScore)~Name+Speaker+T+Task+Sex+N+Area2+Area1+i.dist+u.dist+a.dist+Duration+Intensity, data=ScoreTableIndividual, mean);

# All
print("", quote=FALSE)
print("All Individual Scores", quote=FALSE)
modelNormScore <- lm(NormScore ~ a.dist*u.dist*Area2*i.dist, ScoreTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore ~ a.dist*u.dist*Area2*i.dist R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


T0Table <- subset(ScoreTable, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T1Table <- subset(ScoreTable, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T2Table <- subset(ScoreTable, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
names(T2Table) <- paste(names(T2Table),".T2", sep="")
names(T2Table)[1] <- "Speaker"
names(T2Table)[3] <- "Task"

TimeTable <- merge(T0Table, T1Table, by = c("Speaker", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTable <- merge(TimeTable, T2Table, by = c("Speaker", "Task"), sort = TRUE, all = TRUE)

# Individual normalized scores versus shape
print("", quote=FALSE)
print("Individual Scores", quote=FALSE)
# T1
modelNormScore <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1, TimeTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1, TimeTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1*i.dist.T1, TimeTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1*i.dist.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelNormScore <- lm(NormScore.T2 ~ a.dist.T2*u.dist.T2, TimeTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2, TimeTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2*i.dist.T2, TimeTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2*i.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

# Averaged scores versus shape
# All
print("", quote=FALSE)
print("Averaged Scores", quote=FALSE)
modelNormScore <- lm(NormScore ~ a.dist*u.dist*Area2*i.dist, ScoreTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore ~ a.dist*u.dist*Area2*i.dist R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


print("", quote=FALSE)
print("By time", quote=FALSE)
# T0
modelNormScore <- lm(NormScore.T0 ~ a.dist.T0*u.dist.T0, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T0 ~ a.dist.T0*u.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T0 ~ a.dist.T0*u.dist.T0*Area2.T0, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T0 ~ a.dist.T0*u.dist.T0*Area2.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T0 ~ a.dist.T0*u.dist.T0*Area2.T0*i.dist.T0, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T0 ~ a.dist.T0*u.dist.T0*Area2.T0*i.dist.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T1
modelNormScore <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1*i.dist.T1, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1*i.dist.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelNormScore <- lm(NormScore.T2 ~ a.dist.T2*u.dist.T2, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormScore <- lm(NormScore.T2 ~ a.dist.T2*i.dist.T2*Area2.T2*u.dist.T2, TimeTable)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2*i.dist.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)
