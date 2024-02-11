#!/bin/bash

# Subcortical structure diffusion statistics 

## Setup - source config file

source config.sh

echo "Starting calculation of diffusion parameters for subcortical nuclei."
sleep 1
echo "______"
sleep 1

echo "Note that all other DWI scripts should be run prior to this script and that subcortical nuclei need to be segmented for all subjects."
sleep 1
echo "______"
sleep 1

## Exit script if FIRST has not been run to segment subcortical nuclei on all subjects in dataset and/or if there are no pre-processed DWI scans

echo "Checking if subcortical segmentations and pre-processed DWI scans exist for all subjects in dataset."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # loop through each subject and exit script if subcortical segmentation nifti file does not exist

    cd "$dir"

    if [ ! -e T1_sub_seg_all_${boundary_corr_method}_firstseg.nii.gz ]; then
        echo "Subject $(basename "$dir") does not have a subcortical nuclei segmentation mask."
        sleep 1
        echo "______"
        sleep 1
        echo "Please use the command 'run_first_all' for all subjects' T1 scans before running this script. Exiting now..."
        exit 1 # exit with error
    fi

    cd "$original_dir"

done

echo "Subcortical nuclei segmentations are present."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # loop through each subject and exit script if pre-processed DWI scans do not exist

    cd "$dir"

    if [ ! -e DTI_FA_corrected.nii.gz ] && [ ! -e DTI_MD.nii.gz ] && [ ! -e DTI_L1.nii.gz ] && [ ! -e DTI_RD.nii.gz ]; then
        echo "Subject $(basename "$dir") does not have all pre-processed DWI scans."
        sleep 1
        echo "______"
        sleep 1
        echo "Please run the DWI wrapper script before executing this script. Exiting now..."
        exit 1 # exit with error
    fi

    cd "$original_dir"

done

echo "And pre-processed DWI scans exist."
sleep 1
echo "______"
sleep 1

## Converting corrected diffusion-weighted images to subcortical nuclei mask space (T1) using FLIRT (not sure if FNIRT would be better here?)

echo "Converting artefact-corrected DWI scans to T1 structural space using FLIRT."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Starting registration for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    # FA map
    flirt -dof 6 -in DTI_FA_corrected -ref T1_roi_brain -omat DTI_FA-2-T1.mat -out DTI_FA-2-T1.nii.gz

    # MD map
    flirt -dof 6 -in DTI_MD -ref T1_roi_brain -omat DTI_MD-2-T1.mat -out DTI_MD-2-T1.nii.gz

    # AD map
    flirt -dof 6 -in DTI_L1 -ref T1_roi_brain -omat DTI_AD-2-T1.mat -out DTI_AD-2-T1.nii.gz

    # RD map
    flirt -dof 6 -in DTI_RD -ref T1_roi_brain -omat DTI_RD-2-T1.mat -out DTI_RD-2-T1.nii.gz

    echo "Registration complete for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "Registration complete for all subjects."
sleep 1
echo "______"
sleep 1

## Option to check quality of registration to T1 space by overlaying subcortical segmentations (just for FA map)

# while true; do

#     echo "Would you like to check the quality of the registration (just FA maps per subject, edit code to check other maps if necessary) (y/n)?"
#     read check

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$check" = "y" ]; then

#         echo "Checking the quality of diffusion registration by overlaying subcortical nuclei segmentations generated in T1 space."
#         sleep 1
#         echo "______"
#         sleep 1

#         find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

#             cd "$dir"

#             echo "Looking at subject $(basename "$dir")"
#             sleep 1
#             echo "______"
#             sleep 1

#             fsleyes # check data

#             echo "Subject $(basename "$dir") has been viewed."
#             sleep 1
#             echo "______"
#             sleep 1

#             cd "$original_dir"

#         done

#         echo "All subjects have had their registration quality checked. Proceeding with the script..."
#         sleep 1
#         echo "______"
#         sleep 1
        
#         break
#     elif [ "$check" = "n" ]; then
#         echo "Registration quality for each subject is not being checked. Continuing with the script..."
#         sleep 1
#         echo "______"
#         sleep 1
#         break
#     else    
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

## Creating subcortical structure masks from FIRST output that generated a mask with all subcortical nuclei that FSL can automatically segment

echo "Creating subcortical structure masks from FIRST output (mask with all subcortical structures combined)."
sleep 1
echo "______"
sleep 1

### Defining arrays for subcortical structure names, lower thresholds, and upper thresholds (for both left and right hemispheres for each structure)

structures=("puta" "caud" "nucacc" "hipp" "amyg" "gp" "thal")

lower_thresholds_leftstruc=(11.5 10.5 25.5 16.5 17.5 12.5 9.5)
upper_thresholds_leftstruc=(12.5 11.5 26.5 17.5 18.5 13.5 10.5)

