#!/bin/bash

# BIANCA preparation 

## Introduction

    # need 4 files for each subject to run BIANCA:
        ### Main structural image (FLAIR)
        ### Binary manual lesion mask for subjects (used to train BIANCA)
        ### Transformation matrix (from main structural image to standard space) - to use spatial features (MNI coordinates)
        ### Other modalities to help segment WMHs (usually a T1-weighted structural image - obtained either via BET/FAST/FLIRT or fsl_anat/FLIRT)

echo "Starting BIANCA preparation."
sleep 2
echo "______"
sleep 2

## Setup - source config file

source config.sh

echo "Your chosen manual lesion mask file name is: $wmh" # display the chosen name to identify manual lesion mask file with 
sleep 1
echo "______"
sleep 1

## Registering T1 structural image to FLAIR image and bias correcting, while also registering FLAIR to MNI space (note: images should be brain extracted prior)
    
echo "Starting T1 registration to FLAIR (main image) and FLAIR registeration to MNI space for all subjects." # show T1 and FLAIR registeration has started
sleep 1
echo "______"
sleep 2

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do
    
    cd "$dir"

    ### running FAST (bias-field correction) for T1

    echo "Running bias-field correction for subject $(basename "$dir")" # show FAST is starting
    sleep 1
    echo "______"
    sleep 1

    fast -b -B --nopve -O 10 T1_roi_brain # generate bias-field corrected T1 image (without PVEs)

    mv T1_roi_brain_restore.nii.gz T1_roi_brain_bias-corrected.nii.gz # rename bias corrected image to something more obvious/explicit

    echo "T1 structural scan has been bias corrected for subject $(basename "$dir")" # show FAST has finished
    sleep 1
    echo "______"
    sleep 1

    ### running FLIRT for T1 to FLAIR (registration)

    echo "Registering $(basename "$dir") T1 strucutral to main image (FLAIR)." # show FLIRT is starting
    sleep 1
    echo "______"
    sleep 1
    
    flirt -dof 6 -in T1_roi_brain_bias-corrected -ref FLAIR_roi_brain -omat T1_roi_brain-2-FLAIR_brain_xfm.mat -out T1_roi_brain-2-FLAIR_roi_brain.nii.gz # register T1 to FLAIR

    echo "Bias corrected T1 for subject $(basename "$dir") has been registered to FLAIR." # show FLIRT has finished
    sleep 1
    echo "______"
    
    ### running FLIRT for FLAIR to MNI (registration)

    echo "Registering subject $(basename "$dir") FLAIR to standard (MNI) space." # show FLIRT is starting
    sleep 1
    echo "______"
    sleep 1

    flirt -in FLAIR_roi_brain -ref ${T_brain} -omat FLAIR_roi_brain-2-MNI_brain.mat \
    -out FLAIR_roi_brain-2-MNI_brain # register FLAIR to MNI (standard) space

    echo "FLAIR for subject $(basename "$dir") registered to standard (MNI) space." # show FLIRT has finished
    sleep 1
    echo "______"

    cd "$original_dir"

done

sleep 1
echo "All T1 images bias-corrected and registered + all FLAIR images registered to standard (MNI) space."
sleep 1
echo "______"
sleep 1

# ** Remove hashtag from the following to enable removal/checking of data **

# ## Checking data for each subject with a manual lesion via FSLeyes

# while true; do

#     echo "Would you like to check all the data for all subjects that have a manual lesion mask (y/n)?"
#     read check # read user input

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$check" = "y" ]; then

#         echo "Look to see if FLAIR image, lesion mask, and T1 image (registered to FLAIR) seem ok." # show it is time to visually check data
#         sleep 1
#         echo "______"
#         sleep 1

#         find "$start_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do # only including subjects with a manual lesion mask

#             if [ -e "$dir/$wmh" ]; then

#                 cd $dir
#                 echo "Checking subject $(basename "$dir") data." # loading FSLeyes for specified subject
#                 sleep 1
#                 echo "______"
#                 sleep 1

#                 fsleyes T1_roi_brain-2-FLAIR_roi_brain.nii.gz FLAIR_roi_brain.nii.gz "$wmh" -cm red -a 70 # check data

#                 echo "Subject $(basename "$dir") checked." # recognising that specified subject has had their scans and mask checked
#                 sleep 1
#                 echo "______"

#                 cd "$original_dir"
#             else 
#                 echo "Subject $(basename "$dir") does not contain a manual lesion mask."
#                 sleep 1
#                 echo "Therefore subject $(basename "$dir") data does not require checking."
#                 sleep 1
#                 echo "______"
#             fi
#         done

#         sleep 1
#         echo "All data for subjects with a manual lesion mask has been checked."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$check" = "n" ]; then
#         echo "Manual lesion masks were not checked."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

# echo "______"
# sleep 1
# echo "______"
# sleep 1
# echo "______"
# sleep 1
# echo "All data appears to be suitable. Moving to the next stage" # show data appears to be ok, if not then script should be manually cancelled by user
# sleep 3
# echo "______""______""______"
# sleep 3

## Generating a master file

    ### Master file contains all information for where to find files for BIANCA (gives an input for BIANCA)
    ### should contain one row per subject, and on each row, a list of all files for that subject (each file should have their parent [subject] directory specified in the master file)

echo "Creating master file for BIANCA training."
sleep 1
echo "______"
sleep 2

### Deleting old masterfile (if it exists)

cd "$start_dir"

file_to_delete="master_file.txt"

if [ -e "$file_to_delete" ]; then
    rm "$file_to_delete"
    echo "Old '$file_to_delete' has been deleted."
else
    echo "No old '$file_to_delete' exists in brain scan folder."
fi

cd ..

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    if [ -e "$dir/$wmh" ]; then

        echo $(basename "$dir")/FLAIR_roi_brain.nii.gz \
            $(basename "$dir")/T1_roi_brain-2-FLAIR_roi_brain.nii.gz \
            $(basename "$dir")/FLAIR_roi_brain-2-MNI_brain.mat \
            $(basename "$dir")/"$wmh" >> master_file.txt
    
    else
        :
    fi
done

mv master_file.txt "$start_dir"

sleep 1
echo "______"
sleep 1
echo "______"
sleep 1
echo "______"
sleep 1
echo "Master file created." # show master file has been successfully made
sleep 3
echo "______"
sleep 3
echo "Subjects ready for BIANCA!" # show subjects are pre-processed for BIANCA