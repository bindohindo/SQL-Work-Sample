import pandas as pd
import os

path = "Raw Data"

# Create a list of all the CSV files in the directory
aggregated_data = []
for file in os.listdir(path):
    if file.endswith(".csv"):
        aggregated_data.append(file)

# Read each CSV into a DataFrame
df_list = []
for file in aggregated_data:
    p = os.path.join(path, file)
    df = pd.read_csv(p)
    df_list.append(df)

# Collate all DataFrames into one and save it in the root folder
all_matches = pd.concat(df_list, ignore_index=True)
all_matches.to_csv("all_matches_raw.csv", index=False)