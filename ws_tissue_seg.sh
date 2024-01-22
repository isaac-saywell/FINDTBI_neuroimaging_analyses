#!/bin/bash

# Main Tissue Segmentation - Wrapper Script



## Pre-processing


### DICOM to NIFTI conversion

bash struc_dicom2nifti.sh

bash flair_dicom2nifti.sh

### Neck crop

bash struc_roi_crop.sh

bash flair_roi_crop.sh

### Brain extraction

bash struc_bet_via_flair.sh


## Partial volume estimation via FAST

bash struc_segmentation.sh



## FSL-VBM or register segmentations to standard space for further analyses where images are in the same space