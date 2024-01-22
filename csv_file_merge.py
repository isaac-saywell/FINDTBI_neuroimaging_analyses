# CSV merger tool

## Setup

import os
import pandas as pd

input_dir = os.getcwd() # directory containing the CSV files to combine
output_file = 'combined_data.csv' # output CSV file where the input CSV data will be copied to
combined_data = pd.DataFrame() # empty dataframe to store the combined data

output_file_name = input("Enter the desired final output CSV file name (e.g., 'brain_data.csv'): ") # give user option to name CSV file with all MRI data

if os.path.exists(output_file): # checking if the output file used to merge already exists
    os.remove(output_file) # deleting output file if it does exist

if os.path.exists(output_file_name): # checking if there is already a CSV file with the chosen name
    os.remove(output_file_name) # deleting if it does exist

## Combining all input CSV files (those in the working directory) into a variable

for filename in os.listdir(input_dir): # looping through all CSV files in the input directory
    if filename.endswith('.csv'):
        file_path = os.path.join(input_dir, filename)
        data = pd.read_csv(file_path)  # reading each CSV file into a dataframe
        data = data.set_index('subject') # necessary to ensure data from all CSV files is concatenated horizontally (uses subject column as an index)
        combined_data = pd.concat([combined_data, data], axis=1, sort=False) # data concatenated into to the "combined_data" data horizontally (side by side)

        ## the lines of code ensuring horizontal printing of data is important, otherwise some CSV files will print in rows below subject ID numbers

combined_data.reset_index(inplace=True) # reseting the index to ensure it is unique

# Writing the combined data to a new CSV file

combined_data.to_csv(output_file, index=False)

# Removing any columns in the dataframe that are duplicates (this is to avoid duplicating subject ID columns)

combined_data = combined_data.loc[:, ~combined_data.columns.duplicated()]

# Writing the cleaned data (without duplicates) to a new CSV file

output_cleaned_file = 'combined_data_cleaned.csv'
combined_data.to_csv(output_cleaned_file, index=False)

# Removing the old output CSV file (not cleaned)

if os.path.exists('combined_data.csv'): # so there's reduced chance for error in code this is written as an 'if statement'
    os.remove('combined_data.csv')
    print('combined_data.csv removed')

# Renaming the output CSV file to desired name

if os.path.exists('combined_data_cleaned.csv'): # same as previous set of code, 'if statement' used to reduce chance of an error
    os.rename('combined_data_cleaned.csv', output_file_name)  
    print(f'combined_data_cleaned.csv renamed to {output_file_name}') # showing cleaned, combined data has been renamed

# Printing the chosen name for the CSV file

print(output_file_name)