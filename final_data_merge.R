library(tidyverse)
library(dplyr)
library(openxlsx)
library(readxl)
#------------------------------------------------#
#             Merging final data                 #
#------------------------------------------------#

all_dem <- read.xlsx("data/all_data_demographics.xlsx")
all_sleep <- read.xlsx("data/all_sleep_data_clean.xlsx")
all_struc <- read.xlsx("data/all_structural_data_clean.xlsx")
all_cog <- read.xlsx("data/all_cog_data_clean.xlsx")
overlapping_subjects <- read.table("data/overlapping_subjects.txt", col.names = "id")

# All subjects with sleep data
all_data_merged <- inner_join(all_dem, all_sleep) %>% 
  left_join(., all_struc) %>% 
  left_join(., all_cog) %>% 
  mutate(included = if_else(is.na(eicv_cm3)==TRUE, "NO", "YES")) %>% 
  arrange(id)

# Removing subjects overlapping across studies
all_data_clean <- anti_join(all_data_merged, overlapping_subjects) %>% 
  arrange(id)

# Check removed subjects
all_data_check <- inner_join(all_data_merged, overlapping_subjects) %>% 
  arrange(id)

# Saving data set
write.xlsx(all_data_clean, "all_data_clean.xlsx")

