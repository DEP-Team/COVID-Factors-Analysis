#================================
# DEPA Final Project
# Demographic and Socioeconomic Data
# author: Whitney Schreiber
# date: 5/14/2021
#================================

rm(list = ls())

# load libraries
library(dplyr)
library(stringr)


# set working directory to script location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


dataPath <- "RawData"


# import ACS data
Population <- read.csv(paste(dataPath, "Population_-_Counties_2015-2019.csv", sep = "/")) %>% 
              select(-c(`ï..OBJECTID`, AFFGEOID, LSAD, ALAND, AWATER, SHAPE_Length, SHAPE_Area,
                        B01001_001M, B09020_021M)) %>% 
              rename(county_name = NAME, state_name = GEO_PARENT_NAME, pop_density = POP_DENSITY,
                     tot_population = B01001_001E,
                     tot_pop_65plus_group_quarters = B09020_021E) %>%	# Population 65+ Living in Group Quarters
              mutate(pop_density = round(pop_density,2))

HouseholdsByType <- read.csv(paste(dataPath, "Households_by_Type_-_Counties_2015-2019.csv", sep = "/")) %>% 
                    select(GEO_PARENT_NAME, NAME, STATEFP, COUNTYFP, GEOID, 
                           B25010_001E,
                           DP02_0015E) %>% 
                    rename(county_name = NAME, state_name = GEO_PARENT_NAME,
                           avg_hh_size = B25010_001E,
                           tot_hh_65plus = DP02_0015E)   # Total Households with one or more people 65 years and over

IncomeAndBenefits <- read.csv(paste(dataPath, "Income_and_Benefits_-_Counties_2015-2019.csv", sep = "/")) %>% 
                     select(GEO_PARENT_NAME, NAME, STATEFP, COUNTYFP, GEOID,
                            DP03_0052E,
                            DP03_0053E,
                            DP03_0054E,
                            DP03_0055E,
                            DP03_0056E,
                            DP03_0057E,
                            INCLT75E_CALC,
                            DP03_0058E,
                            HOUSELT75KP_CALC,
                            DP03_0074PE) %>% 
                     rename(county_name = NAME, state_name = GEO_PARENT_NAME,
                            tot_hh_inc_lessthan_10000 = DP03_0052E,  # Total Households with Income - Less than $10000
                            tot_hh_inc_10000_14999 = DP03_0053E,     # Total Households with Income - $10000 to $14999
                            tot_hh_inc_15000_24999 = DP03_0054E,     # Total Households with Income - $15000 to $24999
                            tot_hh_inc_25000_34999 = DP03_0055E,     # Total Households with Income - $25000 to $34999
                            tot_hh_inc_35000_49999 = DP03_0056E,     # Total Households with Income - $35000 to $49999
                            tot_hh_inc_50000_74999 = DP03_0057E,     # Total Households with Income - $50000 to $74999
                            tot_hh_inc_lessthan_75000 = INCLT75E_CALC,    # Total Households with Income - less than $75000
                            tot_hh_inc_75000_99999 = DP03_0058E,          # Total Households with Income - $75000 to $99999
                            pct_hh_inc_lessthan_75000 = HOUSELT75KP_CALC, # Percent of Households with income in the past 12 months that was less than $75000
                            pct_hh_receive_foodstamps = DP03_0074PE)      # Households: Receiving Food Stamps/SNAP (%)


PovertyStatus <- read.csv(paste(dataPath, "Population_and_Poverty_Status_-_Counties_2015-2019.csv", sep = "/")) %>% 
                 select(GEO_PARENT_NAME, NAME, STATEFP, COUNTYFP, GEOID,
                        B17017_002E,
                        B17017_031E) %>% 
                 rename(county_name = NAME, state_name = GEO_PARENT_NAME,
                        tot_hh_below_poverty_level = B17017_002E,  # Total Households Below the Poverty Level
                        tot_hh_above_poverty_level = B17017_031E)  # Total Households Above Poverty Level

