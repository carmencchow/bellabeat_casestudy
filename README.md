<h1>Bellabeat Case Study  🚶🏾‍♀️⌚</h1>
<p>Carmen Chow</p> 
<p>September 2024</p>

<h2>Background</h2>
<p>Bellabeat is a high-tech manufacturer of health-focused products for women.  Founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women.  Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. Sršen knows that an analysis of Bellabeat’s available consumer data would reveal more opportunities for growth. She has asked the marketing analytics team to focus on a Bellabeat product and analyze smart device usage data in order to gain insight into how people are already using their smart devices. Then, using this information, she would like high-level recommendations for how these trends can inform Bellabeat marketing strategy.</p>

<h2>Stakeholders</h2>
<p>*  Urška Sršen: Bellabeat’s cofounder and Chief Creative Officer</p>
<p>*  Sando Mur: Mathematician and Bellabeat’s cofounder</p>
<p>*  Bellabeat marketing analytics team: A team of data analysts responsible for collecting, analyzing, and reporting data that helps guide Bellabeat’s marketing strategy. </p>

<h2>Ask</h2>
<h3><b>Business Task</b></h3>
Analyze smart device fitness data to gain insights into trends that can be applied to Bellabeat customers. 

<h2>Prepare</h2>

<h3><b>Data Source</b></h3>
We will look at publicly available Fitbit Fitness Tracker Data from 30 Fitbit users who consented to the submission of personal tracker data. The data points include daily physical activity, step count, calories burned, and hours slept. The dataset, provided under the Mobius license, consists of 18 wide format CSV files of anonymized user information. Link to data: https://www.kaggle.com/arashnic/fitbit .

<h3><b>Data Bias and Credibility. Does it ROCCC?</b></h3>
<p><b>R</b>eliable - Low; the data is from only 30 participants
<p><b>O</b>riginal - Low; the data was collected by a third-party provider, Amazon Mechanical Turk
<p><b>C</b>omprehensive - Medium, various data points unavailable (e.g. fitness level, age, gender ...)  
<p><b>C</b>urrent - Low; the data is from April to May 2016, making it over 8 years old.
<p><b>C</b>ited - Low; the dataset is available via Mobius on Kaggle
          
<h3><b>Data Limitations</b></h3>
<p>*  Some data sets have a small sample size of 33 Fitbit users, while the weight data has an even smaller sample size of 8.</p>
<p>*  The data is over 8 years old and therefore no longer current. 
<p>*  Details on how long participants wore their Fitbit throughout the day are missing. </p>
<p>*  Key information, such as the age, gender, and overall health of the participants, is also missing.</p>

<h3><b>R packages and libraries</b></h3>
<p>We’ll be using R for our data analysis and data visualization. Let’s start by installing and running the following R packages: 

```
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
```

Out of the 18 available files, we’ll focus on 3. The remaining files either contain information outside the scope of the Business Task or duplicate data that is already found in `dailyActivity_merged.csv`.

```
dailyActivity_merged.csv
sleepDay_merged.csv
weightLogInfo_merged.csv

```

<h2>Process</h2>
In R Studio we'll read and save each CSV file as a data frame:

```
dailyActivity_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
sleepDay_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
weightLogInfo_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")
```

We'll use `ls()` to check that the files have been correctly imported correctly in the environment pane of R Studio. Then we'll use `head()` to return the first few rows of each data frame. Here are the first six rows of the `sleepDay_merged` data: 

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

We'll use `colnames()` to view the column headers to check if there are any formatting issues that need to be addressed. We can see that column names in the `weightLogInfo_merged` data frame will need to be changed from camel case to snake case to align with R’s naming conventions.

```> colnames(weightLogInfo_merged)
[1] "Id"             "Date"           "WeightKg"       "WeightPounds"   "Fat"           
[6] "BMI"            "IsManualReport" "LogId"  
```

Since each data frame has an `id` column that must be linked to a Fitbit user, let's check  the number of unique ids which will indicate the number of participants in our sample group.  

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

Due to the smaller sample size from the `weightLogInfo_merged` data frame, we will not be joining it to the other data sets to avoid sampling bias.

Below is a summary of the data cleansing steps we’ll conduct to transform our raw, unclean data into processed data for analysis.

<h3><b>Data Cleaning</b></h2>

*  Use the `clean_names()` function to format column names to camelcase.

```
daily_activity <- clean_names(dailyActivity_merged)
daily_sleep <- clean_names(sleepDay_merged)
```
          
