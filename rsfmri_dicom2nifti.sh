#!/bin/bash

# Resting-state DICOM to NIFTI conversion of necessary files

## Setup - source config file

source config.sh

## fMRI field maps

for dir in "$start_dir"/*/; do

    echo "Converting field maps from DICOM to NIFTI for: $(basename "$dir")"
    
    field_map_dir=$(find "$dir" -maxdepth 1 -type d -name "GRE_FIELD_MAPPING_00[0-9]*")
    if [[ -n "$field_map_dir" ]]; then

        cd "$dir"

        # Get the last integer in the folder names (FMAP_MAG is always represented by a lower 4th integer in FIND-TBI brain scans)
        MAG_folder=$(ls -1d GRE_FIELD_MAPPING_00* | sort -t'0' -k2,2n | tail -n 2 | head -n 1 | grep -oE '[0-9]+$')
        PHASE_folder=$(ls -1d GRE_FIELD_MAPPING_00* | sort -t'0' -k2,2n | tail -n 1 | grep -oE '[0-9]+$')

        echo "MAG = $MAG_folder"
        echo "PHASE = $PHASE_folder"

        # Magnitude image

        mag_dir=$(find . -type d -name "GRE_FIELD_MAPPING_$MAG_folder")
        cd "$mag_dir"

        dcm2niix -z y -f FMAP_MAG . # convert to NIFTI and create image name

        mv "FMAP_MAG_e1.nii.gz" "../FMAP_MAG.nii.gz" # move magnitude image back into subject parent directory and rename

        cd .. # move back to the subject scan directory

        echo "NIFTI magnitude field map produced for: $(basename "$dir")"

        # Phase image

        phase_dir=$(find . -type d -name "GRE_FIELD_MAPPING_$PHASE_folder")
        cd "$phase_dir"

        dcm2niix -z y -f FMAP_PHASE . # convert to NIFTI and create image name

        mv FMAP_PHASE_e2_ph.nii.gz ../FMAP_PHASE.nii.gz # move phase image back into subject parent directory

        cd "$original_dir" # move back to subject scan directory

        echo "NIFTI phase field map produced for: $(basename "$dir")"

    else
        echo "FMAP folders not found."
    fi

    cd "$original_dir"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject field maps."
sleep 1 
echo "______"
sleep 1

## 4D resting-state image

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting 4D resting state DICOM to NIFTI for: $(basename "$dir")" 

    cd "$dir"/EP2D_BOLD_MOCO_490_MEAS_SMS_8_00* # move into subject resting state directory

    dcm2niix -z y -f resting . # convert to NIFTI and create image name

    mv resting.nii.gz .. # move file outside of DICOM folder

    cd "$original_dir"

    echo "NIFTI 4D resting image produced for: $(basename "$dir")"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject 4D resting-state images."
sleep 1 
echo "______"
sleep 1

## T1 structural scan

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting T1 DICOM to NIFTI for: $(basename "$dir")" 

    cd "$dir"

    if [ -e T1* ]; then
        echo "DICOM T1 image already exists."
    else
    
        cd T1_MPRAGE_SAG_P2_0* # cd to T1 folder

        dcm2niix -z y -f T1 . # convert to NIFTI and create image name
        
        mv T1.nii.gz .. # move it outside its folder

        echo "$(basename "$dir") T1 converted."
    fi

    cd "$original_dir"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject T1 structural scans."
sleep 1 
echo "______"
sleep 1

## FLAIR structural scan

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting FLAIR DICOM to NIFTI for: $(basename "$dir")" 

    cd "$dir"

    if [ -e FLAIR* ]; then
        echo "DICOM FLAIR image already exists."
    else
    
        cd T2_FLAIR_SAG_P2_1MM_BIOBANK_0* # cd to FLAIR folder

        dcm2niix -z y -f FLAIR . # convert to NIFTI and create image name
        
        mv FLAIR.nii.gz .. # move it outside its folder

        echo "$(basename "$dir") FLAIR converted."
    fi

    cd "$original_dir"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject FLAIR structural scans."
sleep 1 
echo "______"
sleep 1
echo "DICOM to NIFTI conversions complete for resting-state pre-processing."