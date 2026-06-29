---
title: "Electric Vehicles and Income Patterns in Washington State"
subtitle: "Data Visualization & Analysis with R"
author: "Liza Snizhko"
date: "December 24, 2025"
format: 
  html:
    theme: cosmo
    toc: true
    embed-resources: true
execute:
  echo: true
---

```{r}
#| output: false
library(tidyverse)
library(dplyr)
library(tigris)
library(sf)
```

## Introduction

**How is income correlated with the distribution of electric vehicles throughout Washington's counties?**

According to the [Department of Ecology](https://ecology.wa.gov/blog/april-2024/a-record-year-for-electric-vehicles-and-plug-in-hybrids-in-washington), Washington had the second-highest rate of electric and plug-in vehicle sales in the nation, behind California. What state was behind Washington? Oregon. The West Coast is far ahead of the rest of the country when it comes to electric transportation, but which counties in Washington truly contribute to this statistic the most? Understanding which Washington counties are driving the state's lead in the adoption of electric vehicles is critical to grasping how state-wide averages can have major differences within region. By identifying the counties that contribute the most to EV adoption, this data assists lawmakers and researchers in understanding where policy, socioeconomic factors, and policy are most necessary and effective to consider. This research can give insight into Washington's scene of Electric Vehicles at the local level.

This analysis uses data to better understand which counties in Washington have higher concentrations of electric vehicles, in order to identify which counties of Washington are more environmentally progressive.

Specifically, it measures Washington's adoption of electric vehicles and identifies:

-   Which Washington counties have the highest EV registrations
-   How median income differs across counties
-   Whether higher income counties display stronger adoption of EV vehicles
-   Which regions have more environmental progress in comparison to other regions

## Analysis of Electric Vehicles

### Questions

Washington State has seen rapid growth in electric vehicle adoption. Washington State data is used to visualize how electric vehicles are distributed across all 39 counties. In particular, the goal is to understand:

-   Which counties have the highest numbers of registered electric vehicles?
-   How large are the differences in EV counts from one county to another?
-   Which parts of the state are the most saturated with electric vehicles, and whether this concentration is mostly around Seattle or generally across the west side of the state

### Electric Vehicles Data

For this analysis, I used electric vehicles data made available by the United States government for state of Washington at [data.gov](https://catalog.data.gov/dataset/electric-vehicle-population-data). The data set tracks all registered Battery Electric Vehicles (BEVs) and Plug-in Hybrid Electric Vehicles (PHEVs) in Washington between 2023 and 2025.

The population for this dataset includes all electric vehicles registered in Washington State (264,628 rows). A randomly selected sample of 70,000 rows is taken using slice_sample() function. This number gives a large portion of the data while keeping the file small enough to work with easily. A sample of 70,000 rows provides a clear picture of the main patterns in the dataset, and because the rows come from a random draw, the sample reflects the overall structure of the full population and allows for accurate results.

The primary features focused on were the counties in Washington and the number of electric vehicles registered in each county, which was calculated during data wrangling using the summarize() function. Data was filtered by the state of WA, because the input data frame sometimes includes entries from CA or other states. These vehicles were removed using filter(State == "WA") so they do not impact the results.

For a sample of data, see below:

```{r}
electric_vh <- read.csv("Electric_Vehicle_Population_Data.csv") |>
  filter(State == "WA") |>
  slice_sample(n = 70000) |>
  glimpse()
```

### Data Preparation

To understand the distribution of electric vehicles across counties and perform analysis, I had to group data by counties and summarize to calculate the total number of vehicles for each of 39 counties. This can be seen below:

```{r}
electric_vh_by_counties <- electric_vh |>
  group_by(County) |>
  summarize(Number_of_vehicles = n())

electric_vh_by_counties |> glimpse()
```

To show the distribution of electric vehicles across counties in Washington state, a choropleth map is the most effective approach. The key benefit of this type of map is that it combines geographic context with numerical data. That allows to see both where electric vehicles adoption is high or low and how large the differences are between counties.

The simplest way to create a map in R is by using shapefiles along with the sf and ggplot2 packages. The process of creating a map involves 2 steps:

#### Importing the general WA state counties map borders with tigris

A dataset depicting the borders of Washington state counties is imported using the tigris package. The counties() function downloads a US Census cartographic boundary shapefile into R. The current data on counties in WA State reflects 2024 data, which is exactly what is needed.

The code below will return a simple features object wa_counties_sf, which is a type of data frame with spatial geometry and is used with the sf package methods. This data frame will contain 39 rows of data on how to draw each county.

```{r}
#| output: false # this line is used here to remove long loading and progress messages from the report that go by default when loading simple features. It will allow to load the data beforehand, so it does not appear in the report.
wa_counties_sf <- counties(state = "WA")
```

```{r}
wa_counties_sf |> glimpse()
```

Further information on using tigris package and its avaialble functions can be found at [Rdocumentation.org with the tigris documentation](https://rdocumentation.org/packages/tigris/versions/2.2.1). More information on the counties() function can be found at [tigris/counties](https://www.rdocumentation.org/packages/tigris/versions/2.2.1/topics/counties)

#### Joining two data frames

The next step is to join the dataframe containing counties and the number of vehicles per county with the wa_counties_sf data frame, which contains county names in the "NAME" feature. This is necessary because the wa_counties_sf data frame only contains the shapes and names of the counties, and the EV data only contains county names and EV counts. Neither dataset alone contains all the information needed to draw a map and display the EV counts on it.

Because we're joing two of these data sets, a column "Number_of_vehicles" will be added the wa_counties_sf data frame, which will show the number of vehicles per county on the map:

```{r}
wa_counties_sf <- wa_counties_sf |>
  left_join(electric_vh_by_counties, by = c("NAME" = "County"))
wa_counties_sf |> glimpse()
```

Knowledge from the tutorial at [R Charts "Join map and data" section](https://r-charts.com/spatial/choropleth-map-ggplot2/#join) is applied.

### Results

Finally, a map visualization is created. The geom_sf() method draws the actual county boundaries on the map. I choose a fill color based on Number_of_vehicles, which means counties with more EVs appear with a stronger color. The size = 0.4 makes the borders more thick but visible.

Next, text labels are added. I do this with geom_sf_text(), which places words directly on top of each county. I use str_glue() because I needed to combine two pieces of information into a single label with the county name and the number of EVs in that county on the next line:

```{r}
#| fig.alt: A choropleth map of Washington State counties showing the distribution of electric vehicles recorded between 2023 and 2025, with King and Snohomish counties having the highest concentrations of EV registrations.

wa_counties_sf |>
  ggplot(aes(fill = Number_of_vehicles)) +
  geom_sf(size = 0.7) +
  geom_sf_text(aes(label = str_glue("{NAME}\n{Number_of_vehicles}")), size = 1.9, color = "white") +
  labs(x = "Longitude",
       y = "Latitude",
       fill = "Number of EVs",
       title = "King County is the most saturated county with electric \nvehicles, accounting for more than half of all vehicles in the state",
       subtitle = "Battery and plug-in hybrid electric vehicles in Washington state, 2023-2025",
       caption = "Data Available at: https://catalog.data.gov/dataset/electric-vehicle-population-data")
```

Code examples from the [R Charts tutorial for creating the simple maps with sf package](https://r-charts.com/spatial/maps-ggplot2) were used. Specifically, used the example from "geom_sf_text and geom_sf_label" section to help write and understand the code for this intermediate tool.

Information on str_glue() is available in the readings in [R for Data Science (Chapter 14)](https://r4ds.hadley.nz/strings.html#sec-glue)

### Electric Vehicles Results

As a summary, electric vehicle adoption in Washington State across all 39 counties isn’t spread out evenly at all. King County alone has approximately 50% of all the EVs in the state, which creates a huge gap compared to other counties. Snohomish and Pierce also have a good number of EVs, but once you look farther east, the numbers drop off pretty quickly. Counties with the least number of electric vehicles have 1-200 electric vehicles registered out of a sample of 70,000 entries. Overall, most EV ownership is clustered around the Seattle metro area, closer to west of Washington state, and rural counties see much lower adoption.

## Analysis of Median Household Income

### Questions

-   How does median income differ across counties?
-   Do higher income counties display a stronger adoption of EV vehicles?
-   Do lower income counties display a weaker adoption of EV vehicles?

### Median Household Income Data

Through the HDPulse Data program, Median Household income Data is shared by the [National Institute on Minority Health and Health Disparities](https://hdpulse.nimhd.nih.gov/data-portal/social/table?age=001&age_options=ageall_1&demo=00011&demo_options=income_3&race=00&race_options=race_7&sex=0&sex_options=sexboth_1&socialtopic=030&socialtopic_options=social_6&statefips=53&statefips_options=area_states). It represents survey respondents from the American Community Survey (ACS) who are analyzed within each geographic region. This data includes features such as the **statistical population**, such as all of the households in counties throughout Washington State. The data includes a **sample**, which includes the individual households that were surveyed by the American Community Survey (ACS). The survey respondents are analyzed within each geographic region. For the **time & place**, the time period between 2019-2023 included locations throughout Washington State. The data's **features** included Median household income, county FIPS codes, and the US ranking as well.

### Data Preparation Steps

To further understand how income varies across Washington's counties, I had to **load data** by reading the HDPulse CSV file, and skip the first four header rows to reach actual data. Then I **selected specific rows** using slice(3:41) to remove summary rows for the 'United States' and 'Washington State', which allowed us to keep only county data. I **renamed the columns** to change columns that were unclear to more readable names.

Lastly, I **converted data types** using parse_number() to remove commas and trailing spaces. In the raw dataset, the numeric cells contained spaces and commas, so R read them as text. Because of that, it wasn’t possible to create visualizations or calculations until I converted these text values into numeric format for the Rank and Income columns.

```{r}
MEDIAN_INCOME <- read.csv("HDPulse_data_export_2.csv", skip = 4) |>
    slice(3:41) |>
    rename(Income = Value..Dollars.,
          Rank_within_US = Rank.within.US..of.3141.counties.,
          ID = FIPS) |>
    mutate(Rank_within_US = parse_number(Rank_within_US),
          Income = parse_number(Income))
```

### Results

I created a bar graph of the median household income to understand how income varies across counties. The geom_col method places bars onto the plot. To make the bars stand out more clearly against the minimal theme background, I used the color red. I used the reorder(County, Income) function to sort counties from lowest to highest income, which allowed us to see the levels of household income amongst Washington's counties more clearly. To add labels and formatting, I used labs() to add a title, subtitle, axis, labels, and caption of the data source. I used horizontal bars to visualize the data more easily, so I placed County on the y axis and Income on the x axis.

```{r}
#| title: "How Does Income Vary Across Counties"
#| fig-width: 10
#| fig-height: 6
#| fig-alt: "Bar Graph of Median Household Income, showing King County and Snohomoish County as most affluent in Washington State."

MEDIAN_INCOME|>
    ggplot(aes(y = reorder(County, Income), x = Income)) + 
    geom_col(fill = "red") +
    labs(x = "County",
         y = "Median Household Income",
         title = "King County and Snohomish County are most affluent in Washington State",
         subtitle = "Median Household Income throughout Washington Counties, 2023-2025",
         caption = "Data Available at: https://hdpulse.nimhd.nih.gov") +
    theme_minimal()
```

### Median Household Income Results

All in all, Washington Counties, income varies slightly, demonstrating income disparities between rural and urban communities. King County has the highest median income at 122,148. Snohomish County is second at 107,982. Whitman County has the lowest income at 52, 893. The income gap between the highest and lowest counties is over \$69,000.

I am checking the variance of income across counties within Washington because I want to identify general levels of income and the level of inequality between counties. I chose the median as a central value because it exemplifies a great middle-point between the varying socioeconomic status's within Washington's counties. Because King County's income as \$122,000+ is greatly higher than other Washington counties, the median value can give us a middle-ground that does not skew too heavily above or below the average income. This is specially meaningful because it is helpful towards identifying certain counties that may need more assistance from the state.

## Analysis of Income and EVs Correlation

### Questions

As the final step, you want to see the correlation between electric vehicles and median income in Washington state counties. I am using the same data sets wrangled and used in the previous steps to conduct the analysis.

Specifically, I want to see if the counties with higher income more likely to have more EVs? What patterns or trends appear when plotting EV count vs median income?

### Data Preparation

I are using the same "Electric Vehicles" and "Median Income" data sets I highlighted above to do the joint analysis. No new data sets are introduced here.

To conduct the correlation analysis, I first needed to join the data frames by county to be able to compare both numeric values of income and number of vehicles. However, I discovered the county names didn’t match: in the EV dataset, counties appear as just the name (e.g., "King"), while in the Income data frame, they appear as "King County." To fix this, I removed the word "County" from Income data frame entries using str_replace(). The function takes the pattern I want to remove, in this case " County," and replaces it with an empty string. After that, I used mutate() to write the cleaned names back into the County column in the MEDIAN_INCOME data frame.

I learned the str_replace() function from examples on [Posit Cloud learning platform](https://posit.cloud/learn/recipes/strings/StringsD)

Then, I performed a left_join() to create combined dataset. In this situation, I could have used any join type, such as full_join() or inner_join(), because the "keys" county names, matched perfectly in both data frames. The joined data frame combined_income_ev can be seen below:

```{r}
MEDIAN_INCOME <- MEDIAN_INCOME |>
  mutate(County = str_replace(County, pattern = " County", replacement = ""))

combined_income_ev <- MEDIAN_INCOME |>
   left_join(electric_vh_by_counties, by = join_by("County"))

combined_income_ev |> glimpse()
```

### Results

The best way to show the correlation is the scatter plot visualization. I use color to show each county’s rank in the United States. Counties with higher ranks have darker colors, and counties with lower ranks have lighter colors, that is why I can easily see which counties are doing better or worse.

I also use scale_y_log10() for the vertical axis. King County and Snohomish County have way more EVs than the other counties, so they are outliers. If I used a normal y-axis, the smaller counties would look almost flat and close to 0. Scale_y_log10() "shrinks" the big numbers so I can see all counties more clearly and it does not change the actual data values or the rank. It only changes how the chart is displayed to make the differences more readable, even though some have much higher EV counts.

```{r}
#| fig.alt: A scatterplot showing that counties with higher median household income tend to have higher numbers of electric vehicles. Each point represents a county, sized and colored by its income rank among all U.S. counties.

combined_income_ev |>
  ggplot(aes(x = Income, y = Number_of_vehicles, color = Rank_within_US)) +
  geom_point() +
  scale_y_log10() +
  labs(x = "Median Household Income, $",
       y = "Number of Electric Vehicles",
      color = "Rank by Income\nWthin all US Counties",
      title = "Higher Median Income Counties Have More Electric Vehicles",
      subtitle = "County-level median household income and EV registration for Washington State, 2023-2025",
      caption = "Data Sources: \nhttps://hdpulse.nimhd.nih.gov \n https://catalog.data.gov/dataset/electric-vehicle-population-data") +
  theme_minimal()
```

### Correlation Results

I found that there is a strong positive correlation between median household income and the number of electric vehicles registered across the counties in Washington. Counties with higher income levels tend to have more EVs overall. For example, King County has over 34,000+ registered EVs, and Snohomish County has 8,500+, which are by far the highest in the dataset. The difference between these counties and the counties with the least number of EVs, such as Garfield County in the southeast part of Washington, is very large, which makes King and Snohomish clear outliers.

I also see that counties with higher median incomes tend to have a higher rank within all US counties, as shown by the color gradient in the plot, which again highlights the connection between income and EV adoption.

This pattern tells us that income level may be an important factor in EV adoption. It also shows that additional policies or incentives for lower-income counties could help increase electric vehicle usage across the state, especially since choosing electric vehicles can support environmental and ecology goals and help reduce the impacts of global warming.

## General Conclusions

The analysis displays a strong correlation between county income levels and the adoption of electric vehicles throughout Washington State. King County (122,00+) and Snohomish County (100,000+) are leaders in the registrations of electrical vehicles, tied with a higher median income. On the other hand, lower income counties, such as Whitman (52,000) have many less electric vehicles. This pattern exemplifies that Washington's high rate of adopting electric vehicles may be driven by few wealthier urban counties, instead of being distributed evenly across the state.

As for the limitations, I likely overestimated the direct role of income. There are many other factors that could interfere with the correlation between EVs and higher median income, such as type of housing and the density of population. Since King and Snohomish counties are outliers, these counties could potentially skew results. I may have underestimated by simply using medians on the county-level, which could limit the variation within a county.

In terms of future directions, this could incorporate action on behalf of the state to invest in certain lower-income communities, grasping urban versus rural patterns within Washington counties, or surveying residents about barriers to adopting Electric Vehicles.

## Project Summary

**Author:** Liza Snizhko

**Data Sets:**

-   [Electric Vehicle Population Data](https://catalog.data.gov/dataset/electric-vehicle-population-data)
-   [Income (Median household income) for Washington by County](https://hdpulse.nimhd.nih.gov/data-portal/social/table?age=001&age_options=ageall_1&demo=00011&demo_options=income_3&race=00&race_options=race_7&sex=0&sex_options=sexboth_1&socialtopic=030&socialtopic_options=social_6&statefips=53&statefips_options=area_states)

**Basic Tools Used:**

-   group_by(), summarize(), slice_sample(), slice(), mutate(), parse_number(), str_replace(), reorder(), str_glue()
    -   str_replace() - [Posit Cloud learning platform](https://posit.cloud/learn/recipes/strings/StringsD)
    -   str_glue() - [R for Data Science (Chapter 14)](https://r4ds.hadley.nz/strings.html#sec-glue)

**Intermediate/Novel Tool Used:**

-   Choropleth Maps, with reference materials including:
    -   [Rdocumentation.org with the tigris documentation](https://rdocumentation.org/packages/tigris/versions/2.2.1/topics/counties)
    -   [R Charts "Join map and data" section](https://r-charts.com/spatial/choropleth-map-ggplot2/#join)
    -   [R Charts tutorial for creating the simple maps with sf package](https://r-charts.com/spatial/maps-ggplot2)
-   Join (left_join()):
    -   [R for Data Science (chapter 19)](https://r4ds.hadley.nz/joins.html#sec-mutating-joins)
