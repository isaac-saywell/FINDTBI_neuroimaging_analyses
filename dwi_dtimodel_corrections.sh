#!/bin/bash

# Fitting diffusion tensor model after topup and eddy and correcting FA map artifacts

echo "Running DTIFIT to fit diffusion tensor model, producing fractional anisotropy and mean diffusivity maps."
sleep 2
echo "______"

## Setup - source config file

source config.sh

## Running dtifit (w/ eddy corrected diffusion data)

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd "$dir"

    echo "Fitting DTI model for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    dtifit -k eddy_unwarped_images.nii.gz -o DTI -m hifi_nodif_brain_mask -r DWI.bvec -b DWI.bval # should overwrite previous DTI files that were created prior to eddy current correction
    
    echo "Subject $(basename "$dir") model fitted."
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "Diffusion tensors have been fitted for each subject. FA and MD maps produced."
sleep 1
echo "______"
sleep 1

## Quickly viewing FA data of all subjects before conducting further corrections

echo "Viewing FA maps for all subjects in a single html web report."
sleep 1
echo "______"
sleep 1

if [ -e "all_subj_FA_scan" ]; then
    rm -r "all_subj_FA_scan" # remove FA scan directory if it already exists
fi

mkdir all_subj_FA_scan # create directory to store FA maps for all subjects

for dir in $(find "$dirs" -maxdepth 1 -mindepth 1 -type d); do # looping through subject folders

    cd "$dir"

    cp DTI_FA.nii.gz ../.. # copy FA map outside of subject directory

    cd "$original_dir"

    mv DTI_FA.nii.gz all_subj_FA_scan/$(basename "$dir")_FA.nii.gz # move copied FA map into new directory with subject specific name

done

cd all_subj_FA_scan # move into FA map folder

slicesdir *.nii.gz # create webpage report with all subject FA maps

cd slicesdir

# open ./index.html # view webpage report using default web browser

cd "$original_dir" # move back to original directory

sleep 1
echo "______"
sleep 1

## Running correction via pre-existing FSL TBSS script

echo "Eroding FA images slightly to remove brain-edge artifacts and zero the end slices (removing outliers)."
sleep 1
echo "______"
sleep 1

cd all_subj_FA_scan

tbss_1_preproc *.nii.gz # run correction script on subject FA maps

cd FA # move into newly created directory (created by tbss_1_preproc script)

cd slicesdir # move into directory with webpage report on corrected FA maps

open ./index.html # view webpage report using default web browser

echo "Compare two webpage reports. Ensure the script corrected for FA map artifacts appropriately."
sleep 1
echo "______"
sleep 1

cd "$original_dir"

## Moving corrected FA maps for each subject back into their specific directories with a new name

echo "Moving corrected FA maps for each subject back into subject directories."
sleep 1
echo "______"
sleep 1

cd all_subj_FA_scan/FA

for FA in *_FA_FA.nii.gz; do # looping through subject specific FA maps

    dir="${FA%%_*}" # extract subject ID from FA map file name

    cp "${FA}" ../..

    cd ../.. # move back to move file into subject directory

    mv "${FA}" "${start_dir}/${dir}/DTI_FA_corrected.nii.gz" # move into subject specific directory with a new, easily identifiable name

    cd all_subj_FA_scan/FA # move back into corrected FA directory for the next subject

    echo "Moved subject "$dir" corrected FA map into subject specific folder with name: DTI_FA_corrected.nii.gz"
    
    sleep 1
    echo "______"
    sleep 1

done

cd "$original_dir"

echo "All subject FA corrected maps have been moved into subject specific directories contained within "$start_dir"."