#!/bin/bash

#############################################################
# Co-register GWR (GW/WM ratio) maps of all subjects to fsaverage.
#
# Arguments: 1) SUBJECST_DIR, 2) N_JOBS (must be multiple of 14)
#            3) SUBSTRING (dir name pattern)
# Usage example: bash step3_reg_surf2fsaverage_GWR.sh 
#                /vast/bandlab/studies/ADNI/recons 14 *acc*
#
# TODO: Find ways to set verbosity=0 for mri_vol2surf.
#
#############################################################

SUBJECTS_DIR=$1
N_JOBS=$2
SUBSTRING=$3
CHECKLIST_GWR="files_to_check_GWR.txt"


# Func1: register GWR,GM,WM maps to fsaverage (in parallel)
register_GWR2fsaverage(){
    #for file in `( cd $SUBJECTS_DIR/$subj/mri/GWC && ls *$1* )`; do
    for file in `ls $SUBJECTS_DIR/$subj/mri/GWC/*$1* | xargs -n 1 basename`; do
        mri_surf2surf --srcsubject $subj \
                      --srcsurfval $SUBJECTS_DIR/$subj/mri/GWC/$file \
                      --trgsubject fsaverage \
                      --trgsurfval $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage/$file \
                      --hemi $1 &
    done
}


## MAIN

# Generate registered GWR,GM,WM maps for every subject - left hemi
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do

if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then
        echo "$subj: GWR/GM/WM maps are already registered to fsaverage."
    else
        echo "$subj: Registering GWR/GM/WM maps to fsaverage (lh)."
        mkdir -p $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage
        register_GWR2fsaverage "lh"
        cnt=$((cnt+14))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel
    
fi # optional

done
wait


# Generate registered GWR,GM,WM maps for every subject - right hemi
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do

if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/reg_surf2fsaverage/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then
        echo "$subj: GWR/GM/WM maps are already registered to fsaverage."
    else
        echo "$subj: Registering GWR/GM/WM maps to fsaverage (rh)."
        register_GWR2fsaverage "rh"
        cnt=$((cnt+14))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait


echo "All done!!"