*  Use `as_Date()` function to format dates from a string data type to a Date object. Use `weekdays()` to extract the day of the week and assign it to a new variable named `weekday`. Use the `ordered()` function to create an ordered factor where the days are ordered chronologically instead of alphabetically.</p>

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

*  Add a new `min_fall_asleep`  column that calculates the time it takes for participants to fall asleep by subtracting `total_minutes_asleep` from `total_time_in_bed`.

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
*  Exclude records that show 0 calories burned and 0 steps. These results could be due to participants failing to wear their tracker or and indication that the tracker was defective in capturing their step count and calories burned on that day.

```
daily_activity <- daily_activity %>%
  filter(calories > 0 & total_steps > 0)
```

<br>

After processing our data, we are now ready to merge the data frames to better understand the relationship between different dimensions such as sleep, activity level, and total steps. Let’s perform a `merge()` based on the common `id` and `date` columns. Specifically, we’ll perform a left join so that the resulting daily_df data frame will include all the rows from the `daily_activity` data frame and only the matching rows from the `daily_sleep` data frame.

```
daily_df <-
  merge(
    x = daily_activity, 
    y = daily_sleep,
    by = c ("id", "date"),
    all.x = TRUE
  )
```

<h2>Analyze & Share </h2>

Let's run the `summary()` function to get an overview of our new dataset’s distribution: 

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

<i>Key takeaways:</i>
<p>
*  <b>8,319</b> - the average number of steps taken per day. This number falls below the recommended 10,000 steps. Moreover, the 1st Qu. results show that 25% of participants averaged less than 4,923 steps a day.
*  <b>5.98</b> kilometers - the average distance walked per day. 
*  <b>210.0</b> - the average number of minutes being lightly active  
*  <b>14.78</b> - the average number of minutes being fairly active 
*  <b>23.02</b> - the average number of minutes being very active 
*  <b>15.9 hours</b> (or 955.8 minutes) - the average amount of time spent sedentary.
*  <b>2,361</b> - the average number of calories burned per day, which equates to approximately 98.3 calories burned per hour.

<br>

We’ll use the installed `ggplot2` package to create several graphs to help us visualize and determine if there are positive or negative relationships between different variables. 

<p><i><b>i) Physical Activity (Step Count)</b></i></p>
Let’s take a look at the relationship between daily step count and daily calories burned. 

<p>

