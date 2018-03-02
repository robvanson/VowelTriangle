# Files

# Vowel Triangle praat script
# To use this script, open it inside Praat
VowelTriangle.praat

# IFA corpus file lists used to generate IFA corpus data
# List of chunks
chunkslist.tsv

# List of concatenated chunks. * wildcard indicates that all files 
# matching this wildcat should be concatenated.
concatlist.tsv
# NOTE: TO USE THIS LIST, ALL FILES MATCHING: "*1FR2.aifc" IN THE 
# IFA CORPUS SHOULD BE RENAMED OR MOVED AS THEY LEAD TO DOUBLE COUNTING.

# R script to create Figure 2, the data and the result
Figure2_plot.R
IFA_corpus_data.tsv
Figure2.pdf

# Table 1
# R script to calculate values for Table 1 Chunks and data
Table1_Chunks.R
IFA_corpus_data.tsv
# R script to calculate values for Table 1 Concat and data
Table1_Concat.R
IFA_corpus_concat.tsv

# R script to generate data from the Plot evaluation experiment and data
PlotExp.R
PlotScores.tsv

# Table 2
# R script to calculate values for area models and data
Table2_Area.R
Patient_data.tsv

# Table 3
# R script to calculate values for articulation rating models and data
Table3_ListeningExp.R
ListeningExp.tsv
Patient_data.tsv

# R script to calculate relative articulation rate models and data
RelArtRate.R
Pataka_results.tsv
Patient_data.tsv
