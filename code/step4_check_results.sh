#!/bin/bash

#############################################################
# Check if the MSSM procedure produced all files
#
# Arguments: 1) SUBJECST_DIR, 2) SUBSTRING (dir name pattern)
#            3) FWHM
# Usage example: bash step4_XX.sh 
#                /vast/bandlab/studies/ADNI/recons "*acc*" 5
#############################################################

SUBJECTS_DIR=$1
SUBSTRING=$2
FWHM=$3
CHECKLIST_GWR="files_to_check_GWR.txt"
CHECKLIST_CT="files_to_check_thickness.txt"

if [ "$SUBSTRING" == "*" ]; then
    n_SUBJ=`ls -1 $SUBJECTS_DIR -I fsaverage | tr '\n' '\0' | xargs -0 -n 1 basename | wc -l`
else
    n_SUBJ=`ls -ld $SUBJECTS_DIR/$SUBSTRING | wc -l`
fi

n_GWR=`wc -l < $CHECKLIST_GWR`
n_GWRfiles_expected=$((n_GWR*n_SUBJ))
n_GWRfiles_generated=`ls -l $SUBJECTS_DIR/$SUBSTRING/mri/GWC/reg_surf2fsaverage_smoothed${FWHM}mm/*div*gz | wc -l`
echo "Number of GWR files expected: $n_GWRfiles_expected"
echo "Number of GWR files generated: $n_GWRfiles_generated"

n_CT=`wc -l < $CHECKLIST_CT`
n_CTfiles_expected=$((n_CT*n_SUBJ))
n_CTfiles_generated=`ls -l $SUBJECTS_DIR/$SUBSTRING/surf/reg_surf2fsaverage_smoothed${FWHM}mm/*thickness | wc -l`
echo "Number of CT files expected: $n_CTfiles_expected"
echo "Number of CT files generated: $n_CTfiles_generated"

if [ $n_GWRfiles_expected == $n_GWRfiles_generated ] && \
    [ $n_CTfiles_expected == $n_CTfiles_generated ]; then
    echo "Successfully generated all MSSM feature maps!!"
else
    echo "Something went wrong!! Start debugging."
fi
    
