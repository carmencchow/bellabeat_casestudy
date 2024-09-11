<h1>Bellabeat Case Study</h1>
<p>Carmen Chow</p> 
<p>September 2024</p>

<h2>Scenario</h2>
<p>Bellabeat is a high-tech manufacturer of health-focused products for women.  Since it was founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women.  Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. Sršen knows that an analysis of Bellabeat’s available consumer data would reveal more opportunities for growth. She has asked the marketing analytics team to focus on a Bellabeat product and analyze smart device usage data in order to gain insight into how people are already using their smart devices. Then, using this information, she would like high-level recommendations for how these trends can inform Bellabeat marketing strategy.</p>

<h2>Stakeholders</h2>
<p>*  Urška Sršen: Bellabeat’s cofounder and Chief Creative Officer</p>
<p>*  Sando Mur: Mathematician and Bellabeat’s cofounder</p>
<p>*  Bellabeat marketing analytics team: A team of data analysts responsible for collecting, analyzing, and reporting data that helps guide Bellabeat’s marketing strategy. </p>

<h2>1. Ask</h2>
<h3><b>Business Task</b></h3>
Analyze FitBit’s Fitness Tracker usage data to gain insight into trends that can be applied to Bellabeat’s customers. 

<h3>Guiding questions</h3>
<p><i><b>What are some trends in smart device usage?</b></i></p>
<p>How could these trends apply to Bellabeat customers?</p> 
<p>How could these trends help influence Bellabeat marketing strategy?</p>

<h2>2. Prepare</h2>

