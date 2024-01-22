#!/bin/bash

# Testing reliability of BIANCA

echo "Starting BIANCA reliability estimation."
sleep 2
echo "______"
sleep 2

## Setup - source config file

source config.sh

### Setup for subjects WITH manual lesion mask

export $wmh # using export to make sure that the "wmh" variable is properly expanded within the find command
man_dir=($(find "$start_dir" -maxdepth 1 -type d -exec sh -c 'test -e "$1/$wmh"' _ {} \; -print)) # identifying directories with a manual lesion mask
for dir in "${man_dir[@]}"; do
    num=$(basename "$dir" | grep -oE '[0-9]+$') # extracting the numerical part of the directory name, assuming it is at the end (so removing the parent directroy from name)
    man_dir_array+=("$num") # array of subjects with manual lesion masks
done

echo "Subjects with manual lesion mask = ${man_dir_array[@]}" # showing array of subjects with a manual lesion mask
sleep 1
echo "______"
sleep 1

total_subj_w_manualmasks=${#man_dir_array[@]} # total number of subjects with a manual lesion mask (edit this)
masterfile_trainingnum=() # empty array to identify training numbers (for subjects with a lesion mask)
for ((i=1; i<=$total_subj_w_manualmasks; i++)); do
    masterfile_trainingnum+=( "$i" )
done

## BIANCA overlap measures

echo "Determining performance metrics via 'bianca_overlap_measures' for subjects with a manual lesion mask."
sleep 1
echo "______"
sleep 1
echo "Note: this may take a while depending on the number of subjects you have and you MUST run other BIANCA scripts prior."
sleep 1
echo "______"
sleep 1

cd "$start_dir"

### User selection of output to text file or just in the terminal

while true; do

    echo "Would you like to output reliability data to a text file (1) or in the terminal (0)?"
    read choice # read user input

    sleep 1
    echo "______"
    sleep 1

    if [ "$choice" = "1" ]; then

        num=1

        echo "You have chosen to output reliability data to a text file for each subject with a manual lesion mask."
        sleep 1
        echo "______"
        sleep 1

        ### Warning message to close text file that will be appended/created if it is already open

        echo "WARNING: make sure to close the text file that is about to be appended/created (if already open)."
        echo "Otherwise a 'Permission denied' error message will appear. A file cannot be edited if it is already open..."
        sleep 5
        echo "______"
        sleep 1

        break
    elif [ "$choice" = "0" ]; then

        num=0

        echo "You have chosen to output reliability data in the terminal for each subject with a manual lesion mask."
        sleep 1
        echo "______"
        sleep 1

        break
    else
        echo "Invalid choice. Please enter '1' or '0'."
    fi
done

### Calculation of reliability

for dir in ${man_dir_array[@]}; do

    echo "Calculating reliability for subject $(basename "$dir")"

    cd "$dir"

    bianca_overlap_measures bianca_output "$thr" "$wmh" "$num" # running bianca_overlap_measures

    # first input is binarised lesion map (normally a float, which is the threshold, is put after the first input - however if the map is already binarised then there is no need for this)
    # second input is the manual lesion mask, the integer after this can be '0' or '1'
    ## 0 = outputs information to the terminal
    ## 1 = outputs information to a text file in subject directory

    # Interpreting output:

    ## Dice Similarity Index (SI): calculated as 2*(voxels in the intersection of manual and BIANCA masks)/(manual mask lesion voxels + BIANCA lesion voxels)
    ## Voxel-level false discovery rate (FDR): number of voxels incorrectly labelled as lesion (false positives, FP) divided by the total number of voxels labelled as lesion by BIANCA (positive voxels)
    ## Voxel-level false negative ratio (FNR): number of voxels incorrectly labelled as non-lesion (false negatives, FN) divided by the total number of voxels labelled as lesion in the manual mask (true voxels)
    ## Cluster-level FDR: number of clusters incorrectly labelled as lesion (FP) divided by the total number of clusters found by BIANCA (positive clusters)
    ## Cluster-level FNR: number of clusters incorrectly labelled as non-lesion (FN) divided by the total number of lesions in the manual mask (true clusters)
    ## Mean Total Area (MTA): average number of voxels in the manual mask and BIANCA output (true voxels + positive voxels)/2
    ## Detection error rate (DER): sum of voxels belonging to FP or FN clusters, divided by MTA
    ## Outline error rate (OER): sum of voxels belonging to true positive clusters (WMH clusters detected by both manual and BIANCA segmentation), excluding the overlapping voxels, divided by MTA

    # Output also provides at the end:

    ## Volume of BIANCA segmentation (after applying the specified threshold)
    ## Volume of manual mask

    sleep 8 # view results in terminal

    echo "______"
    sleep 1
    echo "Reliability for subject $(basename "$dir") has been shown in terminal or outputted to a text file in subject folder."
    sleep 1
    echo "______"
    sleep 1
    echo "Note: that if data has been exported to a text file there will just be float values displayed without a legend.\
    Open this script and check contents for interpretation of this data. The 'Interpreting output' section shows what these values mean\
    (in the order of what they are displayed in the script)."
    sleep 1
    echo "______"
    sleep 1

    cd ..

done

## Visual inspection of overlap between manual and automated masks

echo "Viewing manual and automated segmentations of WMH."
sleep 1
echo "______" 
sleep 1

cd "$start_dir"

for ((i=0; i<${#man_dir[@]}; i++)); do

    dir="${man_dir_array[i]}"

    cd "$dir"

    echo "Looking at subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    fsleyes FLAIR_roi_brain.nii.gz -b 60 -c 75 wmh.nii.gz -cm red bianca_output_bin.nii.gz -cm green

    echo "Subject $(basename "$dir") checked."

    sleep 1
    echo "______"
    sleep 1

    cd ..

done

cd "$original_dir"

sleep 3
echo "______""______""______"
sleep 3
echo "Reliability checked for all subjects with a manual lesion mask." # show reliability has been checked