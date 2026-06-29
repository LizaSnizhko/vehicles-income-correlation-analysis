library(tidyverse)
library(dplyr)
library(tigris)
library(sf)

electric_vh <- read.csv("Electric_Vehicle_Population_Data.csv") |>
  filter(State == "WA") |>
  slice_sample(n = 70000) |>
  glimpse()

electric_vh_by_counties <- electric_vh |>
  group_by(County) |>
  summarize(Number_of_vehicles = n())

electric_vh_by_counties |> glimpse()

wa_counties_sf <- counties(state = "WA")

wa_counties_sf |> glimpse()

wa_counties_sf <- wa_counties_sf |>
  left_join(electric_vh_by_counties, by = c("NAME" = "County"))

wa_counties_sf |> glimpse()

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

MEDIAN_INCOME <- read.csv("HDPulse_data_export_2.csv", skip = 4) |>
    slice(3:41) |>
    rename(Income = Value..Dollars.,
          Rank_within_US = Rank.within.US..of.3141.counties.,
          ID = FIPS) |>
    mutate(Rank_within_US = parse_number(Rank_within_US),
          Income = parse_number(Income))

MEDIAN_INCOME|>
    ggplot(aes(y = reorder(County, Income), x = Income)) + 
    geom_col(fill = "red") +
    labs(x = "County",
         y = "Median Household Income",
         title = "King County and Snohomish County are most affluent in Washington State",
         subtitle = "Median Household Income throughout Washington Counties, 2023-2025",
         caption = "Data Available at: https://hdpulse.nimhd.nih.gov") +
    theme_minimal()

MEDIAN_INCOME <- MEDIAN_INCOME |>
  mutate(County = str_replace(County, pattern = " County", replacement = ""))

combined_income_ev <- MEDIAN_INCOME |>
   left_join(electric_vh_by_counties, by = join_by("County"))

combined_income_ev |> glimpse()

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
