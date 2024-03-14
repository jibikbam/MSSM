#!/bin/bash

#############################################################
# Co-register cortical thickness maps of all subjects to fsaverage.
#
# Arguments: 1) SUBJECST_DIR, 2) N_JOBS (must be a multiple of 8)
#            3) SUBSTRING (dir name pattern)
# Usage example: bash step3_reg_surf2fsaverage_GWR.sh 
#                /vast/bandlab/studies/ADNI/recons 112 *acc*
#
# Ref: https://surfer.nmr.mgh.harvard.edu/fswiki/mri_vol2surf
#
# You can check resulting files:
# $ tksurfer bert lh inflated -overlay bert/mri/GWC/subcortwm-1.nii.gz
# (it will look somewhat grainy since there is no smoothing)
#
# TODO: Find ways to set verbosity=0 for mri_vol2surf & mri_vol2vol
#       & mris_calc.
#
#############################################################

SUBJECTS_DIR=$1
N_JOBS=$2
SUBSTRING=$3
CHECKLIST_GWR="files_to_check_GWR.txt"


# Func1: Generate WM intensity surface by projecting along the surface normal
WM_surface_normal_projection(){
    mri_vol2surf --mov $SUBJECTS_DIR/$subj/mri/orig.mgz \
                 --ref $SUBJECTS_DIR/$subj/mri/orig.mgz \
                 --reg $SUBJECTS_DIR/$subj/mri/orig-temp.mgz.reg \
                 --fwhm 0 --surf-fwhm 0 --hemi $1 --projdist -$2 \
                 --o $SUBJECTS_DIR/$subj/mri/GWC/subcortwm$2.$1.nii.gz
}

# Func2: Generate GM intensity surface by projecting along the surface normal
GM_surface_normal_projection(){
    mri_vol2surf --mov $SUBJECTS_DIR/$subj/mri/orig.mgz \
                 --ref $SUBJECTS_DIR/$subj/mri/orig.mgz \
                 --reg $SUBJECTS_DIR/$subj/mri/orig-temp.mgz.reg \
                 --fwhm 0 --surf-fwhm 0 --hemi $1 --projfrac $2 \
                 --o $SUBJECTS_DIR/$subj/mri/GWC/cortgm$2.$1.nii.gz
}

# Func3: Generate GM/WM ratio files
GWR(){
    mris_calc --output $SUBJECTS_DIR/$subj/mri/GWC/$1_subcortwm-1divgm$2.nii.gz \
              $SUBJECTS_DIR/$subj/mri/GWC/cortgm$2.$1.nii.gz div \
              $SUBJECTS_DIR/$subj/mri/GWC/subcortwm1.$1.nii.gz
    mris_calc --output $SUBJECTS_DIR/$subj/mri/GWC/$1_subcortwm-0.5divgm$2.nii.gz \
              $SUBJECTS_DIR/$subj/mri/GWC/cortgm$2.$1.nii.gz div \
              $SUBJECTS_DIR/$subj/mri/GWC/subcortwm.5.$1.nii.gz
}


## MAIN

# Create a sympolic link for fsaverage
if [ ! -f $SUBJECTS_DIR/fsaverage ]; then
    ln -s /autofs/cluster/freesurfer/centos7_x86_64/7.2.0/subjects/fsaverage $SUBJECTS_DIR
fi

# Create identity registration file for every subject (in parallel)
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do  # -I: exception

if [[ $subj == $SUBSTRING ]]; then # optional

    FILE=$SUBJECTS_DIR/$subj/mri/orig-temp.mgz
    DIR=$SUBJECTS_DIR/$subj/mri/GWC

    if [[ -f $FILE && -d $DIR ]]; then
        echo "$subj: Registration file and mri/GWC dir exists."
    else
        echo "$subj: Generating registration file and mri/GWC dir."
        mri_vol2vol --s $subj --mov $SUBJECTS_DIR/$subj/mri/orig.mgz \
                    --targ $SUBJECTS_DIR/$subj/mri/orig.mgz --regheader \
                    --o $SUBJECTS_DIR/$subj/mri/orig-temp.mgz --save-reg &
        mkdir -p $SUBJECTS_DIR/$subj/mri/GWC &
        cnt=$((cnt+2))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait


# Generate WM intensity surfaces for every subject
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do  # -I: exception
    
if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then
        echo "$subj: WM surface maps exist."
    else
        echo "$subj: Generating WM surface maps."
        WM_surface_normal_projection "lh" 1 &  # "&" puts process in background for parallel processing
        WM_surface_normal_projection "rh" 1 &
        WM_surface_normal_projection "lh" .5 &
        WM_surface_normal_projection "rh" .5 &
        cnt=$((cnt+4))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait


# Generate GM intensity surfaces for every subject
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do  # -I: exception
   
if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then 
        echo "$subj: GM surface maps exist."
    else
        echo "$subj: Generating GM surface maps."
        GM_surface_normal_projection "lh" .2 &
        GM_surface_normal_projection "rh" .2 &
        GM_surface_normal_projection "lh" .4 &
        GM_surface_normal_projection "rh" .4 &
        GM_surface_normal_projection "lh" .6 &
        GM_surface_normal_projection "rh" .6 &
        GM_surface_normal_projection "lh" .8 &
        GM_surface_normal_projection "rh" .8 &
        cnt=$((cnt+4))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait


# Generate GWR maps for every subject
cnt=0
for subj in $(ls $SUBJECTS_DIR | grep -v '^fsaverage$'); do  # -I: exception
   
if [[ $subj == $SUBSTRING ]]; then # optional

    all_files_exist=1
    while read file; do
        if [ ! -e $SUBJECTS_DIR/$subj/mri/GWC/$file ]; then
            all_files_exist=$((all_files_exist*0))
        fi
    done < $CHECKLIST_GWR

    if [ $all_files_exist == 1 ]; then 
        echo "$subj: GWR (GM/WM) maps exist."
    else
        echo "$subj: Generating GWR (GM/WM) maps."    
        GWR "lh" .2 &
        GWR "rh" .2 &
        GWR "lh" .4 &
        GWR "rh" .4 &
        GWR "lh" .6 &
        GWR "rh" .6 &
        GWR "lh" .8 &
        GWR "rh" .8 &
        cnt=$((cnt+8))
    fi

    if (($cnt % $N_JOBS == 0)); then wait; fi # run N_JOBS in parallel

fi # optional

done
wait

echo "All done!!"
