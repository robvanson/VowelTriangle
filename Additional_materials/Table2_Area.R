# R
library("lmtest")

TaskTable <- read.table("Patient_data.tsv", header = TRUE, sep = "\t", na.strings = "-");

# Convert to T0, T1, T2 table
T0Table <- subset(TaskTable, subset = T == 0, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist"))
T1Table <- subset(TaskTable, subset = T == 1, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist"))
T2Table <- subset(TaskTable, subset = T == 2, select = c("Speaker", "T", "Task", "Sex", "N", "Area2", "i.dist", "u.dist", "a.dist"))
names(T2Table) <- paste(names(T2Table),".T2", sep="")
names(T2Table)[1] <- "Speaker"
names(T2Table)[3] <- "Task"

TimeTable <- merge(T0Table, T1Table, by = c("Speaker", "Task"), suffixes = c(".T0", ".T1"), sort = TRUE, all = TRUE)
TimeTable <- merge(TimeTable, T2Table, by = c("Speaker", "Task"), sort = TRUE, all = TRUE)

selectionList <- names(TimeTable)[grep("^T[.]", names(TimeTable), invert = TRUE)]
selectionList <- selectionList[grep("^Sex[.]T[12]", selectionList, invert = TRUE)]
selectionList <- selectionList[grep("^Task[.]vowels[.]T[12]", selectionList, invert = TRUE)]
TimeTable <- subset(TimeTable, select = c(selectionList))


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

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2 + Speaker, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 + Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

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

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Speaker, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Speaker: R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

# Dapre
# T1
print("", quote=FALSE)
print("Dapre", quote=FALSE)
DapreTimeTable <- subset(TimeTable, subset=Task=="Dapre")
modelT1 <- lm(Area2.T1 ~ Area2.T0, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
print(paste("T1 ~ Area.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
print(paste("T1 ~ Area2.T0 + Area2.T2 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2 + Speaker, DapreTimeTable)
aicmodelT1 <- AIC(modelT1)
print(paste("T1 ~ Area2.T0 + Area2.T2 + Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(Area2.T2 ~ Area2.T1, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
print(paste("T2 ~ Area.T1 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Area2.T0, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
print(paste("T2 ~ Area2.T1 + Area2.T0 R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Speaker, DapreTimeTable)
aicmodelT2 <- AIC(modelT2)
print(paste("T2 ~ Area2.T1 + Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# Words
# T1
print("", quote=FALSE)
print("Words", quote=FALSE)
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

modelT1 <- lm(Area2.T1 ~ Area2.T0 + Area2.T2 + Speaker, WordsTimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Area2.T0 + Area2.T2 + Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

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

modelT2 <- lm(Area2.T2 ~ Area2.T1 + Speaker, WordsTimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Area2.T1 + Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


# All
# T1
print("", quote=FALSE)
print("All", quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Task, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Task R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Speaker, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT1 <- lm(Area2.T1 ~ Speaker + Task, TimeTable)
aicmodelT1 <- AIC(modelT1)
x <- summary(modelT1)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T1 ~ Speaker + Task R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT1),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

print("", quote=FALSE)
# T2
modelT2 <- lm(Area2.T2 ~ Speaker, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Speaker R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)

modelT2 <- lm(Area2.T2 ~ Speaker + Task, TimeTable)
aicmodelT2 <- AIC(modelT2)
x <- summary(modelT2)
p <- pf(x$fstatistic[1],x$fstatistic[2],x$fstatistic[3],lower.tail=FALSE)
print(paste("T2 ~ Speaker + Task R^2 =", sprintf("%.3g", x$adj.r.squared), " (aic=", sprintf("%.4g", aicmodelT2),  ", p=", sprintf("%.3g",p), ")", sep=""), quote=FALSE)


