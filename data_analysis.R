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

# Import steps per hour data frame
steps_hour <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/hourlySteps_merged.csv")
hourly_steps <- clean_names(steps_hour)

# Check unique ids
steps_ids <- n_distinct(hourly_steps$id)
print(steps_ids)

# split column into date and hour
hourly_steps <- hourly_steps %>% 
  separate(activity_hour, c("date", "hour"), 
  sep = "^\\S*\\K")
head(hourly_steps)

# Most active hours
avg_steps <- hourly_steps %>%
  group_by(hour) %>%
  summarize(avg_steps = mean(step_total)) %>%
  mutate(avg_steps = as.integer(avg_steps)) %>%
  arrange(desc(avg_steps)) 

print(avg_steps)
 
# ------------------------ Visualizations with ggplot ------------------------------- #

# ------------------- (i) PHYSICAL ACTIVITY: TOTAL STEPS -------------------------------- #

# Plotting Calories burned vs. steps
ggplot(daily_df, aes(x = total_steps, y = calories)) +
  geom_point(color = "purple") +
  geom_smooth() + 
  labs(title = "Calories Burned per Day vs. Total Steps per Day",
       x = "Total Steps",
       y = "Calories Burned")

# Total Steps vs. Hour 
ggplot(avg_steps, aes(y = reorder(hour, avg_steps), x = avg_steps, fill = avg_steps)) +
  geom_bar(stat = "identity", width = 0.5) +
  scale_fill_gradient(high = "darkblue", low = "lightblue") +
  labs(x = "Average Steps", y = "Hour of the Day", title = "Average Steps per Hour") +
  theme(axis.text.y = element_text(angle = 0))


# ------------------- (ii) PHYSICAL ACTIVITY: MODERATE to VIGOROUS ACTIVITY ----------------- #

# Very Active minutes vs. Calories Burned
ggplot(daily_df, aes(x = very_active_minutes, y = calories)) +
  geom_point(color = "blue") +
  geom_smooth() + 
  labs(title = "Calories Burned per Day vs. Very Active Minutes per Day",
       x = "Very Active Minutes per Day",
       y = "Calories Burned per Day")

# Lightly Active minutes vs. Calories Burned
ggplot(daily_df, aes(x = lightly_active_minutes, y = calories)) +
  geom_point(color = "lightblue") +
  geom_smooth() + 
  labs(title = "Calories Burned per Day vs. Lightly Active Minutes per Day",
       x = "Lightly Active Minutes",
       y = "Calories")

# Create new data frame showing avg calories burned per day
cals_weekday <- daily_df %>%
  mutate(day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  group_by(day_of_week) %>%
  summarize(avg_cals = mean(calories)) %>%
  mutate(avg_cals = round(avg_cals, digits = 0)) %>%
  arrange(desc(avg_cals)) 

# Total Calories vs. Day of Week
ggplot(cals_weekday, aes(y = avg_cals, x = day_of_week, fill = avg_cals)) +
  geom_bar(stat = "identity", width = 0.3, fill="thistle3") +
  geom_text(aes(label = avg_cals), vjust = -0.5, color = "black") +
  labs(x = "Day of the Week", y = "Average Calories", title = "Average Calories by Day") +
  theme(axis.text.y = element_text(angle = 0))

# Create a new long-format df with the selected activity levels
activity_df <- daily_df %>%
  mutate(day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  select(day_of_week, sedentary_minutes, lightly_active_minutes, fairly_active_minutes, very_active_minutes) %>%
  pivot_longer(
    cols = c(sedentary_minutes, lightly_active_minutes, fairly_active_minutes, very_active_minutes),
    names_to = "activity_level",
    values_to = "minutes"
  ) %>%
  mutate(activity_level = gsub("_minutes", "", activity_level))

# Create new column combining fairly active and very active minutes
daily_df <- daily_df %>%
  mutate(
  moderate_vigorous_minutes = fairly_active_minutes + very_active_minutes
)


# Plot count of moderate_vigorous minutes 
ggplot(daily_df, aes(x = moderate_vigorous_minutes)) +
  geom_histogram(fill = "darkgoldenrod1") +
  labs(x ='Moderate Vigorous Activities in minutes)', y='Count', title = 'Moderate to Vigorous Activity in a Day')

# ------------------------------- (iii) SEDENTARY MINUTES --------------------------------- #

# Plot count of minutes asleep
ggplot(daily_df, aes(x = total_minutes_asleep)) +
  geom_histogram(fill = "darkseagreen") +
  labs(x ='Sedentary Activity in minutes)', y='Count', title = "Minutes of Sleep in a Day")

# ------------------------------------ (iv) SLEEP --------------------------------------- #

# Plot count of minutes asleep
ggplot(daily_df, aes(x = total_minutes_asleep)) +
  geom_histogram(fill = "darkseagreen") +
  labs(x ='Sedentary Activity in minutes)', y='Count', title = "Minutes of Sleep in a Day")

# Create new data frame showing avg minutes asleep per day
weekly_sleep_df <- daily_df %>%
  mutate(day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  group_by(day_of_week) %>%
  summarize(avg_min = mean(total_minutes_asleep, na.rm = TRUE)) %>%
  mutate(avg_min = round(avg_min, digits = 0)) %>%
  arrange(desc(avg_min))

# Plotting Sleep vs. Day of the Week
ggplot(weekly_sleep_df, aes(y = avg_min/60, x = day_of_week, fill = avg_min)) +
  geom_bar(stat = "identity", width = 0.3, fill="coral") +
  geom_text(aes(label = round(avg_min/60, digits = 2)), vjust = -0.5, color = "black") +
  labs(x = "Day of the Week", y = "Average Hours Asleep", title = "Average Number of Hours Asleep by Day") +
  theme(axis.text.y = element_text(angle = 0))



# ----------------------------------- OTHER ------------------------------------------
# Plot activity levels and days of the week
# ggplot(activity_df, aes(x = day_of_week, y = minutes, fill = activity_level)) +
#   geom_bar(stat = "identity") +
#   labs(x = "Day of the Week", y = "Minutes of Activity", title = "Activity Levels by Day of the Week")
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   scale_fill_manual(values = c("sedentary" = "lightgrey", 
#                                "lightly_active" = "blue", 
#                                "moderately_active" = "green", 
#                                "very_active" = "red"))








