#!/bin/bash

# Subcortical Structure Volume Estimation

## Setup - source config file

source config.sh

## Running FIRST to segment subcortical structures in T1 scans

echo "Running FIRST for subjects to segment subcortical structures and estimate volumes for these brain regions."
sleep 1
echo "______"
sleep 1
echo "WARNING: you will require NIFTI images that have been cropped and brain extracted before running this script "
sleep 4
echo "______"
sleep 1

echo "Creating affine registeration matrix for all subject T1 images." # show T1 registeration has started
sleep 1
echo "______"
sleep 2

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Running FLIRT for subject $(basename "$dir") T1." # show registeration has starting
    sleep 1
    echo "______"
    sleep 1

    flirt -in T1_roi_brain -ref ${T_brain} -omat T1_roi_brain-2-MNI_brain.mat -out T1_roi_brain-2-MNI_brain.nii.gz # running FLIRT

    echo "Subject $(basename "$dir") T1 registered to standard (MNI) space. Affine matrix created." # show registeration has finished for a subject
    sleep 1
    echo "______"

    cd "$original_dir"

done

sleep 1
echo "MNI standard space affine matrix created for all subject T1 images and all T1 images have been registered to standard space."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # while loop iterating FIRST across all subjects in directory

    cd "$dir"

    echo "Segmenting subcortical structures in both hemispheres (caudate, putamen, pallidum, hippocampus, amygdala, nucleus accumbens, thalamus) for subject $(basename "$dir")"
    sleep 1
    echo "______"

    run_first_all -i T1_roi_brain -b -a T1_roi_brain-2-MNI_brain.mat -m fast \
    -s L_Accu,L_Amyg,L_Caud,L_Hipp,L_Pall,L_Puta,L_Thal,R_Accu,R_Amyg,R_Caud,R_Hipp,R_Pall,R_Puta,R_Thal \
    -o T1_sub_seg # running FIRST to segment subcortical structures using FAST as a boundary correction method

    # -i = T1 image to run FIRST on
    # -b = use to specify that the T1 image has been brain extracted
    # -s = subcortical structures to segment (each structure has to be in a list, seperated by commas without spaces)
        # There are a total of 15 possible structures, where labels to identify structures are completely strict
        # Labels for these structures include: L_Accu L_Amyg L_Caud L_Hipp L_Pall L_Puta L_Thal R_Accu R_Amyg R_Caud R_Hipp R_Pall R_Puta R_Thal BrStem
    # -a = affine matrix representing registeration of T1 to standard (MNI) space
    # -m = specifies the boundary correction method (can use FAST, threshold a simple single-Gaussian intensity model, or none)
    # -o = output image name (with have additional labels added for each segmented subcortical structure)

    echo "Subject $(basename "$dir") has been segmented."
    sleep 1
    echo "______"

    cd "$original_dir"

done

sleep 1
echo "Subcortical structures segmented for all subjects."
sleep 1
echo "______"
sleep 1

# ** Remove hashtag from the following to enable removal/checking of data **

# ## Check output of FLIRT - registeraton to standard space (always make sure to check this if it hasn't been done already)

# while true; do

#     echo "Do you need to check T1 registeration to standard (MNI) space (y/n)?"
#     read check

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$check" = "y" ]; then

#         echo "Checking registeration for all subjects"
#         sleep 1
#         echo "______"

#         find "$start_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do # while loop iterating registeration check across all subjects in directory

#             cd "$dir"
            
#             echo "Looking at subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             fsleyes "$T_brain" T1_roi_brain-2-MNI_brain -a 50 -cm red-yellow # check data

#             echo "Subject $(basename "$dir") checked." # show subject data has been viewed
#             sleep 1
#             echo "______"

#             cd "$original_dir"
        
#         done

#         sleep 1
#         echo "Subcortical structures segmented for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$check" = "n" ]; then
#         echo "Did not check T1 registeration to standard (MNI) space."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

# ## Check output logs of all subjects to ensure there have been no errors

# while true; do

#     echo "Do you need to check FIRST output logs to see if there have been any errors (y/n)?"
#     read error # read user input

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$error" = "y" ]; then

#         echo "Loading output logs for all subjects..."
#         sleep 1
#         echo "______"
#         sleep 1
#         echo "If there is no extra output between lines (______) then NO errors have occurred."
#         sleep 1
#         echo "______"
#         sleep 3

#         find "$start_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do # while loop iterating log check across all subjects in directory

#             cd "$dir"
#             cd "T1_sub_seg.logs" # cd into subject's FIRST logs
            
