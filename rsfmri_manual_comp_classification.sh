#!/bin/bash

# Melodic output check

## Setup - source config file

source config.sh

## Checking melodic data

echo "Checking the output of melodic (also allows manual labelling of resting-state components)."

sleep 3
echo "______"
sleep 1
echo "Note that a custom scene that contains both the melodic and ortho layout combined will be loaded. This can easily be created in the FSLeyes GUI if not already done."
sleep 1 
echo "______"
sleep 1
echo "If the custom scene has not been pre-emptively created then the script will default to the standard melodic scene (a pre-existing FSLeyes layout option)."
sleep 1
echo "______"
sleep 1

no_custom_layout=false  # introduce an error flag to track if the custom layout is not present

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Checking melodic for subject $(basename "$dir")"
    sleep 1
    echo "______"
    sleep 1

    # Capture the output of fsleyes in a subshell
    fsleyes_output=$( { fsleyes --scene melodic_ortho melodic.ica/filtered_func_data.ica/mean.nii.gz melodic.ica/filtered_func_data.ica/melodic_IC.nii.gz -dr 3 10 -cm red-yellow -nc blue-lightblue; } 2>&1 )

    # Check the content of the output for errors
    if [[ $fsleyes_output == *"ValueError: No layout named"* ]]; then
        echo "FSLeyes failed to run with melodic_ortho scene. Loading melodic output with pre-existing FSL melodic layout."
        echo "______"
        echo "NOTE. You will have to exit FSLeyes to load FSLeyes with these changed settings."
        echo "______"
        echo "Following subjects will be loaded with this pre-existing melodic layout."
        # Use the alternative fsleyes command
        fsleyes --scene melodic melodic.ica/filtered_func_data.ica/mean.nii.gz melodic.ica/filtered_func_data.ica/melodic_IC.nii.gz -dr 3 10 -cm red-yellow -nc blue-lightblue
    fi

    echo "______"
    sleep 1
    echo "Subject $(basename "$dir") melodic output checked."
    sleep 1
    echo "______"

    cd "$original_dir"

done

echo "______"
sleep 1
echo "Melodic output for all subjects has been checked."