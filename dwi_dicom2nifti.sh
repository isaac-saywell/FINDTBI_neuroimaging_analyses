#!/bin/bash

# Convert DICOM to NIFTI for DWI (main diffusion scan and scans with reverse phase-encode directions)

## Setup - source config file

source config.sh

## DICOM to NIFTI conversion

echo "Beginning DICOM to NIFTI conversion for DWI data."
sleep 1
echo "______"

## Main diffusion scan (dwidata, bvals, bvecs)

echo "Starting DICOM to NIFTI conversion for subject diffusion images"
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting for: $(basename "$dir")" 

    cd "$dir"

    if [ -e DWI.nii.gz ]; then
        echo "DICOM DWI image already exists."
    else
        cd CMRR_MB3_DIFF_B0_B1000_B2000_104_DIRECTIONS_00* # cd to main diffusion DICOM folder

        dcm2niix -i y -z y -f DWI . # convert to nifti and create image name
        
        mv DWI.nii.gz .. # move main diffusion image out of DICOM folder
        mv DWI.bval .. # move bvals file out of DICOM folder
        mv DWI.bvec .. # move bvecs file out of DICOM folder
        mv DWI.json .. # move .json file out of DICOM folder

        echo "$(basename "$dir") main diffusion scan converted."
    fi

    cd "$original_dir"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject main diffusion scans."
sleep 1 
echo "______"
sleep 1

## Scans with reversee phase-encode directions (there can be more than one)

echo "Starting DICOM to NIFTI conversion for subject reverse phase-encode direction images"
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    echo "Converting for: $(basename "$dir")"

    cd "$dir"

    if [ -e DWI_PA.nii.gz ]; then
        echo "DICOM DWI_PA image already exists."
    else
        cd DIFF_MB3_PA_00* # cd to reverse phase-encode scan folder

        dcm2niix -i y -z y -f DWI_PA . # convert to nifti and create image name
        
        mv DWI_PA.nii.gz .. # move it outside its DICOM folder
        mv DWI_PA.bval .. # move it outside its DICOM folder
        mv DWI_PA.bvec .. # move it outside its DICOM folder
        mv DWI_PA.json .. # move .json file outside of DICOM folder

        echo "$(basename "$dir") scans with reverse phase-encode directions converted."
    fi

    cd "$original_dir"

done

sleep 1
echo "______"
sleep 1
echo "DICOM to NIFTI conversion complete for all subject reverse phase-encode direction scans."
sleep 1
echo "______"
sleep 1

echo "All subjects DICOM files converted to NITFI."
sleep 1
echo "______"

# ** Remove hashtag from the following to enable removal/checking of data **

# ## Optional removal of diffusion DICOM files

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

#             echo "Deleting diffusion DICOM files for subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             cd "$dir"

#             rm -r CMRR_MB3_DIFF_B0_B1000_B2000_104_DIRECTIONS_00* # remove directory with main diffusion scan DICOM files
#             rm -r DIFF_MB3_PA_00* # remove directory with reverse phase-encode directions scans 

#             cd "$original_dir"

#             sleep 1
#             echo "Diffusion DICOM files removed for subject $(basename "$dir")"
#             sleep 1
#             echo "______"
#             sleep 1
#         done
        
#         sleep 1
#         echo "Diffusion DICOM files deleted for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         break

#     elif [ "$delete_DICOM" = "n" ]; then
#         echo "Diffusion DICOM files were not deleted from system."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

# sleep 1
# echo "Diffusion NIFTI files are available."
# sleep 1
# echo "______"
# sleep 1

# ## Optional checking of data

# while true; do

#     echo "Now that NIFTI files have been created, do you want to check your main diffusion scan for any severe/large artifacts (y/n)?"
#     read check # read user input

#     sleep 1
#     echo "______"
#     sleep 1
    
#     if [ "$check" = "y" ]; then

#         echo "Checking main diffusion check for all subjects via FSLeyes. Once FSLeyes open run a movie loop to check all 3D volumes."
#         sleep 1
#         echo "______"

#         for dir in $(find "$dirs" -maxdepth 1 -mindepth 1 -type d); do # looping through subject folders

#             echo "Checking diffusion scans (main one first) for subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             cd "$dir"

#             fsleyes DWI.nii.gz # check main diffusion data (run movie loop to check 3D volumes look ok)
#             fsleyes DWI_PA.nii.gz # check scans with reverse phase-encode directions (run movie loop - all volumes should look very similar, unlike the main diffusion scan)

#             cd ../..

#             sleep 1
#             echo "Subject $(basename "$dir") diffusion data has been checked."
#             sleep 1
#             echo "______"
#             sleep 1
#         done

#         sleep 1
#         echo "Diffusion data checked for major artifacts across all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$check" = "n" ]; then
#         echo "Diffusion data was not checked in FSLeyes."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done