#             echo "Looking at logs for subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             cat *.e* # read any errors (no output if no errors with FIRST)

#             echo "______"
#             sleep 1
#             echo "Subject $(basename "$dir") logs have been loaded." # show logs have been displayed (if any errors)
#             sleep 1
#             echo "______"

#             cd "$original_dir"
        
#         done
        
#         sleep 1
#         echo "FIRST output logs checked for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$error" = "n" ]; then
#         echo "Did not check subject error logs."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

# ## View combination of all subcortical segmentations in FSLeyes

# while true; do

#     echo "Do you need to check subcortical segmentations (y/n)?"
#     read subcor # read user input

#     sleep 1
#     echo "______"
#     sleep 1

#     if [ "$subcor" = "y" ]; then

#         echo "Checking subcortical segmentation for all subjects."
#         sleep 1
#         echo "______"

#         find "$start_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do # while loop iterating registeration check across all subjects in directory

#             cd "$dir"
            
#             echo "Viewing subject $(basename "$dir")"
#             sleep 1
#             echo "______"

#             fsleyes T1_roi_brain -b 60 -c 70 T1_sub_seg_all_fast_firstseg.nii.gz \
#             -cm random -a 15 -dr 0 118 # check data

#             echo "Subject $(basename "$dir") subcortical segmentation has been checked." # show logs have been displayed (if any errors)
#             sleep 1
#             echo "______"

#             cd "$original_dir"

#         done

#         sleep 1
#         echo "Subcortical segmentation checked for all subjects."
#         sleep 1
#         echo "______"
#         sleep 1

#         break
#     elif [ "$subcor" = "n" ]; then
#         echo "Did not check subcortical segmentations."
#         sleep 1
#         echo "______"
#         break
#     else
#         echo "Invalid choice. Please enter 'y' or 'n'."
#     fi
# done

## Generate a webpage report to view all subcortical segmentations simultaneously

echo "Creating a directory containing all subject structural images and subcortical segmentations via first."

mkdir subcor_webpage

sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    cp T1_sub_seg_all_fast_firstseg.nii.gz ../..
    cp T1_roi_brain.nii.gz ../..

    cd ../..

    mv T1_sub_seg_all_fast_firstseg.nii.gz subcor_webpage/$(basename "$dir")_T1_sub_seg_all_fast_firstseg.nii.gz
    mv T1_roi_brain.nii.gz subcor_webpage/$(basename "$dir")_T1_roi_brain.nii.gz

done

echo "Directory created. Creating the webpage report to view."

sleep 1
echo "______"
sleep 1

cd subcor_webpage

first_roi_slicesdir *_T1_roi_brain.nii.gz *_T1_sub_seg_all_fast_firstseg.nii.gz

cd "$original_dir"

echo "Quality of segmentations across all subjects can be easily viewed in the subcor_webpage/slicesdir directory. \
From there load the index.html file in a web browser to view subcortical structure segmentation."

sleep 1
echo "______"
sleep 1

## Structure volume analysis and CSV file creation

echo "Outputting subcortical structure (Nucleus Accumbens, Amygdala, Hippocampus, Caudate, Putamen, Pallidus, Thalamus) \
volume for both left and right hemispheres (and total structure volume) to a CSV file."
sleep 2
echo "______"
sleep 2

