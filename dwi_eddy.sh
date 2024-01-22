#!/bin/bash

# Eddy (correcting for motion and eddy currents in DWI data)

echo "Running eddy to correct for motion and eddy currents."
sleep 2
echo "______"

## Setup - source config file

source config.sh

## Checking that bvecs are correct before running eddy

echo "Using dtifit to check if bvecs are current before running eddy."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    echo "Checking subject $(basename "$dir"). If lines go across paths then either data and/or bvecs file are corrupted."
    sleep 1
    echo "______"
    sleep 1

    dtifit -k DWI.nii.gz -o DTI -m hifi_nodif_brain_mask -r DWI.bvec -b DWI.bval # creating a mask image

    # fsleyes dti_FA.nii.gz dti_V1.nii.gz -ot linevector -mo dti_FA # check data - see if lines follow pathways and don't go across paths
    ##### remove comment if you want to check each subject (removes automation)
    
    echo "Subject $(basename "$dir") checked."
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "Bvecs have been checked. Proceeding with eddy..."
sleep 1
echo "______"
sleep 1

## Running eddy (takes exactly 18 minutes per subject for MacBook with M3 (not pro or max) chip)

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    start_time=$(date +%s)  # record start time for subject

    cd "$dir"

    if [ -f "index.txt" ]; then # remove acqparams text file if it exists (so we start with a clean file)
        rm "index.txt"
    fi 

    echo "Starting eddy for subject $(basename "$dir") at $(date "+%H:%M:%S"). This will take 2-4 hours..."
    sleep 1
    echo "______"

    numing=$(fslval DWI.nii.gz dim4) # setting variable for indicies for all volumes of DWI
    index="index.txt" # creating index text file

    for ((i = 0; i < numing; i++)); do
        echo "1" >> "$index" # output total number of volumes at '1' to text file
    done

    eddy --imain=DWI --mask=hifi_nodif_brain_mask --index=index.txt --acqp=acqparams.txt \
    --bvecs=DWI.bvec --bvals=DWi.bval --fwhm=0 --topup=topup_AP_PA_b0 --flm=quadratic --out=eddy_unwarped_images \
    --data_is_shelled

    echo "Eddy has finished running for subject $(basename "$dir")"
    sleep 1
    echo "______"

    cd "$original_dir"

    end_time=$(date +%s) # record end time
    total_elapsed_time=$((end_time - start_time)) # record total elapsed time
    total_elapsed_hours=$((total_elapsed_time / 3600))
    total_elapsed_minutes=$(( (total_elapsed_time % 3600) / 60 )) # calculating time in hours and minutes

    echo "Total time for subject $(basename "$dir"): $total_elapsed_hours hours and $total_elapsed_minutes minutes." # print run time
    sleep 1
    echo "______"

done

echo "Eddy complete for all subjects. Diffusion-weighted images should be in alignment with each other and undistorted."
sleep 1
echo "______"
sleep 1

# ** Remove hashtag from the following to enable removal/checking of data **

# # Checking eddy output before continuing with microstructural analysis

# while true; do

#     echo "Would you like the check the output of eddy before continuing with diffusion analyses (y/n)?"
#     read check

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$check" = "y" ]; then

#         echo "Checking eddy output for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

#             cd "$dir"

#             echo "Looking at subject $(basename "$dir"). Run in movie mode, should look exactly like 'DWI.nii.gz' but distortion corrected."

#             sleep 1
#             echo "______"
#             sleep 1

#             fsleyes DWI.nii.gz -dr 0 12500 eddy_unwarped_images.nii.gz -dr 12500 # check data, see difference between corrected vs uncorrected

#             echo "Subject $(basename "$dir") has been checked."

#             sleep 1
#             echo "______"
#             sleep 1

#             cd "$original_dir"

#         done

#         echo "Eddy output checked for all subjects. Continue with analyses..."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$check" = "n" ]; then
#         echo "Eddy output was not checked for dataset."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'"
#     fi
# done

# echo "Able to now run microstructural analysis or tractography on pre-processed DWI data..."