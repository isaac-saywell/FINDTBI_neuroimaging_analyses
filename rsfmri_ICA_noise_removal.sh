#!/bin/bash

# Automatic classification of components, removal of noise components, and registeration of single-subject data to standard space

## Setup - source config file

source config.sh

## Checking if there is a training set for automatic resting-state component classification

echo "Prior to automatically classifying ICA components as signal or noise a training set (manually classified components from sample) \
of approximately 20 subjects needs to be produced."
sleep 1
echo "______"
sleep 1
echo "These manual label text files should be saved in melodic.ica/filtered_func_data.ica"
sleep 1
echo "______"
sleep 1

# ### Check with user if they want to exit the script to manually classify components for some subjects

# while true; do

#     echo "Do you need to exit the script to manually classify components for a subset of subjects (y/n)?"
#     read component

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$component" = "y" ]; then

#         echo "Exiting script without error."
#         sleep 2
#         exit 0 # exit without error 
#     elif [ "$component" = "n" ]; then
#         echo "Continuing with script. There should be manual labels of components for some subjects"
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

echo "Script will exit if there is not one instance of a manual classification text file across subject directories (should be named 'labels.txt')."
sleep 1
echo "______"
sleep 1

if find "$start_dir" -type f -name "labels.txt" -print -quit | grep -q .; then
    echo "At least one manual component classification text file was found. Continuing with script."
    sleep 1
    echo "______"
    sleep 1
else
    echo "No component classification text file found in any of subject directories. Please manually classify components for a subset of subjects."
    exit 1 # exit with error 
fi

## Creating training set from manually labelled components in sample

echo "Producing a training data file from subjects with manually labelled components to be used with the automatic classifier."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    if [ -e "$dir/melodic.ica/filtered_func_data.ica/labels.txt" ]; then 

        echo "Subject $(basename "$dir") has manually classified components. Producing a text file with unclassified noise/artefacts."

        sleep 1
        echo "______"
        sleep 1

        cd "$dir"
        cd melodic.ica/filtered_func_data.ica # move into subject directory folder that contains manual classification

        grep 'Unclassified noise' labels.txt | awk -F, '{print $1}' | sed 's/ //g' | sed 's/$/,/' | tr -d '\n' | sed 's/,$/\n/' | sed 's/,/, /g' > hand_labels_noise.txt

        sed -i '' '1s/^/[/; $s/$/]/' hand_labels_noise.txt # add square brackets

        mv hand_labels_noise.txt .. # move manually classified noise components into parent melodic directory for subject

        echo "Text file with manually classified noise components produced for subject $(basename "$dir")"

        sleep 1
        echo "______"
        sleep 1

        cd "$original_dir"

    fi

done

### Creating variable holding a list of all subject melodic directories that contain manually classified noise components

dir_w_labels=$(find "$start_dir" -type f -name "hand_labels_noise.txt" -exec dirname {} \; | sort -u | awk -F'/' '{print $(NF-1)}' | tr '\n' ' ') # store just subject ID numbers
dir_w_labels_with_mel="" 
for dir in $dir_w_labels; do
    subject_id=$(basename "$dir")
    dir_w_labels_with_mel+="$subject_id/melodic.ica " # append melodic directory to each subject ID in variable (needed for FIX)
done

dir_w_labels_with_mel=${dir_w_labels_with_mel# } # trim leading space

echo "Here is a list of directories that contain manually classified noise components: $dir_w_labels"
sleep 1
echo "_______"
sleep 1

echo "And here is the variable that has 'melodic.ica' appended to each subject directory in that list: $dir_w_labels_with_mel"
sleep 1
echo "______"
sleep 1

## FIX - automatic component classification

echo "Automatically classifying resting-state components as 'signal' or 'unclassified noise' using FIX and a training set from sample."
sleep 1
echo "______"
sleep 1
echo "Note that pyFIX needs to be installed on your machine. Currently is not part of the standard FSL package. See the README for instructions."
    ### https://git.fmrib.ox.ac.uk/fsl/pyfix
sleep 1
echo "______"
sleep 1

# ### Feature extraction for each subject melodic directory

# find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

#     cd "$dir"

#     echo "Extracting features for subject $(basename "$dir")"

#     sleep 1
#     echo "______"
#     sleep 1

#     fix -f melodic.ica # runs FAST for partial volume estimations and extracts each independent component from 4D resting-state image (among executing other commands for other outputs)

#     echo "Features have been obtained for subject $(basename "$dir")"
    
#     sleep 1
#     echo "______"
#     sleep 1

#     cd "$original_dir"

# done

echo "FIX has extracted features for all subjects. Moving onto training a classifer for automated component classification."

sleep 1
echo "______"
sleep 1

### Training the classifier 

cd "$start_dir"

echo "Creating training set/classifier using subjects with manually labelled components."

sleep 1
echo "______"
sleep 1

fix -t FIND_TBI_FIX_trainingset -l $dir_w_labels_with_mel

echo "Training classifier produced as 'FIND_TBI_FIX_trainingset'."

sleep 1
echo "_______"
sleep 1

cd "$original_dir"

### Classifying ICA components

echo "Classifying ICA components automatically, using FIX, for each subject."

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Automatically classifying components as signal or noise for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    fix -c melodic.ica "$script_path/$start_dir/FIND_TBI_FIX_trainingset.pyfix_model" $pyfix_thr # run FIX at preset threshold using training model that should be in brain scan folder

    echo "FIX complete for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "FIX complete for all subjects. Continuing with the script."
sleep 1
echo "______"
sleep 1

## Removal of components identified as noise

echo "Removing components identified as noise..."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Putting subject $(basename "$dir") noise components in a variable and removing these via fslregilt."

    sleep 1
    echo "______"
    sleep 1

    noise_components=$(tail -n 1 melodic.ica/fix4melview_FIND_TBI_FIX_trainingset_thr${pyfix_thr}.txt) # putting identified noise components in a variable
    f_noise=$(echo "$noise_components" | sed 's/\[\([^]]*\)\]/"\1"/g') # restructuring variable 

    echo "For subject $(basename "$dir") these are the component numbers that were classified as noise: ${f_noise}"

    sleep 1
    echo "______"
    sleep 1

    fsl_regfilt -i melodic.ica/filtered_func_data.nii.gz -d melodic.ica/filtered_func_data.ica/melodic_mix \
    -o melodic.ica/filtered_func_data_clean.nii.gz -f "${f_noise}"

    echo "Noise components removed from subject $(basename "$dir") resting-state functional data."

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

## Registering cleaned single-subject data to standard space (using applywarp) 

echo "Cleaned resting-state functional data needs to be converted from subject to standard space before group analysis."
sleep 1
echo "______"
sleep 1
echo "Applying transformations/warps to each subject in dataset..."

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"/melodic.ica

    echo "Using applywarp for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    applywarp -r reg/standard.nii.gz -i filtered_func_data_clean.nii.gz -o filtered_func_data_clean_standard.nii.gz \
    --premat=reg/example_func2highres.mat -w reg/highres2standard_warp.nii.gz

    echo "Subject $(basename "$dir") registered."

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"
    
done

echo "Cleaned resting-state functional data converted to standard space for all subjects."
