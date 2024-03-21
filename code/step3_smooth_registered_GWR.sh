#!/bin/bash

#############################################################
# Spatially smooth GWR, GM, WM maps (that are already
# registered to fsaverage)
#
# Arguments: 1) SUBJECST_DIR, 2) N_JOBS (must be multiple of 14)
#            3) SUBSTRING (dir name pattern)
# Usage example: bash stepX.sh 
#                /vast/bandlab/studies/ADNI/recons 14 *acc*
#############################################################


SUBJECTS_DIR=$1
N_JOBS=$2
SUBSTRING=$3
FWHM=$4
CHECKLIST_GWR="files_to_check_GWR.txt"

# Func1: smooth GWR,GM,WM maps that are already registered to fsaverage
smooth(){
    #for file in `( cd $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage && ls *$1* )`; do
    for file in `ls $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage/*$1* | xargs -n 1 basename`; do
        mri_surf2surf   --s fsaverage \
                        --srcsurfval $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage/$file \
                        --trgsurfval $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage_smoothed${FWHM}mm/$file \
                        --fwhm-trg ${FWHM} \
                        --hemi "$1" &
    done
}


## MAIN

## Generate smoothed GWR,GM,WM maps for lh (in parallel)
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do

if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage_smoothed${FWHM}mm/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then
        echo "$subj: GWR/GM/WM maps are already smoothed."
    else
        echo "$subj: Spatially smoothing GWR/GM/WM maps (lh)."
        mkdir -p $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage_smoothed${FWHM}mm
        smooth "lh"
        cnt=$((cnt+14))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait


## Generate smoothed GWR,GM,WM maps for rh (in parallel)
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do

if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage_smoothed${FWHM}mm/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then
        echo "$subj: GWR/GM/WM maps are already smoothed."
    else
        echo "$subj: Spatially smoothing GWR/GM/WM maps (rh)."
        smooth "rh"
        cnt=$((cnt+14))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait

echo "All done!!"