RaceAndEthnicity <- read.csv(paste(dataPath, "Race_and_Ethnicity_-_Counties_2015-2019.csv", sep = "/")) %>% 
                    select(GEO_PARENT_NAME, NAME, STATEFP, COUNTYFP, GEOID,
                           B02001_002E, B02001_003E, B02001_004E, B02001_005E, B02001_006E, 
                           B02001_007E, B02001_008E, B03001_002E, B03001_003E) %>%
                    rename(county_name = NAME, state_name = GEO_PARENT_NAME,
                           tot_pop_white_alone = B02001_002E,	 # Total Population - White alone
                           tot_pop_black_alone = B02001_003E,	 # Total Population - Black or African American alone
                           tot_pop_american_indian_alaskan_alone = B02001_004E,	 # Total Population - American Indian and Alaska Native alone
                           tot_pop_asian_alone = B02001_005E,	 # Total Population - Asian alone
                           tot_pop_hawaiian_pacific_islander_alone = B02001_006E,	 # Total Population - Native Hawaiian and Other Pacific Islander alone
                           tot_pop_other_race_alone = B02001_007E,	 # Total Population - Some other race alone
                           tot_pop_two_or_more_races = B02001_008E,	 # Total Population - Two or more races
                           tot_pop_not_hisp = B03001_002E,	 # Total Population - Not Hispanic or Latino
                           tot_pop_hisp = B03001_003E) # Total Population - Hispanic or Latino (of any race)

WorkedAtHome <- read.csv(paste(dataPath, "Worked_at_Home_-_Counties_2015-2019.csv", sep = "/")) %>% 
                select(GEO_PARENT_NAME, NAME, STATEFP, COUNTYFP, GEOID,
                       DP03_0024E) %>% 
                rename(county_name = NAME, state_name = GEO_PARENT_NAME,
                       tot_pop_wfh = DP03_0024E)  # Total Population - Worked at home

RAW.AgeAndSex <- read.csv(paste(dataPath, "Population_by_Age_and_Sex_-_Counties_2015-2019.csv", sep = "/")) %>% 
  select(GEO_PARENT_NAME, NAME, STATEFP, COUNTYFP, GEOID,
        B01001_002E,B01001_003E,B01001_004E,B01001_005E,B01001_006E,B01001_007E,B01001_008E,
        B01001_009E,B01001_010E,B01001_011E,B01001_012E,B01001_013E,B01001_014E,B01001_015E,
        B01001_016E,B01001_017E,B01001_018E,B01001_019E,B01001_026E,B01001_027E,B01001_028E,
        B01001_029E,B01001_030E,B01001_031E,B01001_032E,B01001_033E,B01001_034E,B01001_035E,
        B01001_036E,B01001_037E,B01001_038E,B01001_039E,B01001_040E,B01001_041E,B01001_042E,
        B01001_043E,B01002_001E,DP05_0015E,DP05_0016E,DP05_0017E,DP05_0025E,DP05_0029E) %>% 
  rename(county_name = NAME, state_name = GEO_PARENT_NAME,
        tot_pop_male = B01001_002E,  # Total Male Population
        tot_pop_male_under_5yrs = B01001_003E,  # Total Population - Males Under 5 Years
        tot_pop_male_5_9yrs = B01001_004E,  # Total Population - Males 5 to 9 Years
        tot_pop_male_10_14yrs = B01001_005E,  # Total Population - Males 10 to 14 Years
        tot_pop_male_15_17yrs = B01001_006E,  # Total Population - Males 15 to 17 Years
        tot_pop_male_18_19yrs = B01001_007E,  # Total Population - Males 18 to 19 Years
        tot_pop_male_20yrs = B01001_008E,  # Total Population - Males 20 Years
        tot_pop_male_21yrs = B01001_009E,  # Total Population - Males 21 Years
        tot_pop_male_22_24yrs = B01001_010E,  # Total Population - Males 22 to 24 Years
        tot_pop_male_25_29yrs = B01001_011E,  # Total Population - Males 25 to 29 Years
        tot_pop_male_30_34yrs = B01001_012E,  # Total Population - Males 30 to 34 Years
        tot_pop_male_35_39yrs = B01001_013E,  # Total Population - Males 35 to 39 Years
        tot_pop_male_40_44yrs = B01001_014E,  # Total Population - Males 40 to 44 Years
        tot_pop_male_45_49yrs = B01001_015E,  # Total Population - Males 45 to 49 Years
        tot_pop_male_50_54yrs = B01001_016E,  # Total Population - Males 50 to 54 Years
        tot_pop_male_55_59yrs = B01001_017E,  # Total Population - Males 55 to 59 Years
        tot_pop_male_60_61yrs = B01001_018E,  # Total Population - Males 60 and 61 Years
        tot_pop_male_62_64yrs = B01001_019E,  # Total Population - Males 62 to 64 Years
        tot_pop_female = B01001_026E,  # Total Female Population
        tot_pop_female_under_5yrs = B01001_027E,  # Total Population - Females Under 5 Years
        tot_pop_female_5_9yrs = B01001_028E,  # Total Population - Females 5 to 9 Years
        tot_pop_female_10_14yrs = B01001_029E,  # Total Population - Females 10 to 14 Years
        tot_pop_female_15_17yrs = B01001_030E,  # Total Population - Females 15 to 17 Years
        tot_pop_female_18_19yrs = B01001_031E,  # Total Population - Females 18 to 19 Years
        tot_pop_female_20yrs = B01001_032E,  # Total Population - Females 20 Years
        tot_pop_female_21yrs = B01001_033E,  # Total Population - Females 21 Years
        tot_pop_female_22_24yrs = B01001_034E,  # Total Population - Females 22 to 24 Years
        tot_pop_female_25_29yrs = B01001_035E,  # Total Population - Females 25 to 29 Years
        tot_pop_female_30_34yrs = B01001_036E,  # Total Population - Females 30 to 34 Years
        tot_pop_female_35_39yrs = B01001_037E,  # Total Population - Females 35 to 39 Years
        tot_pop_female_40_44yrs = B01001_038E,  # Total Population - Females 40 to 44 Years
        tot_pop_female_45_49yrs = B01001_039E,  # Total Population - Females 45 to 49 Years
        tot_pop_female_50_54yrs = B01001_040E,  # Total Population - Females 50 to 54 Years
        tot_pop_female_55_59yrs = B01001_041E,  # Total Population - Females 55 to 59 Years
        tot_pop_female_60_61yrs = B01001_042E,  # Total Population - Females 60 and 61 Years
        tot_pop_female_62_64yrs = B01001_043E,  # Total Population - Females 62 to 64 Years
        median_age = B01002_001E,  # Median Age
        tot_pop_65_74yrs = DP05_0015E,  # Total Population - 65 to 74 years
        tot_pop_75_84yrs = DP05_0016E,  # Total Population - 75 to 84 years
        tot_pop_85plus = DP05_0017E,  # Total Population - 85 years and over
        tot_pop_18plus = DP05_0025E,  # Total Population - 18 years and over
        tot_pop_65plus = DP05_0029E)  # Total Population - 65 years and over

