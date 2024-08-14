#------------------------------------------------------------------#
#                        Loading packages                       ####
#------------------------------------------------------------------#
library(tidyverse)
library(openxlsx)

#------------------------------------------------------------------#
#                         Loading data                          ####
#------------------------------------------------------------------#

# Loading data
fact_cog <- read.xlsx("fact_cog.xlsx", startRow = 2)
rvci_cog <- read.xlsx("rvci_cog.xlsx", startRow = 2)
bt_cog <- read.xlsx("bt_demographics.xlsx")

# Cleaning datasets

## FACT
fact_cog_clean <- fact_cog %>% 
  rename(id = X1,
         adas_cog_tot = "ADAS-Cog.13-Item.Score",
         tmt_a = "Trails.A.-.Time.to.complete.(seconds)", 
         tmt_b = "Trails.B.-.Time.to.complete.(seconds)",
         dsst = "DSST.Score.(total.completed.correctly)") %>% 
  mutate(id = str_replace(id, "FACT_", "FACTORIAL_")) %>% 
  select(id, adas_cog_tot, tmt_a, tmt_b, dsst)


## RVCI
rvci_cog_clean <- rvci_cog %>% 
  rename(id = X1,
         adas_cog_tot = "ADAS-Cog.13-Item.Score",
         tmt_a = "Trails.A.-.Time.to.complete.(seconds)", 
         tmt_b = "Trails.B.-.Time.to.complete.(seconds)",
         dsst = "DSST.Score.(total.completed.correctly)") %>% 
  select(id, adas_cog_tot, tmt_a, tmt_b, dsst)

## BT
bt_cog_clean <- bt_cog %>%
  filter(Assessment.Period == "Baseline") %>%
  rename(id = ID,
         adas_cog_tot = "ADAS.Cog.Total.Score",
         tmt_a = "Trail.Making.A.time.to.complete", 
         tmt_b = "Trail.Making.B.time.to.complete",
         dsst = "DSST.in.90.Secs") %>% 
  mutate(id = str_replace(id, "BT-", "BT_")) %>% 
  select(id, adas_cog_tot, tmt_a, tmt_b, dsst)

# Merging all
all_data_cog <- rbind(fact_cog_clean, rvci_cog_clean, bt_cog_clean)

# Computing TMT B minus A and cleaning DSST

all_data_cog <- all_data_cog %>% 
  mutate(tmt_bma = tmt_b - tmt_a) %>% 
  mutate(dsst = ifelse(dsst == "DNC", NA, dsst),
         dsst = as.numeric(dsst))

# Saving dataset  
write.xlsx(all_data_cog, "all_cog_data_clean.xlsx")
