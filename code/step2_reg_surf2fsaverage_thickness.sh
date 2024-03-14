#!/bin/bash

#############################################################
# Co-register cortical thickness maps of all subjects to fsaverage.
#
# Arguments: 1) SUBJECST_DIR, 2) N_JOBS (must be even number)
#            3) SUBSTRING (dir name pattern)
# Usage example: bash stepX.sh 
#                /vast/bandlab/studies/ADNI/recons 14 *acc*
#############################################################

SUBJECTS_DIR=$1
N_JOBS=$2
SUBSTRING=$3
CHECKLIST_CT="files_to_check_thickness.txt"

# Func1: register CT file to fsaverage
register_CT2fsaverage(){
    mri_surf2surf --srcsubject $subj --srcsurfval thickness --src_type curv \
                  --trg_type curv --trgsubject fsaverage \
                  --trgsurfval $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage/$1.thickness \
                  --hemi $1
}


## MAIN

# generate registered CT files for every subject (in parallel)
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do

if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_CT

    if [ $all_files_exist == 1 ]; then

        echo "$subj: Cortical thickness maps are already registered to fsaverage."
    else
        echo "$subj: Registering cortical thickness maps to fsaverage."
        mkdir -p $SUBJECTS_DIR/$subj/surf/reg_surf2fsaverage
        register_CT2fsaverage "lh" &
        register_CT2fsaverage "rh" &
        cnt=$((cnt+2))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait

echo "All done!!"
