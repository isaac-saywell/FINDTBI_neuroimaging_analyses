#!/bin/bash

# Calculating whole-brain FA and MD statistics

echo "Calculating FA and MD for each participant."
sleep 1

## Setup - source config file

source config.sh

## Output to CSV file

echo "subject,FA,MD,AD,RD" > dwi_data.csv # creating CSV file with headers

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # while loop writing volumes to CSV for every subject

    cd "$dir"
    
    FA=`fslstats DTI_FA_corrected -M | awk '{ fa = $1; print fa }'` # prints mean FA value for the subject's entire brain

    MD=`fslstats DTI_MD -M | awk '{ md = $1; print md }'` # prints mean MD value for subject's entire brain

    AD=`fslstats DTI_L1 -M | awk '{ ad = $1; print ad}'` # prints mean AD value for subject's entire brain

    fslmaths DTI_L2.nii.gz -add DTI_L3.nii.gz -div 2 DTI_RD.nii.gz # create a radial diffusivity brain map
    RD=`fslstats DTI_RD -M | awk '{ rd = $1; print rd}'` # prints mean RD value for subject's entire brain

    cd "$original_dir"

    echo "$(basename "$dir"),${FA},${MD},${AD},${RD}" >> dwi_data.csv

done

sleep 1
echo "______"
sleep 1
echo "CSV file with basic diffusion parameters has been created."
sleep 1
echo "______"