<h3><b>Data Source</b></h3>
<p>The publicly available FitBit Fitness Tracker Data (https://www.kaggle.com/arashnic/fitbit)
includes data from 33  fitbit users who consented to the submission of personal tracker data, including information about daily physical activity, steps, calories burned, and sleep monitoring. The dataset is provided under the Mobius license and consists of 18 wide format CSV files of anonymized user information.</p>

<h3><b>Data Limitations</b></h3>
<p>*  Some of the data sets have a sample size of 33 FitBit users, while the data for weight had an even smaller sample size of 8.</p>
<p>*  Data is 8 years old there not current. It covers a one month period from 2016-04-12 to 2016-05-12.</p>
<p>*  Information about how long each participant wore their Fitbit is missing.</p>
<p>*  Demographic information pertaining to the ages of the participants is also missing.</p>

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
Open R Studio and run the `read_csv()` R command to read each CSV file and save it as a data frame in R:

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
Below is a summary of the data cleansing steps we’ll conduct to transform our raw, unclean data into processed data for analysis:

<br>
          
*  Use the `clean_names()` function to format column names to camelcase.

```
daily_activity <- clean_names(dailyActivity_merged)
daily_sleep <- clean_names(sleepDay_merged)
```
          
*  Use the `as_Date()` function to format dates from a string data type to a Date object. Then use the `weekdays()` function to extract the day of the week from it and assign it to a new column named `weekday`. Use the `ordered()` function to create an ordered factor where the days are ordered chronologically instead of alphabetically.</p>

```
daily_activity <- daily_activity %>%
  rename(date = activity_date) %>%
  mutate(date = as_date(date, format = "%m/%d/%Y")) %>%
  mutate(weekday = weekdays(date)) %>% 
  mutate(weekday = ordered(weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday","Friday", "Saturday", "Sunday")))
```

*  Split the `sleep_day column` in the daily_sleep data frame into an `hour` column and a `date` column.

```
daily_sleep <- daily_sleep %>%
  separate(sleep_day, c("date", "hour"),sep = "^\\S*\\K") %>%
  mutate(date = as.Date(date, format = "%m/%d/%Y"))
```

*  Add a new `min_fall_asleep`  column that calculates the time it takes for participants to fall asleep. We will subtract `total_minutes_asleep` from `total_time_in_bed`.

```
daily_sleep <- daily_sleep %>%
  mutate( 
    min_fall_asleep = total_time_in_bed - total_minutes_asleep
  )
```
*  Use `distinct()` and `drop_na()` functions to remove duplicate rows and NA values.

```
daily_activity <- daily_activity %>%
  distinct() %>%
  drop_na()

daily_sleep <- daily_sleep %>%
  distinct() %>%
  drop_na()
```
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

<h2>4. Analyze </h2>

Now that we’ve finished cleaning our data, it’s time to move on to the analysis part of the process. We’ll run the `summary()` function to get an overview of our new dataset’s distribution: 

```
  total_steps    total_distance     calories    total_minutes_asleep
 Min.   :    4   Min.   : 0.00   Min.   :  52   Min.   : 58.0       
 1st Qu.: 4923   1st Qu.: 3.37   1st Qu.:1856   1st Qu.:361.0       
 Median : 8053   Median : 5.59   Median :2220   Median :432.5       
 Mean   : 8319   Mean   : 5.98   Mean   :2361   Mean   :419.2       
 3rd Qu.:11092   3rd Qu.: 7.90   3rd Qu.:2832   3rd Qu.:490.0       
 Max.   :36019   Max.   :28.03   Max.   :4900   Max.   :796.0       
                                                NA's   :453
```
```
 sedentary_minutes lightly_active_minutes fairly_active_minutes very_active_minutes
 Min.   :   0.0    Min.   :  0.0          Min.   :  0.00        Min.   :  0.00     
 1st Qu.: 721.5    1st Qu.:146.5          1st Qu.:  0.00        1st Qu.:  0.00     
 Median :1021.0    Median :208.0          Median :  8.00        Median :  7.00     
 Mean   : 955.8    Mean   :210.0          Mean   : 14.78        Mean   : 23.02     
 3rd Qu.:1189.0    3rd Qu.:272.0          3rd Qu.: 21.00        3rd Qu.: 35.00     
 Max.   :1440.0    Max.   :518.0          Max.   :143.00        Max.   :210.00     
 moderate_vigorous_minutes
 Min.   :  0.00           
 1st Qu.:  0.00           
 Median : 26.00           
 Mean   : 37.79           
 3rd Qu.: 61.00           
 Max.   :275.00
```
<br>

<i>Some key numbers:</i>

<br>

*  <b>8,319</b> - the average number of steps taken per day. This number falls below the recommended 10,000 steps. Moreover, the 1st Qu. results show that 25% of participants averaged less than 4,923 steps a day.
<br>
*  <b>5.98</b> kilometers - the average distance walked per day. 
<br>
*  <b>210.0</b> - the average number of minutes being lightly active  
*  <b>14.78</b> - the average number of minutes being fairly active 
*  <b>23.02</b> - the average number of minutes being very active 
<br>
*  <b>15.9 hours</b> (or 955.8 minutes) - the average amount of time spent sedentary. 
<br>
*  <b>2,361</b> - the average number of calories burned per day, which equates to approximately 98.3 calories burned per hour.

<br>

<p>We’ll use the installed `ggplot2` package to create several customizable graphs to help us visualize and establish different relationships and correlation between our sleep, activity level, step count, and calories burned dimensions. We’ll focus our visualizations on the key health indicators of Physical Activity (step count and moderate to vigorous activity), Sedentary Behaviour and Sleep. </p>

<br>
<p><i><b>i) Physical Activity (Step Count)</b></i></p>
Let’s take a look at the relationship between daily step count and daily calories burned. 

<br>

