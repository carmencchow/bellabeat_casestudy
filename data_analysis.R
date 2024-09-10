# STEP 1: Prepare --------------------------------------

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

# STEP 2: Process --------------------------------------
# Import and view data
dailyActivity_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
sleepDay_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
weightLogInfo_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")

str(dailyActivity_merged)
str(sleepDay_merged)

colnames(weightLogInfo_merged)

names(dailyActivity_merged)
names(sleepDay_merged)
names(weightLogInfo_merged)

# Check number of unique ids / unique users
activity_ids <- n_distinct(dailyActivity_merged$Id)
print(activity_ids)

sleep_ids <- n_distinct(sleepDay_merged$Id)
print(sleep_ids)

weight_ids <- n_distinct(weightLogInfo_merged$Id)
print(weight_ids)


# STEP 3: Clean  --------------------------------------
# Format column names
daily_activity <- clean_names(dailyActivity_merged)
daily_sleep <- clean_names(sleepDay_merged)
weight_log <- clean_names(weightLogInfo_merged)

# Format dates, reorder days of the week, rename date, add new column
daily_activity <- daily_activity %>%
  rename(date = activity_date) %>%
  mutate(date = as_date(date, format = "%m/%d/%Y")) %>%
  mutate(weekday = weekdays(date)) %>% 
  mutate(weekday = ordered(weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday","Friday", "Saturday", "Sunday")))

# Split date-time column into two columns
daily_sleep <- daily_sleep %>%
  separate(sleep_day, c("date", "hour"),sep = "^\\S*\\K") %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))
typeof(daily_sleep$date)

weight_log <- weight_log %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))

# add new min_fall_asleep column 
daily_sleep <- daily_sleep %>%
  mutate( 
    min_fall_asleep = total_time_in_bed - total_minutes_asleep
  )

# remove duplicates and NA
daily_activity <- daily_activity %>%
  distinct() %>%
  drop_na()

daily_sleep <- daily_sleep %>%
  distinct() %>%
  drop_na()

head(daily_activity)
head(daily_sleep)

# only include records where calories and step count > 0
daily_activity <- daily_activity %>%
  filter(calories > 0 & total_steps > 0)

# merge daily activity and daily sleep data frames
daily_df <-
  merge(
    x = daily_activity, 
    y = daily_sleep,
    by = c ("id", "date"),
    all.x = TRUE
  )

colnames(daily_df)

# # delete unnecessary columns
# daily_df <- daily_df %>%
#   select(-hour,-total_sleep_records)

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
  group_by(weekday) %>%
  summarise(steps = sum(total_steps)) %>%
  arrange(desc(steps))
print(steps_by_day)

# Total calories by day
calories_by_day <- daily_df %>%
  group_by(weekday) %>%
  summarise(calories = mean(calories)) %>%
  arrange(desc(calories))
print(calories_by_day)

# Import steps per hour data frame
steps_hour <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/hourlySteps_merged.csv")
hourly_steps <- clean_names(steps_hour)
head(hourly_steps)

# Check unique ids
steps_ids <- n_distinct(hourly_steps$id)
print(steps_ids)

# split column into date and hour
hourly_steps <- hourly_steps %>% 
  separate(activity_hour, c("date", "hour"), 
  sep = "^\\S*\\K") 

# Most active hours
avg_steps <- hourly_steps %>%
  group_by(hour) %>%
  summarize(avg_steps = mean(step_total)) %>%
  mutate(avg_steps = as.integer(avg_steps)) %>%
  arrange(desc(avg_steps)) 


# ------------------------ Visualizations with ggplot ------------------------------- #

# ------------------- (i) PHYSICAL ACTIVITY: TOTAL STEPS -------------------------------- #

# Plotting Calories burned vs. steps
ggplot(daily_df, aes(x = total_steps, y = calories)) +
  geom_point(color = "purple") +
  geom_smooth() + 
  labs(title = "Calories Burned per Day vs. Total Steps per Day",
       x = "Total Steps",
       y = "Calories Burned")

# Calculating the mean and median number of steps
mean_steps <- daily_df %>%
  summarise(mean_value = round(mean(total_steps), digits = 0)) %>%
  pull(mean_value)
print(mean_steps)

