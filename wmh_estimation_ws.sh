#!/bin/bash

############################################################################################
#####                  White Matter Hyperintensity Estimation Script                   #####
############################################################################################

## IMPORTANT INFORMATION (please read before starting script)

### Minimum requirements prior to running this script:

    #### Files

        ##### T1 DICOM files
        ##### FLAIR DICOM files
        ##### Some subjects with a manual lesion mask (named: wmh.nii.gz), note: mask can only be produced after running BET

    #### Directory Locations

        ## Should have a parent directory that contains: this script + the sub-scripts that this script requires
        ## A sub-directory containing all the subject directories - the name of subject directories in this folder should be their ID
        ## Inside the subject directories there should be additional directories containing the T1 and FLAIR DICOM files

## Introduction (starting the script)

echo "Starting further sub-scripts to estimate WMHs."
sleep 2
echo "______"
sleep 1
echo "______"

## Checking that there are manual lesion masks before proceeding with pre-processing for BIANCA

while true; do

    echo "Do you have subjects with manually segmented lesion masks (y/n)?"
    read mask # read user input

    sleep 1
    echo "______"
    sleep 1

    if [ "$mask" = "y" ]; then

        echo "Subjects with manual lesion masks are available. Proceeding with BIANCA pre-processing."
        sleep 1
        echo "______"
        sleep 1

        break
    elif [ "$mask" = "n" ]; then

        echo "Please draw manual lesion (WMH) masks using FLAIR images for a subset of subjects (approximately 20-30%)."
        sleep 1
        echo "______"
        sleep 1
        echo "______"
        echo "Cancelling WMH estimation script."
        sleep 1
        echo "______"

        exit 0 # exits the script with a status of zero (exits script without an error)

    else
        echo "Invalid choice. Please enter 'y' or 'n'."
    fi
done
    
## Pre-processing subjects for BIANCA

while true; do

    echo "Do you need to pre-process images for BIANCA (y/n)?"
    read bianca_prep # read user input

    sleep 1
    echo "______"
    sleep 1

    if [ "$bianca_prep" = "y" ]; then
        echo "Starting script to pre-process images for BIANCA..."
        sleep 1
        echo "______"
        bash bianca_prep.sh # run sub-script
        break
    elif [ "$bianca_prep" = "n" ]; then
        echo "Skipping BIANCA pre-processing..."
        sleep 1
        echo "______"
        break
    else
        echo "Invalid choice. Please enter 'y' or 'n'."
    fi
done

sleep 1
echo "______"
sleep 1
echo "Brain extracted images have been pre-processed and are ready for BIANCA. Proceeding with the next stage."
sleep 1
echo "______"
sleep 1

## Running BIANCA

while true; do

    echo "Do you need to run BIANCA for subjects in your dataset (y/n)?"
    read bianca_run # read user input

    sleep 1
    echo "______"
    sleep 1

    if [ "$bianca_run" = "y" ]; then
        echo "Starting script to run BIANCA on subjects..."
        sleep 1
        echo "______"
        bash run_bianca.sh # run sub-script
        break
    elif [ "$bianca_run" = "n" ]; then
        echo "Skipping running BIANCA..."
        sleep 1
        echo "______"
        break
    else
        echo "Invalid choice. Please enter 'y' or 'n'."
    fi
done

sleep 1
echo "______"
sleep 1
echo "BIANCA has been executed for pre-processed subjects and data has been produced in an output file."
sleep 1
echo "______"
sleep 1

## Running reliability tests

while true; do

    echo "Do you want to test the reliability of the automated WMH segmentations produced by BIANCA \
    for subjects with a manual lesion mask (y/n)?"
    read reliability # read user input

    sleep 1
    echo "______"
    sleep 1

    if [ "$reliability" = "y" ]; then
        echo "Starting script to quantify BIANCA reliability..."
        sleep 1
        echo "______"
        sleep 1
        bash bianca_reliability_test.sh # run sub-script
        break
    elif [ "$reliability" = "n" ]; then
        echo "Skipping running BIANCA..."
        sleep 1
        echo "______"
        break
    else
        echo "Invalid choice. Please enter 'y' or 'n'."
    fi
done

sleep 1
echo "______""______""______"
sleep 3
echo "WMH estimation is complete!"