#------------------------------------------------------------------#
# Loading packages                                              ####
#------------------------------------------------------------------#
library(tidyverse)
library(openxlsx)

#------------------------------------------------------------------#
# Loading data                                                  ####
#------------------------------------------------------------------#
# Data ready for FreeSurfer
data_all <- read.xlsx("all_data_clean_final.xlsx")

fsgd <- as.data.frame(c("GroupDescriptorFile 1", 
                        "Title", 
                        "MeasurementName", 
                        "Class", 
                        "Class",
                        "Class",
                        "Class",
                        "Variables"))

# Revisions to account for sleep medicine
## need to create a categorical variable that merges sex with sleep medicine

data_all <- data_all %>% 
  unite(sex_sleep_med, c(sex, sleep_medication_psqi), remove = FALSE)

# Creating fsgd files

# ------------------------------------------------------------ #
#                           Sleep Time                         #
# ------------------------------------------------------------ #

#### Sleep time average ####
sleep_time_avg <- fsgd 
sleep_time_avg[2, 2] <- "sleep_time_avg"
sleep_time_avg[3, 2] <- "thickness"
sleep_time_avg[4, 2] <- "female_yes"
sleep_time_avg[5, 2] <- "female_no"
sleep_time_avg[6, 2] <- "male_yes"
sleep_time_avg[7, 2] <- "male_no"
sleep_time_avg[8, 2:6] <- c("sleep_time_avg", "age", "moca", NA, NA)
sleep_time_avg[9:121, 2:6] <- data_all[c("id", "sex_sleep_med", "sleep_time_avg", "age", "moca")]
sleep_time_avg[9:121, 1] <- "Input"

