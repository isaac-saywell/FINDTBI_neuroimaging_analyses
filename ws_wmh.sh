#!/bin/bash

# BIANCA/White Matter Hyperintensities



## Pre-processing

### Check for at least one manual lesion mask (script will not function if one does not exist)

source config.sh # load the 'wmh' variable

if ! find "$start_dir" -type d -exec test -e "{}/$wmh" \; -print | grep -q .; then
    echo "File '$wmh' not found in any subdirectory. Please generate some manual lesion masks. Exiting the script."
    exit 1
fi

### DICOM to NIFTI conversion

bash struc_dicom2nifti.sh

bash flair_dicom2nifti.sh

### Neck crop

bash struc_roi_crop.sh

bash flair_roi_crop.sh

### Brain extraction

bash struc_bet_via_flair.sh

bash flair_brain_extraction.sh

### BIANCA preparation

bash wmh_bianca_prep.sh



## Producing lesion probability maps


### Running BIANCA

bash wmh_run_bianca.sh

### Post-processing

bash wmh_post_proc.sh



## Data generation

bash wmh_stats.sh