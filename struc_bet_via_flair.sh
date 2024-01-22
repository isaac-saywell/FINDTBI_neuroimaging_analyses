#!/bin/bash

# T1 brain extraction via FLAIR images

## Setup - source config file

source config.sh

## Exit script if T1_roi_brain images already exist

total_subjects=$(find "$start_dir" -maxdepth 1 -mindepth 1 -type d | wc -l)
found_count=0

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    if [ -e "$dir"/T1_roi_brain.nii.gz ]; then
        ((found_count++))
    fi
done

if [ "$found_count" -eq "$total_subjects" ]; then
    echo "Structural images, brain extracted by FLAIR scan registration already exist in all subject directories. Exiting script."
    exit 0
fi

## ROI cropping for FLAIR scan

echo "Cropping neck out of FLAIR scans."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    if [ -e FLAIR_roi.nii.gz ]; then
        echo "Cropped FLAIR images already exist."
    else
        robustfov -i FLAIR.nii.gz -r FLAIR_roi # command to automatically identify where to crop for only neck removal
    fi 

    cd "$original_dir"

done

echo "______"
sleep 1
echo "Neck removed from all subject FLAIR scans."
sleep 1
echo "______"
sleep 1

## Registering FLAIR to T1

echo "Registering FLAIR to T1 Space for all subjects."

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Running FLIRT for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    flirt -dof 6 -in FLAIR_roi.nii.gz -ref T1_roi.nii.gz -omat FLAIR-2-T1.mat -out FLAIR-2-T1.nii.gz

    echo "Finished FLIRT for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "All subject FLAIR images registered to T1 space."

sleep 1
echo "______"
sleep 1

## Brain extraction for FLAIR images

echo "Commencing brain extraction for all subject FLAIR (in T1 space) images."

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Running BET for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    bet2 FLAIR-2-T1.nii.gz FLAIR-2-T1_brain.nii.gz

    echo "Finished BET for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "All subject FLAIR-2-T1 images have been brain extracted."

sleep 1
echo "______"
sleep 1

## Eroding brain extraction image by one voxel

echo "Eroding BET images by one voxel for all subjects."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Eroding BET image for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    fslmaths FLAIR-2-T1_brain.nii.gz -ero FLAIR-2-T1_brain_refined.nii.gz

    echo "Erosion complete for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "BET image erosion complete for all subjects."

sleep 1
echo "______"
sleep 1

## Binarising brain extracted image

echo "Binarising brain extracted image (eroded or not eroded) into a mask."

sleep 1
echo "______"
sleep 1

for dir in "$start_dir"/*/; do
    if [ -e "$dir/FLAIR-2-T1_brain_refined.nii.gz" ]; then
        brain2mask="FLAIR-2-T1_brain_refined.nii.gz"
        break 
    else
        brain2mask="FLAIR-2-T1_brain.nii.gz"
    fi
done

echo "Chosen BET image to mask is ${brain2mask}"

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Binarising BET image for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    fslmaths "$brain2mask" -bin FLAIR-2-T1_brain_mask.nii.gz

    echo "Finished creating BET image mask for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "All subject BET images have been converted into binarised masks."

sleep 1
echo "______"
sleep 1

## Deleting non-brain tissue from T1 image using FLAIR-2-T1 brain mask

echo "Removing non-brain tissue using FLAIR-2-T1 brain mask."

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Removing non-brain tissue in T1 image for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    fslmaths T1_roi.nii.gz -mas FLAIR-2-T1_brain_mask.nii.gz T1_roi_brain.nii.gz

    echo "Finished non-brain tissue removal for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "Non-brain tissue removed for all subjects with FLAIR-2-T1 masks."

sleep 1
echo "______"
sleep 1