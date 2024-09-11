
<h1>Bellabeat Case Study</h1>
<p>Carmen Chow</p> 
<p>September 2024</p>

<h2>Scenario</h2>
<p>Bellabeat is a high-tech manufacturer of health-focused products for women.  Since it was founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women.  Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. Sršen knows that an analysis of Bellabeat’s available consumer data would reveal more opportunities for growth. She has asked the marketing analytics team to focus on a Bellabeat product and analyze smart device usage data in order to gain insight into how people are already using their smart devices. Then, using this information, she would like high-level recommendations for how these trends can inform Bellabeat marketing strategy.</p>

<h2>Stakeholders </h2>
* Urška Sršen: Bellabeat’s cofounder and Chief Creative Officer
* Sando Mur: Mathematician and Bellabeat’s cofounder; key member of the Bellabeat executive team 
* Bellabeat marketing analytics team: A team of data analysts responsible for collecting, analyzing, and reporting data that helps guide Bellabeat’s marketing strategy. 

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
Analyze FitBit’s Fitness Tracker usage data to gain insight into trends that can be applied to Bellabeat’s customers. 

<h3>Guiding questions</h3>
What are some trends in smart device usage? 
How could these trends apply to Bellabeat customers? 
How could these trends help influence Bellabeat marketing strategy?

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
<p>The publicly available FitBit Fitness Tracker Data (https://www.kaggle.com/arashnic/fitbit)
includes data from 33  fitbit users who consented to the submission of personal tracker data, including information about daily physical activity, steps, calories burned, and sleep monitoring. The dataset is provided under the Mobius license and consists of 18 wide format CSV files of anonymized user information.</p>

<h3><b>Data Limitations</b></h3>
<p>- Some of the data sets have a sample size of 33 FitBit users, while the data for weight had an even smaller sample size of 8.</p>
<p>- Data is 8 years old there not current. It covers a one month period from 2016-04-12 to 2016-05-12.</p>
<p>- Information about how long each participant wore their Fitbit is missing.</p>
<p>- Demographic information pertaining to the ages of the participants is also missing.</p>

<h3><b>R packages and libraries</b></h3>
<p>We’ll be using R for our data analysis and data visualization. Let’s start by installing the following R packages and loading their libraries by running install.packages() and library() in R Studio.</p>

```# install packages
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
```

Before processing our data, we’ll preview the eighteen CSV files in Excel to get an overview of the data’s overall structure to determine which files will be useful in answering our Business Task.  Out of the 18 available files, we’ll focus our attention on the following three:

```dailyActivity_merged.csv```
```sleepDay_merged.csv```
```weightLogInfo_merged.csv```

The other files either contain information that does not impact our Business Task or have data points that already exist in the `dailyActivity_merged.csv` file.


<h2>3. Process</h2>
Let’s open R Studio and run the `read_csv()` R command to read each CSV file and save it as a data frame in R:

```
dailyActivity_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
sleepDay_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
weightLogInfo_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")
```

Check that the files have been imported correctly in the environment pane with `ls()`. We'll take a closer look at each data frame by using `head()` to return the first few rows. Running `head(sleepDay_merged)`


```
          Id SleepDay              TotalSleepRecords TotalMinutesAsleep TotalTimeInBed
       <dbl> <chr>                             <dbl>              <dbl>          <dbl>
1 1503960366 4/12/2016 12:00:00 AM                 1                327            346
2 1503960366 4/13/2016 12:00:00 AM                 2                384            407
3 1503960366 4/15/2016 12:00:00 AM                 1                412            442
4 1503960366 4/16/2016 12:00:00 AM                 2                340            367
5 1503960366 4/17/2016 12:00:00 AM                 1                700            712
6 1503960366 4/19/2016 12:00:00 AM                 1                304            320
```

We can also use  `colnames()` to view the column headers for each data frame to check if there are any formatting issues that need to be addressed. We can see that column names in the `weightLogInfo_merged` data frame will need to be changed from camel case to snake case to align with R’s naming conventions.

```> colnames(weightLogInfo_merged)
[1] "Id"             "Date"           "WeightKg"       "WeightPounds"   "Fat"           
[6] "BMI"            "IsManualReport" "LogId"  
```

Since each data frame has an `id` column that must be linked to a FitBit user, let's check  the number of unique ids which will indicate the number of actual participants in our sample group.  

```
activity_ids <- n_distinct(dailyActivity_merged$Id)
print(activity_ids)
[1] 33

sleep_ids <- n_distinct(sleepDay_merged$Id)
print(sleep_ids)
[1] 24

weight_ids <- n_distinct(weightLogInfo_merged$Id)
print(weight_ids)
[1] 8
```

Due to the smaller sample size from the `weightLogInfo_merged` data frame, we will not be joining it to the other data sets in order to not introduce sampling bias.

Below is a summary of the data cleansing steps we’ll conduct to transform our raw, unclean data into processed data for analysis.

<h3><b>Data Cleaning</b></h2>
Below is a summary of the data cleansing steps we’ll conduct to transform our raw, unclean data into processed data for analysis.
<p>

*  Use the `clean_names()` function to format column names to camelcase.
```
daily_activity <- clean_names(dailyActivity_merged)
daily_sleep <- clean_names(sleepDay_merged)
```
<br>

*  Use the `as_Date()` function to format dates from a string data type to a Date object. Then use the `weekdays()` function to extract the day of the week from it and assign it to a new column named `weekday`. Use the `ordered()` function to create an ordered factor where the days are ordered chronologically instead of alphabetically.</p>

```
daily_activity <- daily_activity %>%
  rename(date = activity_date) %>%
  mutate(date = as_date(date, format = "%m/%d/%Y")) %>%
  mutate(weekday = weekdays(date)) %>% 
  mutate(weekday = ordered(weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday","Friday", "Saturday", "Sunday")))
```
<br>

*  Split the `sleep_day column` in the daily_sleep data frame into an `hour` column and a `date` column.

```
daily_sleep <- daily_sleep %>%
  separate(sleep_day, c("date", "hour"),sep = "^\\S*\\K") %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))
```

<br>

*  Add a new `min_fall_asleep`  column that calculates the time it takes for participants to fall asleep. We will subtract `total_minutes_asleep` from `total_time_in_bed`.

```
daily_sleep <- daily_sleep %>%
  mutate( 
    min_fall_asleep = total_time_in_bed - total_minutes_asleep
  )
```
<br>

*  Use `distinct()` and `drop_na()` functions to remove duplicate rows and NA values.

```
daily_activity <- daily_activity %>%
  distinct() %>%
  drop_na()

daily_sleep <- daily_sleep %>%
  distinct() %>%
  drop_na()
```

<br>

*  Exclude records that show 0 calories burned and 0 steps walked for entries which could indicate that the participant didn’t wear their Fitbit or the tracker was defective in capturing their step count and calories burned.

```
daily_activity <- daily_activity %>%
  filter(calories > 0 & total_steps > 0)
```

<br>
After processing our data, we are now ready to merge the data frames to better understand the relationship between different dimensions such as sleep, activity level, and total steps. Let’s perform a `merge()` based on the common `id` and `date` columns. Specifically, we’ll perform a left join so that the resulting daily_df data frame will include all rows from the `daily_activity` data frame and only the matching rows from the `daily_sleep` data frame.

```
daily_df <-
  merge(
    x = daily_activity, 
    y = daily_sleep,
    by = c ("id", "date"),
    all.x = TRUE
  )
```


