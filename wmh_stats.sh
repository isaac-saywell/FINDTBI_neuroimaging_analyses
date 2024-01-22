#!/bin/bash

# White Matter Hyperintensity Volume Statistics

## Setup

source config.sh

## Calculating lesion volume and putting values in CSV file

echo "Calculating WMH volume."
sleep 2
echo "______"
sleep 2

if [ -e "wmh_data.csv" ]; then
    rm "wmh_data.csv"  # delete CSV file if it exists
fi

echo "subject,wmh_num_vox,wmh_vol,wmh_num_cluster,wmh_clustervol" > wmh_data.csv # creating CSV file with headers

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # while loop writing volumes to CSV for every subject

    wmh_num_vox=`fslstats $dir/bianca_output_bin.nii.gz -V | awk '{ x = $1; print x }'` # without masks and using fslstats rather than bianca_cluster_stats
    wmh_vol=`fslstats $dir/bianca_output_bin.nii.gz -V | awk '{ x = $2; print x }'` # without masks and using fslstats rather than bianca_cluster_stats
    
    bianca_clusterstats_output=$(bianca_cluster_stats "$dir/bianca_output_bin.nii.gz" 0 $clus_size "$dir/T1_roi_brain_bianca_mask2FLAIR.nii.gz")
    wmh_num_cluster=$(echo "$bianca_clusterstats_output" | awk '/T1_roi_brain_bianca_mask2FLAIR.nii.gz/ && /WMH number/ {print $NF}')
    wmh_clustervol=$(echo "$bianca_clusterstats_output" | awk '/T1_roi_brain_bianca_mask2FLAIR.nii.gz/ && /WMH volume/ {print $NF}')

    echo "$(basename "$dir"),${wmh_num_vox},${wmh_vol},${wmh_num_cluster},${wmh_clustervol}" >> wmh_data.csv

done

echo "______"
sleep 1
echo "CSV file created."