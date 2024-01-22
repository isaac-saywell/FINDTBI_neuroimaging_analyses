#!/bin/bash

# Subcortical Volume Estimation - Wrapper Script



## Pre-processing

### DICOM 2 NIFTI conversion

bash struc_dicom2nifti.sh

bash flair_dicom2nifti.sh

### Neck crop

bash struc_roi_crop.sh

bash flair_roi_crop.sh

### Brain extraction

bash struc_bet_via_flair.sh



## Subcortical volume estimation

bash subcor_volume.sh