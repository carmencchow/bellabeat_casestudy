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

# merge daily activity and daily sleep data frames
daily_df <-
  merge(
    x = daily_activity, 
    y = daily_sleep,
    by = c ("id", "date"),
    all.x = TRUE
  )

View(daily_df)

# Summary statistics for selected columns from each data frame 
daily_df %>%
  select(
    total_steps,
    total_distance,
    calories,
    total_minutes_asleep
  ) %>%
  summary()


daily_df %>%
  select(
    sedentary_minutes,
    lightly_active_minutes,
    fairly_active_minutes,
    very_active_minutes,
  ) %>%
  summary()


# Total steps by day
steps_by_day <- daily_df %>%
  group_by(day_of_week) %>%
  summarise(steps = sum(total_steps)) %>%
  arrange(desc(steps))
print(steps_by_day)

# Total calories by day
calories_by_day <- daily_df %>%
  group_by(day_of_week) %>%
  summarise(calories = mean(calories)) %>%
  arrange(desc(calories))
print(calories_by_day)

# Import Calories per hour data frame
steps_hour <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/hourlySteps_merged.csv")
hourly_steps <- clean_names(steps_hour)

# split column into date and hour
hourly_steps <- hourly_steps %>% 
  separate(activity_hour, c("date", "hour"), 
  sep = "^\\S*\\K")

View(hourly_steps)

# Check unique ids
steps_ids <- n_distinct(hourly_steps$id)
print(steps_ids)
