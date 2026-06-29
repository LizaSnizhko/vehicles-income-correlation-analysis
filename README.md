# Washington State Electric Vehicle & Income Analysis

**R | Quarto | ggplot2 | sf | dplyr | Data Visualization**

This project analyzes the relationship between **electric vehicle (EV) adoption** and **median household income** across all 39 counties in Washington State.
I cleaned and transformed over **70,000 records** in R before creating multiple visualizations to explore geographic and socioeconomic patterns in EV ownership.

**Open the interactive report here: [View Project](https://lizasnizhko.github.io/vehicles-income-correlation-analysis/)**

<img width="5994" height="2590" alt="visuals" src="https://github.com/user-attachments/assets/7d4c2b86-efcc-4deb-9e7f-359e6608ebcb" />

## Project Highlights

* Cleaned and wrangled 70,000+ EV registration records using **dplyr**
* Combined multiple public datasets through data joins
* Created a **choropleth map** using spatial data with **sf** and **tigris**
* Built bar charts and scatterplots using **ggplot2**
* Produced a fully reproducible **Quarto HTML report**

## Research Question

Do counties with higher median household incomes also have higher electric vehicle adoption?

## Key Findings

* King County contains approximately half of all sampled EV registrations.
* Higher-income counties generally exhibit greater EV adoption.
* EV ownership is concentrated around the Seattle metropolitan area.
* Rural counties show substantially lower EV registration counts.

## Visualizations

The project includes:

* Washington State choropleth map of EV registrations
* County median household income bar chart
* Income vs. EV registration scatterplot

## Technologies

* R
* Quarto
* tidyverse
* dplyr
* ggplot2
* sf
* tigris

## Data Sources

- Electric Vehicle Population Data  
  https://catalog.data.gov/dataset/electric-vehicle-population-data

- Median Household Income Data (HDPulse / NIMHD)  
  https://hdpulse.nimhd.nih.gov/data-portal/social/table?age=001&age_options=ageall_1&demo=00011&demo_opt

