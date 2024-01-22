#!/bin/bash

# Crop out the neck of T1 and FLAIR images

## Setup - source config file

source config.sh

echo "WARNING: you will require NIFTI images before running this script "
sleep 3
echo "______"
sleep 1

echo "Removing the neck from all subjects' T1 and FLAIR images."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    if  [ -e FLAIR_roi.nii.gz ]; then
        echo "Cropped FLAIR images already exist."
    else
        robustfov -i FLAIR.nii.gz -r FLAIR_roi # command to automatically identify where to crop for only neck removal
    fi

    cd "$original_dir"

done

sleep 1
echo "Neck cropped out of T1 and FLAIR images for all subjects in directory."