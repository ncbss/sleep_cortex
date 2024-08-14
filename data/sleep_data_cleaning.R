library(tidyverse)
library(dplyr)
library(openxlsx)
library(readxl)

#------------------------------------------------------------------#
#                           FACT data                              #
#------------------------------------------------------------------#

# Path to data
path <- "fact_sleep_analysis.xlsx"

# Import data
fact_sleep_raw <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map(read_excel, 
      path = path, 
      range = "A1:AC8") # keeping only columns with raw data, will compute average later

# Merge list into single data frame
fact_sleep_merged <- do.call("rbind", fact_sleep_raw)

# Use row names as ids
fact_sleep_merged <- cbind(rownames(fact_sleep_merged), fact_sleep_merged, row.names=NULL)

fact_sleep_clean <- fact_sleep_merged %>% 
  rename(id = 1, days = 2) %>% 
  rename_all(tolower) %>% 
  select(1,2,9,13,30) %>% 
  rename_with(~(gsub(" ", "_", .x, fixed = TRUE))) %>%  
  rename_with(~(gsub("_(min)", "", .x, fixed = TRUE))) %>%
  rename_with(~(gsub("_%", "", .x, fixed = TRUE))) %>% 
  rename_with(~(gsub("#", "", .x, fixed = TRUE))) %>% 
  mutate(id = str_replace_all(id, c("\\.[:digit:]" = "", "_checked" = "", "_manual" = ""))) %>% 
  mutate(id = paste("FACTORIAL_", id, sep = ""))

#------------------------------------------------------------------#
#                           RVCI data                              #
#------------------------------------------------------------------#

# Path to data
path <- "rvci_sleep_analysis.xlsx"

# Import data
rvci_sleep_raw <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map(read_excel, 
      path = path, 
      range = "A1:AC8") # keeping only columns with raw data, will compute average later

# The column names within the sheets are not the same, because of this, rbind can't merge the sheets
# So I will apply the same names too all columns using the last participant as a reference
data_names <- colnames(rvci_sleep_raw$`093_checked`)
rvci_sleep_raw <- lapply(rvci_sleep_raw, setNames, data_names)

# Merge list into single data frame
rvci_sleep_merged <- do.call("rbind", rvci_sleep_raw)

# Use row names as ids
rvci_sleep_merged <- cbind(rownames(rvci_sleep_merged), rvci_sleep_merged, row.names=NULL)

rvci_sleep_clean <- rvci_sleep_merged %>% 
  rename(id = 1, days = 2) %>% 
  rename_all(tolower) %>% 
  select(1,2,9,13,30) %>% 
  rename_with(~(gsub(" ", "_", .x, fixed = TRUE))) %>%  
  rename_with(~(gsub("_(min)", "", .x, fixed = TRUE))) %>%
  rename_with(~(gsub("_%", "", .x, fixed = TRUE))) %>% 
  rename_with(~(gsub("#", "", .x, fixed = TRUE))) %>% 
  mutate(id = str_replace_all(id, c("\\.[:digit:]" = "", "_checked" = "", "_manual" = ""))) %>% 
  mutate(id = paste("RVCI_", id, sep = ""))

#------------------------------------------------------------------#
#                           BT data                                #
#------------------------------------------------------------------#

# Path to data
path <- "bt_sleep_analysis.xlsx"

# Import data
bt_sleep_raw <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map(read_excel, 
      path = path, 
      range = "A18:H47", # keeping only columns with raw data, will compute average later
      col_type = "text") # I have to import it as text, because R converts time to days

# The column names within the sheets are not the same AND the data is not in the same format as FACT and RVC, because of this, rbind can't merge the sheets
# So I will apply the same names too all columns, numbered as days of the week (1-7) and pivot sheets 

data_names <- c("var_names", "0":"6")
bt_sleep_raw <- lapply(bt_sleep_raw, setNames, data_names)

# Merge list into single data frame
bt_sleep_merged <- do.call("rbind", bt_sleep_raw)

# Use row names as ids
bt_sleep_merged <- cbind(rownames(bt_sleep_merged), bt_sleep_merged, row.names=NULL)

## Clean up ids
bt_sleep_clean <- bt_sleep_merged %>% 
  rename(id = 1) %>% 
  mutate(id = str_replace_all(id, c("\\.[:digit:]*" = "", "_checked" = "", "_manual" = "")))

# Pivoting dataset to long format
## Pivot longer first
bt_sleep_clean <- bt_sleep_clean %>% 
  pivot_longer(cols = c("0":"6"),
               names_to = "days",
               names_prefix = "wk",
               values_to = "temp")

## Pivot to wider
bt_sleep_clean <- bt_sleep_clean %>% 
  pivot_wider(id_cols = c(id, days),
                  names_from = var_names,
                  values_from = temp)

## More cleaning and filtering for baseline data anly 
bt_sleep_clean <- bt_sleep_clean %>% 
  separate(id, c("id", "time"), sep = " ") %>% 
  filter(time == "Baseline") %>% 
  select(1, 3, 11, 15, 32) %>% 
  rename_all(tolower) %>% 
  rename_with(~(gsub(" ", "_", .x, fixed = TRUE))) %>%  
  rename_with(~(gsub("_(%)", "", .x, fixed = TRUE))) %>% 
  mutate(id = str_replace(id, "-", "_"))

## Converting data to numeric and transforming time to minutes
bt_sleep_clean <- bt_sleep_clean %>% 
  mutate_at(3:5, as.numeric) %>% 
  mutate(actual_sleep_time = actual_sleep_time * 1440) # multiplying time in days to minutes

#------------------------------------------------------------------#
#                           Merging data                           #
#------------------------------------------------------------------#

## Cleaning um number of days to match all participants across the three datasets
all_sleep_data <- rbind(bt_sleep_clean, fact_sleep_clean, rvci_sleep_clean) %>% 
  mutate(days = if_else(days == "0", "1",
                if_else(days == "1", "2",
                if_else(days == "1", "2",
                if_else(days == "2", "3",
                if_else(days == "3", "4",
                if_else(days == "4", "5",
                if_else(days == "5", "6",
                if_else(days == "6", "7", 
                if_else(days == "7", "7", "999"))))))))))

# Checking observations for duplicates and NAs
all_sleep_data %>% 
  group_by(is.na(fragmentation_index)==TRUE) %>% 
  count() %>% 
  ungroup()

missing_data <- all_sleep_data %>% 
  filter(is.na(actual_sleep_time))

# Checking counts
table(rvci_sleep_clean$id)
table(fact_sleep_clean$id)
table(bt_sleep_clean$id)

# Computing average for sleep measures
all_sleep_data <- all_sleep_data %>% 
  filter(days < 999) %>% 
  filter(is.na(actual_sleep_time)==FALSE) %>% 
  group_by(id) %>% 
  summarise(sleep_time_min = min(actual_sleep_time),
            sleep_time_max = max(actual_sleep_time),
            sleep_time_avg = mean(actual_sleep_time),
            sleep_time_sd = sd(actual_sleep_time),
            sleep_efficiency_avg = mean(sleep_efficiency),
            sleep_efficiency_sd = sd(sleep_efficiency),
            fragmentation_index_avg = mean(fragmentation_index),
            fragmentation_index_sd = sd(fragmentation_index),
            days = n())

# Final list of eligible subjects
all_sleep_data_clean <- all_sleep_data %>% 
  filter(days >= 5)

# Saving data set
write.xlsx(all_sleep_data, "all_sleep_data_raw.xlsx")
write.xlsx(all_sleep_data_clean, "all_sleep_data_clean.xlsx")