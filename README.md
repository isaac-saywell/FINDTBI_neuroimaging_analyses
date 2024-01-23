# FIND-TBI Project MRI Automated Statistics via FSL

This folder contains a series of bash and python scripts that have been designed to estimate different brain reserve parameters, but can be used as automated methods to obtain statistics from different MRI scans (structural, diffusion, functional, etc.) using the FMRIB Software Library (FSL).


## Requirements

1. Install latest release of [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation)

These scripts were developed in FSL version 6.0.7.1 on MacOS (Sonoma 14.2.1), however should also work on Linux systems (or subsystem on Windows).

2. Install the latest release of [pyFIX](https://git.fmrib.ox.ac.uk/fsl/pyfix)

pyFIX is a semi-automated classifier tool that attempts to arrange single-subject ICA components as 'signal' or 'noise' so that artefacts can be removed from fMRI data. pyFIX works by extracting fMRI features, generating a training dataset for the classifier (via manual labelling of ICA components), and using the trained dataset to automatically classify ICA components.

Can be difficult to install pyFIX. Recommendations are to use command 'git clone' to save the pyFIX directory to your PC's User and install pyFIX using 'pip install -e pyfix'. From there to check if install worked type 'fix' in the terminal, this should provide options for the fix command. If this does not work then there is a need to troubleshoot the issue, make sure any dependencies are installed.


## Usage

Please read the following sections before using scripts.

### Wrapper scripts

All shell scripts beginning with 'ws' are wrapper scripts that run a series of sub-scripts. These wrapper scripts automatically pre-process data, run FSL commands and generate useable statistics. They require no user intervention and run each sub-script in the correct order to produce necessary files to run the next sub-script.

### Sub-scripts

Sub-scripts can be run in isolation, allowing the user to break up sections of pre-processing and analysis to check data and ensure commmands are working appropriately. This can be especially useful if only some of the pre-processing scripts are needed and the user wants to generate statistical output from processed data not specified in any of the FIND-TBI scripts. However, running sub-scripts by themselves removes some of the autonomy that comes with the wrapper scripts.

### Quick data checking

Most sub-scripts contain commented-out for/while loops that allow the user to quickly check data in FSLeyes if necessary (usually important). These have been commented-out to ensure that each wrapper script can be run from start to finish without user intervention, making them fully automated. If you want to check your data as you go make sure to remove the comments for these loops as necessary.

### Example files

There is a folder named __example_manual_files__ which contains examples of manually produced files (resting-state fMRI component classification and white matter hyperintensity masking). See 'info.txt' in folder __example_manual_files__ for more information.

### Storing of files

__Scripts__ - these should be stored in the same directory as your folder containing all subject directories (e.g., scripts should be in directory 'mri' when path is: /Users/XXXX/mri/subject_brainscans/subject_X)

__Subject brain scans__ - for the loops in these scripts to function subject brain scans should be stored in a subject-specific directory and original DICOM files from MRI scanner should be stored in another directory within each subject-specific directory (e.g., /Users/XXXX/mri/subject_brainscans/subject_X/DICOM_files)

FIND-TBI DICOM files are stored within an extra folder per subject (e.g., /Users/XXXX/mri/subject_brainscans/HEAD_FIND-TBI_*/subject_X/DICOM_files). That 'HEAD_FIND-TBI_*' folder needs to be removed for these scripts to work

### CONFIG file

***IMPORTANT!***

These scripts have been designed to be user friendly, requiring little interaction with the user so they are as automated as possible. The only file that needs to be edited is the 'config.sh' script (other scripts can be edited to enable FSLeyes data checks as well). 

Within this script the user must set common environmental variables used in almost every script, as well as variables unique to measuring specific brain parameters. This also includes desired thresholds for certain FSL commands and MRI scanner parameters. A detailed description of what each variable represents, and should be changed to, is included within the config.sh shell script. 

## Guidelines/Steps to using each brain measure parameter script

The following sections contain information about which scripts are relevant each parameter estimation, requirements for each brain measure, and general tips.

### Basic Tissue Segmentation

__Script Purpose__

Segmentation of the three main gross brain/CNS tissue types (Cerebrospinal fluid, Grey Matter, White Matter), calculation of total brain volume and total intracranial volume.

- *ws_tissue_seg.sh*

__Sub-scripts (in order)__

1. *struc_dicom2nifti.sh* - converts DICOM T1 structural files into NIFTI format so they can be used in FSL

2. *flair_dicom2nifti.sh* - converts DICOM T2 FLAIR files into NIFTI format so they can be used in FSL

3. *struc_roi_crop.sh* - crops the neck out of NIFTI T1 structural images

4. *flair_roi_crop.sh* - crops the neck out of NIFTI T2 FLAIR images

5. *struc_bet_via_flair.sh* - automatically extracts brain tissue from T1 structural images using FLAIR images registered to T1 space (as FLAIR images have higher fat saturation, and therefore greater delineation of what is and what is not actual brain tissue)

6. *bash struc_segmentation.sh* - performs the segmentation of tissue types in the T1 structural image and calculates volumes

__DICOM Files Required__

1. T1_MPRAGE_SAG_P2_0* - T1 Structural Scan

2. T2_FLAIR_SAG_P2_1MM_BIOBANK_0* - T2 FLAIR Scan

__Manual Requirements?__

NO

__Main Considerations for this Script__

- All scripts relevant to basic tissue segmentation start with 'struc', excluding some that start with 'flair' that are required for T1 structural scan brain extraction via FLAIR scan

- Fast is set to iteration main loop 10 times for bias-field correction, this number should be increased if bias-field is deemed particularly bad

__Key Statistical Output File__

struc_tissueseg_data.csv

Data:
```
    CSF - volume
    CSF - number of voxels
    Grey Matter - volume
    Grey Matter - number of voxels
    White Matter - volume
    White Matter - number of voxels
    Total Brain Volume - sum of grey matter and white matter volume
    Total Intracranial Volume - sum of grey matter, white matter, and CSF volume
```

### Subcortical Structure Segmentation

__Script Purpose__

Segmentation of seven different grey matter subcortical structures including: Nuclues Accumbens, Thalamus, Putamen, Caudate, Globus Pallidus, Hippocampus, and Amygdala (both left and right hemisphere for all structures)

- *ws_subcor.sh*

__Sub-scripts (in order)__

1. *struc_dicom2nifti.sh* - converts DICOM T1 structural files into NIFTI format so they can be used in FSL

2. *flair_dicom2nifti.sh* - converts DICOM T2 FLAIR files into NIFTI format so they can be used in FSL

3. *struc_roi_crop.sh* - crops the neck out of NIFTI T1 structural images

4. *flair_roi_crop.sh* - crops the neck out of NIFTI T2 FLAIR images

5. *struc_bet_via_flair.sh* - automatically extracts brain tissue from T1 structural images using FLAIR images registered to T1 space (as FLAIR images have higher fat saturation, and therefore greater delineation of what is and what is not actual brain tissue)

6. *subcor_volume.sh* - runs FIRST (FSL's automated tool for subcortical structure segmentation) to segment structures, generates a web report that allows easy and quick checking of segmentation quality, and outputs the total volume of each of these grey matter subcortical structures

__DICOM Files Required__

1. T1_MPRAGE_SAG_P2_0* - T1 Structural Scan

2. T2_FLAIR_SAG_P2_1MM_BIOBANK_0* - T2 FLAIR Scan

__Manual Requirements?__

NO

__Main Considerations for this Script__

- All scripts relevant to subcortical segmentation start with 'struc', 'flair' or 'subcor'

- Registeration of T1 structural scan to standard space is required to produce an affine registeration matrix. Here FLIRT is used with 6 DOF, if registeration is poor then FNIRT should be used after or FLIRT arguments should be adjusted

- If desired specific subcortical structures can be extracted instead of those listed in the script (currently all possible subcortical segmentations that FIRST can perform are executed, except for brainstem/ventricle), which would speed up segmentation with larger datasets and reduce the length of the data outputted to the CSV file

__Key Statistical Output File__

subcorseg_data.csv

Data:
```
    Left-Thalamus - volume
    Left-Caudate - volume
    Left-Putamen - volume
    Left-Pallidus - volume
    Left-Hippocampus - volume
    Left-Amygdala - volume
    Left-Accumbens - volume
    Right-Thalamus - volume
    Right-Caudate  - volume
    Right-Putamen - volume
    Right-Pallidus - volume
    Right-Hippocampus - volume
    Right-Amygdala - volume
    Right-Accumbens - volume
```

### White Matter Hyperintensity Estimation

__Script Purpose__

Aims to automatically mask white matter hyperintensities (small lesions in white matter) using FSL's BIANCA tool and a training set of manual lesion masks that are generated from a subset of the data being analysed. This pre-processing then allows estimation of the number of voxels containing WMHs, number of clusters of WMHs and the total volume of WMHs per subject

- *ws_wmh.sh*

__Sub-scripts (in order)__

1. *struc_dicom2nifti.sh* - converts DICOM T1 structural files into NIFTI format so they can be used in FSL

2. *flair_dicom2nifti.sh* - converts DICOM T2 FLAIR files into NIFTI format so they can be used in FSL

3. *struc_roi_crop.sh* - crops the neck out of NIFTI T1 structural images

4. *flair_roi_crop.sh* - crops the neck out of NIFTI T2 FLAIR images

5. *struc_bet_via_flair.sh* - automatically extracts brain tissue from T1 structural images using FLAIR images registered to T1 space (as FLAIR images have higher fat saturation, and therefore greater delineation of what is and what is not actual brain tissue)

6. *flair_brain_extraction.sh* - extracts brain tissue from T2 FLAIR images

7. *wmh_bianca_prep.sh* - pre-processing steps to prepare the data for BIANCA

8. *wmh_run_bianca.sh* - BIANCA is run on the subset of subject data that contains manual lesion masks and those without these manual masks. Note that manual lesion masks MUST be created before this sub-script

9. *wmh_post_proc.sh* - post-processing steps to manipulate the data how the user wants it (binarising lesion probability maps at a designated threshold and creating an inclusion mask for brain areas that can have WMHs)

10. *wmh_stats.sh* - outputs statistics to a CSV file using both fslstats (number of WMH voxels, WMH total volume) and a specific BIANCA cluster stats command (total number of WMH clusters and WMH volume within the inclusion mask)

11. (EXTRA SCRIPT) *wmh_bianca_reliability_test.sh* - assesses the performance of BIANCA against manually segmented WMHs

__DICOM Files Required__

1. T1_MPRAGE_SAG_P2_0* - T1 Structural Scan

2. T2_FLAIR_SAG_P2_1MM_BIOBANK_0* - T2 FLAIR Scan

__Manual Requirements?__

YES - researcher needs to manually mask WMHs by viewing subject FLAIR scans and creating these masks in FSLeyes edit mode. A subset of approximately 20% of the dataset should be sufficient to training BIANCA to automatically classify WMHs across the remaining subjects in the dataset

__Main Considerations for this Script__

- All scripts relevant to WMH estimation start with 'struc', 'flair' or 'wmh'

- Note that there are many variables to change for these WMH scripts in the config file. Check these carefully.

- When specifying the name for a WMH manual mask in the config file ensure that the file extension (e.g., '.nii.gz') is included within this environmental variable

- The BIANCA reliability script is not automatically run as part of *ws_wmh.sh*, run *wmh_bianca_reliability_test.sh* separately to test BIANCA performance. Results can be outputted either directly to the terminal or saved to a text file

- BIANCA is run separately for subjects with a manual lesion mask and those without. For subjects WITH a manual lesion mask it uses the training data from other subjects' manual lesion masks to guide automated classification (leaving out the subject being classified). For subjects WITHOUT a manual lesion mask a training classifier is produced from those with manual lesion masks and that classifier guides automated classification of WMHs

- Make sure to check your data and change your threshold accordingly before binarising your lesion probability maps. Optimal threshold varies per dataset

- While generating the inclusion mask for eligible WMH brain areas an error will appear in the terminal, ignore this and allow the script to continue to run. Masks will still be generated. This inclusion mask is generic and produced via a pre-existing FSL command, for more specific masking the user needs to create their own

__Key Statistical Output File__

wmh_data.csv

Data:
```
    wmh_num_vox - number of WMH voxels
    wmh_vol - total WMH volume
    wmh_num_cluster - number of WMH clusters (within inclusion mask)
    wmh_clustervol - total WMH volume (within inclusion mask)
```

### Diffusion Parameter Estimation

__Script Purpose__

Pre-processes diffusion-weighted images, correcting for multiple common artefacts with this imaging type, fitting a diffusion tensor to the data and outputs statistics representing fractional anisotropy (FA), mean diffusivity (MD), axial diffusivity (AD), and radial diffusivity (RD)

- *ws_dwi.sh*

__Sub-scripts (in order)__

1. *dwi_dicom2nifti.sh* - converts main diffusion scan and reverse phase-encode scan from DICOM to NIFTI format so they can be used in FSL

2. *dwi_topup.sh* - extracts DWI image at a pre-specified bvals, generates files to perform topup and then runs topup (correcting for susceptibility-induced distortions)

3. *dwi_eddy.sh* - fits a diffusion tensor to the data to check bvecs, and corrects for eddy current distortions

4. *dwi_dtimodel_corrections.sh* - fits a diffusion tensor model to the data that has been corrected for both susceptibility-induced distortions and eddy currents artefacts, then it uses a pre-existing FSL script to erode brain-edge artefacts from images, and moves these corrected diffusivity brain image maps into subject directories

5. *dwi_stats.sh* - generates statistics for the four main diffusivity parameters (FA, MD, AD, RD) as averages across the whole brain

__DICOM Files Required__

1. CMRR_MB3_DIFF_B0_B1000_B2000_104_DIRECTIONS_00* - main diffusion scan 

2. DIFF_MB3_PA_00* - reverse phase-encode diffusion scan

__Manual Requirements?__

NO

__Main Considerations for this Script__

- All scripts relevant to diffusion-weighted imaging start with 'dwi'

- DWI 3D volumes were extracted for when bvals=100 prior to running topup, this number can be changed in the config file

- The '.json' files produced from the DICOM to NIFTI conversions are very important for this script. They are used to generate a text file (acqparams.txt) that guides topup and eddy current correction

- Note that the topup script (*dwi_topup.sh*) MUST be run prior to eddy current correction via *dwi_eddy.sh* as it produces a text file (acqparams.txt) with critical information for eddy current correction 

- For the *dwi_eddy.sh* script it first fits a diffusion tensor to check if bvecs are correct for that data, this can be checked in FSLeyes. To ensure that the script remains automated the check data for each subject in this loop has been commented out. However, this comment can be taken out (removing the automated nature of the script) to view each subject as the data is processed. Another option is to leave the check until the end, despite the FSLeyes command being commented out the diffusion tensor is still fitted to the data and can be checked as a post-processing step

- For the *dwi_dtimodel_corrections.sh* script there is an option to check the diffusion tensor model fit for all subjects in a webpage report. This has been commented out to keep the script automated, however, the comment can be removed or the model fit can be checked later as a post-processing step

__Key Statistical Output File__

dwi_data.csv

Data:
```
    FA - mean fractional anisotropy across entire brain
    MD - mean diffusivity across entire brain
    AD - mean diffusion parallel to white matter tracts in the entire brain
    RD - mean diffusion perpendicular to white matter tracts in the entire brain
```

### Resting-state functional MRI

__Script Purpose__

Pre-processes resting-state fMRI, uses single-subject independent component analysis (ICA) to classify components as signal or noise, runs group ICA to produce 'good' component spatial maps and time series averaged across the entire dataset, runs dual regression on group ICA output to develop subject-specific spatial maps and time series for each 'good' component from dataset-specific template, and then generates statistics from spatial maps and time series of each signal component as estimates of functional connectivity

- *ws_rsfmri.sh*

__Sub-scripts (in order)__

1. *rsfmri_dicom2nifti.sh* - converts field map scans, T1 structural, 4D resting-state, and FLAIR scans from DICOM to NIFTI format so they can be used in FSL

2. *rsfmri_brain_extraction.sh* - performs brain extraction for T1 structural scan via FLAIR scan (using the script *struc_bet_via_flair.sh*) and for the field map magnitude scan

3. *rsfmri_design_generator.sh* - generates a FEAT (FSL's fMRI analysis tool) design file that guides the input into FEAT, which is used with the 'melodic' option for resting-state fMRI pre-processing/analysis. Then makes unique design files specific to each subject to allow run FEAT with melodic settings (single-subject)

4. *rsfmri_melodic+fmap_rads.sh* - converts field map images into radians for melodic analysis and then runs single-subject ICA via melodic

5. *rsfmri_manual_comp_classification.sh* (NOT PART OF THE WS SCRIPT) - used separately from the wrapper script as an intermediate tool to classify ICA components as signal or noise. Loads FSLeyes in custom or melodic layout per subject, giving the option to classify each component manually 

6. *rsfmri_ICA_noise_removal.sh* - creates a training set text file containing manually labelled noise components for the subset of subjects with a manual classification of components, uses training data to automatically classify ICA components via pyFIX, uses FSL command fsl_regfilt to remove noise components from single-subject ICA data, and then registers cleaned data to standard MNI space

7. *rsfmri_groupica+dualr.sh* - generates a text file containing all clean and registered subject resting-state images, runs melodic on all subjects at once for a set number of components (group ICA), runs dual regression to generate subject-specific spatial maps and time series from group ICA data, and gives the option to view data for each subject in FSLeyes at the end of the script

8. *rsfmri_func_con_stats.sh* - copies subject-specific dual regression output into each unique subject directory and outputs data into a CSV file

__DICOM Files Required__

1. GRE_FIELD_MAPPING_0*(higher integer) - Phase field map scan

2. GRE_FIELD_MAPPING_0*(lower integer) - Magnitude field map scan

3. EP2D_BOLD_MOCO_490_MEAS_SMS_8_0* - 4D resting state scan

4. T1_MPRAGE_SAG_P2_0* - T1 Structural scan

5. T2_FLAIR_SAG_P2_1MM_BIOBANK_0* - T2 FLAIR scan

__Manual Requirements?__

YES - a subset of subjects (approxiamtely 20% of the dataset) need to have their ICA components classified as either signal or noise manually in FSLeyes (melodic layout/view), which is then used as training data to automatically classify components across the remaining subjects via pyFIX

__Main Considerations for this Script__

- All scripts relevant to resting-state fMRI start with 'struc', 'flair' or 'rsfmri'

- Note that there are many variables to change for these resting-state scripts in the config file. Check these carefully.

- Note that classification of different field map files (magnitude and phase) varies for FIND-TBI scans (e.g., different integers in directory names per subject), however, the GRE_FIELD_MAPPING_0* directory that ends with a higher integer is always the phase field map and the lower integer directory contains the magnitude scan. The automated code has been designed to recognise this and names each processed NIFTI image accordingly

- When converting magnitude field maps into NIFTI format there are sometimes two copies produced. The code will just move one copy out of the DICOM folder and use that (which one it uses does not matter)

- When using the script *rsfmri_manual_comp_classification.sh* note that it will try and load FSLeyes in a custom layout that includes both a lightbox (melodic layout) and ortho view (allows easier identification of certain noise components, like the superior sagittal sinus). If there has been no preset custom layout set (see comments in *rsfmri_manual_comp_classification.sh*) then the user must exit FSLeyes (it will load a blank window) and then the script will load the subject's ICA data in the standard melodic view. To just use the standard melodic view edit the *rsfmri_manual_comp_classification.sh* script

- The *rsfmri_ICA_noise_removal.sh* script will exit if there have been no manual classifications of ICA components for at least one subject

- In the *rsfmri_groupica+dualr.sh* there a FSLeyes command to check the output of group ICA has been commented out to ensure the script stays automated. This comment can be removed to check the data before dual regression or be left and the output can be examined as a post-processing step

__Key Statistical Output File__

rsfmri_data.csv

Data:
```
    tseries_comp_x - time series for component 'x' (x number of components generated here is dependent on number of components selected for group ICA)
    spatialvol_comp_x - volume of spatial map clusters at a selected threshold for component 'x' 
        (x number of components generated here is dependent on number of components selected for group ICA)
```

### Data Combination

__Script Purpose__

Combines data from all previously listed CSV files (any CSV file in the directory containing scripts will be included in this merged CSV file)

- *ws_data_combination.sh*

__Sub-scripts (in order)__

1. *csv_file_merge.py* - merges all CSV files with subject-specific data in wide format into one CSV file

__DICOM Files Required__

NONE - CSV files with subject data required

__Manual Requirements?__

YES - user needs to input their desired name for the combined data CSV file at the beginning of executing the script and also at the end of the script the user needs to identify if they want to calculate 'total healthy brain volume' (total brain volume minus WMH volume within inclusion mask)

__Main Considerations for this Script__

- This script automatically combines the data in each CSV file into one, however, requires the most input from the user compared to other scripts (excluding those with manual masking and component classification). However, the script is extremely short and takes less than a minute to execute

- Note this script may produce an extra empty column in your merged CSV file with the header "Unnamed: *". Just ignore and delete this column if it appears, I couldn't figure out how to delete it

__Key Statistical Output File__

*.csv (user inputs the name for their combined CSV file at the beginning of the script)

Data:
```
    All processed brain measure data combined
```

## Potential issues

### Conversion of fieldmaps to radians

In FSL 6.0.7.1 the fsl_prepare_fieldmap terminal command does not exist and only allows launching of the GUI. This GUI is broken as well and does not provide an output. Likely an issue with the most recent release of FSL not having a script for the fsl_prepare_fieldmap command. The fsl_prepare_fieldmap command works with earlier releases (6.0.2.1)

If the fsl_prepare_fieldmap command does not work (either presenting an error or providing no output) then copy the UNIX executable file (included in this directory along with all the scripts) into you FSL directory. More specifically copy it to /Users/your_username/fsl/bin/ (location where FSL commands are stored as executable files). This version of the fsl_prepare_fieldmap is from version 6.0.2.1 of FSL and should allow the command to work and the GUI to provide an output image
