#!/bin/bash

# Diffusion Weighted Imaging - Wrapper Script



## Pre-processing


### DICOM to NIFTI conversion

bash dwi_dicom2nifti.sh 

### Artefact correction #1 - topup

bash dwi_topup.sh

sleep 1
echo "______"
sleep 1
echo "Approximately 30% of the diffusion pre-processing is complete."
sleep 1
echo "______"
sleep 1

### Artefact correction #2 - eddy current

bash dwi_eddy.sh 

sleep 1
echo "______"
sleep 1
echo "Approximately 90% of the diffusion pre-processing is complete."
sleep 1
echo "______"
sleep 1

### Creating diffusion tensor model from dataset

bash dwi_dtimodel_corrections.sh

sleep 1
echo "______"
sleep 1
echo "Diffusion pre-processing is complete."
sleep 1
echo "______"
sleep 1



## Data generation


bash dwi_stats.sh

sleep 1
echo "______"
sleep 1
echo "Diffusion pipeline complete. Data is available."