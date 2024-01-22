#!/bin/bash

# Estimating white matter hyperintensities

echo "Starting WMH estimations for dataset."
sleep 1
echo "______"
sleep 1

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

echo "Array of number of subjects for training set = ${masterfile_trainingnum[@]}" # showing array of numbers assigned to subjects with a manual lesion mask that are eligible to be included in BIANCA training set
sleep 1
echo "______"
sleep 1

### Setup for subjects WITHOUT manual lesion mask

auto_dir=($(find "$start_dir" -maxdepth 1 -type d -exec test ! -e {}/"$wmh" \; -print)) # identifying directories without a manual lesion mask
auto_dir_array=()
while IFS= read -r -d '' dir; do
    subj=$(basename "$dir" | grep -oE '[0-9]+$' | tr -d '[:space:]') # had to do different code for creating an array for these subjects because a blank space was being printed before directories (not sure why)
    if [ -n "$subj" ]; then
        auto_dir_array+=("$subj") # array of subjects without a manual lesion mask
    fi
done < <(find "$start_dir" -maxdepth 1 -type d -exec test ! -e {}/"$wmh" \; -print0)

total_subj_without_manualmasks=${#auto_dir_array[@]} # total number of subjects with NO manual lesion mask (edit this)
automated_subject_number=() # empty array
for ((i=1; i<=$total_subj_without_manualmasks; i++)); do
    automated_subject_number+=( "$i" )
done

echo "Subjects with NO manual lesion mask = ${auto_dir_array[@]}" # showing array of subjects without a manual lesion mask
sleep 1
echo "______"
sleep 1

## Generating lesion probability maps for all subjects with manual lesion masks and creating BIANCA training file for subjects without a manual lesion mask (running BIANCA)

echo "Running BIANCA for subjects with manual lesion masks." # show BIANCA is running
sleep 2
echo "______" 
sleep 2

cd "$start_dir"

for ((i=0; i<${#man_dir[@]}; i++)); do
    dir="${man_dir_array[i]}"
    x="${masterfile_trainingnum[i]}"

    echo "Developing lesion probability map for subject $(basename "$dir") (training set number = $x)."
    sleep 2
    echo "______"

    current_array=("${masterfile_trainingnum[@]}") # create a copy of the original array for this iteration

    unique_trainingnum=() # initialise unique_trainingnum for this iteration

    for element in "${masterfile_trainingnum[@]}"; do # selecting all but the query subject as the training set
        if [ "$element" -ne "$x" ]; then
            unique_trainingnum+=("$element")
        fi
    done
    
    echo "New training set (without query subject): ${unique_trainingnum[@]}" # to see if correct training subjects have been picked  
    sleep 3
    echo "______"
    sleep 1

    echo ${unique_trainingnum[@]} > unique_trainingnum.txt # need to convert integer array into a text file to add commas between integers

    sed -e 's/\s\+/,/g' unique_trainingnum.txt > unique_trainingnum_com.txt
    mapfile -t unique_trainingnum_com < unique_trainingnum_com.txt # commas between integers are required for BIANCA

    bianca --singlefile=master_file.txt --trainingnums=$unique_trainingnum_com --labelfeaturenum=4 \
    --querysubjectnum=$x --brainmaskfeaturenum=1 --featuresubset=1,2 --matfeaturenum=3 \
    --trainingpts=2000 --nonlespts=10000 --selectpts=noborder -o $dir/bianca_output \
    --saveclassifierdata=mytraining -v # note: training data will be developed from the last subject query (according to this for loop)

    # singlefile = name of the masterfile that gives information to other BIANCA arguments
    # trainingnums = number of rows (subjects) in the masterfile
    # labelfeature = column number representing manual lesion masks
    # querysubjectnum = column number for the specific subject to train BIANCA onto
    # brainmaskfeaturenum = column number to derive non-zero mask from (brain extracted FLAIR image)
    # featuressubset = column numbers for images to use (brain extracted T1 image registered to brain extracted FLAIR, and brain extracted FLAIR)
    # matfeaturenum = column number for matrix file (to extract spatial features)
    # saveclassifierdata = saving training data to file
    # -v = use verbose mode

    ### Checking lesion probability map

    # ** Remove hashtag from the following to enable removal/checking of data **

    # echo "Check lesion probability map in FSLeyes."
    # sleep 2

    # fsleyes $dir/FLAIR_roi_brain.nii.gz $dir/bianca_output.nii.gz -cm red-yellow -a 60 -dr 0.95 1.01 # pre-emptively thresholded at 0.95

    # echo "Finished checking lesion probability map for subject $(basename "$dir")" # show that lesion probability map has been viewed
    # echo "______"
    # sleep 2
    echo "Lesion probability map produced for subject $(basename "$dir")"
    sleep 2 
    echo "______"
    sleep 2
    
done

sleep 1
echo "A unique lesion probability probability map has been produced for all subjects with a manual lesion mask."
sleep 1
echo "______"
sleep 1

cd "$original_dir"

echo "______"
sleep 5 
echo "BIANCA finished running for all subjects with manually segmented lesions." # show that BIANCA has produced probability maps for the training set
sleep 1
echo "______"
sleep 1
echo "A training file has also been generated." # show that BIANCA has finished and a training file has been produced
sleep 1
echo "______"
sleep 1

## Developing unique masterfiles for each subject (needed to run BIANCA on subjects without a manual lesion mask - i.e., via the training file)
        ### note: this will create masterfiles for subjects with manual lesion masks (these masterfiles are unnecessary though)

echo "Preparing BIANCA for other subjects (w/o lesion mask)."
sleep 1
echo "______"
sleep 1
echo "Creating unique masterfile per subject."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    if [ ! -e "$dir/$wmh" ]; then

        cd "$start_dir"
    
        echo $(basename "$dir")/FLAIR_roi_brain.nii.gz \
            $(basename "$dir")/T1_roi_brain-2-FLAIR_roi_brain.nii.gz \
            $(basename "$dir")/FLAIR_roi_brain-2-MNI_brain.mat \
            $(basename "$dir")/"$wmh" > master_file_$(basename "$dir").txt

        cd "$original_dir"

    fi
done

sleep 1
echo "Separate unique masterfiles created for each subject."
sleep 1
echo "______"
echo "Masterfile production complete."
sleep 1
echo "______"
sleep 1

## Generating lesion probability map for all subjects without manual lesion masks (running BIANCA)
### (note that BIANCA needs to be initially trained with a separate masterfile of subjects with a manual lesion mask)

cd "$start_dir"

echo "Running BIANCA for all subjects in dataset that don't have a manual lesion mask." # show BIANCA is running
sleep 1
echo "______"

for ((i=0; i<${#auto_dir_array[@]}; i++)); do # with just auto_dir the for loop was iterating past the number of directories with no manual lesion mask (it was doing blanks)
    # therefore unlike subjects with a lesion mask the array was used to specify the for loop rather than the variable that identifies directories
    dir="${auto_dir_array[i]}"

    echo "Developing lesion probability map for subject $(basename "$dir")"
    sleep 1
    echo "______"

    bianca --singlefile=master_file_$dir.txt --loadclassifierdata=mytraining --querysubjectnum=1 \
    --brainmaskfeaturenum=1 --featuresubset=1,2 --matfeaturenum=3 \
    -o $dir/bianca_output -v 

    ### Checking lesion probability map

    echo "Check lesion probability map in FSLeyes."
    sleep 1
    echo "______"
    sleep 1

    fsleyes $dir/FLAIR_roi_brain.nii.gz $dir/bianca_output.nii.gz -cm red-yellow -a 60 -dr 0.95 1.01 # check data; pre-emptively thresholded at 0.95, adjust as needed

    echo "Finished checking lesion probability map for subject $(basename "$dir")" # show that lesion probability map has been viewed
    echo "______"
    sleep 1
    echo "Lesion probability map produced for subject $(basename "$dir")"
    sleep 1 
    echo "______"
    sleep 1

done

sleep 1
echo "A unique lesion probability probability map has been produced for all subjects WITHOUT a manual lesion mask."
sleep 1
echo "______"
sleep 1

cd "$original_dir"

sleep 1
echo "BIANCA has finished running for all subjects without a manual lesion mask." # show that BIANCA has finished
sleep 1
echo "______"
sleep 1