AgeAndSex <- RAW.AgeAndSex %>% 
  mutate(tot_pop_male_0_9yrs=tot_pop_male_under_5yrs+tot_pop_male_5_9yrs,
         tot_pop_male_10_19yrs=tot_pop_male_10_14yrs+tot_pop_male_15_17yrs+tot_pop_male_18_19yrs,
         tot_pop_male_20_29yrs=tot_pop_male_20yrs+tot_pop_male_21yrs+tot_pop_male_22_24yrs+tot_pop_male_25_29yrs,
         tot_pop_male_30_39yrs=tot_pop_male_30_34yrs+tot_pop_male_35_39yrs,
         tot_pop_male_40_49yrs=tot_pop_male_40_44yrs+tot_pop_male_45_49yrs,
         tot_pop_male_50_64yrs=tot_pop_male_50_54yrs+tot_pop_male_55_59yrs+tot_pop_male_60_61yrs+tot_pop_male_62_64yrs,
         tot_pop_female_0_9yrs=tot_pop_female_under_5yrs+tot_pop_female_5_9yrs,
         tot_pop_female_10_19yrs=tot_pop_female_10_14yrs+tot_pop_female_15_17yrs+tot_pop_female_18_19yrs,
         tot_pop_female_20_29yrs=tot_pop_female_20yrs+tot_pop_female_21yrs+tot_pop_female_22_24yrs+tot_pop_female_25_29yrs,
         tot_pop_female_30_39yrs=tot_pop_female_30_34yrs+tot_pop_female_35_39yrs,
         tot_pop_female_40_49yrs=tot_pop_female_40_44yrs+tot_pop_female_45_49yrs,
         tot_pop_female_50_64yrs=tot_pop_female_50_54yrs+tot_pop_female_55_59yrs+tot_pop_female_60_61yrs+tot_pop_female_62_64yrs
         ) %>% 
  select(state_name, county_name, STATEFP, COUNTYFP, GEOID,
         median_age, tot_pop_18plus, tot_pop_65plus, tot_pop_65_74yrs, tot_pop_75_84yrs, tot_pop_85plus,
         tot_pop_male, tot_pop_male_0_9yrs, tot_pop_male_10_19yrs, tot_pop_male_20_29yrs,
                       tot_pop_male_30_39yrs,tot_pop_male_40_49yrs,tot_pop_male_50_64yrs,
         tot_pop_female,tot_pop_female_0_9yrs,tot_pop_female_10_19yrs,tot_pop_female_20_29yrs,
                      tot_pop_female_30_39yrs,tot_pop_female_40_49yrs,tot_pop_female_50_64yrs)