write.table(sleep_time_avg, "fs_analysis/a_fsgd/final/sleep_time_avg.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)


#### Sleep time variability ####
sleep_time_sd <- fsgd
sleep_time_sd[2, 2] <- "sleep_time_sd_lg"
sleep_time_sd[3, 2] <- "thickness"
sleep_time_sd[4, 2] <- "female_yes"
sleep_time_sd[5, 2] <- "female_no"
sleep_time_sd[6, 2] <- "male_yes"
sleep_time_sd[7, 2] <- "male_no"
sleep_time_sd[8, 2:6] <- c("sleep_time_sd_lg", "age", "moca", NA, NA)
sleep_time_sd[9:121, 2:6] <- data_all[c("id", "sex_sleep_med", "sleep_time_sd_lg", "age", "moca")]
sleep_time_sd[9:121, 1] <- "Input"

write.table(sleep_time_sd, "fs_analysis/a_fsgd/final/sleep_time_sd.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)

# ------------------------------------------------------------ #
#                     Sleep Efficiency                         #
# ------------------------------------------------------------ #

## Sleep efficiency average
sleep_efficiency_avg <- fsgd  
sleep_efficiency_avg[2, 2] <- "sleep_efficiency_avg"
sleep_efficiency_avg[3, 2] <- "thickness"
sleep_efficiency_avg[4, 2] <- "female_yes"
sleep_efficiency_avg[5, 2] <- "female_no"
sleep_efficiency_avg[6, 2] <- "male_yes"
sleep_efficiency_avg[7, 2] <- "male_no"
sleep_efficiency_avg[8, 2:6] <- c("sleep_efficiency_avg", "age", "moca", NA, NA)
sleep_efficiency_avg[9:121, 2:6] <- data_all[c("id", "sex_sleep_med", "sleep_efficiency_avg", "age", "moca")]
sleep_efficiency_avg[9:121, 1] <- "Input"

write.table(sleep_efficiency_avg, "fs_analysis/a_fsgd/final/sleep_efficiency_avg.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)

## Sleep efficiency variability
sleep_efficiency_sd <- fsgd  
sleep_efficiency_sd[2, 2] <- "sleep_efficiency_sd_lg"
sleep_efficiency_sd[3, 2] <- "thickness"
sleep_efficiency_sd[4, 2] <- "female_yes"
sleep_efficiency_sd[5, 2] <- "female_no"
sleep_efficiency_sd[6, 2] <- "male_yes"
sleep_efficiency_sd[7, 2] <- "male_no"
sleep_efficiency_sd[8, 2:6] <- c("sleep_efficiency_sd_lg", "age", "moca", NA, NA)
sleep_efficiency_sd[9:121, 2:6] <- data_all[c("id", "sex_sleep_med", "sleep_efficiency_sd_lg", "age", "moca")]
sleep_efficiency_sd[9:121, 1] <- "Input"

write.table(sleep_efficiency_sd, "fs_analysis/a_fsgd/final/sleep_efficiency_sd.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)


# ------------------------------------------------------------ #
#                     Fragmentation index                      #
# ------------------------------------------------------------ #

## Fragmentation index average
fragmentation_index_avg <- fsgd  
fragmentation_index_avg[2, 2] <- "fragmentation_index_avg"
fragmentation_index_avg[3, 2] <- "thickness"
fragmentation_index_avg[4, 2] <- "female_yes"
fragmentation_index_avg[5, 2] <- "female_no"
fragmentation_index_avg[6, 2] <- "male_yes"
fragmentation_index_avg[7, 2] <- "male_no"
fragmentation_index_avg[8, 2:6] <- c("fragmentation_index_avg", "age", "moca", NA, NA)
fragmentation_index_avg[9:121, 2:6] <- data_all[c("id", "sex_sleep_med", "fragmentation_index_avg", "age", "moca")]
fragmentation_index_avg[9:121, 1] <- "Input"

write.table(fragmentation_index_avg, "fs_analysis/a_fsgd/final/fragmentation_index_avg.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)

## Fragmentation index variability
fragmentation_index_sd <- fsgd  
fragmentation_index_sd[2, 2] <- "fragmentation_index_sd_lg"
fragmentation_index_sd[3, 2] <- "thickness"
fragmentation_index_sd[4, 2] <- "female_yes"
fragmentation_index_sd[5, 2] <- "female_no"
fragmentation_index_sd[6, 2] <- "male_yes"
fragmentation_index_sd[7, 2] <- "male_no"
fragmentation_index_sd[8, 2:6] <- c("fragmentation_index_sd_lg", "age", "moca", NA, NA)
fragmentation_index_sd[9:121, 2:6] <- data_all[c("id", "sex_sleep_med", "fragmentation_index_sd_lg", "age", "moca")]
fragmentation_index_sd[9:121, 1] <- "Input"

write.table(fragmentation_index_sd, "fs_analysis/a_fsgd/final/fragmentation_index_sd.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)

## Fragmentation index variability adjusting for average
fragmentation_index_sd_avg <- fsgd  
fragmentation_index_sd_avg[2, 2] <- "fragmentation_index_sd_lg"
fragmentation_index_sd_avg[3, 2] <- "thickness"
fragmentation_index_sd_avg[4, 2] <- "female_yes"
fragmentation_index_sd_avg[5, 2] <- "female_no"
fragmentation_index_sd_avg[6, 2] <- "male_yes"
fragmentation_index_sd_avg[7, 2] <- "male_no"
fragmentation_index_sd_avg[8, 2:7] <- c("fragmentation_index_sd_lg", "age", "moca", "fragmentation_index_avg", NA, NA)
fragmentation_index_sd_avg[9:121, 2:7] <- data_all[c("id", "sex_sleep_med", "fragmentation_index_sd_lg", "age", "moca", "fragmentation_index_avg")]
fragmentation_index_sd_avg[9:121, 1] <- "Input"

write.table(fragmentation_index_sd_avg, "fs_analysis/a_fsgd/final/fragmentation_index_sd_avg.fsgd", sep = "\t", na = "", row.names = FALSE, col.names = FALSE, quote = FALSE)

