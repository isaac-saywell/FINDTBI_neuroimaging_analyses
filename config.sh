#!/bin/bash

# Config file

## Used as a source script for variable paths

########################################################################################################################
#####                                                                                                              #####
##### PLEASE EDIT THE FOLLOWING ENVIRONMENTAL VARIABLES TO MATCH YOUR PC PATHS, DIRECTORIES, AND OTHER INFORMATION #####
#####                                                                                                              #####
########################################################################################################################



## Setting common environmental variables present in every script


### List of subject directories containing brain scans

dirs=`ls -d sample_brain_scans/`

### Name of directory containing subject brain scan directories

start_dir="sample_brain_scans"

### Original/Starting working directory

original_dir=$(pwd)

### Path to 1mm brain extracted standard (MNI152) space image - DO NOT EDIT

T_brain="${FSLDIR}/data/standard/MNI152_T1_1mm_brain"

### Path to 2mm standard (MNI152) space image (not-brain extracted) - DO NOT EDIT

std_2mm="${FSLDIR}/data/standard/MNI152_T1_2mm"



## Setting environmental variables for automatic generation of a FEAT design.fsf file


### Path for where generic (not subject specific) design file should be saved

design_path="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/" # path should finish in location of scripts

### Path to where subject-specific melodic directory should be created

output_dir="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/$start_dir/XXXX/melodic"

    #### Important considerations for specifying this path:
        # '$start_dir' should be used as your brain scan folder
        # 'XXXX' is important to use in place of what would be your subject directory, make sure to only substitute the subject ID with 'XXXX'
        # 'melodic' needs to be the last directory of the path

### Path to standard space (MNI152) brain image (brain extracted)

MNI_input="${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz" # **should not need to change this**

### Path to 4D resting-state functional image

resting_input="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/$start_dir/XXXX/resting"

    #### Important considerations for specifying this path:
        # '$start_dir' should be used as your brain scan folder
        # 'XXXX' is important to use in place of what would be your subject directory, make sure to only substitute the subject ID with 'XXXX'
        # 'resting' needs to be the last name of the path

### Path to T1 structural image

T1_input="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/$start_dir/XXXX/T1_roi_brain"

    #### Important considerations for specifying this path:
        # '$start_dir' should be used as your brain scan folder
        # 'XXXX' is important to use in place of what would be your subject directory, make sure to only substitute the subject ID with 'XXXX'
        # 'T1_roi_brain' needs to be the last name of the path

### Path to fieldmap image (in radians)

FMAP_RADS_input="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/$start_dir/XXXX/FMAP_RADS"

    #### Important considerations for specifying this path:
        # '$start_dir' should be used as your brain scan folder
        # 'XXXX' is important to use in place of what would be your subject directory, make sure to only substitute the subject ID with 'XXXX'
        # 'FMAP_RADS' needs to be the last name of the path

### Path to fieldmap image (magnitude, brain extracted)

FMAP_MAG_brain_input="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/$start_dir/XXXX/FMAP_MAG_brain"

    #### Important considerations for specifying this path:
        # '$start_dir' should be used as your brain scan folder
        # 'XXXX' is important to use in place of what would be your subject directory, make sure to only substitute the subject ID with 'XXXX'
        # 'FMAP_MAG_brain' needs to be the last name of the path

### Echo spacing used by scanner for resting-state fMRI in ms

echo_spacing=0.64 # if using FIND-TBI study scans this should not need to be changed

### Time echo (EPI TE) used by scanner for resting-state fMRI in ms

epi_te=39 # if using FIND-TBI study scans this should not need to be changed



## Setting diffusion-weighted imaging parameters

### Number of bvals to extract the 3D main diffusion-weighted scan image

bval=100 # change this to desired number of bvals to investigate



## Setting resting-state fMRI independent component analysis (ICA) environmental variables

### Number of components desired to generate with groupICA

group_comp=20 
    
    # selecting the dimensionality of groupICA is relatively subjective, this number can range anywhere from 10 to 100 (usually somewhere in the range of 20-40 works well)

### Response time (TR) used by scanner for resting-state fMRI in seconds

tr=0.736 # if using FIND-TBI study scans this should not need to be changed

### Path to visualise subject-specific spatial maps (dual regression stage 1 and 2 results)

script_path="/Users/a1747725/Documents/neuroimaging_projects/fsl/brain_reserve_testing/" # path should finish in location of scripts

### Lower threshold value used to generate binarised spatial maps of components

thr_rs=9.5 # quite subjective, needs to be adjusted according to the data



## Setting white matter hyperintensity (WMH) environmental variables

### Name for file that represents manually generated WMH lesion masks

wmh=wmh.nii.gz # if given name does not work may have to add '.nii.gz' to the end of the label

### Threshold value used to generate binarised lesion (WMH) probability maps

thr=0.9 # generic threshold value is 0.9, this can be altered as needed based on the data

### Cluster size (in voxels) used to produce BIANCA statistics (WMH volume and number of clusters)

clus_size=1