#------------------
# merge demographic data sets
#------------------
merged_data <- merge(Population, HouseholdsByType,  by = c("state_name", "county_name", "STATEFP", "COUNTYFP", "GEOID"))
merged_data <- merge(merged_data, AgeAndSex,  by = c("state_name", "county_name", "STATEFP", "COUNTYFP", "GEOID"))
merged_data <- merge(merged_data, IncomeAndBenefits,  by = c("state_name", "county_name", "STATEFP", "COUNTYFP", "GEOID"))
merged_data <- merge(merged_data, PovertyStatus,  by = c("state_name", "county_name", "STATEFP", "COUNTYFP", "GEOID"))
merged_data <- merge(merged_data, RaceAndEthnicity,  by = c("state_name", "county_name", "STATEFP", "COUNTYFP", "GEOID"))
merged_data <- merge(merged_data, WorkedAtHome,  by = c("state_name", "county_name", "STATEFP", "COUNTYFP", "GEOID"))

# reformat FIPS codes
merged_data_aggr <- merged_data %>% 
                rename(state_id = STATEFP,
                       county_id = GEOID) %>%  # using FIPS code as GEOID
                mutate(state_id = str_pad(state_id, 2, pad = "0"),
                       county_id = str_pad(county_id, 5, pad = "0")) %>%
                select(-c(COUNTYFP, COUNTYNS))

# export merged census/ACS data
write.csv(merged_data_aggr, paste0("DEPA_FinalProject_MergedACS_",Sys.Date(),".csv"), row.names = FALSE)


