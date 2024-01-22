#!/bin/bash

# Resting fMRI test script

echo "Starting resting state fMRI pre-processing for ICA."
sleep 2
echo "______"

## Setup - source config file

source config.sh

### Required DICOM files

    # GRE_FIELD_MAPPING_000*LOWER NUMBER = MAG image files (will output two nifti images pick one of two)
    # GRE_FIELD_MAPPING_000*HIGHER NUMBER = PHASE image files
    # EP2D_BOLD_MOCO_490_MEAS_SMS_8_0009 = Resting state 4D files
    # T1_MPRAGE = T1 structural scan (needs to be brain extracted)
    # FLAIR = T2 FLAIR scan (for T1 brain extraction)

## Produce field map image in radians (RADS) 

#### ** CURRENTLY IN FSL 6.0.7.1 ON MACOS THIS COMMAND DOES NOT WORK AS THE SCRIPT FOR IT DOES NOT EXIST (need to produce FMAPS in RADS separately or move script into fsl directory) **

echo "Using field map files to produce a field map image in radians (RADS)"
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting to RADS for: $(basename "$dir")"
    sleep 1
    echo "______"

    cd "$dir"

    fsl_prepare_fieldmap SIEMENS FMAP_PHASE.nii.gz FMAP_MAG_brain.nii.gz FMAP_RADS 2.46 ### currently does not have a command line option

    cd "$original_dir"

    sleep 1
    echo "Fieldmap RADS image produced for: $(basename "$dir")"
    sleep 1
    echo "______"

done

sleep 1
echo "'FMAP_RADS' images produced for all subjects in directory."
sleep 1
echo "______"
sleep 1

## Running melodic (single-subject)

echo "Running melodic for all subjects using automatically generated, subject specific design files"
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Running automated melodic for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    feat "$(basename "$dir")_design.fsf" # run automated melodic for all subjects

    echo "______"
    sleep 1
    echo "Melodic finished for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

sleep 3
echo "______"
sleep 1
echo "Melodic complete for all subjects."
sleep 1
echo "______"
sleep 1

echo "Resting-state single-subject pre-processing is complete." 
sleep 1
echo "______"
sleep 1
echo "Now components should be either classified manually in FSLeyes or a training set needs to be developed in FSLeyes before automated component classification."