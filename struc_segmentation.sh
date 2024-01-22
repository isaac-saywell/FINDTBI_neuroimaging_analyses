#!/bin/bash

# Automated Segementation of CSF, Grey Matter, and White Matter

## Setup - source config file

source config.sh

## Running FAST to segement the three tissue types

echo "Starting automated segmentation of CSF, GM, and WM."
sleep 2
echo "______"
sleep 1
echo "WARNING: you will require NIFTI images that have been cropped and brain extracted before running this script "
sleep 4
echo "______"
sleep 1

echo "Running FAST for subjects to segment three tissue types."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    echo "Segmenting tissue for subject $(basename "$dir")"
    sleep 1
    echo "______"

    fast -O 10 T1_roi_brain # running FAST to generate PVEs

    echo "Subject $(basename "$dir") has been segmented."
    sleep 1
    echo "______"

    cd "$original_dir"

done

sleep 2
echo "FAST complete for all subjects. PVEs produced."
sleep 2
echo "______"
sleep 2

# ** Remove hashtag from the following to enable removal/checking of data **

# ## Checking results of FAST in FSLeyes

# while true; do

#     echo "Do you need to check the partial volume segmentations for each subject (y/n)?"
#     read check # read user input

#     sleep 1
#     echo "______"
#     sleep 1 

#     if [ "$check" = "y" ]; then

#         echo "Checking PVEs for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         find "$start_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do # while loop allowing viewing of PVEs for all subjects in directory

#             cd "$dir"

#             echo "Checking PVEs for subject $(basename "$dir")"
#             sleep 1
#             echo "______"
#             sleep 1
#             echo "Note: green = CSF, blue = GM, red = WM."

#             fsleyes T1_roi_brain -b 60 -c 70 T1_roi_brain_pve_0 -cm green -dr 0.5 1 \
#             T1_roi_brain_pve_1 -cm blue-lightblue -dr 0.5 1 T1_roi_brain_pve_2 -cm red-yellow -dr 0.5 1 # check data

#             echo "______"
#             sleep 1
#             echo "Subject $(basename "$dir") PVEs checked."
#             sleep 1
#             echo "______"

#             cd "$original_dir"

#         done

#         echo "______"
#         sleep 1
#         echo "PVEs for all subjects have been checked."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$check" = "n" ]; then
#         echo "PVEs for subjects were not checked in FSLeyes."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

## Writing CSF, GM, and WM to CSV file

sleep 1
echo "Outputting tissue volume for each of the three PVE components (CSF, GM, WM) to a CSV file."
sleep 1
echo "______"
sleep 1

echo "subject,CSF_vol,voxCSF,GM_vol,voxGM,WM_vol,voxWM,TOT_brain_vol,TOT_icv" > struc_tissueseg_data.csv # creating CSV file with headers

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # while loop writing volumes to CSV for every subject

    cd "$dir"
    
    CSF_vol=`fslstats T1_roi_brain_pve_0 -M -V | awk '{ vol = $1 * $3 ; print vol }'` # prints volume for CSF

    voxCSF=`fslstats T1_roi_brain_pve_0 -V | awk '{ vox = $1; print vox }'` # prints total number of voxels for CSF

    GM_vol=`fslstats T1_roi_brain_pve_1 -M -V | awk '{ vol = $1 * $3 ; print vol }'` # prints volume for GM

    voxGM=`fslstats T1_roi_brain_pve_1 -V | awk '{ vox = $1; print vox }'` # prints total number of voxels for GM

    WM_vol=`fslstats T1_roi_brain_pve_2 -M -V | awk '{ vol = $1 * $3 ; print vol }'` # prints volume for WM

    voxWM=`fslstats T1_roi_brain_pve_2 -V | awk '{ vox = $1; print vox }'` # prints total number of voxels for WM

    # -V = outputs voxels and volume for "non-zero" voxels
    # -M = outputs the mean voxel PVE across "non-zero" voxels
    # multiplying the mean voxel across the image (ignoring voxels with an intensity of zero) by the second number produced by -V (volume) gives total volume in mm^3

    TOT_brain_vol=$(echo "$GM_vol + $WM_vol" | bc) # adding both types of tissues together to calculate total brain volume

    TOT_icv=$(echo "$TOT_brain_vol + $CSF_vol" | bc) # adding all PVEs together to obtain an estimate of total ICV

    cd "$original_dir"

    echo "$(basename "$dir"),${CSF_vol},${voxCSF},${GM_vol},${voxGM},${WM_vol},${voxWM},${TOT_brain_vol},${TOT_icv}" >> struc_tissueseg_data.csv

done

sleep 2
echo "______"
sleep 2
echo "CSV file with segmentation data has been created."
sleep 2
echo "______"