# R
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.v.son@nki.nl
#
library("lmtest")

TaskTable <- read.table("Patient_data.tsv", header = TRUE, sep = "\t", na.strings = "-");

print(paste("# N: ", length(TaskTable$Area2), ", Mean (sd): ", sprintf("%.3g", mean(TaskTable$Area2, na.rm = TRUE)), " (", sprintf("%.3g", sd(TaskTable$Area2, na.rm = TRUE)), ")", sep=""), quote=FALSE)

# Convert to T0, T1, T2 table
T0Table <- subset(TaskTable, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist"))
T1Table <- subset(TaskTable, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist"))
T2Table <- subset(TaskTable, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist"))
names(T2Table) <- paste(names(T2Table),".T2", sep="")
names(T2Table)[1] <- "Speaker"
names(T2Table)[2] <- "T"
names(T2Table)[3] <- "Task"
names(T2Table)[4] <- "Sex"

TimeTable <- merge(T0Table, T1Table, by = c("Speaker", "Sex", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTable <- merge(TimeTable, T2Table, by = c("Speaker",  "Sex", "Task"), sort = TRUE, all = TRUE)

selectionList <- names(TimeTable)[grep("^T[.]", names(TimeTable), invert = TRUE)]
selectionList <- selectionList[grep("^Sex[.]T[12]", selectionList, invert = TRUE)]
selectionList <- selectionList[grep("^Task[.]vowels[.]T[12]", selectionList, invert = TRUE)]
TimeTable <- subset(TimeTable, select = c(selectionList))
TimeTable$Speaker <- factor(TimeTable$Speaker)

# Linear model
# All
# T1
print("", quote=FALSE)
print("Words + Dapre", quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2 + Sex, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 + Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(Area2.T2 ~ Area2.T1, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Area2.T0, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Area2.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Sex, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Sex: R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

# Dapre
# T0
print("", quote=FALSE)
print("Dapre", quote=FALSE)
DapreTimeTable <- subset(TimeTable, subset=Task=="Dapre")

modelT0 <- lm(Area2.T0 ~ Sex, DapreTimeTable)
aicmodelT0 <- AIC(modelT0)
x <- summary(modelT0)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area.T0 ~ Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# T1
print("", quote=FALSE)
modelT1 <- lm(Area2.T1 ~ Area2.T0, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2 + Sex, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
print(paste("T1 ~ Area2.T0 + Area2.T2 + Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(Area2.T2 ~ Area2.T1, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Area2.T0, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Area2.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Sex, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# Words
# T0
print("", quote=FALSE)
print("Words", quote=FALSE)
WordsTimeTable <- subset(TimeTable, subset=Task=="Words")

modelT0 <- lm(Area2.T0 ~ Sex, WordsTimeTable)
aicmodelT0 <- AIC(modelT0)
x <- summary(modelT0)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("Area.T0 ~ Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

# T1
print("", quote=FALSE)
WordsTimeTable <- subset(TimeTable, subset=Task=="Words")
modelT1 <- lm(Area2.T1 ~ Area2.T0, WordsTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2, WordsTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2 + Sex, WordsTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 + Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(Area2.T2 ~ Area2.T1, WordsTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Area2.T0, WordsTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Area2.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Sex, WordsTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# All
# T1
print("", quote=FALSE)
print("All", quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Task, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Task R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Sex, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Sex + Task, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Sex + Task R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(Area2.T2 ~ Sex, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Sex R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Sex + Task, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Sex + Task R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# Leave one out tests
# T0
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models T0", quote=FALSE)
speakerList <- levels(WordsTimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(WordsTimeTable, subset=!(Speaker == subject))
	testTable <- subset(WordsTimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$Area2.T0 - mean(trainTable$Area2.T0, na.rm = TRUE)))
	
	model <- lm(Area2.T0 ~ Sex, trainTable)
	predArea2T0 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$Area2.T0 - predArea2T0))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("Area2.T0 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("Area2.T0 ~ Sex", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (r^2=", sprintf("%.3g", (1-mean(diff1**2, na.rm = TRUE)/rmse_mean**2)), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


# T1
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models T1", quote=FALSE)
speakerList <- levels(WordsTimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(WordsTimeTable, subset=!(Speaker == subject))
	testTable <- subset(WordsTimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$Area2.T1 - mean(trainTable$Area2.T1, na.rm = TRUE)))
	
	model <- lm(Area2.T1 ~ Area2.T0 + Area2.T2, trainTable)
	predArea2T1 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$Area2.T1 - predArea2T1))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("Area2.T1 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("Area2.T1 ~ Area2.T0 + Area2.T2", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (r^2=", sprintf("%.3g", (1-mean(diff1**2, na.rm = TRUE)/rmse_mean**2)), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)


# Leave one out tests
# T2
print("", quote=FALSE)
print("Leave-One-Out predictions of linear models T2", quote=FALSE)
speakerList <- levels(WordsTimeTable$Speaker)

diff0 <- c()
diff1 <- c()
diff2 <- c()
for(subject in speakerList){
	trainTable <- subset(WordsTimeTable, subset=!(Speaker == subject))
	testTable <- subset(WordsTimeTable, subset=Speaker == subject)
	
	diff0 <- c(diff0, (testTable$Area2.T2 - mean(trainTable$Area2.T2, na.rm = TRUE)))
	
	model <- lm(Area2.T2 ~ Area2.T0 + Sex, trainTable)
	predArea2T2 <- predict(model, testTable)
	diff1 <- c(diff1, (testTable$Area2.T2 - predArea2T2))
}

print("", quote=FALSE)
rmse_mean <- sqrt(mean(diff0**2, na.rm = TRUE))
mae_mean <- mean(abs(diff0), na.rm = TRUE)
print(paste("Area2.T2 ~ Mean", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", rmse_mean), sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mae_mean), sep=""), quote=FALSE)

print("", quote=FALSE)
print(paste("Area2.T2 ~ Area2.T0 + Sex", sep=""), quote=FALSE)
print(paste("RMSE: ", sprintf("%.3g", sqrt(mean(diff1**2, na.rm = TRUE))), " (r^2=", sprintf("%.3g", (1-mean(diff1**2, na.rm = TRUE)/rmse_mean**2)), ")", sep=""), quote=FALSE)
print(paste("MAE: ", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)), " (", sprintf("%.3g", mean(abs(diff1), na.rm = TRUE)/mae_mean), ")", sep=""), quote=FALSE)
