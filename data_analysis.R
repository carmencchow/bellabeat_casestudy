# install packages
install.packages("tidyverse")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("tidyr")
install.packages("janitor")
install.packages("readr")
install.packages("lubridate")

# run packages
library(tidyverse)
library(dplyr)
library(ggplot2)
library(tidyr)
library(janitor)
library(readr)
library(lubridate)

# Import and view data
dailyActivity_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
sleepDay_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
weightLogInfo_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")

head(dailyActivity_merged)
colnames(dailyActivity_merged)

head(sleepDay_merged)
head(weightLogInfo_merged)

# Format column names
daily_activity <- clean_names(dailyActivity_merged)
daily_sleep <- clean_names(sleepDay_merged)
weight_log <- clean_names(weightLogInfo_merged)

View(daily_activity)
View(daily_sleep)
View(weight_log)

# Check number of unique ids / unique users
activity_ids <- n_distinct(daily_activity$id)
print(activity_ids)

sleep_ids <- n_distinct(daily_sleep$id)
print(sleep_ids)

weight_ids <- n_distinct(weight_log$id)
print(weight_ids)
