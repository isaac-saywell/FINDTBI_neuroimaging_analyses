#!/bin/bash

# BIANCA Post-processing

## Setup

source config.sh

echo "Beginning BIANCA post-processing steps..."
sleep 1
echo "______"
sleep 1

## Binarising lesion probability maps for all subjects

echo "______"
sleep 1
echo "Applying binarised lesion probability map to all subjects in dataset at threshold "$thr"."
sleep 1
echo "______"
sleep 1
echo "Make sure to check your data and adjust this threshold by evaluating the overlap with manual masks (for subjects that have one)."
sleep 1
echo "______"
sleep 1
echo "This can be done by viewing the lesion map and mask in FSLeyes and by conducting a performance evaluation via command 'bianca_overlap_measures' (see script: wmh_bianca_reliability_test.sh)."

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    # check if the input file exists
    if [ -e "$dir/bianca_output.nii.gz" ]; then
        fslmaths $dir/bianca_output.nii.gz -thr "$thr" -bin $dir/bianca_output_bin.nii.gz
    else
        echo "Input file not found in directory: $(basename "$dir")"
    fi

    # -thr = thresholding what is classified as a lesion from the probability lesion map output
    # -bin = used to binarise the output of the lesion map

done

echo "______"
sleep 1
echo "Binarised lesion maps generated for all subjects."
sleep 1
echo "______"
sleep 1

## Masking 

echo "Creating a mask from structural image to reduce false positive hyperintensities due to FLAIR artefacts."
sleep 1
echo "______"
sleep 1

### Run FAST if there is no PVE for CSF

echo "Tissue partial volume estimations (specifically for CSF) are needed to generate an inclusion mask. FAST will be executed for a subject if there is no CSF estimation."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    if [ ! -e T1_roi_brain_pve_0.nii.gz ]; then

        echo "There are no partial volume estimations for subject $(basename "$dir") structural image. Running FAST now."
        
        sleep 1
        echo "______"
        sleep 1

        fast -O 10 T1_roi_brain # running FAST to generate PVEs

        echo "FAST complete for subject $(basename "$dir")"
        sleep 1
        echo "______"
        sleep 1
    fi

    cd "$original_dir"

done

echo "There are PVE maps for CSF across each subject."
sleep 1
echo "______"
sleep 1

### Calculate the inverse of structural to MNI standard space

echo "Generating field coefficients for structural to standard space."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

        if [ ! -e T1_roi_brain-2-MNI_brain.mat ]; then

            echo "Running FLIRT for subject $(basename "$dir") to generate affine matrix."

            flirt -in T1_roi_brain -ref ${T_brain} -omat T1_roi_brain-2-MNI_brain.mat \
            -out T1_roi_brain-2-MNI_brain # register T1 to MNI (standard) space

            echo "FLIRT complete for subject $(basename "$dir")"

        fi

        echo "Running FNIRT for subject $(basename "$dir")."
        
        sleep 1
        echo "______"
        sleep 1

        fnirt --ref=${std_2mm} --in=T1_roi.nii.gz --aff=T1_roi_brain-2-MNI_brain.mat --cout=T1_warps_in_MNI --config=T1_2_MNI152_2mm # generate field coefficients output from '-cout'
        # note FNIRT requires non-brain extracted inputs (unlike FLIRT), however we still use the affine matrix produced from FLIRT with brain extracted inputs

        # if a Jacobian warning appears it can be ignored (unless your lower value is around -0.5, around 0 is ok, and your range should be tight) - https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;f2771bce.1511

        echo "FNIRT complete for subject $(basename "$dir")"
        sleep 1
        echo "______"
        sleep 1

    cd "$original_dir"

done

echo "All subjects have their structural scans registered to standard MNI space."
sleep 1
echo "______"
sleep 1

echo "Calculating the inverse of structural to MNI space using invwarp."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Performing invwarp for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    invwarp --ref=T1_roi_brain --warp=T1_warps_in_MNI --out=inv_warp_vol

    echo "invwarp complete for subject $(basename "$dir")"
    
    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "invwarp complete for all subjects."
sleep 1
echo "______"
sleep 1

echo "Now an inclusion mask can be created. Ignore numpy warning messages, mask will still be generated."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Creating an inclusion mask for subject $(basename "$dir"), that excludes cortical GM and subcortical GM structures."

    sleep 1
    echo "______"
    sleep 1

    make_bianca_mask T1_roi.nii.gz T1_roi_brain_pve_0.nii.gz inv_warp_vol.nii.gz 0 # note that script adds '_brain' to the structural image automatically, so the non-extracted structural image should be specified

    mv T1_roi_bianca_mask.nii.gz T1_roi_brain_bianca_mask.nii.gz

    echo "Mask created for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

### Transform the mask output from T1 to FLAIR space via registeration

echo "Masked created. Registering them to FLAIR space for use with lesion maps."
sleep 1
echo "______"
sleep 1

find "$start_dir" -maxdepth 1 -mindepth 1 -type d | sort | while read -r dir; do

    cd "$dir"

    echo "Registering structural mask to FLAIR space for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    flirt -dof 6 -in T1_roi_brain_bianca_mask -ref FLAIR_roi_brain -omat T1_roi_brain_bianca_mask2FLAIR.mat -out T1_roi_brain_bianca_mask2FLAIR.nii.gz

    echo "Registeration complete for subject $(basename "$dir")"

    sleep 1
    echo "______"
    sleep 1

    cd "$original_dir"

done

echo "Inclusion masks created for all subjects and registered to FLAIR space."
sleep 1
echo "______"
sleep 1
echo "BIANCA post-processing is complete."