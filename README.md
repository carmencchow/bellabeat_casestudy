<h1>Bellabeat Case Study</h1>
<p>Carmen Chow</p> 
<p>September 2024</p>

<h2>Scenario</h2>
<p>Bellabeat is a high-tech manufacturer of health-focused products for women.  Since it was founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women.  Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. Sršen knows that an analysis of Bellabeat’s available consumer data would reveal more opportunities for growth. She has asked the marketing analytics team to focus on a Bellabeat product and analyze smart device usage data in order to gain insight into how people are already using their smart devices. Then, using this information, she would like high-level recommendations for how these trends can inform Bellabeat marketing strategy.</p>

<h2>Stakeholders </h2>
<p>Urška Sršen: Bellabeat’s cofounder and Chief Creative Officer</p>
<p>Sando Mur: Mathematician and Bellabeat’s cofounder; key member of the Bellabeat executive team </p>
<p>Bellabeat marketing analytics team: A team of data analysts responsible for collecting, analyzing, and reporting data that helps guide Bellabeat’s marketing strategy. </p>

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

<p>Before processing our data, we’ll preview the eighteen CSV files in Excel to get an overview of the data’s overall structure to determine which files will be useful in answering our Business Task.  Out of the 18 available files, we’ll focus our attention on the following three:<p>

```dailyActivity_merged.csv```
```sleepDay_merged.csv```
```weightLogInfo_merged.csv```

<p>The other files either contain information that does not impact our Business Task or have data points that already exist in the</p> `dailyActivity_merged.csv` file.


<h2>3. Process</h2>
<p>Let’s open R Studio and run the `read_csv()` R command to read each CSV file and save it as a data frame in R:</p>

```
dailyActivity_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/dailyActivity_merged.csv")
sleepDay_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/sleepDay_merged.csv")
weightLogInfo_merged <- read_csv("C:/Users/carme/OneDrive/Desktop/TurkFitBit/mturkfitbit_export_4.12.16-5.12.16/Fitabase Data 4.12.16-5.12.16/weightLogInfo_merged.csv")
```

<p>Check that the files have been imported correctly in the environment pane with `ls()`. We'll take a closer look at each data frame by using `head()` to return the first few rows:


# Displaying a Tibble in R

Here is an example of a tibble in R:

```r
library(tibble)

# Create a simple tibble
my_tibble <- tibble(
  name = c("Alice", "Bob", "Carol"),
  age = c(30, 25, 35),
  score = c(95, 88, 92)
)

my_tibble
