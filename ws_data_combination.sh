#!/bin/bash

# Bash script for loading python code to combine data from several CSV files together

## Using the current directory as the input directory

input_dir="$PWD"

## Specifying the python script file

python_script="csv_file_merge.py"

## Python script will fail if there are any empty CSV files in directory - following code exits this bash script if there is an empty CSV file
### Note all CSV files in this directory should also have the same number of rows

echo "______"
sleep 1
echo "Making sure there are no empty CSV files in working directory (python code will fail if there are)."
sleep 1
echo "______"

empty_csv_files=($(find . -maxdepth 1 -type f -name "*.csv" -size 0)) # locating any empty CSV files in working directory

if [ ${#empty_csv_files[@]} -gt 0 ]; then
    echo "Empty CSV file(s) found in the current directory. Exiting the script."
    exit 1 # exit with error - empty CSV files found
else
    echo "No empty CSV files found. Proceeding with the script."
fi

## Running the python script with Python 3 and extracting the last item printed from the python script

echo "Enter the desired final output CSV file name (e.g., 'brain_data.csv'): " # since we are stored the python script print in a variable no print statements will appear in terminal, hence an echo is used here to give direction to the user

output_file_name=$(python3 "$python_script" | tail -n 1)

sleep 1
echo "______"
sleep 1
echo "Python script executed."
sleep 1
echo "______"
sleep 1
echo "Data from all FSL brain measure parameters that have been used is saved as a CSV file."
sleep 1
echo "______"

## Removing old combined data CSV file if it exists

input_csv="$output_file_name" # name of CSV file specified in 'csv_file_merge.py' python script
output_csv="${output_file_name}_appended.csv" # name for CSV file that is to be appended with healthy brain volume

## Estimating healthy brain volume from FAST and BIANCA outputs

sleep 1
echo "______"
sleep 1

echo "Calculating 'healthy brain volume' for all subjects by taking the difference of 'total brain volume' and 'wmh volume'."
sleep 1
echo "______"
sleep 1

### Using awk to calculate and print healthy brain volume in appended CSV file

awk 'BEGIN {FS=OFS=","}
FNR == 1 {
    for (i = 1; i <= NF; i++) {
        if ($i == "TOT_brain_vol") tot_brain_col = i
        if ($i == "wmh_clustervol") wmh_clustervol_col = i
    }
    if (tot_brain_col == "" || wmh_clustervol_col == "") {
        print "Error: TOT_brain_vol or wmh_clustervol column not found in the input file."
        exit 1
    }
    print $0, "healthybrain_vol"
    next
}
{
    tot_brain_vol = $tot_brain_col
    wmh_clustervol = $wmh_clustervol_col
    healthybrain_vol = tot_brain_vol - wmh_clustervol

    # Use printf to format healthybrain_vol as an integer.
    printf "%s%s%d\n", $0, OFS, healthybrain_vol
}' "$input_csv" > "$output_csv"

if [ -e "$input_csv" ]; then
    rm "$input_csv"
    echo "Old "$input_csv" data file without healthy brain volume deleted."
    sleep 1
    echo "______"
    sleep 1
else
    echo "An older "$input_csv" data file does not exist."
    sleep 1
    echo "______"
    sleep 1
fi

mv "$output_csv" "$input_csv"

echo "______"
sleep 1
echo "CSV file with all brain measure parameter data created as '"$input_csv"'."
sleep 1
echo "Data combination has been completed."