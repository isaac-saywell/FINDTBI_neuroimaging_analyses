#!/bin/bash

# Removal of unnecessary MRI image directory (HEAD_FIND-TBI*)

## Setup

source config.sh

## Loop through all subject directories with the unnecessary extra directory and remove it

    # All scripts rely on there not being an extra directory before subject MRI files, therefore all files need to be moved up one directory and the extra directory
    # (HEAD_FIND-TBI) needs to be deleted

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # looping through subject folders

    cd $dir/HEAD_FIND-TBI_*

    mv * .. # move all contents of unnecessary directory to parent directory

    cd .. # move out of unnecessary directory

    rm -r HEAD_FIND-TBI_* # delete unnecessary directory (should be empty)

    cd "$original_dir" # move back to starting directory

done



    

