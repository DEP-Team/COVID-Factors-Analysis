import urllib

import pandas as pd
from openpyxl import load_workbook

week_list = [22, 23, 24, 25, 26, 27, 28, 29]

# Download weekly reports
for i in week_list:
    urllib.request.urlretrieve(
        f"https://www2.census.gov/programs-surveys/demo/tables/hhp/2021/wk{i}/health5_week{i}.xlsx",
        f"data/raw/census_hhp/table_5_week_{i}.xlsx")

# Alignment of rows / columns across reports
# Import template for one file
template = pd.read_excel("data/raw/census_hhp/Data_Lookups_v4.xlsx")

# Setup template. Data files have previously been conformed across rows / columns
week_22_table = pd.ExcelFile("data/raw/census_hhp/table_5_week_22.xlsx")
week_22_tab_names = week_22_table.sheet_names

template = template.append([template] * (len(week_22_tab_names) - 1))

k = 689  # rows in template
state_names = [ele for idx, ele in enumerate(week_22_tab_names) for i in range(k)]
template['Region'] = state_names

state_names = [ele for idx, ele in enumerate(range(1, 68)) for i in range(k)]
template['Region_id'] = state_names

# Populate template for each file (this step can be further automated)
wb = load_workbook(filename="data/raw/census_hhp/table_5_week_22.xlsx")

for i in range(len(template['CELL'])):
    template['Count'].iloc[i] = wb[template['Region'].iloc[i]][template['CELL'].iloc[i]].value

print(template.head())
print(template.columns)

# Remove columns that are not useful for SQL upload
del template['CELL']
del template['Count_temp']
del template['Region']

# Save down for one file locally and check. Make sure to adjust survey_id
template.to_csv(r'data/raw/census_hhp/template_temp_22.csv', index = False)

# Consolidate into one file
all_files = [
    "data/raw/census_hhp/template_temp_22.csv",
    "data/raw/census_hhp/template_temp_23.csv",
    "data/raw/census_hhp/template_temp_24.csv",
    "data/raw/census_hhp/template_temp_25.csv",
    "data/raw/census_hhp/template_temp_26.csv",
    "data/raw/census_hhp/template_temp_27.csv",
    "data/raw/census_hhp/template_temp_28.csv",
    "data/raw/census_hhp/template_temp_29.csv",
]

consolidated_template = pd.concat((pd.read_csv(f) for f in all_files))
consolidated_template.to_csv(r'data/raw/census_hhp/Consolidated_template.csv', index=False)

#Check to:
# Update survey number (individual)
# Update characteristic_id / response_id columns - adjustments came later in the process
# Replace "-" and "" with "0"