![calories](https://github.com/user-attachments/assets/d77ea900-2d68-4e6d-9a6f-3674a9428630)

Not surprisingly, the chart shows a strong positive correlation between calories burned and the number of steps walked, which iswhich is a good thing as step count has been linked to a reduction in mortality rates discussed in this journal article. Let’s see if the day of the week affects the step count.  

<p>For general fitness and overall health, 10,000 steps is usually touted as the recommended number of steps for adults. Let’s see if the day of the week has any impact on our participants’ total daily step count.</p>

```
steps_by_day <- daily_df %>%
  group_by(weekday) %>%
  summarise(steps = sum(total_steps)) %>%
  arrange(desc(steps))
print(steps_by_day)
```
Tuesday seems to be the day in which users walked the most. 

```
  weekday     steps
  <ord>       <dbl>
1 Tuesday   1235001
2 Wednesday 1133906
3 Thursday  1088658
4 Saturday  1010969
5 Friday     938477
6 Monday     933704
7 Sunday     838921
```
<br>

![avcals](https://github.com/user-attachments/assets/2a700a3c-5b31-4887-9330-44074d9063b9)

<br>

We would expect the order of the days to be identical or fairly similar to the days that had the highest step count. In fact, with the exception of Tuesday, they aren’t. This is likely because the calories burned per day do not come only only from the calories burned from the total steps recorded, but also from other physical activity (which could include non-steps like swimming, calisthenics, or weight training etc.) which contribute to your daily calories burned but not your step count. Other calories burned in a day include your <b>Basal Metabolic Rate (BMR)</b> which is the number of calories your body needs to perform basic functions and <b>NEAT</b> or <i>non-exercise activity thermogenesis</i>, which is the calories burned through daily activity that does not include intentional physical exercise (e.g. fidgeting, cooking).  Although the average calories doesn’t differ greatly, Tuesdays and Saturdays edge out the other days with the most number of steps recorded. However, when we take into account that the difference between the highest average, <i>2441</i> and the lowest average, <i>2274</i> is a mere 167 steps and the average person walks around 100 steps per minute. 

Since the daily calories burned throughout the week do not differ significantly from day to day, let’s bring in the `hourlySteps_merged.csv` and see if there are any hourly trends that show when users are most active. We’ll create a data frame for it and perform the same data cleansing steps outlined in the <b>Process</b> part of this analysis. The data frame also has `33 id`s and using `head()` we’ll take a look at the first 6 rows.

```
          id activity_hour         step_total
       <dbl> <chr>                      <dbl>
1 1503960366 4/12/2016 12:00:00 AM        373
2 1503960366 4/12/2016 1:00:00 AM         160
3 1503960366 4/12/2016 2:00:00 AM         151
4 1503960366 4/12/2016 3:00:00 AM           0
5 1503960366 4/12/2016 4:00:00 AM           0
6 1503960366 4/12/2016 5:00:00 AM           0
```

We will perform an additional step using the `separate()` function to split the `activity_hour` column into two separate columns, one for  `date` and one for `hour` which results in this table: 

```
           id date      hour           step_total
        <dbl> <chr>     <chr>               <dbl>
 1 1503960366 4/12/2016 " 12:00:00 AM"        373
 2 1503960366 4/12/2016 " 1:00:00 AM"         160
 3 1503960366 4/12/2016 " 2:00:00 AM"         151
 4 1503960366 4/12/2016 " 3:00:00 AM"           0
 5 1503960366 4/12/2016 " 4:00:00 AM"           0
 6 1503960366 4/12/2016 " 5:00:00 AM"           0
 7 1503960366 4/12/2016 " 6:00:00 AM"           0
 8 1503960366 4/12/2016 " 7:00:00 AM"           0
 9 1503960366 4/12/2016 " 8:00:00 AM"         250
10 1503960366 4/12/2016 " 9:00:00 AM"        1864
```

Let’s take a look at the distribution of total steps taken among the 33 participants. We can see there were more than 90 records of users getting the 10,000 recommended daily steps. We have a right skewed graph due to a number of participants who took more than the average number of steps on certain days, with a number even logging an astounding more 30,000 steps which is more three times the recommended number.

![stepcount](https://github.com/user-attachments/assets/caaa6899-74a3-4779-843c-bab3b102c2bd)

However, despite abnormally high number of steps from some above average active participants, we also see that 50% of participants are getting less than 8319 steps a day or less than the recommended daily step count. 
Let’s see if the time of day has an affect on our participant’s activity levels by We’ll use the `summarize()` and `arrange()` functions to order the daily average steps from highest to lowest to find peak hours of activity:


```
avg_steps <- hourly_steps %>%
  group_by(hour) %>%
  summarize(avg_steps = mean(step_total)) %>%
  mutate(avg_steps = as.integer(avg_steps)) %>%
  arrange(desc(avg_steps)) 
```

<br>

And plotting the average number of steps to the time of day in hours shows:

We see that the highest average number of steps was recorded between 5:00 and 7:00 PM, peaking at 6:00 PM with 599 average steps. With the next highest period of time being in the afternoon between 12–2 PM. We could speculate that these peaks in activity could coincide with lunchtime and after work workout/activity

<br>

![steps](https://github.com/user-attachments/assets/f0ca58e4-d9d4-44c7-8125-d3f841aee601)

<i><b>ii) Physical Activity (Moderate to Vigorous Activity)</b></i>
Let’s shift our focus to physical activity levels and their effect on calories burned in a 24-hour period. 

<br>

![very](https://github.com/user-attachments/assets/0d294861-b0e4-4a90-8c07-badbf67ebf80)

<br>

![lightly](https://github.com/user-attachments/assets/6801e5d2-43b6-454e-b85d-ec6a363f7025)

<br>

![sed_cals](https://github.com/user-attachments/assets/bc00bd6e-0be0-4e65-b9fd-2532a71bde11)

<br>

Beginning with the first scatterplot we can see a fairly strong positive relationship between the minutes of vigorous activity and total calories burned. In other words, calories burned increase with prolonged minutes of vigorous activity. Although the correlation is not as strong, we can see the positive impact even lightly vigorous activity has on calories burned. Examining the last graph, it is interesting to note that with the last scatterplot, there is a marked downturn after 1000 minutes of being sedentary.

Since the WHO’s recommendation calls for <b>150 to 300 minutes</b> of <i>moderate to vigorous aerobic activity</i> per week, we can combine the `fairly_active_minutes` and `very_active_minutes` columns into a new column called `moderate_vigorous_minutes`. We’ll plot a histogram to show the frequency of moderate to vigorous minutes over the span of a month. Let’s view the updated summary statistics to include this new column and use it to see the effects of moderate to vigorous activity on calories burned. 

```  
 very_active_minutes moderate_vigorous_minutes
 Min.   :  0.00      Min.   :  0.00           
 1st Qu.:  0.00      1st Qu.:  0.00           
 Median :  7.00      Median : 26.00           
 Mean   : 23.02      Mean   : 37.79           
 3rd Qu.: 35.00      3rd Qu.: 61.00           
 Max.   :210.00      Max.   :275.00
```

![modvig](https://github.com/user-attachments/assets/711ab08c-e267-4708-ab8e-852adc4b7bde)

We see a disproportionately high count of participants recording 0 minutes of moderate to vigorous minutes of activity per day. With a frequency of 300 for 33 users across the span of a month, this translates to ⅓ of the time! With the median being 26 minutes and the mean is 37.8 minutes. This tells us that 50% of the participants have 26 minutes or less of moderate to vigorous activity with the average time being 37.8 minutes. We have a right-skewed, while there are a few participants with significantly higher activity times compared to the rest, there is a huge number of participants who get 0 minutes a day!

<br>
<b><i>iii) Sedentary Behavior</i></b>

<br>
<p>Let’s take a look at the distribution of sedentary minutes in a day. The histogram shows us the median is 1021 minutes or 17.02 hours and the mean is 955.9 minutes or 15.93 hours. We have a couple of outliers, for example someone got 0 minutes of sedentary activity a day, is that possible?? We see a histogram with two distinct peaks where the majority of participants are getting between 600 and 900 and 1000 and 1300 minutes of non-activity.</p>

![sedentary](https://github.com/user-attachments/assets/66ccbf2d-b4a4-46fc-95d9-e1265d9b1e6e)

<b><i>iv) Sleep</i></b>
<p>Just like our exploration of activity levels and the day of the week, let’s see if sleep patterns are consistent throughout the week. Once again, we’ll use `summary()` to get an overview of the distribution of sleep times from our `daily_df` data frame. </p>

```
 total_minutes_asleep total_time_in_bed min_fall_asleep 
 Min.   : 58.0        Min.   : 61.0     Min.   :  0.00  
 1st Qu.:361.0        1st Qu.:403.8     1st Qu.: 17.00  
 Median :432.5        Median :463.0     Median : 25.50  
 Mean   :419.2        Mean   :458.5     Mean   : 39.31  
 3rd Qu.:490.0        3rd Qu.:526.0     3rd Qu.: 40.00  
 Max.   :796.0        Max.   :961.0     Max.   :371.00  
 NA's   :453          NA's   :453       NA's   :453
```
<i>Key Numbers</i> 
*  <b>6.9 hours</b> (or 419.5 minutes) - the average sleep time.
*  <b>39.17 mins</b> - the average time needed to fall asleep.
*  25% of participants are sleeping <b>6 hours</b> or less (361 minutes or less). 
*  The shortest sleep time recorded was 58 minutes while the highest was 796 minutes.

![minsleep](https://github.com/user-attachments/assets/8265026e-b607-4d38-8560-93dfc9ccbc59)

<br>
From the histogram we see the most common range of sleep. It looks like there are more people sleeping less than the average. It looks like some people are sleeping significantly more than recommended, with 800 minutes (13.3 hours of sleep). We see that the distribution is slightly skewed to the right (?) Mean 419.2 minutes and median is 432.5 minutes We see the graph shows that that 50% of people get at least 7.21 hours of sleep.

<br>
<p>
![sleep](https://github.com/user-attachments/assets/c0bd916d-3834-4c3e-8571-741ff1c3e78d)
</p>
<br>
Participants got the most hours of sleep on Sunday and Wednesday.
Let’s explore the relationship between activity level and total minutes of sleep with these graphs where I’ve plotted the different intensity levels on the y-axis to the minutes of sleep on the left axis. Red (sedentary), purple (lightly active), blue (moderately active), and yellow (very active). Looking at the graphs, we can see a negative correlation between Sedentary Minutes and Sleep chart shows a positive correlation when mapping the minutes of very active minutes and sleep, and in the first graph we see that the more minutes a participant spends doing sedentary activity, the fewer minutes of sleep they get.

<br>

![sedentary](https://github.com/user-attachments/assets/1ab3e6c1-0280-4987-a89b-7f99ddabc24d)

![lightly_sleep](https://github.com/user-attachments/assets/90986f51-c931-41bf-96d7-f3b519e6f8ef)

![farily](https://github.com/user-attachments/assets/b2d70e34-8818-48a6-88b5-1f28a6bae33f)

![very_sleep](https://github.com/user-attachments/assets/436e1782-e8a1-4865-af88-ada47368367d)

<b>Final Summary</b>
Let’s summarize our results for the four metrics before making our recommendations to the marketing team:

*  50% of participants take less than 8,053 steps per day and 25% take less than 4,923.
*  50% of participants sleep less than 7.2 hours a day.
*  50% of participants are sedentary for more than 15.9 hours a day.
*  50% of participants get less than 26 minutes of moderate to vigorous activity a day while a startling high number of participants recorded 300 counts of <i>0 minutes of moderate to vigorous activity</i> or roughly ⅓ of the month.

<h2>5. Share</h2>
Link to the Google Slide deck here: 

<h2>6. Act</h2>
