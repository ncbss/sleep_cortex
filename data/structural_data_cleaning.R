#------------------------------------------------------------------#
#                        Loading packages                       ####
#------------------------------------------------------------------#
library(tidyverse)
library(openxlsx)

#------------------------------------------------------------------#
#                        Loading data                           ####
#------------------------------------------------------------------#

# FreeSurfer data
## Loading thickness data
all_aparc_thickness_lh <- read.xlsx("all_aseg_parc.xlsx", sheet = "aparc_thickness_lh")
all_aparc_thickness_rh <- read.xlsx("all_aseg_parc.xlsx",sheet = "aparc_thickness_rh")

## Loading aseg volumetric data 
all_aseg_stats <- read.xlsx("all_aseg_parc.xlsx", sheet = "aseg_stats")

#------------------------------------------------------------------#
#                        Data management                        ####
#------------------------------------------------------------------#

## Renaming 1st column to merge later
all_aparc_thickness_lh <- rename(all_aparc_thickness_lh, id = lh.aparc.thickness)
all_aparc_thickness_rh <- rename(all_aparc_thickness_rh, id = rh.aparc.thickness)

## Cleaning up
all_aparc_thickness <- left_join(all_aparc_thickness_lh, all_aparc_thickness_rh, by = "id") %>% 
  rename_with(~(gsub("-", "_", .x, fixed = TRUE))) %>% 
  rename(lh_mean_thickness = lh_MeanThickness_thickness,
         rh_mean_thickness = rh_MeanThickness_thickness) %>% 
  mutate(mean_thickness = (rh_mean_thickness + lh_mean_thickness)/2)

# Volumetric data
## Renaming variables
all_aseg_stats <- all_aseg_stats %>% 
  rename(id = "Measure:volume",
         lh_wm_vol = lhCerebralWhiteMatterVol,
         rh_wm_vol = rhCerebralWhiteMatterVol,
         cerebral_wm_vol = CerebralWhiteMatterVol,
         lh_cortex_vol = lhCortexVol,
         rh_cortex_vol = rhCortexVol,
         sub_cort_gm_vol = SubCortGrayVol,
         total_gm_vol = TotalGrayVol,
         eicv = EstimatedTotalIntraCranialVol) %>% 
  rename_with(~(gsub("-", "_", .x, fixed = TRUE))) %>%
  rename_all(tolower) %>% 
  select(id, 
         lh_wm_vol, rh_wm_vol, cerebral_wm_vol,
         lh_cortex_vol, rh_cortex_vol, sub_cort_gm_vol, total_gm_vol,
         left_hippocampus, right_hippocampus, 
         left_lateral_ventricle, right_lateral_ventricle,
         left_inf_lat_vent, right_inf_lat_vent, eicv) %>% 
  mutate(lh_wm_vol_cm3 = lh_wm_vol/1000, 
         rh_wm_vol_cm3 = rh_wm_vol/1000, 
         cerebral_wm_vol_cm3 = cerebral_wm_vol/1000,
         lh_cortex_vol_cm3 = lh_cortex_vol/1000, 
         rh_cortex_vol_cm3 = rh_cortex_vol/1000, 
         sub_cort_gm_vol_cm3 = sub_cort_gm_vol/1000,
         left_hippocampus_cm3 = left_hippocampus/1000,
         right_hippocampus_cm3 = right_hippocampus/1000,
         total_gm_vol_cm3 = total_gm_vol/1000,
         left_lateral_ventricle_cm3 = left_lateral_ventricle/1000,
         right_lateral_ventricle_cm3 = right_lateral_ventricle/1000,
         left_inf_lat_vent_cm3 = left_inf_lat_vent/1000,
         right_inf_lat_vent_cm3 = right_inf_lat_vent/1000,
         eicv_cm3 = eicv/1000)

#------------------------------------------------------------------#
#                        Merging final data                     ####
#------------------------------------------------------------------#
subjects_list <- read.table("subjects_list.txt", col.names = "id")

# Merging
all_structural_data_clean <- left_join(subjects_list, all_aparc_thickness, by= c("id")) %>% 
  left_join(., all_aseg_stats, by= "id")

# Checking observations for duplicates
tableone::CreateTableOne(data = all_structural_data_clean, "id")

# Saving 
write.xlsx(all_structural_data_clean, "all_structural_data_clean.xlsx")

