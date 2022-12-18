#------------------------------------------------------------------#
#                        Loading packages                       ####
#------------------------------------------------------------------#
library(tidyverse)
library(openxlsx)

#------------------------------------------------------------------#
#                         Loading data                          ####
#------------------------------------------------------------------#

# Loading data
fact_dem <- read.xlsx("fact_demographics.xlsx")
rvci_dem <- read.xlsx("rvci_demographics.xlsx")
bt_dem <- read.xlsx("bt_demographics.xlsx")

# Cleaning datasets

## FACT
fact_dem_clean <- fact_dem %>% 
  rename(id = Record.number,
         age = "Current.age", 
         height = "Average.Standing.Height.(cm)", 
         weight = "Average.Weight.(kg)", 
         education = "3..How.many.years.of.school.have.you.finished?", 
         moca = MoCA.Score, mmse = MMSE.TOTAL.SCORE) %>% 
  rename_all(tolower) %>% 
  select(id, sex, education, age, moca, mmse, height, weight) %>% 
  mutate_at(4:8, as.numeric) %>% 
  mutate(bmi = weight/((height/100)^2)) %>% 
  filter(is.na(height) == FALSE) %>% 
  filter(is.na(age) == FALSE) %>% 
  mutate(sex = tolower(sex)) %>% 
  mutate(id = str_replace(id, "FACT_", "FACTORIAL_")) %>% 
  mutate(education = str_replace_all(education, c("trades or professional certificate or diploma \\(CEGEP in Quebec\\)" = "trade school",
                                                  "Less than grade 9" = "high school or less",
                                                  "high school certificate or diploma" = "high school or less",
                                                  "grades 9-13, without certificate or diploma" = "high school or less",
                                                  "some university certificate or diploma" = "some university")))

## RVCI
rvci_dem_clean <- rvci_dem %>% 
  rename(age = "Age.at.Enrollment", height = "Height.(cm)", weight = "Weight.(kg)", moca = Total.MoCA, mmse = Total.MMSE) %>% 
  rename_all(tolower) %>%
  rename_with(~(gsub(".", "_", .x, fixed = TRUE))) %>% 
  mutate(sex = str_replace_all(sex, c("M" = "male", "F" = "female"))) %>% 
  select(id, age, sex, education, moca, mmse, height, weight, bmi) %>% 
  mutate(education = str_replace_all(education, c("trades or professional certificate or diploma \\(CEGEP in Quebec\\)" = "trade school",
                                                    "Less than grade 9" = "high school or less",
                                                    "high school certificate or diploma" = "high school or less",
                                                    "grades 9-13, without certificate or diploma" = "high school or less",
                                                    "some university certificate or diploma" = "some university")))

## BT
bt_dem_clean <- bt_dem %>%
  filter(Assessment.Period == "Baseline") %>%
  select(ID, Sex, Age, Education, 
         MMSE, MoCA, 
         Average.Height, Average.Weight, BMI) %>%
  rename_with(~(gsub("-", "_", .x, fixed = TRUE))) %>% 
  rename_with(~(gsub(":", "", .x, fixed = TRUE))) %>% 
  rename_with(~ tolower(gsub(".", "_", .x, fixed = TRUE))) %>% 
  rename(height = average_height, weight = average_weight) %>% 
  mutate(id = str_replace(id, "-", "_")) %>% 
  mutate(sex = str_replace_all(sex, c("F" = "female", "M" = "male"))) %>% 
  mutate(education = if_else(education <= 2, "high school or less",
                     if_else(education == 3, "trade school",
                     if_else(education == 4, "some university",
                     if_else(education == 5, "university degree", "999")))))
  

# Merging all
## Eligible subjects with FreeSurfer data 
subjects_list <- read.table("subjects_list.txt", col.names = "id")
all_data_demographics <- rbind(fact_dem_clean, 
                               rvci_dem_clean,
                               bt_dem_clean)


#------------------------------------------------------------------#
#                            PSQI data                          ####
#------------------------------------------------------------------#

# Loading data
fact_psqi <- read.xlsx("Gui_PSQI_April 2022.xlsx", sheet = "FACT")
rvci_psqi <- read.xlsx("Gui_PSQI_April 2022.xlsx", sheet = "RVCI")
bt_psqi <- read.xlsx("Gui_PSQI_April 2022.xlsx", sheet = "Buying Time")

# Merging and cleaning up variable names
all_psqi <- rbind(bt_psqi, fact_psqi, rvci_psqi) %>% 
  filter(ID != "RVCI_016_v2") %>%  # Removing this participant, using the v1 data
  filter(Assessment.Period == "Baseline") %>% 
  mutate(ID = str_replace_all(ID, c("-" = "_",
                                    "FACT_" = "FACTORIAL_"))) %>% 
  rename(id = ID) %>% 
  rename_with(~(gsub(".Category.", "_", .x, fixed = TRUE))) %>% 
  rename_with(~(gsub(":.", "_", .x, fixed = TRUE))) %>% 
  rename_with(~(gsub(".", "_", .x, fixed = TRUE))) %>% 
  rename_all(tolower) %>% 
  select(1, 7:14)

# Final names
all_psqi %>% names()


# Merging with demographics
all_data_demographics <- left_join(all_data_demographics, all_psqi)


#------------------------------------------------------------------#
#                        Sleep medication data                  ####
#------------------------------------------------------------------#

# Load data from REDCap

# Compute medication from PSQI
all_data_demographics <- all_data_demographics %>% 
  mutate(sleep_medication_psqi = ifelse(psqi_6_medications == 0, "no", ifelse(psqi_6_medications >= 1,"yes", NA)),
         sleep_dist_psqi = ifelse(psqi_5_sleep_disturbances == 0, "no", ifelse(psqi_5_sleep_disturbances >= 1,"yes", NA)),
         sleep_medication_psqi = ifelse(id == "RVCI_055", "no", sleep_medication_psqi)) # Confirmed no sleep meds from HRU meds

# Saving dataset  
write.xlsx(all_data_demographics, "all_data_demographics.xlsx")