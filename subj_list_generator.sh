#!/bin/bash

# Subject List Creation

## Setup - source config file

source config.sh

## Creating a text file that automatically updates with a list of all subjects

echo "Appending list of subjects."
sleep 1
echo "______"
sleep 1

echo "Searching for if a subject list text file is already present in working directory."
sleep 1
echo "______"

if [ -e "list_subjects.txt" ]; then
    echo "Removing pre-existing subject list."
    sleep 1
    rm "list_subjects.txt" # removes old subject list if it exists
    echo "______"
    sleep 1
    echo "Old subject list text file removed."
    sleep 1
    echo "______"
else
    echo "There is no pre-existing subject list in working directory. No text file removed."
    sleep 1
    echo "______"
fi

echo "Adding all possible subjects specified in brain scan folder."
sleep 1
echo "______"

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort > list_subjects.txt # use find to list subject directories and append them to list_subjects.txt

sed -i 's/sample_brain_scans\///' list_subjects.txt # used to remove "sample_brain_scans/" from text file so it just shows subject numbers

echo "List of subjects appended."