median_steps <- daily_df %>%
  summarise(median_value = round(median(total_steps), digits = 0)) %>%
  pull(median_value)
print(median_steps)

# Plotting frequency of steps
ggplot(daily_df, aes(x = total_steps)) +
  geom_histogram(fill = "cadetblue1", color = "black") +
  geom_vline(xintercept = mean_steps, color = "red", linetype = "solid", size = 0.8) +
  geom_vline(xintercept = median_steps, color = "blue", linetype = "solid", size = 0.8) +
  annotate("text", x = mean_steps + 2800, y = 110, label = "Mean: 8319", color = "red") +
  annotate("text", x = median_steps - 3200, y = 110, label = "Median: 8053", color = "blue") +
  labs(x ='Steps', y='Count', title = 'Daily Step Count')
theme_minimal()


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
  labs(title = "Calories Burned vs. Very Active Minutes",
       x = "Very Active Minutes",
       y = "Calories")

# Lightly Active minutes vs. Calories Burned
ggplot(daily_df, aes(x = lightly_active_minutes, y = calories)) +
  geom_point(color = "aquamarine3") +
  geom_smooth() + 
  labs(title = "Calories Burned vs. Lightly Active Minutes",
       x = "Lightly Active Minutes",
       y = "Calories")

# Sedentary minutes vs. Calories Burned
ggplot(daily_df, aes(x = sedentary_minutes, y = calories)) +
  geom_point(color = "deepskyblue") +
  geom_smooth() + 
  labs(title = "Calories Burned vs. Sedentary Minutes",
       x = "Sedentary Minutes",
       y = "Calories")

# New df showing avg calories burned per day
cals_weekday <- daily_df %>%
  # mutate(day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  group_by(weekday) %>%
  summarize(avg_cals = mean(calories)) %>%
  mutate(avg_cals = round(avg_cals, digits = 0)) %>%
  arrange(desc(avg_cals)) 

View(cals_weekday)

# Total Calories vs. Day of Week
ggplot(cals_weekday, aes(y = avg_cals, x = weekday, fill = avg_cals)) +
  geom_bar(stat = "identity", width = 0.2, fill="thistle3", color = "black") +
  geom_text(aes(label = avg_cals), vjust = -0.5, color = "black") +
  labs(x = "Day of the Week", y = "Calories", title = "Average Calories by Day") +
  theme(axis.text.y = element_text(angle = 0))

# Create new column combining fairly active and very active minutes
daily_df <- daily_df %>%
  mutate(
  moderate_vigorous_minutes = fairly_active_minutes + very_active_minutes
)
colnames(daily_df)

# Calculating the mean and median
mean_mod_vig <- daily_df %>%
  summarise(mean_value = round(mean(moderate_vigorous_minutes), digits = 1)) %>%
  pull(mean_value)
print(mean_mod_vig)

median_mod_vig <- daily_df %>%
  summarise(median_value = round(median(moderate_vigorous_minutes), digits = 2)) %>%
  pull(median_value)
print(median_mod_vig)

# Plot count of moderate_vigorous minutes 
ggplot(daily_df, aes(x = moderate_vigorous_minutes)) +
  geom_histogram(fill = "darkgoldenrod1", color = "black") +
  geom_vline(xintercept = mean_mod_vig, color = "red", linetype = "solid", size = 0.8) +
  geom_vline(xintercept = median_mod_vig, color = "blue", linetype = "solid", size = 0.8) +
  annotate("text", x = mean_mod_vig + 17, y = 320, label = "Mean: 26", color = "red") +
  annotate("text", x = median_mod_vig - 20, y = 320, label = "Median: 37.8", color = "blue") +
  labs(x ='Minutes', y='Count', title = 'Moderate to Vigorous Activity in a Day')
  theme_minimal()

# ------------------------------- (iii) SEDENTARY MINUTES --------------------------------- #

# Calculating the mean and median
mean_sedentary <- daily_df %>%
  summarise(mean_value = round(mean(sedentary_minutes, na.rm = TRUE), digits = 1)) %>%
  pull(mean_value)
print(mean_sedentary)

median_sedentary <- daily_df %>%
  summarise(median_value = round(median(sedentary_minutes, na.rm = TRUE), digits = 2)) %>%
  pull(median_value)