![calories](https://github.com/user-attachments/assets/d77ea900-2d68-4e6d-9a6f-3674a9428630)

As expected, the chart shows a strong positive correlation between calories burned and the number of steps walked. We can understand why walking 10,000 steps a day is widely recommended due to it's calorie-burning ability(?) which has positive health benefits like reversing heart disease (article link).

Let’s see if the day of the week has any impact on our participants’ total daily step count.</p>

```
steps_by_day <- daily_df %>%
  group_by(weekday) %>%
  summarise(steps = sum(total_steps)) %>%
  arrange(desc(steps))
print(steps_by_day)
```
Tuesday seems to be the day when Fitbit users walked the most. 

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

Let's take a look at average calories burned throughout the week. We would expect the order of the days to be identical or fairly similar to the days that had the highest step count. In fact, with the exception of Tuesday, they aren’t. Why?

Calories burned is likely an aggregate of calories burned through physical activity (step and non-step activities like swimming or weight training), calories burned while performing basic funcions (Basal Metabolic Rate), and calories burned through non-exercise activity thermogenesis (NEAT) like fidgeting. 

![avcals](https://github.com/user-attachments/assets/2a700a3c-5b31-4887-9330-44074d9063b9)

<br>
Although the average calories don't change much day to day, our data shows a slight increase in calories burned on Tuesday and Saturday. At this point, we'll bring in the `hourlySteps_merged.csv` to see if there are any hourly trends that show when users are most active. We’ll create a data frame and perform the same data cleansing steps outlined in the <b>Process</b> part of this analysis. We see that the `hourlySteps_merged` data frame also has `33 id`s. Let's examine the first 6 rows.

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

We'll perform an additional cleaning step using the `separate()` function to split the `activity_hour` column into two separate columns, one for  `date` and one for `hour`:  

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

Now, we'll take a look at the distribution of total steps taken among the 33 participants. We can see there were more than 90 records of users getting the 10,000 recommended daily steps from 2016-04-12 to 2016-05-12. Graphing the frequency of steps taken results in a right skewed graph due to a number of participants who took more than the average number of steps on certain days, with a participant even logging nearly 36,000 steps in a single day, which is more three times the recommended number.

![stepcount](https://github.com/user-attachments/assets/caaa6899-74a3-4779-843c-bab3b102c2bd)

Despite the high step count from these highly active participants, notice that 50% of participants are getting less than 8,319 steps a day or less than the recommended daily step count of 10,000 steps.

Let's see when the participants are walking the most in a day. We’ll use the `summarize()` and `arrange()` functions to order the daily average steps from highest to lowest to find peak hours of activity:


```
avg_steps <- hourly_steps %>%
  group_by(hour) %>%
  summarize(avg_steps = mean(step_total)) %>%
  mutate(avg_steps = as.integer(avg_steps)) %>%
  arrange(desc(avg_steps)) 
```

<br>

We see that the highest average step count is between 5pm and 7pm, peaking at 6 pm with 599 average steps. The next period of high step count happens in the afternoon between 12 and 2 pm. 


<br>

![steps](https://github.com/user-attachments/assets/f0ca58e4-d9d4-44c7-8125-d3f841aee601)

<i><b>ii) Physical Activity (Moderate to Vigorous Activity)</b></i>
<p>Let’s shift our focus to physical activity levels and their effect on the total number of calories burned per day. 
          
<br>

![very](https://github.com/user-attachments/assets/0d294861-b0e4-4a90-8c07-badbf67ebf80)

<br>

![lightly](https://github.com/user-attachments/assets/6801e5d2-43b6-454e-b85d-ec6a363f7025)

<br>

![sed_cals](https://github.com/user-attachments/assets/bc00bd6e-0be0-4e65-b9fd-2532a71bde11)

<br>

Beginning with the first scatterplot, we can see a strong positive correlation between minutes of vigorous activity and total calories burned. We can expect people who spend more time participating in vigorou s activity to generally burn more calories throughout the day. Although  not as strong, the positive correlation continues even for light activities. With sedentary behavior, the positive correlation experiences a marked downtown after 1000 minutes sedentary activity.

Since the WHO’s recommendation calls for <b>150 to 300 minutes of moderate to vigorous aerobic activity per week</b>, we'll create a `moderate_vigorous_minutes` variable that combines fairly active and very active minutes together.  We’ll plot a histogram to show the frequency of moderate to vigorous minutes over the span of a month. We'll also view the updated summary statistics to include this new column. 

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

We see a worryingly disproportionately high count of participants recording 0 minutes of moderate to vigorous activity on <b>300 occasions</b>. Since our data looks at 33 participants over 4 weeks, these equates to roughly <b>one-third of the month!</b>

```
33 participants x 7 days a week x 4 weeks = 924 total occasions in a month

300/924 x 100 = 32.47%
```

Our right-skewed histogram show several occasions when participants had hours of moderate to vigorous activity, however the histogram also tells us that 50% of the participants had 26 minutes or less of moderate to vigorous activity with the average time being 37.8 minutes. 

<br>
<b><i>iii) Sedentary Behavior</i></b>
<p>
<p>Let’s take a look at the distribution of sedentary minutes in a day. The histogram below shows us the median is 1021 minutes which means 50% of participants are sedentary for at least 17.02 hours, while the majority of participants seem to be getting somewhere between 600 and 1200 minutes (or 10-20 hours) of non-activity.</p>

![sedentary](https://github.com/user-attachments/assets/66ccbf2d-b4a4-46fc-95d9-e1265d9b1e6e)

<b><i>iv) Sleep</i></b>
<p>
Let’s see what the data tells us about our participants sleep patterns and whether they are getting the recommended 7 or more hours of sleep. We’ll use the  `summary()` function to get an overview of the distribution of sleep times from our `daily_df` data frame. 
</p>

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
<i>Key takeaways</i> 
*  <b>6.9 hours</b> (or 419.5 minutes) - the average sleep time.
*  <b>39.17 mins</b> - the average time needed to fall asleep.
*  25% of participants are sleeping <b>6 hours</b> or less (361 minutes or less). 
*  The shortest sleep time recorded was 58 minutes while the highest was 796 minutes.

![minsleep](https://github.com/user-attachments/assets/8265026e-b607-4d38-8560-93dfc9ccbc59)

<br>
The National Sleep Foundation recommends 7 to 9 hours of sleep for young adults and adults. The histogram aboves shows that 50% of participants are getting 7.2 hours (432.5 minutes) or more of sleep. Half of the participants are not getting the recommended minimum, while a few are sleeping more than 9 hours. They also tend to sleep longer on weekends and Wednesdays.

<br>
<p>

![sleep](https://github.com/user-attachments/assets/c0bd916d-3834-4c3e-8571-741ff1c3e78d)

</p>
<br>

Let's see the impact of different activity levels on total minutes of sleep visualized in the following 4 scatterplots:

<p>

![sedentary](https://github.com/user-attachments/assets/1ab3e6c1-0280-4987-a89b-7f99ddabc24d)

![lightly_sleep](https://github.com/user-attachments/assets/90986f51-c931-41bf-96d7-f3b519e6f8ef)

![farily](https://github.com/user-attachments/assets/b2d70e34-8818-48a6-88b5-1f28a6bae33f)

![very_sleep](https://github.com/user-attachments/assets/436e1782-e8a1-4865-af88-ada47368367d)

We see that sedentary minutes negatively impact sleep duration: more time spent being inactive means less time spent asleep. Sleep duration improves with more time spent engaging in moderatly active and very active activities. 

<h3><b>Final Summary</b></h3>

*  50% of participants take less than 8,053 steps per day and 25% take less than 4,923.
*  50% of participants sleep less than 7.2 hours a day.
*  50% of participants are sedentary for more than 15.9 hours a day.
*  50% of participants get less than 26 minutes of moderate to vigorous activity a day
* 0 minutes of moderate to vigorous activity for 1/3 of the month 

<h2>Act</h2>

<p>Before making our recommendations for Bellabeat's marketing strategy, we should remind ourselves of the limitations this non-ROCCC dataset presents. Moving forward, Bellabeat should collect first-party data provided by actual customers who are wearing their fitness tracker for a specified number of hours. 
          
However, based on our findings, we can make the following recommendations to enhance user engagement and help users get the most out of their Bellabeat product 

* <b>AI Integration</b>
* Adding an AI feature to the Leaf and Tracker app will enable users better understand and interpret health data. This could inclue an AI health chatbot that answers questions and reports on users' health data. Users can interacat work with the AI to set and suggest workout, make recommendations and modifications to their plans etc.
            - Coaching - generate personalized workouts
            - Reporting - analyzing and interpreting health reports
            - Motivating - include daily affirmations or reminders
            - Goal Settings - recommend goals

* Communicate to Bellabeat customers the importance of limiting the number of sedentary hours and increasing the minutes of moderate to vigorous activity so they are meeting the recommended 150-300 minutes every week. The AI chatbox can also provide two individualized fitness tracks tailored to individual needs. One track could offer moderate levels of exercise while the other more vigorous activites. Users can then customize their workout based on their goals.
 
* <b>Workout ideas</b>
Bellabeat can introduce short workouts with the messaging "Every Move Counts" in reference to the World Health Organization's Every Move Counts initiative: https://www.who.int/news-room/events/detail/2020/11/26/default-calendar/webinar-who-2020-guidelines-on-physical-activity-and-sedentary-behaviour. The campaign coud be 

* <b>Special Features</b>
To incentive users, Bellabeat users who meet their daily step count or their 150-300 minutes of daily moderate-vigorous exercise can unlock exclusive features or be invited to participate in virtual fitness challenges. Dynamic leaderboards where users can see their progres in real time. 

* <b>Notifications and Reminders</b>
High sedentary behaviour was observed in over half of the sample population for a third of the month. Bellabeat should communicate the dangers of prolonged sedentary activity and should implement a notification that alerts users when no activity has been detected for a set amount of time.
 
* Sleep: Gamify the experiene - challenge users to achieve the perfect sleep score. Set a reminder for users to start winding down - blue light, turn off technology.

<h2>References</h2>
National Sleep Foundation <p>https://pubmed.ncbi.nlm.nih.gov/29073398/#:~:text=Seven%20to%209%20hours%20is,is%20recommended%20for%20older%20adults 

<p>World Health Organization Physical Activity 
<p>https://www.who.int/initiatives/behealthy/physical-activity#:~:text=Should%20do%20at%20least%2060,least%203%20times%20per%20week.

<p>World Health Organization Every Move Counts - Launch of the new WHO Guidelines on Physical Activity and Sedentary Behaviours</p>
https://www.who.int/news-room/events/detail/2020/11/26/default-calendar/webinar-who-2020-guidelines-on-physical-activity-and-sedentary-behaviour

<p>How Many Steps Should you Take a Day</p>
https://www.medicalnewstoday.com/articles/how-many-steps-should-you-take-a-day

<p>Google Expands It's Al Footprint in Healthcare with Fitbit Chatbot - Coming Soon</p>
https://www.techtimes.com/articles/302750/20240320/google-expands-ai-footprint-healthcare-fitbit-chatbot-coming-soon.htm