#------------------
# calculate population percentages and reorder columns
#------------------
demographics <- merged_data_aggr %>% 
  mutate(
# age and gender
    pct_hh_65plus=round(tot_hh_65plus/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_pop_65plus_group_quarters=round(tot_pop_65plus_group_quarters/tot_population,4),
    pct_pop_18plus=round(tot_pop_18plus/tot_population,4),
    pct_pop_65plus=round(tot_pop_65plus/tot_population,4),
    pct_pop_65_74yrs=round(tot_pop_65_74yrs/tot_population,4),
    pct_pop_75_84yrs=round(tot_pop_75_84yrs/tot_population,4),
    pct_pop_85plus=round(tot_pop_85plus/tot_population,4),
    pct_pop_male=round(tot_pop_male/tot_population,4),
    pct_pop_male_0_9yrs=round(tot_pop_male_0_9yrs/tot_population,4),
    pct_pop_male_10_19yrs=round(tot_pop_male_10_19yrs/tot_population,4),
    pct_pop_male_20_29yrs=round(tot_pop_male_20_29yrs/tot_population,4),
    pct_pop_male_30_39yrs=round(tot_pop_male_30_39yrs/tot_population,4),
    pct_pop_male_40_49yrs=round(tot_pop_male_40_49yrs/tot_population,4),
    pct_pop_male_50_64yrs=round(tot_pop_male_50_64yrs/tot_population,4),
    pct_pop_female=round(tot_pop_female/tot_population,4),
    pct_pop_female_0_9yrs=round(tot_pop_female_0_9yrs/tot_population,4),
    pct_pop_female_10_19yrs=round(tot_pop_female_10_19yrs/tot_population,4),
    pct_pop_female_20_29yrs=round(tot_pop_female_20_29yrs/tot_population,4),
    pct_pop_female_30_39yrs=round(tot_pop_female_30_39yrs/tot_population,4),
    pct_pop_female_40_49yrs=round(tot_pop_female_40_49yrs/tot_population,4),
    pct_pop_female_50_64yrs=round(tot_pop_female_50_64yrs/tot_population,4),
# income and benefits, poverty status
    pct_hh_below_poverty_level=round(tot_hh_below_poverty_level/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_above_poverty_level=round(tot_hh_above_poverty_level/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_lessthan_10000=round(tot_hh_inc_lessthan_10000/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_10000_14999=round(tot_hh_inc_10000_14999/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_15000_24999=round(tot_hh_inc_15000_24999/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_25000_34999=round(tot_hh_inc_25000_34999/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_35000_49999=round(tot_hh_inc_35000_49999/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_50000_74999=round(tot_hh_inc_50000_74999/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
    pct_hh_inc_lessthan_75000=round(pct_hh_inc_lessthan_75000,4),
    pct_hh_inc_75000_99999=round(tot_hh_inc_75000_99999/(tot_hh_below_poverty_level+tot_hh_above_poverty_level),4),
# race and ethnicity
    pct_pop_white_alone=round(tot_pop_white_alone/tot_population,4),
    pct_pop_black_alone=round(tot_pop_black_alone/tot_population,4),
    pct_pop_american_indian_alaskan_alone=round(tot_pop_american_indian_alaskan_alone/tot_population,4),
    pct_pop_asian_alone=round(tot_pop_asian_alone/tot_population,4),
    pct_pop_hawaiian_pacific_islander_alone=round(tot_pop_hawaiian_pacific_islander_alone/tot_population,4),
    pct_pop_other_race_alone=round(tot_pop_other_race_alone/tot_population,4),
    pct_pop_two_or_more_races=round(tot_pop_two_or_more_races/tot_population,4),
    pct_pop_hisp=round(tot_pop_hisp/tot_population,4),
    pct_pop_not_hisp=round(tot_pop_not_hisp/tot_population,4),
    # worked at home
    pct_pop_wfh=round(tot_pop_wfh/tot_population,4)
  ) %>% 
  select(
    state_name,county_name,state_id,county_id,tot_population,pop_density,
    median_age,tot_pop_18plus,tot_pop_65plus,tot_pop_65_74yrs,tot_pop_75_84yrs,tot_pop_85plus,
    pct_pop_18plus,pct_pop_65plus,pct_pop_65_74yrs,pct_pop_75_84yrs,pct_pop_85plus,
    tot_pop_male,tot_pop_male_0_9yrs,tot_pop_male_10_19yrs,tot_pop_male_20_29yrs,tot_pop_male_30_39yrs,tot_pop_male_40_49yrs,tot_pop_male_50_64yrs,
    pct_pop_male,pct_pop_male_0_9yrs,pct_pop_male_10_19yrs,pct_pop_male_20_29yrs,pct_pop_male_30_39yrs,pct_pop_male_40_49yrs,pct_pop_male_50_64yrs,
    tot_pop_female,tot_pop_female_0_9yrs,tot_pop_female_10_19yrs,tot_pop_female_20_29yrs,tot_pop_female_30_39yrs,tot_pop_female_40_49yrs,tot_pop_female_50_64yrs,
    pct_pop_female,pct_pop_female_0_9yrs,pct_pop_female_10_19yrs,pct_pop_female_20_29yrs,pct_pop_female_30_39yrs,pct_pop_female_40_49yrs,pct_pop_female_50_64yrs,
    tot_pop_white_alone,tot_pop_black_alone,tot_pop_american_indian_alaskan_alone,tot_pop_asian_alone,tot_pop_hawaiian_pacific_islander_alone,
    tot_pop_other_race_alone,tot_pop_two_or_more_races,tot_pop_not_hisp,tot_pop_hisp,
    pct_pop_white_alone,pct_pop_black_alone,pct_pop_american_indian_alaskan_alone,pct_pop_asian_alone,pct_pop_hawaiian_pacific_islander_alone,
    pct_pop_other_race_alone,pct_pop_two_or_more_races,pct_pop_hisp,pct_pop_not_hisp,
    tot_pop_wfh,pct_pop_wfh,
    avg_hh_size,tot_hh_65plus,pct_hh_65plus,tot_pop_65plus_group_quarters,pct_pop_65plus_group_quarters,
    tot_hh_below_poverty_level,tot_hh_above_poverty_level,pct_hh_below_poverty_level,pct_hh_above_poverty_level,pct_hh_receive_foodstamps,
    tot_hh_inc_lessthan_10000,tot_hh_inc_10000_14999,tot_hh_inc_15000_24999,tot_hh_inc_25000_34999,tot_hh_inc_35000_49999,tot_hh_inc_50000_74999,
    tot_hh_inc_lessthan_75000,tot_hh_inc_75000_99999,pct_hh_inc_lessthan_10000,pct_hh_inc_10000_14999,pct_hh_inc_15000_24999,pct_hh_inc_25000_34999,
    pct_hh_inc_35000_49999,pct_hh_inc_50000_74999,pct_hh_inc_lessthan_75000,pct_hh_inc_75000_99999
  )

# export final dataset
write.csv(demographics, paste0("DEPA_FinalProject_Demographics_withNamesIDs",Sys.Date(),".csv"), row.names = FALSE)

# keep only FIPS code ("county_id")
demographics_final <- demographics %>% dplyr::select(-c(state_name, county_name, state_id))
write.csv(demographics_final, paste0("DEPA_FinalProject_Demographics_ImportMe_",Sys.Date(),".csv"), row.names = FALSE)












