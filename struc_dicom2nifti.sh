#!/bin/bash

# Convert DICOM to NIFTI

## Setup - source config file

source config.sh

## DICOM to NIFTI conversion

echo "Starting DICOM to NIFTI conversion for subject T1 images"
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting for: $(basename "$dir")" 

    cd "$dir"

    if [ -e T1.nii.gz ]; then
        echo "DICOM T1 image already exists."
    else

        cd T1_MPRAGE_SAG_P2_0* # cd to T1 folder

        dcm2niix -z y -f T1 . # convert to nifti and create image name
        
        mv T1.nii.gz .. # move it outside its folder

        echo "$(basename "$dir") T1 converted."
    fi

    cd "$original_dir"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject T1 images"
sleep 1 
echo "______"
sleep 1

# ** Remove hashtag from the following to enable removal/checking of data **

# ## Optional removal of DICOM files

# while true; do

#     echo "Now that NIFTI files have been created, do you want to delete DICOM files (y/n)?"
#     read delete_DICOM # read user input

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$delete_DICOM" = "y" ]; then

#         echo "WARNING. This will permanently delete DICOM files off your system. You have 10 seconds to cancel this..."
#         sleep 10
#         echo "______"

#         for dir in $(find "$dirs" -maxdepth 1 -mindepth 1 -type d); do # looping through subject folders

#             echo "Deleting DICOM files for subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             cd "$dir"

#             rm -r T1_MPRAGE_SAG_P2_0* # remove T1 DICOM files
#             rm -r T2_FLAIR_SAG_P2_1MM_BIOBANK_0* # remove FLAIR DICOM files

#             cd ..

#             sleep 1
#             echo "DICOM files removed for subject $(basename "$dir")"
#             sleep 1
#             echo "______"
#             sleep 1
#         done

#         sleep 1
#         echo "______"
#         sleep 1
#         echo "DICOM files deleted for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         break

#     elif [ "$delete_DICOM" = "n" ]; then
#         echo "DICOM files were not deleted from system."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

# sleep 1
# echo "NIFTI files are available. Proceed with the next stage."
# sleep 1
# echo "______"
# sleep 1