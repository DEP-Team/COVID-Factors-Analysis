import requests
import numpy as np
import pandas as pd
import urllib
import openpyxl
from openpyxl import Workbook, load_workbook

week_list =[22,23,24,25,26,27,28,29]

#Download weekly reports
for i in week_list:
    urllib.request.urlretrieve(f"https://www2.census.gov/programs-surveys/demo/tables/hhp/2021/wk{i}/health5_week{i}.xlsx", f"C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/table_5_week_{i}.xlsx")  

# Alignment of rows / columns across reports

#Import template for one file
Template = pd.read_excel("C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/EERD/Data_Lookups_v4.xlsx")

### Setup Template. Data files have previously been conformed across rows / columns
week_22_table = pd.ExcelFile("C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/table_5_week_22.xlsx")
Week_22_tab_names=week_22_table.sheet_names

Template = Template.append([Template]*(len(Week_22_tab_names)-1))

K = 689 # rows in template
state_names = [ele for idx, ele in enumerate(Week_22_tab_names) for i in range(K)]
Template['Region'] = state_names

K = 689 # rows in template
state_names = [ele for idx, ele in enumerate(range(1,68)) for i in range(K)]
Template['Region_id'] = state_names

#Populate template for each file (this step can be further automated)
wb = load_workbook(filename="C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/table_5_week_22.xlsx")

for i in range(len(Template['CELL'])):
    Template['Count'].iloc[i] = wb[Template['Region'].iloc[i]][Template['CELL'].iloc[i]].value

print(Template.head())
print(Template.columns)

#Remove columns that are not useful for SQL upload
del Template['CELL']
del Template['Count_temp']
del Template['Region']

#Save down for one file locally and check. Make sure to adjust survey_id
Template.to_csv(r'C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_22.csv', index = False)

#Consolidate into one file
all_files=["C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_22.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_23.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_24.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_25.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_26.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_27.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_28.csv","C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Template_temp_29.csv"]
Consolidated_Template = pd.concat((pd.read_csv(f) for f in all_files))
Consolidated_Template.to_csv(r'C:/Users/Fetouh/Desktop/Rami_Temp/Data_Engineering/Project/Vaccinations/Downloads/Upload/Consolidated_Template.csv', index = False)

#Check to: 
# Update survey number (individual)
# Update characteristic_id / response_id columns - adjustments came later in the process
# Replace "-" and "" with "0"

print('complete')