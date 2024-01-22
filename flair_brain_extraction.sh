#!/bin/bash

# # FLAIR brain extraction

## Setup - source config file

source config.sh

## BET

echo "Commencing brain extraction for all subject FLAIR images."

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    if [ -e FLAIR_roi_brain.nii.gz ]; then
        echo "Brain extracted FLAIR image already exists."
    else

        echo "Running BET for subject $(basename "$dir")"

        sleep 1
        echo "______"
        sleep 1

        bet2 FLAIR_roi FLAIR_roi_brain

        echo "Finished BET for subject $(basename "$dir")"

        sleep 1
        echo "______"
        sleep 1
    fi

    cd "$original_dir"

done

echo "Brain extraction complete for all subject FLAIR images."