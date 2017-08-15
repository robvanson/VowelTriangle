VowelTable <- read.table("VowelFormantsFPA.tsv", header = TRUE, sep = "\t", na.strings = "-");
AverageVowels <- aggregate(cbind(F1, F2)~Phon+Sex, data=VowelTable, mean);
SdevVowels <- aggregate(cbind(F1, F2)~Phon+Sex, data=VowelTable, sd);

