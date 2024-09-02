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

# Format dates and rename date activity_date column
daily_activity <- daily_activity %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))

daily_sleep <- daily_sleep %>%
  rename(date = sleep_day) %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))

weight_log <- weight_log %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))

typeof(daily_activity$date)
typeof(daily_sleep$date)
typeof(weight_log$date)

# add new column that displays min taken to fall asleep
sleep_day <- daily_sleep %>%
  mutate(
    min_fall_asleep = total_time_in_bed - total_minutes_asleep
  )

# add new day_of_week column
daily_activity <- daily_activity %>%
  mutate(
    day_of_week = weekdays(date) 
  )

# only include records where calories and step count > 0
daily_activity <- daily_activity %>%
  filter(calories > 0 & total_steps > 0)
  

View(daily_activity)


# import hourly steps data
hourly_steps <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/hourlySteps_merged.csv")


