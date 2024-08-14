# Loading packages
# Place this script in the folder where the text files containing the volumetric and cortical data can be found
# Ensure that the packages listed below are installed in your R version
# From the terminal, navigate to the folder and run the command: Rscript volmeas-to-excel_modified.R

library(openxlsx)
library(tidyverse)
library(data.table)

# USAGE:
# Rscript volmeas-to-excel <files.txt>

files <- list.files(pattern = "*.txt") # get files
files.strip <- gsub("[.]txt","", files) # remove .txt extension

# read files and move them to excel spreadsheet called outfile
all_aseg_parc <- lapply(files, fread)
names(all_aseg_parc) <- paste(files.strip)

# save sheet with all aseg parcelations
write.xlsx(all_aseg_parc, 
             file = "all_aseg_parc.xlsx", 
             append = TRUE, rowNames=FALSE)