#!/bin/bash

# Resting-state brain extraction

## Setup - source config file

source config.sh

## ROI crop of T1 structural scans (cropping out the neck)

echo "Removing the neck from all subjects' T1 images."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    if [ -e T1_roi.nii.gz ]; then
        :
    else
        robustfov -i T1.nii.gz -r T1_roi # command to automatically identify where to crop for only neck removal
    fi

    cd "$original_dir"

done

sleep 1
echo "Neck cropped out of T1 images for all subjects in directory."
sleep 1
echo "______"
sleep 1

### Brain extraction for field map magnitude image

echo "Brain extracting FMAP_MAG images for all subjects..."
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    echo "Running BET for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    bet2 FMAP_MAG FMAP_MAG_brain # can also erode this further by one voxel all around brain tissue using 'fslmaths -ero'

    echo "Subject $(basename "$dir") brain extracted."
    sleep 1
    echo "______"

    cd "$original_dir"

done

sleep 1
echo "All subject magnitude field maps brain extracted."
sleep 1
echo "______"

## T1 brain extraction via FLAIR scans

echo "Running BET via FLAIR images for better delineation of brain material."
sleep 1
echo "______"
sleep 1

t1_bet_check=false

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    if [ ! -e T1_roi_brain.nii.gz ]; then
        echo "Not all subjects have brain extracted T1 structural scans. Loading sub-script to generate these files."
        t1_bet_check=true
        break
    fi

    cd "$original_dir"

done

if [ "$t1_bet_check"= true ]; then
    bash struc_bet_via_flair.sh # run sub-script
fi

echo "______"
sleep 1
echo "T1 BET finished."
sleep 1
echo "______"