echo "subject,L_Accu,R_Accu,TOT_Accu,L_Amyg,R_Amyg,TOT_Amyg,L_Hipp,R_Hipp,TOT_Hipp,\
L_Caud,R_Caud,TOT_Caud,L_Puta,R_Puta,TOT_Puta,L_Pall,R_Pall,TOT_Pall,L_Thal,R_Thal,TOT_Thal" > subcorseg_data.csv # creating CSV file with headers

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do # while loop writing volumes to CSV for every subject

    echo "Printing subject $(basename "$dir") to CSV file."
    sleep 1
    echo "______"
    sleep 1

    cd "$dir"
    
    L_Accu=`fslstats T1_sub_seg_all_fast_firstseg -l 25.5 -u 26.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Nucleus Accumbens
    R_Accu=`fslstats T1_sub_seg_all_fast_firstseg -l 57.5 -u 58.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Nucleus Accumbens
    TOT_Accu=$(echo "$L_Accu + $R_Accu" | bc) # prints volume for both Left and Right Nucleus Accumbens combined (needed to use bc command as float values were causing issues)

    L_Amyg=`fslstats T1_sub_seg_all_fast_firstseg -l 17.5 -u 18.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Amygdala
    R_Amyg=`fslstats T1_sub_seg_all_fast_firstseg -l 53.5 -u 54.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Amygdala
    TOT_Amyg=$(echo "$L_Amyg + $R_Amyg" | bc) # prints volume for both Left and Right Amygdala combined (needed to use bc command as float values were causing issues)

    L_Hipp=`fslstats T1_sub_seg_all_fast_firstseg -l 16.5 -u 17.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Hippocampus
    R_Hipp=`fslstats T1_sub_seg_all_fast_firstseg -l 52.5 -u 53.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Hippocampus
    TOT_Hipp=$(echo "$L_Hipp + $R_Hipp" | bc) # prints volume for both Left and Right Hippocampus combined (needed to use bc command as float values were causing issues)

    L_Caud=`fslstats T1_sub_seg_all_fast_firstseg -l 10.5 -u 11.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Caudate
    R_Caud=`fslstats T1_sub_seg_all_fast_firstseg -l 49.5 -u 50.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Caudate
    TOT_Caud=$(echo "$L_Caud + $R_Caud" | bc) # prints volume for both Left and Right Caudate combined (needed to use bc command as float values were causing issues)

    L_Puta=`fslstats T1_sub_seg_all_fast_firstseg -l 11.5 -u 12.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Putamen
    R_Puta=`fslstats T1_sub_seg_all_fast_firstseg -l 50.5 -u 51.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Putamen
    TOT_Puta=$(echo "$L_Puta + $R_Puta" | bc) # prints volume for both Left and Right Putamen combined (needed to use bc command as float values were causing issues)

    L_Pall=`fslstats T1_sub_seg_all_fast_firstseg -l 12.5 -u 13.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Pallidus
    R_Pall=`fslstats T1_sub_seg_all_fast_firstseg -l 51.5 -u 52.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Pallidus
    TOT_Pall=$(echo "$L_Pall + $R_Pall" | bc) # prints volume for both Left and Right PAllidus combined (needed to use bc command as float values were causing issues)

    L_Thal=`fslstats T1_sub_seg_all_fast_firstseg -l 9.5 -u 10.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Left Thalamus
    R_Thal=`fslstats T1_sub_seg_all_fast_firstseg -l 48.5 -u 49.5 -V | awk '{ vol = $2 ; print vol }'` # prints volume for Right Thalamus
    TOT_Thal=$(echo "$L_Thal + $R_Thal" | bc) # prints volume for both Left and Right Thalamus combined (needed to use bc command as float values were causing issues)

    # The output of subcortical segmenetation via FIRST uses CMA standard labels for each structure
    # That being each structure has a unique integer used to identify it (there are even unique integers for left vs right structures)
        ## -l = should be '-0.5' the CMA label for your structure of interest
        ## -u = should be '+0.5' the CMA label for your structure of interest
    # These lower and upper labels allow specification of the exact integer for the structure of interest (there are no CMA labels that are floats)

    # CMA labels for subcortical structures that can be segmented through FIRST:

        ## 10 Left-Thalamus
        ## 11 Left-Caudate
        ## 12 Left-Putamen
        ## 13 Left-Pallidus
        ## 16 Brain-Stem / 4th Ventricle
        ## 17 Left-Hippocampus
        ## 18 Left-Amygdala
        ## 26 Left-Accumbens
        ## 49 Right-Thalamus
        ## 50 Right-Caudate 
        ## 51 Right-Putamen
        ## 52 Right-Pallidus
        ## 53 Right-Hippocampus
        ## 54 Right-Amygdala
        ## 58 Right-Accumbens

    # -V = outputs voxels and volume for "non-zero" voxels, first number is number of voxels and second number is structure volume in mm^3

    cd "$original_dir"

    echo "$(basename "$dir"),${L_Accu},${R_Accu},${TOT_Accu},${L_Amyg},${R_Amyg},${TOT_Amyg},${L_Hipp},${R_Hipp},${TOT_Hipp},${L_Caud},${R_Caud},${TOT_Caud},${L_Puta},${R_Puta},${TOT_Puta},${L_Pall},${R_Pall},${TOT_Pall},${L_Thal},${R_Thal},${TOT_Thal}" >> subcorseg_data.csv
    
    echo "Subject $(basename "$dir") subcortical segmentation data has been exported."
    sleep 1
    echo "______"
    sleep 1

done

sleep 1
echo "______"
sleep 1
echo "CSV file with subcortical segmentation data has been created."