#!/bin/bash

# Topup (to estimate and correct for susceptibility induced distortions)

echo "Running Topup to correct for susceptibility induced distortions."
sleep 2
echo "______"

## Setup - source config file

source config.sh

### Creating readtime function to read .json files

get_readtime() {
    filename=$1
    while IFS= read -r line; do
        if [[ $line =~ "TotalReadoutTime" ]]; then
            line=$(echo $line | sed 's/.*: //' | sed 's/, *$//')
            readtime=$(echo $line | sed 's/, *$//')
            echo $readtime
            return
        fi
    done < "$filename"
}

## Generating files needed to run Topup

echo "Selecting DWI 3D volumes for bvals=100 and extracting into a new image."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    echo "Identifying and extracting 3D volumes with approximately bvals=100 for subject $(basename "$dir")"
    sleep 1
    echo "______"

    select_dwi_vols DWI.nii.gz DWI.bval B0_main $bval # output file is B0_main

    echo "Extraction complete for subject $(basename "$dir")"
    sleep 1
    echo "______"

    cd "$original_dir"

done

echo "Extraction finished for all subjects in dataset."
sleep 1
echo "______"
sleep 1

## Making text file (acqparams.txt) (AP is negative, PA is positive) and
## Concatenating reverse phase-encoded B0 images into a single image for Topup

echo "Creating Topup parameters text file (acqparams.txt) for each subject."
echo "And merging B0 images."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    json_file="${original_dir}/${dirs}/$(basename "$dir")/DWI.json"
    json_file_PA="${original_dir}/${dirs}/$(basename "$dir")/DWI_PA.json"

    cd "$dir"

    if [ -f "acqparams.txt" ]; then # remove acqparams text file if it exists (so we start with a clean file)
        rm "acqparams.txt"
    fi 

    echo "Producing text file for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    b0imgs="${original_dir}/${dirs}/$(basename "$dir")/B0_main" # set location for extracted B0 images
    readtime=$(get_readtime "$json_file") # get readtime from .json file
    num_b0=$(fslval B0_main dim4) # capture 4th dimension of B0 image (4th time series axis)

    acqparams_old="acqparams_old.txt" # create parameters text file

    for ((i = 0; i < num_b0; i++)); do
        echo "0 -1 0 $readtime" >> "$acqparams_old"
    done

    select_dwi_vols DWI_PA.nii.gz DWI_PA.bval DWI_B0_PA $bval # select volumes with b=100 for reverse phase-encoding scan, output file is B0_main

    b0imgs_PA="${original_dir}/${dirs}/$(basename "$dir")/DWI_B0_PA"
    readtime_PA=$(get_readtime "${json_file_PA}")
    num_b0_PA=$(fslval DWI_B0_PA dim4)

    for ((i = 0; i < num_b0_PA; i++)); do
        echo "0 1 0 $readtime_PA" >> "$acqparams_old"
    done

    while read -r line; do
        echo $line | tr -s ' ' ' ' >> acqparams.txt # append spaces between rows text (not sure if needed but these spaces were present in DTI_training acqparams.txt files)
        echo >> acqparams.txt
    done < "$acqparams_old"

    if [ -f "acqparams_old.txt" ]; then # remove acqparams text file if it exists (so we start with a clean file)
        rm "acqparams_old.txt"
    fi 

    echo "acqparams.txt produced for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    echo "Merging B0 images across time for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    fslmerge -t AP_PA_b0 "$b0imgs" "$b0imgs_PA" # merging all b0 images across time

    echo "B0 images merged for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "All subjects now have an acqparams.txt in their directory."
echo "And all subjects have a merged B0 image for Topup."
sleep 1
echo "______"
sleep 1

## Running Topup

echo "Commencing Topup for each subject."
sleep 1
echo "______"
sleep 1
echo "Warning. Topup may take an extended period of time per subject."
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    echo "Running Topup for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    topup --imain=AP_PA_b0 --datain=acqparams.txt --config=b02b0.cnf --out=topup_AP_PA_b0 --iout=topup_AP_PA_b0_iout --fout=topup_AP_PA_b0_fout

    echo "Topup complete for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    echo "Generating a brain mask from corrected b0 image for subject $(basename "$dir") and brain extracting this mask at a threshold of 0.2"
    # 0.2 fractional intensity is a common threshold chosen for this b0 mask, check data in FSLeyes after to make sure that threshold works for your data 
    sleep 1
    echo "______"
    sleep 1

    fslmaths topup_AP_PA_b0_iout -Tmean hifi_nodif # generating temporal mean b0 brain mask

    bet hifi_nodif hifi_nodif_brain -m -f 0.2 # running brain extraction at threshold 0.2 and as a brain mask

    echo "b0 brain mask and binary brain mask from BET produced for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "Topup complete for all subjects."
sleep 1
echo "______"
sleep 1

# ** Remove hashtag from the following to enable removal/checking of data **

# while true; do

#     echo "Do you want to check the output of Topup and BET from Topup before proceeding (highly recommended) (y/n)?"
#     read check # read user input

#     sleep 1
#     echo "______"
#     sleep 1
    
#     if [ "$check" = "y" ]; then

#         echo "Checking Topup and brain extracted binary masks from topup data for all subjects."
#         sleep 1
#         echo "______"

#         for dir in $(find "$dirs" -maxdepth 1 -mindepth 1 -type d); do # looping through subject folders

#             echo "Checking Topup output for subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             cd "$dir"

#             fsleyes topup_AP_PA_b0_iout # check data - make sure that this looks undistorted

#             echo "Checking BET output for subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             fsleyes hifi_nodif hifi_nodif_brain -cm red-yellow -a 50 # check data - should look undistorted, less noisy and have good brain extraction

#             echo "Subject $(basename "$dir") Topup output and BET results checked."
#             sleep 1
#             echo "______"
#             sleep 1

#             cd ../..

#         done

#         sleep 1
#         echo "______"
#         sleep 1
#         echo "All subject Topup output and brain extracted binary masks have been checked."
#         sleep 1
#         echo "______"
#         sleep 1
        
#         break

#     elif [ "$check" = "n" ]; then
#         echo "Topup output and brain extracted binary masks produced after Topup were not checked."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

# echo "DWI data is ready for eddy current correction."