lower_thresholds_rightstruc=(50.5 49.5 57.5 52.5 53.5 51.5 48.5)
upper_thresholds_rightstruc=(51.5 50.5 58.5 53.5 54.5 52.5 49.5)

### Creating masks automatically by iterating through subjects

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    for ((i=0; i<${#structures[@]}; i++)); do

        # Generate left and right structure masks
        fslmaths T1_sub_seg_all_${boundary_corr_method}_firstseg -thr ${lower_thresholds_leftstruc[i]} -uthr ${upper_thresholds_leftstruc[i]} L_${structures[i]}_T1_mask.nii.gz
        fslmaths T1_sub_seg_all_${boundary_corr_method}_firstseg -thr ${lower_thresholds_rightstruc[i]} -uthr ${upper_thresholds_rightstruc[i]} R_${structures[i]}_T1_mask.nii.gz

        # Combine left and right masks into one image
        fslmaths L_${structures[i]}_T1_mask.nii.gz -add R_${structures[i]}_T1_mask.nii.gz TOT_${structures[i]}_T1_mask.nii.gz

    done

    cd "$original_dir"

done

echo "Nuclei specific subcortical masks have been generated."
sleep 1
echo "______"
sleep 1

## Masking DWI scans in T1 space using specific subcortical structure masks (calling structures variable created for previous loop)

echo "Using previously created masks to mask DWI scans in T1 space so nuclei specific DWI statistics can be generated."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    for structure in "${structures[@]}"; do

        # Generate structure masks for each relevant image produced by DTI model (FA, MD, AD, and RD maps)
        for map in "FA" "MD" "AD" "RD"; do
            fslmaths "DTI_${map}-2-T1" -mas "L_${structure}_T1_mask" "L_DTI_${map}-2-T1_${structure}_mask.nii.gz"
            fslmaths "DTI_${map}-2-T1" -mas "R_${structure}_T1_mask" "R_DTI_${map}-2-T1_${structure}_mask.nii.gz"
            fslmaths "DTI_${map}-2-T1" -mas "TOT_${structure}_T1_mask" "TOT_DTI_${map}-2-T1_${structure}_mask.nii.gz"
        done

    done

    cd "$original_dir"

done

echo "Specific subcortical structure DWI masks have been produced."
sleep 1
echo "______"
sleep 1

## Appending to subcortical nuclei mean diffusion measures to DWI statistics CSV file

echo "Adding mean diffusion statistics for subcortical nuclei structures to DWI CSV file."
sleep 1
echo "______"
sleep 1

### Defining mask types (left, right or both) and map type (which DTI parameter)

masks_types=("L" "R" "TOT")
maps=("FA" "MD" "AD" "RD")

### Deleting CSV file if it exists already

if [ -e dwi_subcor_stats.csv ]; then
    rm "dwi_subcor_stats.csv"
fi

### Creating a new CSV file

output_csv="dwi_subcor_stats.csv"
touch "$output_csv"

### Creating unique headers for CSV (specific headers for each structure, map and side of structure)

first_iteration=true # flag to track first iteration of loop

for map in "${maps[@]}"; do
    for structure in "${structures[@]}"; do
        for mask in "${masks_types[@]}"; do
            if [ "$first_iteration" = true ]; then
                echo -n "subject,${mask}_${structure}_${map}," >> "$output_csv"  # Append 'subject' header in the first iteration
                first_iteration=false
            else
                echo -n "${mask}_${structure}_${map}," >> "$output_csv"  # Append headers as columns
            fi
        done
    done
done

truncate -s-1 "$output_csv" # remove trailing comma from the last column header

echo "" >> "$output_csv" # add a newline to separate headers from data

### Appending subject-specific DTI data to the CSV for each header

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    # Creating variables that store DWI map values
    all_FA=""
    all_MD=""
    all_AD=""
    all_RD=""

    for structure in "${structures[@]}"; do

        for mask in "${masks_types[@]}"; do

            FA=`fslstats "${mask}_DTI_FA-2-T1_${structure}_mask" -M | awk '{ fa = $1; print fa }'`

            MD=`fslstats "${mask}_DTI_MD-2-T1_${structure}_mask" -M | awk '{ md = $1; print md }'`

            AD=`fslstats "${mask}_DTI_AD-2-T1_${structure}_mask" -M | awk '{ ad = $1; print ad }'`

            RD=`fslstats "${mask}_DTI_RD-2-T1_${structure}_mask" -M | awk '{ rd = $1; print rd }'`

            # Accumulating DWI map values
            all_FA+=",$FA"
            all_MD+=",$MD"
            all_AD+=",$AD"
            all_RD+=",$RD"

        done
        
    done

    cd "$original_dir"

    echo "$(basename "$dir")${all_FA}${all_MD}${all_AD}${all_RD}" >> "$output_csv"

done

echo "Subcortical nuclei structure diffusion statistics have been appended to the CSV file. Script is complete."