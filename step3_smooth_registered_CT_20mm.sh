#!/bin/bash

#############################################################
# Spatially smooth cortical thickness maps (that are already
# registered to fsaverage)
#
# Arguments: 1) SUBJECST_DIR, 2) N_JOBS (must be even number)
#            3) SUBSTRING (dir name pattern)
# Usage example: bash stepX.sh 
#                /vast/bandlab/studies/ADNI/recons 14 *acc*
#############################################################

SUBJECTS_DIR=$1
N_JOBS=$2
SUBSTRING=$3
CHECKLIST_CT="files_to_check_CT.txt"


# Func1: smooth CT maps that are already registered to fsaverage
smooth(){
    mri_surf2surf   --s fsaverage \
                    --src_type curv \
                    --trg_type curv \
                    --srcsurfval $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage/$1.thickness \
                    --trgsurfval $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage_smoothed20mm/$1.thickness \
                    --fwhm-trg 20 \
                    --hemi $1
}


## MAIN

# generate smoothed CT maps (in parallel)
cnt=0
for subj in `ls $SUBJECTS_DIR -I fsaverage`; do

if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage_smoothed20mm/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_CT

    if [ $all_files_exist == 1 ]; then
        echo "$subj: Cortical thickness maps are already smoothed."
    else
        echo "$subj: Spatially smoothing cortical thickness maps."
        mkdir -p $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage_smoothed20mm
        smooth "lh" &
        smooth "rh" &
        cnt=$((cnt+2))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait

echo "All done!!"
