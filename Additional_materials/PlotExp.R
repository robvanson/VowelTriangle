# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#
#
ScoreTableIndividual <- read.table("PlotScores.tsv", header = TRUE, sep = "\t", na.strings = "-");
ScoreTableIndividual$VowelDensity <- ScoreTableIndividual$N/ScoreTableIndividual$Duration
ScoreTableIndividual$T <- factor(ScoreTableIndividual$T, ordered=TRUE)
ScoreTableIndividual$Speaker <- factor(ScoreTableIndividual$Speaker, ordered=FALSE)

# Normalize scores
ScoreTableIndividual$NormScore <- ScoreTableIndividual$Score
for(eval in unique(ScoreTableIndividual$Evaluator)){
	ScoreTableIndividual[ScoreTableIndividual$Evaluator==eval,]$NormScore <- as.vector(scale(ScoreTableIndividual[ScoreTableIndividual$Evaluator==eval,]$Score))
}

# Convert T moments to columns
T0TableIndividual <- subset(ScoreTableIndividual, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T1TableIndividual <- subset(ScoreTableIndividual, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
T2TableIndividual <- subset(ScoreTableIndividual, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore"))
names(T2TableIndividual) <- paste(names(T2TableIndividual),".T2", sep="")
names(T2TableIndividual)[1] <- "Speaker"
names(T2TableIndividual)[3] <- "Task"

TimeTableIndividual <- merge(T0TableIndividual, T1TableIndividual, by = c("Speaker", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTableIndividual <- merge(TimeTableIndividual, T2TableIndividual, by = c("Speaker", "Task"), sort = TRUE, all = TRUE)


# All Individual score
print("", quote=FALSE)
print("All Individual Scores", quote=FALSE)
modelNormScore <- lm(NormScore ~ a.dist*u.dist*Area2*i.dist, ScoreTableIndividual)
aicmodelNormScore <- AIC(modelNormScore)
x <- summary(modelNormScore)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormScore ~ a.dist*u.dist*Area2*i.dist R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormScore), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

# Average over evaluators
ScoreTable <- aggregate(cbind(Score, NormScore)~Name+Speaker+T+Task+Sex+N+Area2+Area1+i.dist+u.dist+a.dist+Duration+Intensity, data=ScoreTableIndividual, mean);


# Adding Listening Experiment
LexpTableIndividual <- read.table("ListeningExp.tsv", header = TRUE, sep = "\t", na.strings = "-");
LexpTableIndividual$T <- factor(LexpTableIndividual$T, ordered=TRUE)
LexpTableIndividual$Speaker <- factor(LexpTableIndividual$Speaker, ordered=FALSE)

# Normalize scores
LexpTableIndividual$NormRating <- LexpTableIndividual$Rating
for(eval in unique(LexpTableIndividual$Evaluator)){
	LexpTableIndividual[LexpTableIndividual$Evaluator==eval,]$NormRating <- as.vector(scale(LexpTableIndividual[LexpTableIndividual$Evaluator==eval,]$Rating))
}

# Average over evaluators
LexpTable <- aggregate(cbind(Rating, NormRating)~Speaker+T+Sex, data=LexpTableIndividual, mean);

# Combine Plot and Listening experiments
ScoreTable <- merge(ScoreTable, LexpTable, by = c("Speaker", "Sex", "T"), suffixes = c(".PE", ".LE"), sort = TRUE, all = TRUE)

# Convert T moments to columns
T0Table <- subset(ScoreTable, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore", "Rating", "NormRating"))
T1Table <- subset(ScoreTable, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore", "Rating", "NormRating"))
T2Table <- subset(ScoreTable, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist", "Score", "NormScore", "Rating", "NormRating"))
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

# Model Plot and Listening Experiments

print("", quote=FALSE)
print("Listening Experiment, all time", quote=FALSE)
print("No relation between results of plot and listening experiments", quote=FALSE)

print(cor.test(ScoreTable$NormRating, ScoreTable$NormScore))
print(cor.test(TimeTable$NormRating.T0, TimeTable$NormScore.T0))
print(cor.test(TimeTable$NormRating.T1, TimeTable$NormScore.T1))
print(cor.test(TimeTable$NormRating.T2, TimeTable$NormScore.T2))

# 
modelNormRating <- lm(NormRating ~ Speaker, ScoreTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating ~ Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormRating <- lm(NormRating ~ Speaker + T, ScoreTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating ~ Speaker + T R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormRating <- lm(NormRating ~ Speaker + T + NormScore, ScoreTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating ~ Speaker + T + NormScore R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


print("", quote=FALSE)
print("Listening Experiment, T", quote=FALSE)


# T0
modelNormRating <- lm(NormRating.T0 ~ NormScore.T0, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T0 ~ NormScore.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T1
modelNormRating <- lm(NormRating.T1 ~ NormRating.T0, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormRating <- lm(NormRating.T1 ~ NormRating.T0 + NormScore.T1, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + NormScore.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormRating <- lm(NormRating.T1 ~ NormRating.T0 + NormScore.T0, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T1 ~ NormRating.T0 + NormScore.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelNormRating <- lm(NormRating.T2 ~ NormRating.T1, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormRating <- lm(NormRating.T2 ~ NormRating.T1 + NormScore.T2, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 + NormScore.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)

modelNormRating <- lm(NormRating.T2 ~ NormRating.T1 + NormScore.T1, TimeTable)
aicmodelNormRating <- AIC(modelNormRating)
x <- summary(modelNormRating)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("NormRating.T2 ~ NormRating.T1 + NormScore.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelNormRating), ", p=", sprintf("%.3g", p), ")", sep=""), quote=FALSE)


print("", quote=FALSE)
# Leave one out tests
# T0
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models T0", quote=FALSE)
speakerList <- levels(TimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(TimeTable, subset=!(Speaker == subject))
	testTable <- subset(TimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$NormScore.T0 - mean(trainTable$NormScore.T0, na.rm = TRUE)))
	
	model <- lm(NormScore.T0 ~ a.dist.T0*u.dist.T0*Area2.T0, trainTable)
	predNormScoreT0 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$NormScore.T0 - predNormScoreT0))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("NormScore.T0 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormScore.T0 ~ a.dist.T0*u.dist.T0*Area.T0", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (r^2=", sprintf("%.3g", (1-mean(diff1**2, na.rm = TRUE)/rmse_mean**2)), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)

# T1
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models T1", quote=FALSE)
speakerList <- levels(TimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(TimeTable, subset=!(Speaker == subject))
	testTable <- subset(TimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$NormScore.T1 - mean(trainTable$NormScore.T1, na.rm = TRUE)))
	
	model <- lm(NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1*i.dist.T1, trainTable)
	predNormScoreT1 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$NormScore.T1 - predNormScoreT1))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("NormScore.T1 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormScore.T1 ~ a.dist.T1*u.dist.T1*Area2.T1*i.dist.T1", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (r^2=", sprintf("%.3g", (1-mean(diff1**2, na.rm = TRUE)/rmse_mean**2)), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


# T2
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models T2", quote=FALSE)
speakerList <- levels(TimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(TimeTable, subset=!(Speaker == subject))
	testTable <- subset(TimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$NormScore.T2 - mean(trainTable$NormScore.T2, na.rm = TRUE)))
	
	model <- lm(NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2, trainTable)
	predNormScoreT2 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$NormScore.T2 - predNormScoreT2))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("NormScore.T2 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("NormScore.T2 ~ a.dist.T2*u.dist.T2*Area2.T2", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (r^2=", sprintf("%.3g", (1-mean(diff1**2, na.rm = TRUE)/rmse_mean**2)), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)