print(median_sedentary)

# Plot count of sedentary minutes
ggplot(daily_df, aes(x = sedentary_minutes)) +
  geom_histogram(fill = "deeppink4", color = "black") +
  # geom_histogram(fill = "deeppink4") +
  geom_vline(xintercept = mean_sedentary, color = "red", linetype = "solid", size = 0.8) +
  geom_vline(xintercept = median_sedentary, color = "blue", linetype = "solid", size = 0.8) +
  annotate("text", x = mean_sleep + 400, y = 120, label = "Mean: 955.9", color = "red") +
  annotate("text", x = median_sleep + 730, y = 120, label = "Median: 1021", color = "blue") +
  labs(x ='Sedentary Minutes', y='Count', title = "Sedentary Minutes in a Day")
  theme_minimal()

# ------------------------------------ (iv) SLEEP --------------------------------------- #

# Calculating mean and median
mean_sleep <- daily_df %>%
  summarise(mean_value = round(mean(total_minutes_asleep, na.rm = TRUE), digits = 1)) %>%
  pull(mean_value)
print(mean_sleep)

median_sleep <- daily_df %>%
  summarise(median_value = round(median(total_minutes_asleep, na.rm = TRUE), digits = 1)) %>%
  pull(median_value)
print(median_sleep)

# Plot count of minutes asleep
ggplot(daily_df, aes(x = total_minutes_asleep)) +
  geom_histogram(fill = "darkseagreen", color = "black") +
  geom_vline(xintercept = mean_sleep, color = "red", linetype = "solid", size = 0.8) +
  geom_vline(xintercept = median_sleep, color = "blue", linetype = "solid", size = 0.8) +
  labs(x ='Minutes of Sleep', y='Count', title = "Minutes of Sleep in a Day") +
  annotate("text", x = mean_sleep - 80, y = 55, label = "Mean: 419.2", color = "red") +
  annotate("text", x = median_sleep + 80, y = 55, label = "Median: 432.5", color = "blue") +
  theme_minimal()

# Create new data frame showing avg minutes asleep per day
weekly_sleep_df <- daily_df %>%
  # mutate(day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  group_by(weekday) %>%
  summarize(avg_min = mean(total_minutes_asleep, na.rm = TRUE)) %>%
  mutate(avg_min = round(avg_min, digits = 0)) %>%
  arrange(desc(avg_min))

# Plotting Sleep vs. Day of the Week
ggplot(weekly_sleep_df, aes(y = avg_min/60, x = weekday, fill = avg_min)) +
  geom_bar(stat = "identity", width = 0.3, fill="coral") +
  geom_text(aes(label = round(avg_min/60, digits = 2)), vjust = -0.5, color = "black") +
  labs(x = "Day of the Week", y = "Average Hours Asleep", title = "Average Number of Hours Asleep by Day") +
  theme(axis.text.y = element_text(angle = 0))

# Plotting different activity levels and minutes of sleep
ggplot(daily_df, aes(x = sedentary_minutes, y = total_minutes_asleep)) +
  geom_point(color = "violetred") +  
  geom_smooth(color = "ivory4") +
  labs(title = "Sedentary Minutes and Sleep",
       x = "Sedentary minutes",
       y = "Minutes of Sleep")

ggplot(daily_df, aes(x = lightly_active_minutes, y = total_minutes_asleep)) +
  geom_point(color = "purple") +  
  geom_smooth(color = "ivory4") +
  labs(title = "Lightly Active Minutes and Sleep",
       x = "Lightly Active minutes",
       y = "Minutes of Sleep")

ggplot(daily_df, aes(x = fairly_active_minutes, y = total_minutes_asleep)) +
  geom_point( color = "blue") +  
  geom_smooth(color = "ivory4") +
  labs(title = "Fairly Active Minutes and Sleep",
       x = "Fairly Active minutes",
       y = "Minutes of Sleep")

ggplot(daily_df, aes(x = very_active_minutes, y = total_minutes_asleep)) +
  geom_point(color = "orange") +  
  geom_smooth(color = "ivory4") +
  labs(title = "Very Active Minutes and Sleep",
       x = "Very Active minutes",
       y = "Minutes of Sleep")
